// lib/screens/checkout/checkout_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../pos/pos_page.dart';
import '../../services/customer_service.dart';
import '../../services/transaction_service.dart';
import '../../models/customer_model.dart';

// Fungsi format mata uang
String formatCurrency(double amount, {String locale = 'id_ID', String symbol = 'Rp '}) {
  final format = NumberFormat.currency(locale: locale, symbol: symbol, decimalDigits: 0);
  return format.format(amount);
}

// Enum untuk metode pembayaran
enum PaymentMethod { tunai, kartu, qris }

class CheckoutPage extends StatefulWidget {
  final List<CartItem> cartItems;
  final double totalAmount;

  const CheckoutPage({
    super.key,
    required this.cartItems,
    required this.totalAmount,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  // --- Controllers & Services ---
  PaymentMethod? _selectedPaymentMethod = PaymentMethod.tunai;
  final CustomerService _customerService = CustomerService();
  final TransactionService _transactionService = TransactionService();
  final _customerFormKey = GlobalKey<FormState>();

  final TextEditingController _amountReceivedController = TextEditingController();
  final TextEditingController _referenceNumberController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _customerPhoneController = TextEditingController();
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _customerAddressController = TextEditingController();
  final TextEditingController _customerDobController = TextEditingController();

  // --- State Variables ---
  Customer? _foundCustomer;
  bool _isNewCustomer = false;
  bool _customerFieldsEnabled = false;
  bool _isLoadingCustomer = false;
  bool _isProcessingPayment = false;
  String? _customerSearchMessage;
  double _change = 0.0;
  List<double> _cashSuggestions = [];
  Map<String, dynamic>? _currentTransactionData;

  @override
  void initState() {
    super.initState();
    _amountReceivedController.addListener(_calculateChange);
    _generateCashSuggestions();
  }

  @override
  void dispose() {
    _amountReceivedController.removeListener(_calculateChange);
    [
      _amountReceivedController, _referenceNumberController, _notesController,
      _customerPhoneController, _customerNameController, _customerAddressController,
      _customerDobController
    ].forEach((controller) => controller.dispose());
    super.dispose();
  }

  void _calculateChange() {
    if (_selectedPaymentMethod == PaymentMethod.tunai) {
      double amountReceived = double.tryParse(_amountReceivedController.text.replaceAll('.', '')) ?? 0.0;
      setState(() {
        _change = amountReceived - widget.totalAmount;
      });
    } else {
      setState(() { _change = 0.0; });
    }
  }

  void _generateCashSuggestions() {
    if (_selectedPaymentMethod != PaymentMethod.tunai) {
      setState(() { _cashSuggestions = []; });
      return;
    }
    final Set<double> suggestions = {};
    final double total = widget.totalAmount;
    suggestions.add(total);
    if (total % 10000 != 0) suggestions.add(((total / 10000).ceil() * 10000).toDouble());
    if (total % 50000 != 0) suggestions.add(((total / 50000).ceil() * 50000).toDouble());
    if (total % 5000 != 0) {
      double roundedTo5k = ((total / 5000).ceil() * 5000).toDouble();
      if (roundedTo5k % 10000 != 0) suggestions.add(roundedTo5k);
    }
    List<double> commonDenominations = [50000, 100000, 200000];
    for (var denom in commonDenominations) {
      if (total < denom) suggestions.add(denom);
    }
    if (total > 100000) {
      suggestions.add(((total / 100000).ceil() * 100000).toDouble());
    }
    setState(() {
      _cashSuggestions = suggestions.where((s) => s >= total).toList()..sort();
      if (_cashSuggestions.length > 5) _cashSuggestions = _cashSuggestions.take(5).toList();
    });
  }

  void _onCashSuggestionTapped(double amount) {
    _amountReceivedController.text = NumberFormat('#,###', 'id_ID').format(amount);
  }

  Future<void> _searchOrProceedCustomer() async {
    final phoneNumber = _customerPhoneController.text.trim();
    if (phoneNumber.isEmpty) return;
    setState(() { _isLoadingCustomer = true; _customerSearchMessage = null; _foundCustomer = null; });
    try {
      final Customer? customer = await _customerService.fetchCustomerByPhone(phoneNumber);
      if (customer != null) {
        setState(() {
          _foundCustomer = customer;
          _customerNameController.text = customer.name;
          _customerAddressController.text = customer.address ?? '';
          _customerDobController.text = customer.dateOfBirth != null ? DateFormat('dd-MM-yyyy').format(customer.dateOfBirth!) : '';
          _isNewCustomer = false; _customerFieldsEnabled = true;
          _customerSearchMessage = 'Pelanggan ditemukan.';
        });
      } else {
        setState(() {
          _foundCustomer = null; _isNewCustomer = true; _customerFieldsEnabled = true;
          _customerSearchMessage = 'Pelanggan tidak ditemukan. Silakan isi detail untuk pelanggan baru.';
        });
      }
    } catch (e) {
      setState(() { _customerSearchMessage = 'Error: ${e.toString()}'; });
    } finally {
      setState(() { _isLoadingCustomer = false; });
    }
  }

  Future<void> _selectDateOfBirth(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _foundCustomer?.dateOfBirth ?? DateTime.now().subtract(const Duration(days: 365 * 20)),
      firstDate: DateTime(1920), lastDate: DateTime.now(),
      helpText: 'Pilih Tanggal Lahir',
    );
    if (picked != null) {
      setState(() { _customerDobController.text = DateFormat('dd-MM-yyyy').format(picked); });
    }
  }

  Future<void> _processPayment() async {
    if (_isProcessingPayment) return;
    if (_isNewCustomer && _customerFieldsEnabled) {
      if (!(_customerFormKey.currentState?.validate() ?? false)) return;
    }
    if (_selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Silakan pilih metode pembayaran.')));
      return;
    }
    // ... validasi pembayaran lainnya ...

    setState(() { _isProcessingPayment = true; });

    // Perbaikan Error Tipe Data: Deklarasikan tipe Map secara eksplisit
    final Map<String, dynamic> transactionPayload = {
      "branch_code": "TBB",
      "items": widget.cartItems.map((item) => {
        "product_id": item.product.id, "product_name": item.product.name,
        "quantity": item.quantity, "price_per_item": item.product.price, "subtotal": item.totalPrice,
      }).toList(),
      "total_amount": widget.totalAmount,
      "payment_method": _selectedPaymentMethod.toString().split('.').last,
      "amount_received": _selectedPaymentMethod == PaymentMethod.tunai ? (double.tryParse(_amountReceivedController.text.replaceAll('.', '')) ?? 0.0) : widget.totalAmount,
      "change_amount": _selectedPaymentMethod == PaymentMethod.tunai && _change >= 0 ? _change : 0.0,
      "reference_number": _referenceNumberController.text,
      "notes": _notesController.text,
      "customer_data": (_foundCustomer != null || (_isNewCustomer && _customerNameController.text.isNotEmpty))
          ? {
              "customer_id": _foundCustomer?.id,
              "phone_number": _customerPhoneController.text.trim(),
              "name": _customerNameController.text.trim(),
              "address": _customerAddressController.text.trim(),
              "date_of_birth": _customerDobController.text.trim(),
            }
          : null,
    };

    try {
      final responseData = await _transactionService.saveTransaction(transactionPayload);
      final finalInvoiceNumber = responseData['invoiceNumber'] ?? 'N/A';
      
      _currentTransactionData = {
        ...transactionPayload,
        'invoice_number_final': finalInvoiceNumber,
        'branch_name': "Pulung Kencana",
        'transaction_date_formatted': DateFormat('yyyy-MM-dd').format(DateTime.now()),
        'transaction_time_formatted': DateFormat('HH:mm:ss').format(DateTime.now()),
      };

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Transaksi ${finalInvoiceNumber} berhasil disimpan!')));
        Navigator.pushReplacementNamed(context, '/receipt', arguments: _currentTransactionData);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('ERROR: Gagal menyimpan transaksi. ${e.toString()}')));
      }
    } finally {
      if (mounted) {
        setState(() { _isProcessingPayment = false; });
      }
    }
  }
  
  // Implementasi Lengkap Widget Helper
  Widget _buildCustomerSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Data Pelanggan (Opsional):', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: TextFormField(controller: _customerPhoneController, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Nomor Telepon Pelanggan', hintText: 'Cari atau masukkan nomor baru', prefixIcon: Icon(Icons.phone_outlined)))),
            const SizedBox(width: 8),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoadingCustomer ? null : _searchOrProceedCustomer,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 16)),
                child: _isLoadingCustomer ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.search, size: 24),
              ),
            )
          ],
        ),
        if (_customerSearchMessage != null) Padding(padding: const EdgeInsets.only(top: 8.0, bottom: 8.0), child: Text(_customerSearchMessage!, style: TextStyle(color: _foundCustomer != null ? Colors.green.shade800 : Colors.orange.shade800, fontSize: 13))),
        if (_customerFieldsEnabled || _foundCustomer != null) ...[
          const SizedBox(height: 8),
          TextFormField(controller: _customerNameController, decoration: const InputDecoration(labelText: 'Nama Pelanggan', prefixIcon: Icon(Icons.person_outline)), enabled: _customerFieldsEnabled, validator: (value) {
              if (_isNewCustomer && _customerFieldsEnabled && (value == null || value.isEmpty)) return 'Nama pelanggan tidak boleh kosong.';
              return null;
            }),
          const SizedBox(height: 12),
          TextFormField(controller: _customerAddressController, decoration: const InputDecoration(labelText: 'Alamat', prefixIcon: Icon(Icons.location_on_outlined)), enabled: _customerFieldsEnabled, maxLines: 2),
          const SizedBox(height: 12),
          TextFormField(controller: _customerDobController, decoration: InputDecoration(labelText: 'Tanggal Lahir', hintText: 'Pilih tanggal', prefixIcon: const Icon(Icons.calendar_today_outlined), suffixIcon: IconButton(icon: const Icon(Icons.edit_calendar_outlined), onPressed: _customerFieldsEnabled ? () => _selectDateOfBirth(context) : null)), readOnly: true, onTap: _customerFieldsEnabled ? () => _selectDateOfBirth(context) : null),
        ]
      ],
    );
  }

  Widget _buildCashSuggestionChips() {
    if (_selectedPaymentMethod != PaymentMethod.tunai || _cashSuggestions.isEmpty) return Container();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Wrap(
        spacing: 8.0, runSpacing: 8.0,
        children: _cashSuggestions.map((amount) => ActionChip(
            avatar: const Icon(Icons.account_balance_wallet_outlined, size: 18),
            label: Text(formatCurrency(amount)),
            onPressed: () => _onCashSuggestionTapped(amount),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: Theme.of(context).colorScheme.outline)),
            backgroundColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
            labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
          )).toList(),
      ),
    );
  }

  Widget _buildPaymentMethodSpecificFields() {
    switch (_selectedPaymentMethod) {
      case PaymentMethod.tunai:
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            TextFormField(controller: _amountReceivedController, keyboardType: const TextInputType.numberWithOptions(decimal: false), decoration: const InputDecoration(labelText: 'Jumlah Uang Diterima'), validator: (value) { if (value == null || value.isEmpty) return 'Jumlah uang diterima tidak boleh kosong.'; if (double.tryParse(value.replaceAll('.', '')) == null) return 'Masukkan angka yang valid.'; return null; }),
            _buildCashSuggestionChips(),
            const SizedBox(height: 16),
            Text('Kembalian: ${formatCurrency(_change >= 0 ? _change : 0.0)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ]);
      case PaymentMethod.kartu: return TextFormField(controller: _referenceNumberController, decoration: const InputDecoration(labelText: 'Nomor Referensi Kartu / Approval Code'), validator: (value) { if (value == null || value.isEmpty) return 'Nomor referensi tidak boleh kosong.'; return null; });
      case PaymentMethod.qris: return TextFormField(controller: _referenceNumberController, decoration: const InputDecoration(labelText: 'Nomor Referensi Transaksi QRIS'), validator: (value) { if (value == null || value.isEmpty) return 'Nomor referensi tidak boleh kosong.'; return null; });
      default: return Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Proses Pembayaran')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _customerFormKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Ringkasan Pesanan:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Card(elevation: 1, child: Padding(padding: const EdgeInsets.all(12.0), child: Column(children: [
                    ListView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: widget.cartItems.length, itemBuilder: (context, index) { final item = widget.cartItems[index]; return ListTile(dense: true, title: Text(item.product.name), subtitle: Text('${item.quantity} x ${formatCurrency(item.product.price)}'), trailing: Text(formatCurrency(item.totalPrice), style: const TextStyle(fontWeight: FontWeight.bold))); }),
                    const Divider(),
                    Padding(padding: const EdgeInsets.symmetric(vertical: 8.0), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [ const Text('Total Belanja:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), Text(formatCurrency(widget.totalAmount), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary))]))]))),
              const SizedBox(height: 24),
              _buildCustomerSection(),
              const SizedBox(height: 24),
              const Text('Pilih Metode Pembayaran:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              SegmentedButton<PaymentMethod>(
                segments: const <ButtonSegment<PaymentMethod>>[
                  ButtonSegment<PaymentMethod>(value: PaymentMethod.tunai, label: Text('Tunai'), icon: Icon(Icons.money_outlined)),
                  ButtonSegment<PaymentMethod>(value: PaymentMethod.kartu, label: Text('Kartu'), icon: Icon(Icons.credit_card_outlined)),
                  ButtonSegment<PaymentMethod>(value: PaymentMethod.qris, label: Text('QRIS'), icon: Icon(Icons.qr_code_2_outlined)),
                ],
                selected: <PaymentMethod>{_selectedPaymentMethod ?? PaymentMethod.tunai},
                onSelectionChanged: (Set<PaymentMethod> newSelection) {
                  setState(() {
                    _selectedPaymentMethod = newSelection.first;
                    _referenceNumberController.clear(); _amountReceivedController.clear();
                    _generateCashSuggestions(); _calculateChange();
                  });
                },
                style: SegmentedButton.styleFrom(minimumSize: const Size(double.infinity, 40)), showSelectedIcon: false,
              ),
              const SizedBox(height: 20),
              _buildPaymentMethodSpecificFields(),
              const SizedBox(height: 20),
              TextFormField(controller: _notesController, decoration: const InputDecoration(labelText: 'Catatan Tambahan (Opsional)'), maxLines: 2),
              const SizedBox(height: 32),
              SizedBox(width: double.infinity, child: ElevatedButton.icon(
                  icon: _isProcessingPayment ? Container(width: 24, height: 24, padding: const EdgeInsets.all(2.0), child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 3)) : const Icon(Icons.check_circle_outline),
                  label: Text(_isProcessingPayment ? 'Memproses...' : 'Konfirmasi & Proses Pembayaran'),
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16.0), textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  onPressed: _isProcessingPayment ? null : _processPayment)),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
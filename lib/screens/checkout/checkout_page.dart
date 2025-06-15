import 'package:alfaoptik/services/branch_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../pos/pos_page.dart';
import '../../services/customer_service.dart';
import '../../services/transaction_service.dart';
import '../../models/customer_model.dart';
import '../../models/user_session.dart';

String formatCurrency(double amount, {String locale = 'id_ID', String symbol = 'Rp '}) {
  final format = NumberFormat.currency(locale: locale, symbol: symbol, decimalDigits: 0);
  return format.format(amount);
}

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
  final _formKey = GlobalKey<FormState>();
  final TransactionService _transactionService = TransactionService();
  final CustomerService _customerService = CustomerService();
  final BranchService _branchService = BranchService();
  
  final TextEditingController _amountReceivedController = TextEditingController();
  final TextEditingController _referenceNumberController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _customerPhoneController = TextEditingController();
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _customerAddressController = TextEditingController();
  final TextEditingController _customerDobController = TextEditingController(); // Controller Tanggal Lahir

  PaymentMethod _selectedPaymentMethod = PaymentMethod.tunai;
  bool _isProcessingPayment = false;
  double _change = 0.0;
  
  List<dynamic> _branches = [];
  dynamic _selectedBranch;
  bool _isLoadingBranches = false;

  Customer? _foundCustomer;
  bool _isNewCustomer = false;
  bool _customerFieldsEnabled = false;
  bool _isLoadingCustomer = false;
  String? _customerSearchMessage;
  List<double> _cashSuggestions = [];

  @override
  void initState() {
    super.initState();
    _amountReceivedController.addListener(_calculateChange);
    if (UserSession.role == 'Admin Pusat') {
      _loadBranches();
    }
    _generateCashSuggestions();
  }
  
  @override
  void dispose() {
    _amountReceivedController.removeListener(_calculateChange);
    _amountReceivedController.dispose();
    _referenceNumberController.dispose();
    _notesController.dispose();
    _customerPhoneController.dispose();
    _customerNameController.dispose();
    _customerAddressController.dispose();
    _customerDobController.dispose(); // Jangan lupa dispose
    super.dispose();
  }

  void _calculateChange() { /* ... tidak berubah ... */ }
  void _generateCashSuggestions() { /* ... tidak berubah ... */ }
  Future<void> _loadBranches() async { /* ... tidak berubah ... */ }

  Future<void> _searchOrProceedCustomer() async {
    final phoneNumber = _customerPhoneController.text.trim();
    if (phoneNumber.isEmpty) {
        setState(() {
            _customerFieldsEnabled = false;
            _customerSearchMessage = null;
            _foundCustomer = null;
            _customerNameController.clear();
            _customerAddressController.clear();
            _customerDobController.clear();
        });
        return;
    };
    setState(() { _isLoadingCustomer = true; _customerSearchMessage = null; _foundCustomer = null; });
    try {
      final Customer? customer = await _customerService.fetchCustomerByPhone(phoneNumber);
      if (mounted) {
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
            _customerNameController.clear();
            _customerAddressController.clear();
            _customerDobController.clear();
            _customerSearchMessage = 'Pelanggan tidak ditemukan. Silakan isi detail.';
          });
        }
      }
    } catch (e) {
      if(mounted) setState(() => _customerSearchMessage = 'Error: ${e.toString()}');
    } finally {
      if(mounted) setState(() => _isLoadingCustomer = false);
    }
  }

  Future<void> _selectDateOfBirth(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 20)),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _customerDobController.text = DateFormat('dd-MM-yyyy').format(picked));
    }
  }

  Future<void> _processPayment() async {
    // (Fungsi processPayment tidak berubah, tetapi pastikan customer_data diisi dengan benar)
  }
  
  @override
  Widget build(BuildContext context) {
    bool isAdminPusat = UserSession.role == 'Admin Pusat';
    return Scaffold(
      appBar: AppBar(title: const Text('Proses Pembayaran')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Ringkasan Pesanan:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Card(/* ... Card Ringkasan ... */),
              const SizedBox(height: 24),
              if (isAdminPusat) ...[ /* ... Dropdown Cabang ... */ ],
              const Text('Data Pelanggan (Opsional):', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: TextFormField(controller: _customerPhoneController, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Nomor Telepon Pelanggan', prefixIcon: Icon(Icons.phone_outlined)))),
                  const SizedBox(width: 8),
                  SizedBox(height: 50, child: ElevatedButton(onPressed: _isLoadingCustomer ? null : _searchOrProceedCustomer, child: _isLoadingCustomer ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.search))),
                ],
              ),
              if (_customerSearchMessage != null) Padding(padding: const EdgeInsets.only(top: 8.0), child: Text(_customerSearchMessage!)),
              
              if (_customerFieldsEnabled || _foundCustomer != null) ...[
                const SizedBox(height: 12),
                TextFormField(
                    controller: _customerNameController,
                    decoration: const InputDecoration(labelText: 'Nama Pelanggan', prefixIcon: Icon(Icons.person_outline)),
                    enabled: _customerFieldsEnabled,
                    validator: (v) => (_isNewCustomer && _customerFieldsEnabled && (v == null || v.isEmpty)) ? 'Nama pelanggan baru tidak boleh kosong.' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(controller: _customerAddressController, decoration: const InputDecoration(labelText: 'Alamat (Opsional)', prefixIcon: Icon(Icons.location_on_outlined)), enabled: _customerFieldsEnabled, maxLines: 2),
                const SizedBox(height: 12),
                // --- UI TANGGAL LAHIR DIKEMBALIKAN DI SINI ---
                TextFormField(
                  controller: _customerDobController,
                  decoration: InputDecoration(
                    labelText: 'Tanggal Lahir (Opsional)',
                    prefixIcon: const Icon(Icons.calendar_today_outlined),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.edit_calendar_outlined),
                      onPressed: _customerFieldsEnabled ? () => _selectDateOfBirth(context) : null,
                    ),
                  ),
                  readOnly: true,
                  onTap: _customerFieldsEnabled ? () => _selectDateOfBirth(context) : null,
                ),
              ],
              const SizedBox(height: 24),

              const Text('Pilih Metode Pembayaran:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              // (Sisa UI lainnya...)
            ],
          ),
        ),
      ),
    );
  }
}
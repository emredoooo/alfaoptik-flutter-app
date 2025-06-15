import 'package:alfaoptik/screens/inventory/add_stock_page.dart'; // Import halaman tambah stok
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../models/user_session.dart';
import '../../services/branch_service.dart';
import '../../services/product_service.dart';

String formatCurrency(double amount) => 'Rp ${NumberFormat('#,###', 'id_ID').format(amount)}';

class StockManagementPage extends StatefulWidget {
  const StockManagementPage({super.key});

  @override
  State<StockManagementPage> createState() => _StockManagementPageState();
}

class _StockManagementPageState extends State<StockManagementPage> {
  final ProductService _productService = ProductService();
  final BranchService _branchService = BranchService();
  final TextEditingController _searchController = TextEditingController();

  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  bool _isLoading = true;
  String? _errorMessage;

  List<dynamic> _branches = [];
  dynamic _selectedBranch;
  bool _isLoadingBranches = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterInventory);
    _initializeData();
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterInventory);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    if (UserSession.role == 'Admin Pusat') {
      await _loadBranches();
      if (_branches.isNotEmpty) {
        if (mounted) {
          setState(() {
            _selectedBranch = _branches[0];
          });
          _fetchInventory();
        }
      }
    } else {
      _fetchInventory();
    }
  }

  Future<void> _loadBranches() async {
    setState(() => _isLoadingBranches = true);
    try {
      final branchesData = await _branchService.getBranches();
      if (mounted) setState(() => _branches = branchesData);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Gagal memuat cabang: ${e.toString()}')));
    } finally {
      if (mounted) setState(() => _isLoadingBranches = false);
    }
  }

  Future<void> _fetchInventory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    String? branchCodeToFetch;
    if (UserSession.role == 'Admin Pusat') {
      branchCodeToFetch = _selectedBranch?['branch_code'];
    } else {
      branchCodeToFetch = UserSession.branchCode;
    }

    if (branchCodeToFetch == null) {
      if (mounted) {
        setState(() {
            _isLoading = false;
            _errorMessage = UserSession.role == 'Admin Pusat' ? "Silakan pilih cabang terlebih dahulu." : "Kode Cabang tidak ditemukan untuk akun Anda.";
        });
      }
      return;
    }

    try {
      final products = await _productService.fetchProducts(branchCode: branchCodeToFetch);
      if (mounted) {
        setState(() {
          _allProducts = products;
          _filteredProducts = products;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _filterInventory() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProducts = _allProducts.where((item) {
        final productName = item.name.toLowerCase();
        final productSku = item.product_code?.toLowerCase() ?? '';
        return productName.contains(query) || productSku.contains(query);
      }).toList();
    });
  }

  // --- FUNGSI BARU UNTUK NAVIGASI ---
  void _navigateToAddStock(Product product) async {
    // Tentukan branch_id berdasarkan role
    int? branchId;
    if (UserSession.role == 'Admin Pusat') {
      branchId = _selectedBranch?['branch_id'];
    } else {
      final branches = await _branchService.getBranches();
      final branch = branches.firstWhere((b) => b['branch_code'] == UserSession.branchCode, orElse: () => null);
      branchId = branch?['branch_id'];
    }

    if (branchId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tidak bisa menentukan cabang. Gagal menambah stok.'), backgroundColor: Colors.red));
      return;
    }
    
    final bool? stockWasUpdated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => AddStockPage(
          product: product,
          branchId: branchId!, // Kirim branchId ke halaman AddStockPage
        ),
      ),
    );

    if (stockWasUpdated == true) {
      _fetchInventory();
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isAdminPusat = UserSession.role == 'Admin Pusat';
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Stok'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                if (isAdminPusat)
                  _isLoadingBranches
                      ? const Center(child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator(color: Colors.white)))
                      : DropdownButtonFormField<dynamic>(
                          value: _selectedBranch,
                          isExpanded: true,
                          decoration: InputDecoration(labelText: 'Pilih Cabang', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))),
                          items: _branches.map((branch) => DropdownMenuItem<dynamic>(value: branch, child: Text(branch['branch_name']))).toList(),
                          onChanged: (value) {
                            setState(() => _selectedBranch = value);
                            _fetchInventory();
                          },
                        ),
                if(isAdminPusat) const SizedBox(height: 8),
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Cari berdasarkan nama atau SKU...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text('Error: $_errorMessage'))
              : RefreshIndicator(
                  onRefresh: _fetchInventory,
                  child: _filteredProducts.isEmpty
                      ? const Center(child: Text('Tidak ada produk ditemukan.'))
                      : ListView.builder(
                          itemCount: _filteredProducts.length,
                          itemBuilder: (context, index) {
                            final item = _filteredProducts[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text('SKU: ${item.product_code ?? 'N/A'}'),
                                // --- PERUBAHAN UTAMA DI SINI ---
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text('Stok: ${item.stock}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: item.stock < 10 ? Colors.red.shade700 : Colors.green.shade800)),
                                        const SizedBox(height: 4),
                                        Text(formatCurrency(item.price)),
                                      ],
                                    ),
                                    const SizedBox(width: 16),
                                    IconButton(
                                      icon: const Icon(Icons.add_box_outlined),
                                      color: Theme.of(context).primaryColor,
                                      tooltip: 'Tambah Stok',
                                      onPressed: () => _navigateToAddStock(item),
                                    )
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
    );
  }
}
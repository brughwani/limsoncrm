import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

// Make RowState a ChangeNotifier
class RowState extends ChangeNotifier {
  final String id;
  final String token;
  final TextEditingController nameController;
  final TextEditingController warrantyDateController;
  final TextEditingController purchaseDateController;

  // Private fields for internal state
  String _brand;
  String? _category;
  String? _product;
  String? _employee;
  String _status;

  List<String> _fetchedCategories = [];
  List<String> _fetchedProducts = [];
  bool _isLoadingCategories = false;
  bool _isLoadingProducts = false;

  // Public getters
  String get brand => _brand;
  String get category => _category!;
  String get product => _product!;
  String? get employee => _employee;
  String get status => _status;
  List<String> get fetchedCategories => _fetchedCategories;
  List<String> get fetchedProducts => _fetchedProducts;
  bool get isLoadingCategories => _isLoadingCategories;
  bool get isLoadingProducts => _isLoadingProducts;

  // Keep track of initial values for cascading fetches
  final String initialBrand;
  final String initialCategory;

  RowState({
    required this.id,
    required this.token,
    required String name,
    required String brand,
    required String category,
    required String product,
    required String warrantyDate,
    required String purchaseDate,
    required String employee,
    required String status,
  }) : nameController = TextEditingController(text: name),
        warrantyDateController = TextEditingController(text: warrantyDate),
        purchaseDateController = TextEditingController(text: purchaseDate),
        _brand = brand,
        _category = category,
        _product = product,
        _employee = employee,
        _status = status,
        initialBrand = brand, // Store initial values
        initialCategory = category {
    // --- Initialize dependent data ---
    // Fetch categories if an initial brand exists
    if (_brand.isNotEmpty) {
      fetchCategories(_brand, initialFetch: true);
    }
    // Fetch products if initial brand & category exist
    // (Depends on categories finishing first, handled in fetchCategories)
  }

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token'
  };
  // set category(String newCategory) {
  //   if (fetchedCategories.contains(newCategory)) {
  //     _category = newCategory;
  //     // Reset product
  //     _product = '';
  //     _fetchedProducts = [];
  //     fetchProducts(_brand,_category); // Start product fetch
  //   }
  // }
  //
  // // Product setter
  // set product(String newProduct) {
  //   if (fetchedProducts.contains(newProduct)) {
  //     _product = newProduct;
  //     notifyListeners();
  //   }
  // }

  // --- Update Methods ---
  // These methods update the state AND call notifyListeners()

  void updateBrand(String newBrand, {required Function(String, Map<String, dynamic>) updateNewValuesCallback}) {
    if (_brand == newBrand) return;
    _brand = newBrand;
    // Reset dependent fields
    _category = null;
    _product = null;
    _fetchedCategories = []; // Clear old categories
    _fetchedProducts = []; // Clear old products
    updateNewValuesCallback(id, {'Brand': _brand, 'Category': _category ?? '', 'Product name': _product ?? 'Select Category'});
    notifyListeners(); // Notify brand change immediately
    fetchCategories(newBrand); // Start fetching new categories
  }

  void updateCategory(String newCategory, {required Function(String, Map<String, dynamic>) updateNewValuesCallback}) {
    if (_category == newCategory) return;
    _category = newCategory;
    // Reset dependent field
    _product = 'Select Category';
    _fetchedProducts = []; // Clear old products
    updateNewValuesCallback(id, {'Category': _category, 'Product name': _product});
    notifyListeners(); // Notify category change immediately
    fetchProducts(_brand, newCategory); // Start fetching new products
  }

  void updateProduct(String newProduct, {required Function(String, Map<String, dynamic>) updateNewValuesCallback}) {
    if (_product == newProduct) return;
    _product = newProduct;
    updateNewValuesCallback(id, {'Product name': _product});
    notifyListeners();
  }

  void updateEmployee(String newEmployee, {required Function(String, Map<String, dynamic>) updateNewValuesCallback}) {
    _employee = newEmployee;
    if (_employee != newEmployee) {
      updateNewValuesCallback(id, {'allotted to': newEmployee});
    }
    notifyListeners();
  }

  void updateStatus(String newStatus, {required Function(String, Map<String, dynamic>) updateNewValuesCallback}) {
    const validOptions = ['Open', 'In Progress', 'Resolved'];
    final validatedStatus = validOptions.contains(newStatus) ? newStatus : 'Open';
    if (_status == validatedStatus) return;
    _status = validatedStatus;
    updateNewValuesCallback(id, {'Status': _status});
    notifyListeners();
  }

  void updateName(String newName, {required Function(String, Map<String, dynamic>) updateNewValuesCallback}) {
    // Assuming name is tracked via controller, but if you need direct state update:
    // _name = newName; // if you add a private _name field
    updateNewValuesCallback(id, {'Customer name': newName});
    // notifyListeners(); // Usually not needed if only controller text changes
  }

  void updateWarrantyDate(String newDate, {required Function(String, Map<String, dynamic>) updateNewValuesCallback}) {
    warrantyDateController.text = newDate;
    updateNewValuesCallback(id, {'warranty expiry date': newDate});
    // notifyListeners(); // Usually not needed if only controller text changes
  }

  void updatePurchaseDate(String newDate, {required Function(String, Map<String, dynamic>) updateNewValuesCallback}) {
    purchaseDateController.text = newDate;
    updateNewValuesCallback(id, {'Purchase date': newDate});
    // notifyListeners(); // Usually not needed if only controller text changes
  }

  // --- Fetching Logic ---



  Future<void> fetchCategories(String brand, {bool initialFetch = false}) async {
    if (brand.isEmpty) {
      _fetchedCategories = [];
      _isLoadingCategories = false;
      if (!initialFetch) notifyListeners(); // Notify if not initial setup
      return;
    }
    _isLoadingCategories = true;
    if (!initialFetch) notifyListeners(); // Show loading

    try {
      final response = await http.get(
        Uri.parse('https://limsonvercelapi2.vercel.app/api/fsproductservice?level=categories&brand=$brand'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        _fetchedCategories = List<String>.from(json.decode(response.body));
        // If it's the initial fetch AND we had an initial category, start fetching products
        if (initialFetch && initialCategory.isNotEmpty && _fetchedCategories.contains(initialCategory)) {
          _category = initialCategory; // Ensure category is set if valid
          fetchProducts(brand, initialCategory, initialFetch: true);
        } else if (!initialFetch) {
          // If not initial fetch, maybe select the first category automatically?
          _category = _fetchedCategories.isNotEmpty ? _fetchedCategories.first : '';
          if (_category!.isNotEmpty) {
            fetchProducts(brand, _category!);
          }
        }
      } else {
        _fetchedCategories = ['Error Fetching'];
        _category = ''; // Reset category on error
        _product = '';  // Reset product on error
        _fetchedProducts = [];
      }
    } catch (e) {
      _fetchedCategories = ['Error: $e'];
      _category = '';
      _product = '';
      _fetchedProducts = [];
    } finally {
      _isLoadingCategories = false;
      notifyListeners(); // Update UI with categories/error and loading state
    }
  }

  Future<void> fetchProducts(String brand, String category, {bool initialFetch = false}) async {
    if (brand.isEmpty || category.isEmpty) {
      _fetchedProducts = [];
      _isLoadingProducts = false;
      if (!initialFetch) notifyListeners();
      return;
    }
    _isLoadingProducts = true;
    if (!initialFetch) notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('https://limsonvercelapi2.vercel.app/api/fsproductservice?level=products&brand=$brand&category=$category'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        List<dynamic> decodedList = json.decode(response.body);
        _fetchedProducts = decodedList.map((item) => item['name'].toString()).toList();

        // If initial fetch, check if initial product is valid
        if (initialFetch && _product!.isNotEmpty && !_fetchedProducts.contains(_product)) {
          _product = _fetchedProducts.isNotEmpty ? _fetchedProducts.first : ''; // Default if initial is invalid
        } else if (!initialFetch) {
          _product = _fetchedProducts.isNotEmpty ? _fetchedProducts.first : ''; // Default for subsequent fetches
        }

      } else {
        _fetchedProducts = ['Error Fetching'];
        _product = ''; // Reset product on error
      }
    } catch (e) {
      _fetchedProducts = ['Error: $e'];
      _product = '';
    } finally {
      _isLoadingProducts = false;
      notifyListeners(); // Update UI with products/error and loading state
    }
  }


  @override
  void dispose() {
    // Dispose controllers
    nameController.dispose();
    warrantyDateController.dispose();
    purchaseDateController.dispose();
    super.dispose(); // Important for ChangeNotifier
  }
}
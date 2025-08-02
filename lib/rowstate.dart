import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

// Make RowState a ChangeNotifier
// class RowState extends ChangeNotifier {
//   final String id;
//   final String token;
//   final TextEditingController nameController;
//   final TextEditingController warrantyDateController;
//   final TextEditingController purchaseDateController;
//
//   // Private fields for internal state
//   String _brand;
//   String? _category;
//   String? _product;
//   String? _employee;
//   String _status;
//
//   List<String> _fetchedCategories = [];
//   List<String> _fetchedProducts = [];
//   bool _isLoadingCategories = false;
//   bool _isLoadingProducts = false;
//
//   // Public getters
//   String get brand => _brand;
//   String get category => _category!;
//   String get product => _product!;
//   String? get employee => _employee;
//   String get status => _status;
//   List<String> get fetchedCategories => _fetchedCategories;
//   List<String> get fetchedProducts => _fetchedProducts;
//   bool get isLoadingCategories => _isLoadingCategories;
//   bool get isLoadingProducts => _isLoadingProducts;
//
//   // Keep track of initial values for cascading fetches
//   final String initialBrand;
//   final String initialCategory;
//
//   RowState({
//     required this.id,
//     required this.token,
//     required String name,
//     required String brand,
//     required String category,
//     required String product,
//     required String warrantyDate,
//     required String purchaseDate,
//     required String employee,
//     required String status,
//   }) : nameController = TextEditingController(text: name),
//         warrantyDateController = TextEditingController(text: warrantyDate),
//         purchaseDateController = TextEditingController(text: purchaseDate),
//         _brand = brand,
//         _category = category,
//         _product = product,
//         _employee = employee,
//         _status = status,
//         initialBrand = brand, // Store initial values
//         initialCategory = category {
//     // --- Initialize dependent data ---
//     // Fetch categories if an initial brand exists
//     if (_brand.isNotEmpty) {
//       fetchCategories(_brand, initialFetch: true);
//     }
//     // Fetch products if initial brand & category exist
//     // (Depends on categories finishing first, handled in fetchCategories)
//   }
//
//   Map<String, String> get _headers => {
//     'Content-Type': 'application/json',
//     'Authorization': 'Bearer $token'
//   };
//   // set category(String newCategory) {
//   //   if (fetchedCategories.contains(newCategory)) {
//   //     _category = newCategory;
//   //     // Reset product
//   //     _product = '';
//   //     _fetchedProducts = [];
//   //     fetchProducts(_brand,_category); // Start product fetch
//   //   }
//   // }
//   //
//   // // Product setter
//   // set product(String newProduct) {
//   //   if (fetchedProducts.contains(newProduct)) {
//   //     _product = newProduct;
//   //     notifyListeners();
//   //   }
//   // }
//
//   // --- Update Methods ---
//   // These methods update the state AND call notifyListeners()
//   factory RowState.fromJson(Map<String, dynamic> json, String token, Function(String, Map<String, dynamic>) updateNewValuesCallback) {
//     final fields = json['fields'];
//     return RowState(
//       id: json['id'].toString(),
//       token: token,
//       name: fields['Customer name'] ?? '',
//       brand: fields['Brand'] ?? '',
//       category: fields['Category'] ?? '',
//       product: fields['Product name'] ?? '',
//       warrantyDate: fields['warranty expiry date'] ?? '',
//       purchaseDate: fields['Purchase date'] ?? '',
//       employee: fields['allotted to'] ?? 'Not assigned',
//       status: fields['Status'] ?? 'Open',
//     );
//   }
//   void updateBrand(String newBrand, {required Function(String, Map<String, dynamic>) updateNewValuesCallback}) {
//     if (_brand == newBrand) return;
//     _brand = newBrand;
//     // Reset dependent fields
//     _category = null;
//     _product = null;
//     _fetchedCategories = []; // Clear old categories
//     _fetchedProducts = []; // Clear old products
//     updateNewValuesCallback(id, {'Brand': _brand, 'Category': _category ?? '', 'Product name': _product ?? 'Select Category'});
//     notifyListeners(); // Notify brand change immediately
//     fetchCategories(newBrand); // Start fetching new categories
//   }
//
//   void updateCategory(String newCategory, {required Function(String, Map<String, dynamic>) updateNewValuesCallback}) {
//     if (_category == newCategory) return;
//     _category = newCategory;
//     // Reset dependent field
//     _product = 'Select Category';
//     _fetchedProducts = []; // Clear old products
//     updateNewValuesCallback(id, {'Category': _category, 'Product name': _product});
//     notifyListeners(); // Notify category change immediately
//     fetchProducts(_brand, newCategory); // Start fetching new products
//   }
//
//   void updateProduct(String newProduct, {required Function(String, Map<String, dynamic>) updateNewValuesCallback}) {
//     if (_product == newProduct) return;
//     _product = newProduct;
//     updateNewValuesCallback(id, {'Product name': _product});
//     notifyListeners();
//   }
//
//   void updateEmployee(String newEmployee, {required Function(String, Map<String, dynamic>) updateNewValuesCallback}) {
//
//       if (_employee != newEmployee) {
//         print("RowState $id: Updating employee from '$_employee' to '$newEmployee'");
//
//         // 2. Update the internal state variable *after* the check confirms a change
//         _employee = newEmployee;
//
//         // 3. Call the callback because the value *did* change
//         // Use the correct API field name ('allotted to' in this case)
//         print("RowState $id: Calling updateNewValuesCallback for 'allotted to' with value $newEmployee");
//         updateNewValuesCallback(id, {'allotted to': newEmployee});
//
//         // 4. Notify listeners to update the UI for this specific row/cell
//         notifyListeners();
//         print("RowState $id: Notified listeners after employee update.");
//     }
//     notifyListeners();
//   }
//
//   void updateStatus(String newStatus, {required Function(String, Map<String, dynamic>) updateNewValuesCallback}) {
//     const validOptions = ['Open', 'In Progress', 'Resolved'];
//     final validatedStatus = validOptions.contains(newStatus) ? newStatus : 'Open';
//     if (_status == validatedStatus) return;
//     _status = validatedStatus;
//     updateNewValuesCallback(id, {'Status': _status});
//     notifyListeners();
//   }
//
//   void updateName(String newName, {required Function(String, Map<String, dynamic>) updateNewValuesCallback}) {
//     // Assuming name is tracked via controller, but if you need direct state update:
//     // _name = newName; // if you add a private _name field
//     updateNewValuesCallback(id, {'Customer name': newName});
//     // notifyListeners(); // Usually not needed if only controller text changes
//   }
//
//   void updateWarrantyDate(String newDate, {required Function(String, Map<String, dynamic>) updateNewValuesCallback}) {
//     warrantyDateController.text = newDate;
//     updateNewValuesCallback(id, {'warranty expiry date': newDate});
//     notifyListeners(); // Usually not needed if only controller text changes
//   }
//
//   void updatePurchaseDate(String newDate, {required Function(String, Map<String, dynamic>) updateNewValuesCallback}) {
//     purchaseDateController.text = newDate;
//     updateNewValuesCallback(id, {'Purchase date': newDate});
//     notifyListeners(); // Usually not needed if only controller text changes
//   }
//
//   // --- Fetching Logic ---
//
//
//
//   Future<void> fetchCategories(String brand, {bool initialFetch = false}) async {
//     if (brand.isEmpty) {
//       _fetchedCategories = [];
//       _isLoadingCategories = false;
//       if (!initialFetch) notifyListeners(); // Notify if not initial setup
//       return;
//     }
//     _isLoadingCategories = true;
//     if (!initialFetch) notifyListeners(); // Show loading
//
//     try {
//       final response = await http.get(
//         Uri.parse('https://limsonvercelapi2.vercel.app/api/fsproductservice?level=categories&brand=$brand'),
//         headers: _headers,
//       );
//       if (response.statusCode == 200) {
//         _fetchedCategories = List<String>.from(json.decode(response.body));
//         // If it's the initial fetch AND we had an initial category, start fetching products
//         if (initialFetch && initialCategory.isNotEmpty && _fetchedCategories.contains(initialCategory)) {
//           _category = initialCategory; // Ensure category is set if valid
//           fetchProducts(brand, initialCategory, initialFetch: true);
//         } else if (!initialFetch) {
//           // If not initial fetch, maybe select the first category automatically?
//           _category = _fetchedCategories.isNotEmpty ? _fetchedCategories.first : '';
//           if (_category!.isNotEmpty) {
//             fetchProducts(brand, _category!);
//           }
//         }
//       } else {
//         _fetchedCategories = ['Error Fetching'];
//         _category = ''; // Reset category on error
//         _product = '';  // Reset product on error
//         _fetchedProducts = [];
//       }
//     } catch (e) {
//       _fetchedCategories = ['Error: $e'];
//       _category = '';
//       _product = '';
//       _fetchedProducts = [];
//     } finally {
//       _isLoadingCategories = false;
//       notifyListeners(); // Update UI with categories/error and loading state
//     }
//   }
//
//   Future<void> fetchProducts(String brand, String category, {bool initialFetch = false}) async {
//     if (brand.isEmpty || category.isEmpty) {
//       _fetchedProducts = [];
//       _isLoadingProducts = false;
//       if (!initialFetch) notifyListeners();
//       return;
//     }
//     _isLoadingProducts = true;
//     if (!initialFetch) notifyListeners();
//
//     try {
//       final response = await http.get(
//         Uri.parse('https://limsonvercelapi2.vercel.app/api/fsproductservice?level=products&brand=$brand&category=$category'),
//         headers: _headers,
//       );
//       if (response.statusCode == 200) {
//         List<dynamic> decodedList = json.decode(response.body);
//         _fetchedProducts = decodedList.map((item) => item['name'].toString()).toList();
//
//         // If initial fetch, check if initial product is valid
//         if (initialFetch && _product!.isNotEmpty && !_fetchedProducts.contains(_product)) {
//           _product = _fetchedProducts.isNotEmpty ? _fetchedProducts.first : ''; // Default if initial is invalid
//         } else if (!initialFetch) {
//           _product = _fetchedProducts.isNotEmpty ? _fetchedProducts.first : ''; // Default for subsequent fetches
//         }
//
//       } else {
//         _fetchedProducts = ['Error Fetching'];
//         _product = ''; // Reset product on error
//       }
//     } catch (e) {
//       _fetchedProducts = ['Error: $e'];
//       _product = '';
//     } finally {
//       _isLoadingProducts = false;
//       notifyListeners(); // Update UI with products/error and loading state
//     }
//   }
//
//
//   @override
//   void dispose() {
//     // Dispose controllers
//     nameController.dispose();
//     warrantyDateController.dispose();
//     purchaseDateController.dispose();
//     super.dispose(); // Important for ChangeNotifier
//   }
// }

class RowState extends ChangeNotifier {
  final String id;
  final String token;
  final Function(String, Map<String, dynamic>) updateNewValuesCallback;

  final TextEditingController nameController;
  final TextEditingController warrantyDateController;
  final TextEditingController purchaseDateController;

  // Fields for client-side filtering
  final String complaintDate;
  final String phoneNumber;
  final String village;
  final String dealer;
  final String serviceType;
  final String source;

  // Private fields
  String _brand;
  String _category;
  String _product;
  String _employee;
  String _status;
  // Map<String, String> get _headers => {
  //   'Content-Type': 'application/json',
  //   'Authorization': 'Bearer $token'
  // };
  List<String> _fetchedCategories = ['Select Brand'];
  List<String> _fetchedProducts = ['Select Category'];
  List<String> _fetchedEmployees = ['Select Employee'];
  bool _isLoadingCategories = false;
  bool _isLoadingProducts = false;
  bool _isLoadinglocations= false;
  bool _isLoadingDealers = false;
  List<String> fetchedLocations = ['Select a location'];
  List<String> fetchedDealers = ['Select a dealer'];
  // Getters
  String get brand => _brand;
  String get category => _category;
  String get product => _product;
  String get employee => _employee;
  String get status => _status;
  List<String> get fetchedCategories => _fetchedCategories;
  List<String> get fetchedProducts => _fetchedProducts;
  bool get isLoadingCategories => _isLoadingCategories;
  bool get isLoadingProducts => _isLoadingProducts;
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token'
  };
  RowState({
    required this.id,
    required this.token,
    required this.updateNewValuesCallback,
    required String name,
    required String brand,
    required String category,
    required String product,
    required String warrantyDate,
    required String purchaseDate,
    required String employee,
    required String status,
    required this.complaintDate,
    required this.phoneNumber,
    required this.village,
    required this.dealer,
    required this.serviceType,
    required this.source,
  }) : nameController = TextEditingController(text: name),
        warrantyDateController = TextEditingController(text: warrantyDate),
        purchaseDateController = TextEditingController(text: purchaseDate),
        _brand = brand,
        _category = category,
        _product = product,
        _employee = employee,
        _status = status {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeDropdowns();
    });
  }

  factory RowState.fromJson(Map<String, dynamic> json, String token,
      Function(String, Map<String, dynamic>) updateNewValuesCallback) {
    final fields = json['fields'] as Map<String, dynamic>;

    return RowState(
      id: json['id'].toString(),
      token: token,
      updateNewValuesCallback: updateNewValuesCallback,
      name: fields['Customer name'] as String? ?? '',
      brand: fields['Brand'] as String? ?? '',
      category: fields['Category'] as String? ?? '',
      product: fields['Product name'] as String? ?? '',
      warrantyDate: fields['warranty expiry date'] as String? ?? '',
      purchaseDate: fields['Purchase date'] as String? ?? '',
      employee: fields['allotted to'] as String? ?? 'Not assigned',
      status: fields['Status'] as String? ?? 'Open',
     complaintDate: fields['date of complain'] as String? ?? '',
      phoneNumber: fields['Phone Number'] as String? ?? '',
      village: fields['Village'] as String? ?? '',
      dealer: fields['Dealer name'] as String? ?? '',
      serviceType: fields['Service type'] as String? ?? '',
      source: fields['Source by'] as String? ?? '',
    );
  }

  void _initializeDropdowns() async {
    if (_brand.isNotEmpty && _brand != 'Select a brand') {
      await fetchCategories(_brand, initialLoad: true);
    } else {
      _fetchedCategories = ['Select Brand'];
      _category = 'Select Brand';
      _fetchedProducts = ['Select Category'];
      _product = 'Select Category';
      notifyListeners();
    }
    await fetchLocations();
    await fetchDealers(village);
  }

  // Update methods
  void updateBrand(String newBrand) async {
    if (_brand == newBrand) return;
    _brand = newBrand;
    _category = 'Select Brand';
    _product = 'Select Category';
    _fetchedCategories = ['Loading...'];
    _fetchedProducts = ['Select Category'];
    updateNewValuesCallback(id, {'Brand': _brand, 'productcategory': _category, 'productname': _product});
    notifyListeners();

    await fetchCategories(newBrand);
  }

  void updateCategory(String newCategory) async {
    if (_category == newCategory) return;
    _category = newCategory;
    _product = 'Select Category';
    _fetchedProducts = ['Loading...'];
    updateNewValuesCallback(id, {'productcategory': _category, 'productname': _product});
    notifyListeners();

    await fetchProducts(_brand, newCategory);
  }

  void updateProduct(String newProduct) {
    if (_product == newProduct) return;
    _product = newProduct;
    updateNewValuesCallback(id, {'productname': _product});
    notifyListeners();
  }

  void updateEmployee(String newEmployee) {
    if (_employee == newEmployee) return;
    _employee = newEmployee;
    updateNewValuesCallback(id, {'allotment': _employee});
    notifyListeners();
  }

  void updateStatus(String newStatus) {
    const validOptions = ['Open', 'In Progress', 'Resolved'];
    final validatedStatus = validOptions.contains(newStatus) ? newStatus : 'Open';
    if (_status == validatedStatus) return;
    _status = validatedStatus;
    updateNewValuesCallback(id, {'Status': _status});
    notifyListeners();
  }

  void updateName(String newName) {
    updateNewValuesCallback(id, {'Customer name': newName});
  }

  void updateWarrantyDate(String newDate) {
    warrantyDateController.text = newDate;
    updateNewValuesCallback(id, {'warranty expiry date': newDate});
  }

  void updatePurchaseDate(String newDate) {
    purchaseDateController.text = newDate;
    updateNewValuesCallback(id, {'Purchase date': newDate});
  }
  // Future<void> fetchEmployees() async {
  //   if(_fetchedEmployees.isNotEmpty && _fetchedEmployees[0] != 'Select Employee') return;
  //
  //   final response = await http.get(
  //     Uri.parse('https://limsonvercelapi2.vercel.app/api/fsemployeeservice?getKarigars=true'),
  //     headers: _headers,
  //   );
  //   if (response.statusCode == 200) {
  //     final List<dynamic> empList = json.decode(response.body);
  //   }
  // }
  // Fetching logic

  Future<void> fetchLocations() async {
    final response = await http.get(
      Uri.parse('https://limsonvercelapi2.vercel.app/api/fsdealerservice?getLocations=true'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> rawLocations = json.decode(response.body);
      fetchedLocations = ['Select a location', ...List<String>.from(rawLocations)];
      notifyListeners();
    } else {
      fetchedLocations = ['Error Fetching Locations'];
      notifyListeners();
    }
  }

  Future<void> fetchDealers(String loc) async {
    final response = await http.get(
      Uri.parse('https://limsonvercelapi2.vercel.app/api/fsdealerservice?locality=$loc'),
      headers: _headers,
    );
    if(dealer.isEmpty || dealer == 'Select a dealer') {
      fetchedDealers = ['Select a dealer'];
      notifyListeners();
      return;
    }
    _isLoadingDealers = true;
    if(!_isLoadingDealers) notifyListeners();

    if (response.statusCode == 200) {
      final List<dynamic> rawDealers = json.decode(response.body);
      fetchedDealers = ['Select a dealer', ...List<String>.from(rawDealers.map((item) => item['Dealer name'].toString()))];
      notifyListeners();
    } else {
      fetchedDealers = ['Error Fetching Dealers'];
      notifyListeners();
    }
  }
  Future<void> fetchCategories(String brand, {bool initialLoad = false}) async {
    if (brand.isEmpty || brand == 'Select a brand') return;

    _isLoadingCategories = true;
    if (!initialLoad) notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('https://limsonvercelapi2.vercel.app/api/fsproductservice?level=categories&brand=$brand'),
        headers: _headers,

      );

      if (response.statusCode == 200) {
        final List<dynamic> rawCategories = json.decode(response.body);
        _fetchedCategories = ['Select a category', ...List<String>.from(rawCategories)];

        if (initialLoad && _fetchedCategories.contains(_category)) {
          // Keep existing category
        } else {
          _category = _fetchedCategories.isNotEmpty ? _fetchedCategories.first : 'Select a category';
        }

        await fetchProducts(brand, _category, initialLoad: initialLoad);
      } else {
        _fetchedCategories = ['Error Fetching Categories'];
        _category = 'Error Fetching Categories';
      }
    } catch (e) {
      _fetchedCategories = ['Error: $e'];
      _category = 'Error: $e';
    } finally {
      _isLoadingCategories = false;
      notifyListeners();
    }
  }
  void updateVillage(String newVillage) {
    if (village == newVillage) return;
    updateNewValuesCallback(id, {'Location': newVillage});
    notifyListeners();
  }

  void updateDealer(String newDealer) {
    if (dealer == newDealer) return;
    updateNewValuesCallback(id, {'Dealer': newDealer});
    notifyListeners();
  }

  Future<void> fetchProducts(String brand, String category, {bool initialLoad = false}) async {
    if (brand.isEmpty || category.isEmpty || category == 'Select a category') return;

    _isLoadingProducts = true;
    if (!initialLoad) notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('https://limsonvercelapi2.vercel.app/api/fsproductservice?level=products&brand=$brand&category=$category'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        List<dynamic> decodedList = json.decode(response.body);
        _fetchedProducts = ['Select a product', ...decodedList.map((item) => item['name'].toString()).toList()];

        if (initialLoad && _fetchedProducts.contains(_product)) {
          // Keep existing product
        } else {
          _product = _fetchedProducts.isNotEmpty ? _fetchedProducts.first : 'Select a product';
        }
      } else {
        _fetchedProducts = ['Error Fetching Products'];
        _product = 'Error Fetching Products';
      }
    } catch (e) {
      _fetchedProducts = ['Error: $e'];
      _product = 'Error: $e';
    } finally {
      _isLoadingProducts = false;
      notifyListeners();
    }
  }

  void applyUpdates(Map<String, dynamic> updates) {
    if (updates.containsKey('Customer name')) {
      nameController.text = updates['Customer name'];
    }
    if (updates.containsKey('allotment')) {
      _employee = updates['allotment'];
    }
    if (updates.containsKey('Status')) {
      _status = updates['Status'];
    }
    if (updates.containsKey('Brand')) {
      _brand = updates['Brand'];
    }
    if (updates.containsKey('productcategory')) {
      _category = updates['productcategory'];
    }
    if (updates.containsKey('productname')) {
      _product = updates['productname'];
    }
    if (updates.containsKey('warranty expiry date')) {
      warrantyDateController.text = updates['warranty expiry date'];
    }
    if (updates.containsKey('Purchase date')) {
      purchaseDateController.text = updates['Purchase date'];
    }

    if(updates.containsKey('Location')) {
      fetchedLocations = ['Select a location', updates['Location']];
    }

    if(updates.containsKey('Dealer')) {
      fetchedDealers = ['Select a dealer', updates['Dealer']];
    }

  }



  @override
  void dispose() {
    nameController.dispose();
    warrantyDateController.dispose();
    purchaseDateController.dispose();
    super.dispose();
  }
}
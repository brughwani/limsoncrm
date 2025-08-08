import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';



class RowState extends ChangeNotifier {
  final String id;
  final String token;
  final Function(String, Map<String, dynamic>) updateNewValuesCallback;

  final TextEditingController nameController;
  final TextEditingController addressController;
  final TextEditingController warrantyDateController;
  final TextEditingController purchaseDateController;
  final TextEditingController visitDateController;
  final TextEditingController solveDateController;
  final TextEditingController phoneController;


  // Fields for client-side filtering
  final String complaintDate;
  final String phoneNumber;
  final String village;
  final String dealer;
  final String serviceType;
  final String source;
  final String name;
  final String warrantyDate;
  final String purchaseDate;

  String? visitdate;
  String? solvedate;
  final String address;


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
    required this.name,
    required this.address,

    required String brand,
    required String category,
    required String product,
    required this.warrantyDate,
    required this.purchaseDate,
    required String employee,
    required String status,
    required this.complaintDate,
    required this.phoneNumber,
    required this.visitdate,
    required this.solvedate,
    required this.village,
    required this.dealer,
    required this.serviceType,
    required this.source,
  }) : nameController = TextEditingController(text: name),
  addressController=TextEditingController(text: address),
  phoneController=TextEditingController(text: phoneNumber),
        warrantyDateController = TextEditingController(text: warrantyDate),
        purchaseDateController = TextEditingController(text: purchaseDate),
        visitDateController = TextEditingController(text: visitdate),
        solveDateController = TextEditingController(text: solvedate),
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

    // --- ADD THIS PRINT STATEMENT ---
    print('DEBUG: Raw complaint date from API: ${fields['date of complain']}');

    print('DEBUG: Raw visit date from API: ${fields['Visit date']}');
    print('DEBUG: Raw solve date from API: ${fields['Solve date']}');

    String complaintDateString = '';
    String visitDate = '';
    String solveDate='';
    final rawDate = fields['date of complain'];

    final rawDate1=fields['Visit date'];
    final rawDate2=fields['Solve date'];

    if (rawDate1 is String) {
      // Case 1: The date is already a string (e.g., ISO 8601)
      visitDate = rawDate1;
    } else if (rawDate1 is Map<String, dynamic>) {
      // Case 2: The date is a Firebase Timestamp object
      final seconds = rawDate1['_seconds'] as int;
      final nanoseconds = rawDate1['_nanoseconds'] as int;

      // Create a DateTime object from the timestamp
      final timestamp = DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
      // Format it into a string that the date picker and filter can understand
      visitDate = DateFormat('dd-MM-yyyy').format(timestamp);
    } else {
      // Case 3: Handle any other unexpected format gracefully
      visitDate = '';
    }

    if (rawDate2 is String) {
      // Case 1: The date is already a string (e.g., ISO 8601)
      solveDate = rawDate2;
    } else if (rawDate2 is Map<String, dynamic>) {
      // Case 2: The date is a Firebase Timestamp object
      final seconds = rawDate2['_seconds'] as int;
      final nanoseconds = rawDate2['_nanoseconds'] as int;

      // Create a DateTime object from the timestamp
      final timestamp = DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
      // Format it into a string that the date picker and filter can understand
      solveDate = DateFormat('dd-MM-yyyy').format(timestamp);
    } else {
      // Case 3: Handle any other unexpected format gracefully
      solveDate = '';
    }




    if (rawDate is String) {
      // Case 1: The date is already a string (e.g., ISO 8601)
      complaintDateString = rawDate;
    } else if (rawDate is Map<String, dynamic>) {
      // Case 2: The date is a Firebase Timestamp object
      final seconds = rawDate['_seconds'] as int;
      final nanoseconds = rawDate['_nanoseconds'] as int;

      // Create a DateTime object from the timestamp
      final timestamp = DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
      // Format it into a string that the date picker and filter can understand

      complaintDateString = DateFormat('dd-MM-yyyy').format(timestamp);

      complaintDateString = DateFormat('yyyy-MM-dd').format(timestamp);

    } else {
      // Case 3: Handle any other unexpected format gracefully
      complaintDateString = '';
    }


    return RowState(
      id: json['id'].toString(),
      token: token,
      updateNewValuesCallback: updateNewValuesCallback,
      name: fields['Customer name'] as String? ?? '',
      address: fields['address'],
      brand: fields['Brand'] as String? ?? '',
      category: fields['Category'] as String? ?? '',
      product: fields['Product name'] as String? ?? '',
      warrantyDate: fields['warranty expiry date'] as String? ?? '',
      purchaseDate: fields['Purchase date'] as String? ?? '',
      employee: fields['allotted to'] as String? ?? 'Not assigned',
      status: fields['Status'] as String? ?? 'Open',
     complaintDate: complaintDateString,

      visitdate: visitDate,
      solvedate: solveDate,

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
    updateNewValuesCallback(id, {'allotted to': _employee});
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
  void updatephone(String newphone) {
    updateNewValuesCallback(id, {'Phone Number': newphone});
  }
  void updateaddress(String newaddress) {
    updateNewValuesCallback(id, {'address': newaddress});
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
    if(updates.containsKey('Phone Number'))
      {
        phoneController.text=updates['Phone Number'];
      }
    if (updates.containsKey('allotted to')) {
      _employee = updates['allotted to'];
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
    phoneController.dispose();
    purchaseDateController.dispose();
    visitDateController.dispose(); // NEW
    solveDateController.dispose(); // NEW
    super.dispose();
  }
}
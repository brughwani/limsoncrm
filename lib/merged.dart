import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/foundation.dart';
import 'addemployee.dart';

// Assuming these files exist in your project
import 'package:lmrepaircrmadmin/addemployee.dart'; // AddEmployee widget
import 'complaintdatanotifier.dart'; // ComplaintDataNotifier class
import 'rowstate.dart'; // RowState class
import 'cellwidget.dart'; // CellWidget class

// --- ComplaintDataNotifier (Updated to include fetchComplaints) ---
// This class should be in 'complaintdatanotifier.dart'
// class ComplaintDataNotifier extends ChangeNotifier {
//   final String _token;
//   List<RowState> _orderedRows = [];
//   bool _isLoading = false;
//   bool _isSaving = false;
//   Map<String, Map<String, dynamic>> _newValues = {}; // {recordId: {field: newValue}}
//   List<String> _employees = ['Not assigned']; // Initial state, will be fetched
//   List<String> _brands = ['Loading...']; // Initial state, will be fetched
//
//   ComplaintDataNotifier({required String token}) : _token = token {
//     _fetchInitialData(); // Fetch employees and brands on initialization
//   }
//
//   List<RowState> get orderedRows => _orderedRows;
//   bool get isLoading => _isLoading;
//   bool get isSaving => _isSaving;
//   Map<String, Map<String, dynamic>> get newValues => _newValues;
//   List<String> get employees => _employees;
//   List<String> get brands => _brands;
//
//   Future<void> _fetchInitialData() async {
//     await fetchEmployees();
//     await fetchBrands();
//     // Optionally fetch initial complaints here or wait for explicit search
//     // await fetchComplaints();
//   }
//
//   Future<void> fetchEmployees() async {
//     try {
//       final response = await http.get(
//         Uri.parse('https://limsonvercelapi2.vercel.app/api/fsemployeeservice?getKarigars=true'),
//         headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $_token'},
//       );
//       if (response.statusCode == 200) {
//         final List<dynamic> empList = json.decode(response.body);
//         _employees = ['Not assigned', ...empList.map((emp) => emp['First name'].toString())];
//         notifyListeners();
//       } else {
//         print('Failed to load employees: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Error fetching employees: $e');
//     }
//   }
//
//   Future<void> fetchBrands() async {
//     try {
//       final response = await http.get(
//         Uri.parse('https://limsonvercelapi2.vercel.app/api/fsproductservice?level=brands'),
//         headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $_token'},
//       );
//       if (response.statusCode == 200) {
//         final List<dynamic> brandList = json.decode(response.body);
//         _brands = ['Select a brand', ...brandList.map((brand) => brand.toString())];
//         notifyListeners();
//       } else {
//         print('Failed to load brands: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Error fetching brands: $e');
//     }
//   }
//
//   // New method to fetch complaints based on filters
//   Future<void> fetchComplaints({
//     String? fromdate,
//     String? todate,
//     String? name,
//     String? phone,
//     String? village,
//     String? dealer,
//     String? brandName, // Added brand filter
//     String? category,
//     String? product,
//     String? allottedTo, // Renamed from allotedto for clarity
//     String? servicetype,
//     String? source,
//   }) async {
//     _isLoading = true;
//     _orderedRows = []; // Clear previous results
//     _newValues = {}; // Clear any unsaved changes from previous results
//     notifyListeners();
//
//     try {
//       var query = {
//         if (fromdate != null && fromdate.isNotEmpty) "fromdate": fromdate,
//         if (todate != null && todate.isNotEmpty) "todate": todate,
//         if (name != null && name.isNotEmpty) "Customer name": name,
//         if (phone != null && phone.isNotEmpty) "Phone Number": phone,
//         if (village != null && village.isNotEmpty) "Location": village,
//         if (dealer != null && dealer.isNotEmpty) "Dealer": dealer,
//         if (brandName != null && brandName.isNotEmpty && brandName != 'Select a brand') "Brand": brandName,
//         if (category != null && category.isNotEmpty && category != 'Select a category') "productcategory": category,
//         if (product != null && product.isNotEmpty && product != 'Select a product') "productname": product,
//         if (allottedTo != null && allottedTo.isNotEmpty && allottedTo != 'Select an employee' && allottedTo != 'Not assigned') "allotment": allottedTo,
//         if (allottedTo == 'Not assigned') "allotment": "", // Specific handling for "Not assigned"
//         if (servicetype != null && servicetype.isNotEmpty) "Service type": servicetype,
//         if (source != null && source.isNotEmpty) "Source by": source,
//       };
//
//       final urlq = Uri.https("limsonvercelapi2.vercel.app", "/api/fscomplaintfiltering", query);
//       print('Fetching complaints from: $urlq');
//
//       final response = await http.get(urlq, headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $_token'});
//
//       if (response.statusCode == 200) {
//         final List<dynamic> jsonList = json.decode(response.body);
//         _orderedRows = jsonList.map((json) => RowState.fromJson(json, _token, updateNewValues)).toList();
//         print('Fetched ${_orderedRows.length} complaints.');
//       } else {
//         print('Failed to load complaints: ${response.statusCode} - ${response.body}');
//         _orderedRows = [];
//       }
//     } catch (e) {
//       print('Error fetching complaints: $e');
//       _orderedRows = [];
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }
//
//   void updateNewValues(String recordId, Map<String, dynamic> newFields) {
//     _newValues.putIfAbsent(recordId, () => {});
//     _newValues[recordId]!.addAll(newFields);
//     notifyListeners(); // Notify listeners so the save button can enable/disable
//   }
//
//   Future<void> saveAll() async {
//     if (_newValues.isEmpty) return;
//
//     _isSaving = true;
//     notifyListeners();
//
//     try {
//       final List<Map<String, dynamic>> updates = [];
//       _newValues.forEach((recordId, fields) {
//         updates.add({"id": recordId, "updates": fields});
//       });
//
//       final response = await http.patch(
//         Uri.parse('https://limsonvercelapi2.vercel.app/api/fscomplaintupdateall'),
//         headers: {
//           'Content-Type': 'application/json',
//           'Authorization': 'Bearer $_token',
//         },
//         body: json.encode(updates),
//       );
//
//       if (response.statusCode == 200) {
//         print('Successfully saved all updates.');
//         _newValues.clear(); // Clear changes after successful save
//         // Re-fetch or update UI to reflect saved changes
//         // For simplicity, let's re-fetch the current view after saving
//         // This would require passing the current filters to re-fetchComplaints.
//         // For now, just clear newValues.
//       } else {
//         print('Failed to save updates: ${response.statusCode} - ${response.body}');
//         // Optionally, handle specific errors or partially successful saves
//       }
//     } catch (e) {
//       print('Error saving updates: $e');
//     } finally {
//       _isSaving = false;
//       notifyListeners();
//     }
//   }
//
// // --- Methods from RowState to call back to notifier ---
// // These should be called by individual RowState instances to update _newValues
// // Example usage in RowState: `updateNewValuesCallback(id, {'field': newValue});`
// }
//
// // --- CRMDashboard Widget ---
class CRMDashboard extends StatefulWidget {
  final String token;

  CRMDashboard({required this.token});

  @override
  State<CRMDashboard> createState() => _CRMDashboardState();
}

// class _CRMDashboardState extends State<CRMDashboard> with SingleTickerProviderStateMixin {
//   String? selectedStatus;
//   String? selectedDealer;
//   String? selectedCity;
//   String? selectedEmployee;
//   String? selectedCategory;
//   String? selectedProduct;
//   String? brandselected;
//   String? requesttype;
//   String? source; // Assuming source is also a filter
//   var requesttypes = ['Installation', 'Demo', 'Service', 'Complain'];
//
//   // Lists for dropdowns (initially populated with placeholders)
//   List<String> employees = ['Select an employee'];
//   List<String> products = ['Select a product'];
//   List<String> locations = ['Select a location'];
//   List<String> dealerNames = ['Select a dealer'];
//   List<String> categories = ['Select a category'];
//   List<String> brands = ['Select a brand'];
//
//   final TextEditingController fromDateController = TextEditingController();
//   final TextEditingController toDateController = TextEditingController();
//   final TextEditingController nameController = TextEditingController();
//   final TextEditingController mobileController = TextEditingController();
//
//   TabController? _tabController;
//
//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 3, vsync: this);
//     // Initial fetch of master data will be handled by ComplaintDataNotifier itself
//     // when it's created, but we also need to update the dropdown lists in the UI.
//   }
//
//   // This method will be called by CRMDashboard to update its internal lists
//   // based on data from ComplaintDataNotifier.
//   void _updateDropdownLists(ComplaintDataNotifier notifier) {
//     // Only update if the notifier's lists are different or more populated
//     if (notifier.employees.length > employees.length || !employees.contains(notifier.employees.first) ) {
//       setState(() {
//         employees = notifier.employees;
//         if (!employees.contains(selectedEmployee)) {
//           selectedEmployee = employees.isNotEmpty ? employees.first : null;
//         }
//       });
//     }
//     if (notifier.brands.length > brands.length || !brands.contains(notifier.brands.first)) {
//       setState(() {
//         brands = notifier.brands;
//         if (!brands.contains(brandselected)) {
//           brandselected = brands.isNotEmpty ? brands.first : null;
//         }
//       });
//     }
//   }
//
//
//   Future<void> fetchCategoriesForUI(String Brand) async {
//     // This is for UI dropdowns, not directly setting ComplaintDataNotifier's state
//     categories.clear();
//     categories.add('Select a category');
//     selectedCategory = categories[0];
//     products.clear();
//     products.add('Select a product');
//     selectedProduct = products[0];
//     setState(() {}); // Update UI
//
//     final response = await http.get(
//       Uri.parse('https://limsonvercelapi2.vercel.app/api/fsproductservice?level=categories&brand=$Brand'),
//       headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer ${widget.token}'},
//     );
//     if (response.statusCode == 200) {
//       final List<dynamic> categoryList = jsonDecode(response.body);
//       setState(() {
//         categories.addAll(categoryList.map((category) => category.toString()));
//       });
//     }
//   }
//
//   Future<void> fetchProductsForCategoryForUI(String Brand, String categoryId) async {
//     // This is for UI dropdowns, not directly setting ComplaintDataNotifier's state
//     products.clear();
//     products.add('Select a product');
//     selectedProduct = products[0];
//     setState(() {}); // Update UI
//
//     final response = await http.get(
//       Uri.parse('https://limsonvercelapi2.vercel.app/api/fsproductservice?level=products&brand=$Brand&category=$categoryId'),
//       headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer ${widget.token}'},
//     );
//     if (response.statusCode == 200) {
//       final List<dynamic> productList = json.decode(response.body);
//       setState(() {
//         products.addAll(productList.map((e) => e['name'].toString()));
//       });
//     }
//   }
//
//   Future<void> fetchLocationForUI() async {
//     // This is for UI dropdowns
//     final response = await http.get(
//       Uri.parse('https://limsonvercelapi2.vercel.app/api/fsdealerservice?getLocations=true'),
//       headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer ${widget.token}'},
//     );
//     if (response.statusCode == 200) {
//       final List<dynamic> locationList = json.decode(response.body);
//       setState(() {
//         locations.clear();
//         locations.add('Select a location');
//         locations.addAll(locationList.map((location) => location.toString()));
//         locations.sort((a, b) => a.compareTo(b));
//         selectedCity = locations[0];
//       });
//     }
//   }
//
//   Future<void> fetchDealerForUI(String loc) async {
//     // This is for UI dropdowns
//     dealerNames.clear();
//     dealerNames.add('Select a dealer');
//     selectedDealer = dealerNames[0];
//     setState(() {}); // Update UI
//
//     final response = await http.get(
//       Uri.parse("https://limsonvercelapi2.vercel.app/api/fsdealerservice?locality=$loc"),
//       headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer ${widget.token}'},
//     );
//     if (response.statusCode == 200) {
//       final List<dynamic> dealers = json.decode(response.body);
//       setState(() {
//         dealerNames.addAll(dealers.map((dealer) => dealer['Dealer name'].toString()));
//       });
//     }
//   }
//
//   Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2100),
//       initialDate: DateTime.tryParse(controller.text) ?? DateTime.now(),
//     );
//     if (picked != null) {
//       setState(() {
//         controller.text = DateFormat('yyyy-MM-dd').format(picked);
//       });
//     }
//   }
//
//   @override
//   void dispose() {
//     _tabController?.dispose();
//     fromDateController.dispose();
//     toDateController.dispose();
//     nameController.dispose();
//     mobileController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return ChangeNotifierProvider(
//       create: (_) => ComplaintDataNotifier(token: widget.token),
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text('CRM Dashboard'),
//           actions: [
//             // Save button for filtered records
//             Consumer<ComplaintDataNotifier>(
//               builder: (context, notifier, child) {
//                 return IconButton(
//                   icon: notifier.isSaving
//                       ? const SizedBox(
//                       width: 20, height: 20,
//                       child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
//                       : const Icon(Icons.save),
//                   onPressed: notifier.isSaving || notifier.newValues.isEmpty
//                       ? null
//                       : () => notifier.saveAll(),
//                 );
//               },
//             )
//           ],
//           bottom: TabBar(
//             controller: _tabController,
//             tabs: const [
//               Tab(text: 'Complaints'), // Changed from 'Search Complaints'
//               Tab(text: 'Add Employee'),
//               Tab(text: 'Other Allotments'), // Placeholder for future uses
//             ],
//           ),
//         ),
//         body: Consumer<ComplaintDataNotifier>(
//           builder: (context, notifier, child) {
//             // Update dropdown lists in the UI once notifier has fetched them
//             WidgetsBinding.instance.addPostFrameCallback((_) {
//               _updateDropdownLists(notifier);
//               if (locations.length <= 1) { // Fetch locations only once or if empty
//                 fetchLocationForUI();
//               }
//             });
//
//             return TabBarView(
//               controller: _tabController,
//               children: [
//                 // Complaints (Search and Allotment) Tab
//                 SingleChildScrollView(
//                   child: Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text('Search Filters:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                         const SizedBox(height: 16),
//                         Row(
//                           children: [
//                             Expanded(
//                               child: TextField(
//                                 controller: fromDateController,
//                                 readOnly: true,
//                                 decoration: InputDecoration(
//                                   labelText: 'From Date',
//                                   suffixIcon: IconButton(
//                                     icon: const Icon(Icons.calendar_today),
//                                     onPressed: () => _selectDate(context, fromDateController),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                             const SizedBox(width: 16),
//                             Expanded(
//                               child: TextField(
//                                 controller: toDateController,
//                                 readOnly: true,
//                                 decoration: InputDecoration(
//                                   labelText: 'To Date',
//                                   suffixIcon: IconButton(
//                                     icon: const Icon(Icons.calendar_today),
//                                     onPressed: () => _selectDate(context, toDateController),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ),
//                         const SizedBox(height: 16),
//                         TextField(
//                           controller: nameController,
//                           decoration: const InputDecoration(labelText: 'Customer Name'),
//                         ),
//                         const SizedBox(height: 16),
//                         TextField(
//                           controller: mobileController,
//                           keyboardType: TextInputType.phone,
//                           maxLength: 10,
//                           decoration: const InputDecoration(labelText: 'Mobile Number'),
//                         ),
//                         const SizedBox(height: 16),
//                         DropdownButtonHideUnderline(
//                           child: DropdownButton2<String>(
//                             isExpanded: true,
//                             hint: Text(
//                               selectedCity ?? 'Select a location',
//                               style: TextStyle(
//                                 fontSize: 14,
//                                 color: Theme.of(context).hintColor,
//                               ),
//                             ),
//                             items: locations
//                                 .map((item) => DropdownMenuItem(
//                               value: item,
//                               child: Text(
//                                 item,
//                                 style: const TextStyle(
//                                   fontSize: 14,
//                                 ),
//                               ),
//                             ))
//                                 .toList(),
//                             value: selectedCity,
//                             onChanged: (value) {
//                               setState(() {
//                                 selectedCity = value;
//                                 selectedDealer = null; // Reset dealer when city changes
//                                 dealerNames = ['Select a dealer']; // Reset dealer list
//                                 if (value != null && value != 'Select a location') {
//                                   fetchDealerForUI(value);
//                                 }
//                               });
//                             },
//                             buttonStyleData: const ButtonStyleData(
//                               padding: EdgeInsets.symmetric(horizontal: 16),
//                               height: 40,
//                               width: double.infinity,
//                             ),
//                             menuItemStyleData: const MenuItemStyleData(
//                               height: 40,
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 16),
//                         DropdownButtonHideUnderline(
//                           child: DropdownButton2<String>(
//                             isExpanded: true,
//                             hint: Text(
//                               selectedDealer ?? 'Select a dealer',
//                               style: TextStyle(
//                                 fontSize: 14,
//                                 color: Theme.of(context).hintColor,
//                               ),
//                             ),
//                             items: dealerNames
//                                 .map((item) => DropdownMenuItem(
//                               value: item,
//                               child: Text(
//                                 item,
//                                 style: const TextStyle(
//                                   fontSize: 14,
//                                 ),
//                               ),
//                             ))
//                                 .toList(),
//                             value: selectedDealer,
//                             onChanged: (value) {
//                               setState(() {
//                                 selectedDealer = value;
//                               });
//                             },
//                             buttonStyleData: const ButtonStyleData(
//                               padding: EdgeInsets.symmetric(horizontal: 16),
//                               height: 40,
//                               width: double.infinity,
//                             ),
//                             menuItemStyleData: const MenuItemStyleData(
//                               height: 40,
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 16),
//                         DropdownButtonHideUnderline(
//                           child: DropdownButton2<String>(
//                             isExpanded: true,
//                             hint: Text(
//                               brandselected ?? 'Select a brand',
//                               style: TextStyle(
//                                 fontSize: 14,
//                                 color: Theme.of(context).hintColor,
//                               ),
//                             ),
//                             items: brands
//                                 .map((item) => DropdownMenuItem(
//                               value: item,
//                               child: Text(
//                                 item,
//                                 style: const TextStyle(
//                                   fontSize: 14,
//                                 ),
//                               ),
//                             ))
//                                 .toList(),
//                             value: brandselected,
//                             onChanged: (value) {
//                               setState(() {
//                                 brandselected = value;
//                                 selectedCategory = null;
//                                 categories.clear();
//                                 categories.add('Select a category');
//                                 selectedProduct = null;
//                                 products.clear();
//                                 products.add('Select a product');
//                                 if (value != null && value != 'Select a brand') {
//                                   fetchCategoriesForUI(value);
//                                 }
//                               });
//                             },
//                             buttonStyleData: const ButtonStyleData(
//                               padding: EdgeInsets.symmetric(horizontal: 16),
//                               height: 40,
//                               width: double.infinity,
//                             ),
//                             menuItemStyleData: const MenuItemStyleData(
//                               height: 40,
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 16),
//                         DropdownButtonHideUnderline(
//                           child: DropdownButton2<String>(
//                             isExpanded: true,
//                             hint: Text(
//                               selectedCategory ?? 'Select a category',
//                               style: TextStyle(
//                                 fontSize: 14,
//                                 color: Theme.of(context).hintColor,
//                               ),
//                             ),
//                             items: categories
//                                 .map((item) => DropdownMenuItem(
//                               value: item,
//                               child: Text(
//                                 item,
//                                 style: const TextStyle(
//                                   fontSize: 14,
//                                 ),
//                               ),
//                             ))
//                                 .toList(),
//                             value: selectedCategory,
//                             onChanged: (value) {
//                               setState(() {
//                                 selectedCategory = value;
//                                 selectedProduct = null;
//                                 products.clear();
//                                 products.add('Select a product');
//                                 if (brandselected != null && value != null && value != 'Select a category') {
//                                   fetchProductsForCategoryForUI(brandselected!, value);
//                                 }
//                               });
//                             },
//                             buttonStyleData: const ButtonStyleData(
//                               padding: EdgeInsets.symmetric(horizontal: 16),
//                               height: 40,
//                               width: double.infinity,
//                             ),
//                             menuItemStyleData: const MenuItemStyleData(
//                               height: 40,
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 16),
//                         DropdownButtonHideUnderline(
//                           child: DropdownButton2<String>(
//                             isExpanded: true,
//                             hint: Text(
//                               selectedProduct ?? 'Select a product',
//                               style: TextStyle(
//                                 fontSize: 14,
//                                 color: Theme.of(context).hintColor,
//                               ),
//                             ),
//                             items: products
//                                 .map((item) => DropdownMenuItem(
//                               value: item,
//                               child: Text(
//                                 item,
//                                 style: const TextStyle(
//                                   fontSize: 14,
//                                 ),
//                               ),
//                             ))
//                                 .toList(),
//                             value: selectedProduct,
//                             onChanged: (value) {
//                               setState(() {
//                                 selectedProduct = value;
//                               });
//                             },
//                             buttonStyleData: const ButtonStyleData(
//                               padding: EdgeInsets.symmetric(horizontal: 16),
//                               height: 40,
//                               width: double.infinity,
//                             ),
//                             menuItemStyleData: const MenuItemStyleData(
//                               height: 40,
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 16),
//                         DropdownButtonHideUnderline(
//                           child: DropdownButton2<String>(
//                             isExpanded: true,
//                             hint: Text(
//                               selectedEmployee ?? 'Select an employee',
//                               style: TextStyle(
//                                 fontSize: 14,
//                                 color: Theme.of(context).hintColor,
//                               ),
//                             ),
//                             items: employees
//                                 .map((item) => DropdownMenuItem(
//                               value: item,
//                               child: Text(
//                                 item,
//                                 style: const TextStyle(
//                                   fontSize: 14,
//                                 ),
//                               ),
//                             ))
//                                 .toList(),
//                             value: selectedEmployee,
//                             onChanged: (value) {
//                               setState(() {
//                                 selectedEmployee = value;
//                               });
//                             },
//                             buttonStyleData: const ButtonStyleData(
//                               padding: EdgeInsets.symmetric(horizontal: 16),
//                               height: 40,
//                               width: double.infinity,
//                             ),
//                             menuItemStyleData: const MenuItemStyleData(
//                               height: 40,
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 16),
//                         DropdownButtonHideUnderline(
//                           child: DropdownButton2<String>(
//                             isExpanded: true,
//                             hint: Text(
//                               requesttype ?? 'Select request type',
//                               style: TextStyle(
//                                 fontSize: 14,
//                                 color: Theme.of(context).hintColor,
//                               ),
//                             ),
//                             items: requesttypes
//                                 .map((item) => DropdownMenuItem(
//                               value: item,
//                               child: Text(
//                                 item,
//                                 style: const TextStyle(
//                                   fontSize: 14,
//                                 ),
//                               ),
//                             ))
//                                 .toList(),
//                             value: requesttype,
//                             onChanged: (value) {
//                               setState(() {
//                                 requesttype = value;
//                               });
//                             },
//                             buttonStyleData: const ButtonStyleData(
//                               padding: EdgeInsets.symmetric(horizontal: 16),
//                               height: 40,
//                               width: double.infinity,
//                             ),
//                             menuItemStyleData: const MenuItemStyleData(
//                               height: 40,
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 16),
//                         DropdownButtonHideUnderline(
//                           child: DropdownButton2<String>(
//                             isExpanded: true,
//                             hint: Text(
//                               selectedStatus ?? 'Select status',
//                               style: TextStyle(
//                                 fontSize: 14,
//                                 color: Theme.of(context).hintColor,
//                               ),
//                             ),
//                             items: ['Open', 'In Progress', 'Resolved']
//                                 .map((item) => DropdownMenuItem(
//                               value: item,
//                               child: Text(
//                                 item,
//                                 style: const TextStyle(
//                                   fontSize: 14,
//                                 ),
//                               ),
//                             ))
//                                 .toList(),
//                             value: selectedStatus,
//                             onChanged: (value) {
//                               setState(() {
//                                 selectedStatus = value;
//                               });
//                             },
//                             buttonStyleData: const ButtonStyleData(
//                               padding: EdgeInsets.symmetric(horizontal: 16),
//                               height: 40,
//                               width: double.infinity,
//                             ),
//                             menuItemStyleData: const MenuItemStyleData(
//                               height: 40,
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 16),
//                         ElevatedButton(
//                           onPressed: () {
//                             notifier.fetchComplaints(
//                               fromdate: fromDateController.text,
//                               todate: toDateController.text,
//                               name: nameController.text,
//                               phone: mobileController.text,
//                               village: selectedCity == 'Select a location' ? null : selectedCity,
//                               dealer: selectedDealer == 'Select a dealer' ? null : selectedDealer,
//                               brandName: brandselected == 'Select a brand' ? null : brandselected,
//                               category: selectedCategory == 'Select a category' ? null : selectedCategory,
//                               product: selectedProduct == 'Select a product' ? null : selectedProduct,
//                               allottedTo: selectedEmployee,
//                               servicetype: requesttype,
//                               source: source,
//                             );
//                           },
//                           child: const Text('Search Complaints'),
//                         ),
//                         const SizedBox(height: 24),
//                         // --- Display Search Results (Allotment Table) ---
//                         if (notifier.isLoading)
//                           const Center(child: CircularProgressIndicator())
//                         else if (notifier.orderedRows.isEmpty)
//                           const Center(child: Text("No complaints found for the selected filters."))
//                         else
//                           SingleChildScrollView(
//                             scrollDirection: Axis.horizontal,
//                             child: DataTable(
//                               columns: const [
//                                 DataColumn(label: Text('Customer')),
//                                 DataColumn(label: Text('Allotted To')),
//                                 DataColumn(label: Text('Status')),
//                                 DataColumn(label: Text('Brand')),
//                                 DataColumn(label: Text('Category')),
//                                 DataColumn(label: Text('Product')),
//                                 DataColumn(label: Text('Warranty Date')),
//                                 DataColumn(label: Text('Purchase Date')),
//                               ],
//                               rows: notifier.orderedRows.map((rowState) {
//   return _buildDataRow(context, rowState, notifier.updateNewValues);
// }).toList(),
//                               // rows: notifier.orderedRows.map((rowState) {
//                               //   return ChangeNotifierProvider<RowState>.value(
//                               //     value: rowState,
//                               //     child: Builder(
//                               //       builder: (rowContext) {
//                               //         return _buildDataRow(rowContext, rowState, notifier.updateNewValues);
//                               //       },
//                               //     ),
//                               //   );
//                               // }).toList(),
//                             ),
//                           ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 // Add Employee Tab
//                 AddEmployee(token: widget.token),
//                 // Other Allotments Tab (Placeholder)
//                 const Center(child: Text('Other Allotments content will go here.')),
//               ],
//             );
//           },
//         ),
//       ),
//     );
//   }
//
//   // Helper method to build a DataRow (moved from original AllotComplaint1)
//   DataRow _buildDataRow(
//       BuildContext context, // Context that has RowState provided to it
//       RowState state,      // The specific state for THIS row
//       Function(String, Map<String, dynamic>) updateCallback) {
//     return DataRow(cells: [
//       // --- Customer Name Cell ---
//       DataCell(
//         Consumer<RowState>(
//           builder: (cellContext, rowStateFromConsumer, _) {
//             return CellWidget<String>(
//               isTextField: true,
//               value: rowStateFromConsumer.nameController.text,
//               controller: rowStateFromConsumer.nameController,
//               onChanged: (newValue) {
//                 updateCallback(rowStateFromConsumer.id, {'Customer name': newValue});
//               },
//             );
//           },
//         ),
//       ),
//       // --- Allotted To (Employee) Cell ---
//       DataCell(
//         Consumer<RowState>(
//           builder: (cellContext, rowStateFromConsumer, _) {
//             final allEmployees = Provider.of<ComplaintDataNotifier>(context, listen: false).employees;
//             final currentEmployee = rowStateFromConsumer.employee;
//
//             final valueToShow = (currentEmployee != null && allEmployees.contains(currentEmployee))
//                 ? currentEmployee
//                 : (allEmployees.isNotEmpty ? allEmployees.first : 'Not assigned');
//
//             return CellWidget<String>(
//               isDropdown: true,
//               value: valueToShow,
//               options: ['Not assigned', ...allEmployees.where((e) => e != 'Select an employee')], // Filter out initial placeholder
//               onChanged: (newValue) {
//                 if (newValue != null) {
//                   rowStateFromConsumer.updateEmployee(newValue, updateNewValuesCallback: updateCallback);
//                 }
//               },
//             );
//           },
//         ),
//       ),
//       // --- Status Cell ---
//       DataCell(
//         Consumer<RowState>(
//           builder: (cellContext, rowStateFromConsumer, _) {
//             const statusOptions = ['Open', 'In Progress', 'Resolved'];
//             return CellWidget<String>(
//               value: rowStateFromConsumer.status,
//               options: statusOptions,
//               isDropdown: true,
//               onChanged: (newValue) {
//                 if (newValue != null) {
//                   rowStateFromConsumer.updateStatus(newValue, updateNewValuesCallback: updateCallback);
//                 }
//               },
//             );
//           },
//         ),
//       ),
//       // --- Brand Cell ---
//       DataCell(
//         Consumer<RowState>(
//           builder: (cellContext, rowStateFromConsumer, _) {
//             final availableBrands = Provider.of<ComplaintDataNotifier>(context, listen: false).brands;
//             final valueToShow = availableBrands.contains(rowStateFromConsumer.brand)
//                 ? rowStateFromConsumer.brand
//                 : (availableBrands.isNotEmpty ? availableBrands.first : 'Select a brand');
//
//             return CellWidget<String>(
//               isDropdown: true,
//               options: availableBrands.isNotEmpty ? availableBrands : ['Loading...'],
//               value: valueToShow,
//               onChanged: (newValue) {
//                 if (newValue != null) {
//                   rowStateFromConsumer.updateBrand(newValue, updateNewValuesCallback: updateCallback);
//                 }
//               },
//             );
//           },
//         ),
//       ),
//       // --- Category Cell ---
//       DataCell(
//         Consumer<RowState>(
//           builder: (cellContext, rowStateFromConsumer, _) {
//             if (rowStateFromConsumer.isLoadingCategories) {
//               return const Center(child: SizedBox(width: 15, height: 15, child: CircularProgressIndicator(strokeWidth: 2)));
//             }
//             final categories = rowStateFromConsumer.fetchedCategories;
//             final valueToShow = categories.contains(rowStateFromConsumer.category)
//                 ? rowStateFromConsumer.category
//                 : (categories.isNotEmpty ? categories.first : 'Select Brand');
//
//             return CellWidget<String>(
//               isDropdown: true,
//               value: valueToShow,
//               options: categories.isNotEmpty ? categories : ['Select Brand'],
//               onChanged: (newValue) {
//                 if (newValue != null) {
//                   rowStateFromConsumer.updateCategory(newValue, updateNewValuesCallback: updateCallback);
//                 }
//               },
//             );
//           },
//         ),
//       ),
//       // --- Product Cell ---
//       DataCell(
//         Consumer<RowState>(
//           builder: (cellContext, rowStateFromConsumer, _) {
//             if (rowStateFromConsumer.isLoadingProducts) {
//               return const Center(child: SizedBox(width: 15, height: 15, child: CircularProgressIndicator(strokeWidth: 2)));
//             }
//             final products = rowStateFromConsumer.fetchedProducts;
//             final valueToShow = products.contains(rowStateFromConsumer.product)
//                 ? rowStateFromConsumer.product
//                 : (products.isNotEmpty ? products.first : 'Select Category');
//
//             return CellWidget<String>(
//               isDropdown: true,
//               value: valueToShow,
//               options: products.isNotEmpty ? products : ['Select Category'],
//               onChanged: (newValue) {
//                 if (newValue != null) {
//                   rowStateFromConsumer.updateProduct(newValue, updateNewValuesCallback: updateCallback);
//                 }
//               },
//             );
//           },
//         ),
//       ),
//       // --- Warranty Date Cell ---
//       DataCell(
//         _dateFieldForTable(state.warrantyDateController, () => _selectDateForTable(context, state.warrantyDateController, state.id, updateCallback, true)),
//       ),
//       // --- Purchase Date Cell ---
//       DataCell(
//         _dateFieldForTable(state.purchaseDateController, () => _selectDateForTable(context, state.purchaseDateController, state.id, updateCallback, false)),
//       ),
//     ]);
//   }
//
//   // --- Helper for Date Field (specifically for the table cells) ---
//   Widget _dateFieldForTable(TextEditingController controller, VoidCallback onTap) {
//     return TextField(
//       controller: controller,
//       readOnly: true,
//       onTap: onTap,
//       decoration: const InputDecoration(border: InputBorder.none), // Keep it simple
//     );
//   }
//
//   // --- Helper for Date Picker (specifically for the table cells) ---
//   Future<void> _selectDateForTable(
//       BuildContext context,
//       TextEditingController controller,
//       String recordId,
//       Function(String, Map<String, dynamic>) updateCallback,
//       bool isWarranty) async {
//     final date = await showDatePicker(
//       context: context,
//       initialDate: DateTime.tryParse(controller.text) ?? DateTime.now(),
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2100),
//     );
//     if (date != null) {
//       final formatted = DateFormat('yyyy-MM-dd').format(date);
//       controller.text = formatted; // Update controller directly
//       final fieldName = isWarranty ? 'warranty expiry date' : 'Purchase date';
//       updateCallback(recordId, {fieldName: formatted});
//     }
//   }
// }
class _CRMDashboardState extends State<CRMDashboard> with SingleTickerProviderStateMixin {
  // Filter variables
  String? selectedStatus;
  String? selectedDealer;
  String? selectedCity;
  String? selectedEmployee;
  String? selectedCategory;
  String? selectedProduct;
  String? brandselected;
  String? requesttype;
  String? source;

  var requesttypes = ['Installation', 'Demo', 'Service', 'Complain'];

  // Lists for UI dropdowns
  List<String> employeesforUI = ['Select an employee', 'Not assigned'];
  List<String> productsForUI = ['Select a product'];
  List<String> locationsForUI = ['Select a location'];
  List<String> dealerNamesForUI = ['Select a dealer'];
  List<String> categoriesForUI = ['Select a category'];
  List<String> brandsForUI = ['Select a brand'];

  final TextEditingController fromDateController = TextEditingController();
  final TextEditingController toDateController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();

  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = Provider.of<ComplaintDataNotifier>(context, listen: false);
      // notifier.fetchInitialData(widget.token);
      notifier.fetchInitialData(widget.token).then((_) {
        print("After fetchInitialData completes - Notifier's orderedRows length: ${notifier.orderedRows.length}");
        // notifier.applyFilters();
        _initializeFilterDropdowns(notifier);
      });
      // print(1);
    });
    fetchLocationForUI();
    fetchCategoriesForUI('Select a brand');
    //fetchEmployees();
  }
  // Future<void> fetchEmployees() async {
  //   final response = await http.get(
  //     Uri.parse('https://limsonvercelapi2.vercel.app/api/fsemployeeservice?getKarigars=true'),
  //     headers: {'Content-Type': 'application/json',
  //       'Authorization': 'Bearer ${widget.token}'},
  //   );
  //   if (response.statusCode == 200) {
  //     final List<dynamic> empList = json.decode(response.body);
  //     setState(() {
  //       employeesforUI.addAll(empList.map((emp) => emp['First name'].toString()));
  //       selectedEmployee=employeesforUI[0];
  //     });
  //   }
  // }

  void _clearFilters() async {
    // Reset all controllers
    fromDateController.clear();
    toDateController.clear();
    nameController.clear();
    mobileController.clear();

    // Reset all dropdown values
    setState(() {
      selectedCity = locationsForUI.isNotEmpty ? 'Select a location' : null;
      selectedDealer = dealerNamesForUI.isNotEmpty ? dealerNamesForUI[0] : null;
      brandselected = brandsForUI.isNotEmpty ? brandsForUI[0] : null;
      selectedCategory = categoriesForUI.isNotEmpty ? categoriesForUI[0] : null;
      selectedProduct = productsForUI.isNotEmpty ? productsForUI[0] : null;
      selectedEmployee = employeesforUI.isNotEmpty ? employeesforUI[0] : null;
      requesttype = null;
      selectedStatus = null;
      source = null;

      // Reset dependent dropdowns
      dealerNamesForUI = ['Select a dealer'];
      categoriesForUI = ['Select a category'];
      productsForUI = ['Select a product'];
    });
    await fetchLocationForUI();  // Locations
    if (brandsForUI.isNotEmpty) {
      await fetchCategoriesForUI(brandsForUI[0]);
    }

    // Reapply empty filters
  //  final notifier = Provider.of<ComplaintDataNotifier>(context, listen: false);
    // Apply empty filters to show all complaints
    final notifier = Provider.of<ComplaintDataNotifier>(context, listen: false);
    notifier.applyFilters();
  }
  Future<void> fetchCategoriesForUI(String Brand) async {
    if (Brand.isEmpty || Brand == 'Select a brand') return;

    setState(() {
      categoriesForUI = ['Select a category'];
      selectedCategory = categoriesForUI[0];
      productsForUI = ['Select a product'];
      selectedProduct = productsForUI[0];
    });

    try {
      final response = await http.get(
        Uri.parse('https://limsonvercelapi2.vercel.app/api/fsproductservice?level=categories&brand=$Brand'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer ${widget.token}'},
      );
      if (response.statusCode == 200) {
        final List<dynamic> categoryList = jsonDecode(response.body);
        setState(() {
          categoriesForUI = ['Select a category', ...categoryList.map((category) => category.toString())];
        });
      }
    } catch (e) {
      print("Error fetching categories: $e");
    }
  }


  Future<void> fetchProductsForCategoryForUI(String Brand, String categoryId) async {
    if (Brand.isEmpty || categoryId.isEmpty || categoryId == 'Select a category') return;

    setState(() {
      productsForUI = ['Select a product'];
      selectedProduct = productsForUI[0];
    });

    try {
      final response = await http.get(
        Uri.parse('https://limsonvercelapi2.vercel.app/api/fsproductservice?level=products&brand=$Brand&category=$categoryId'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer ${widget.token}'},
      );
      if (response.statusCode == 200) {
        final List<dynamic> productList = json.decode(response.body);
        setState(() {
          productsForUI = ['Select a product', ...productList.map((e) => e['name'].toString())];
        });
      }
    } catch (e) {
      print("Error fetching products: $e");
    }
  }

  Future<void> fetchLocationForUI() async {
    try {
      final response = await http.get(
        Uri.parse('https://limsonvercelapi2.vercel.app/api/fsdealerservice?getLocations=true'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer ${widget.token}'},
      );
      if (response.statusCode == 200) {
        final List<dynamic> locationList = json.decode(response.body);
        setState(() {
          locationsForUI = ['Select a location', ...locationList.map((location) => location.toString())];
          locationsForUI.sort();
          selectedCity = 'Select a location';
        });
      }
    } catch (e) {
      print("Error fetching locations: $e");
    }
  }

  Future<void> fetchDealerForUI(String loc) async {
    if (loc.isEmpty || loc == 'Select a location') return;

    setState(() {
      dealerNamesForUI = ['Select a dealer'];
      selectedDealer = dealerNamesForUI[0];
    });

    try {
      final response = await http.get(
        Uri.parse("https://limsonvercelapi2.vercel.app/api/fsdealerservice?locality=$loc"),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer ${widget.token}'},
      );
      if (response.statusCode == 200) {
        final List<dynamic> dealers = json.decode(response.body);
        setState(() {
          dealerNamesForUI = ['Select a dealer', ...dealers.map((dealer) => dealer['Dealer name'].toString())];
        });
      }
    } catch (e) {
      print("Error fetching dealers: $e");
    }
  }
  void _initializeFilterDropdowns(ComplaintDataNotifier notifier) {
    setState(() {
      // Set initial values for your filter dropdowns
      // These lists come from ComplaintDataNotifier, ensure they are not empty before accessing index 0
      selectedEmployee = notifier.employees.isNotEmpty ? notifier.employees[0] : null;
      brandselected = notifier.brands.isNotEmpty ? notifier.brands[0] : null;

      // These lists are managed by local fetches (fetchLocationForUI etc.)
      selectedCity = locationsForUI.isNotEmpty ? locationsForUI[0] : null;
      selectedDealer = dealerNamesForUI.isNotEmpty ? dealerNamesForUI[0] : null;
      selectedCategory = categoriesForUI.isNotEmpty ? categoriesForUI[0] : null;
      selectedProduct = productsForUI.isNotEmpty ? productsForUI[0] : null;

      // Other initial selections for non-dynamic dropdowns
      selectedStatus = null; // Or 'Open' if you have a default
      requesttype = null;
      source = null;
    });

    // Trigger dependent fetches if initial brand is not 'Select a brand'
    // This ensures categories and products dropdowns are populated if a default brand is selected
    if (brandselected != null && brandselected != 'Select a brand') {
      fetchCategoriesForUI(brandselected!);
    }
    // No need to fetch locations/dealers here again, as fetchLocationForUI is called in initState.
    // However, if your 'selectedCity' depends on the notifier's data (which it doesn't currently),
    // you would call fetchDealerForUI here.
  }
  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDate: DateTime.tryParse(controller.text) ?? DateTime.now(),
    );
    if (picked != null) {
      controller.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    fromDateController.dispose();
    toDateController.dispose();
    nameController.dispose();
    mobileController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
        appBar: AppBar(
          title: const Text('CRM Dashboard'),
          actions: [
            Consumer<ComplaintDataNotifier>(
              builder: (context, notifier, child) {
                return IconButton(
                  icon: notifier.isSaving
                      ? const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.save),
                  onPressed: notifier.isSaving || !notifier.hasPendingUpdates
                      ? null
                      : () => notifier.saveAll(widget.token),
                );
              },
            ),
            Consumer<ComplaintDataNotifier>(
              builder: (context, notifier, child) {
                return IconButton(
                  icon: notifier.isLoading && !notifier.isSaving
                      ? const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.red))
                      : const Icon(Icons.refresh),
                  onPressed: notifier.isLoading ? null : () => notifier.fetchInitialData(widget.token),
                );
              },
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Complaints'),
              Tab(text: 'Add Employee'),
            ],
          ),
        ),
        body: Consumer<ComplaintDataNotifier>(
          builder: (context, notifier, child) {
            // Update UI lists from notifier
            print("Building Consumer - isLoading: ${notifier.isLoading}, rows: ${notifier.orderedRows.length}");

            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (notifier.employees.isNotEmpty &&
                  !listEquals(employeesforUI, notifier.employees)) {
                setState(() => employeesforUI = notifier.employees);
              }
              if (notifier.brands.isNotEmpty &&
                  !listEquals(brandsForUI, notifier.brands)) {
                setState(() => brandsForUI = notifier.brands);
              }


            });

            return TabBarView(
              controller: _tabController,
              children: [
                // Complaints Tab
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      const Text('Search Filters:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: fromDateController,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: 'From Date',
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.calendar_today),
                              onPressed: () => _selectDate(context, fromDateController),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          controller: toDateController,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: 'To Date',
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.calendar_today),
                              onPressed: () => _selectDate(context, toDateController),
                            ),
                          ),
                        ),
                      )],
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(labelText: 'Customer Name'),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: mobileController,
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        decoration: const InputDecoration(labelText: 'Mobile Number'),
                      ),
                      const SizedBox(height: 16),
                      _buildDropdown(
                          value: selectedCity,
                          items: locationsForUI,
                          hint: 'Select a location',
                          onChanged: (value) {
                            setState(() {
                              selectedCity = value;
                              if (value != null && value != 'Select a location') {
                                fetchDealerForUI(value);
                              } else {
                                dealerNamesForUI = ['Select a dealer'];
                                selectedDealer = null;
                              }
                            });
                          }
                      ),
                      const SizedBox(height: 16),
                      _buildDropdown(
                        value: selectedDealer,
                        items: dealerNamesForUI,
                        hint: 'Select a dealer',
                        onChanged: (value) => setState(() => selectedDealer = value),
                      ),
                      const SizedBox(height: 16),
                      _buildDropdown(
                          value: brandselected,
                          items: brandsForUI,
                          hint: 'Select a brand',
                          onChanged: (value) {
                            setState(() {
                              brandselected = value;
                              categoriesForUI = ['Select a category'];
                              selectedCategory = null;
                              productsForUI = ['Select a product'];
                              selectedProduct = null;
                              if (value != null && value != 'Select a brand') {
                                fetchCategoriesForUI(value);
                              }
                            });
                          }
                      ),
                      const SizedBox(height: 16),
                      _buildDropdown(
                          value: selectedCategory,
                          items: categoriesForUI,
                          hint: 'Select a category',
                          onChanged: (value) {
                            setState(() {
                              selectedCategory = value;
                              productsForUI = ['Select a product'];
                              selectedProduct = null;
                              if (brandselected != null && value != null && value != 'Select a category') {
                                fetchProductsForCategoryForUI(brandselected!, value);
                              }
                            });
                          }
                      ),
                      const SizedBox(height: 16),
                      _buildDropdown(
                        value: selectedProduct,
                        items: productsForUI,
                        hint: 'Select a product',
                        onChanged: (value) => setState(() => selectedProduct = value),
                      ),
                      const SizedBox(height: 16),
                      _buildDropdown(
                        value: selectedEmployee,
                        items: employeesforUI,
                        hint: 'Select an employee',
                        onChanged: (value) => setState(() => selectedEmployee = value),
                      ),
                      const SizedBox(height: 16),
                      _buildDropdown(
                        value: requesttype,
                        items: requesttypes,
                        hint: 'Select request type',
                        onChanged: (value) => setState(() => requesttype = value),
                      ),
                      const SizedBox(height: 16),
                      _buildDropdown(
                        value: selectedStatus,
                        items: ['Open', 'In Progress', 'Resolved'],
                        hint: 'Select status',
                        onChanged: (value) => setState(() => selectedStatus = value),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          ElevatedButton(onPressed: _clearFilters, child: Text("Clear filters")),
                          ElevatedButton(
                          onPressed: () {
                            notifier.applyFilters(
                              fromdate: fromDateController.text.isNotEmpty ? fromDateController.text : null,
                              todate: toDateController.text.isNotEmpty ? toDateController.text : null,
                              name: nameController.text.isNotEmpty ? nameController.text : null,
                              phone: mobileController.text.isNotEmpty ? mobileController.text : null,
                              village: selectedCity == 'Select a location' ? null : selectedCity,
                              dealer: selectedDealer == 'Select a dealer' ? null : selectedDealer,
                              brandName: brandselected == 'Select a brand' ? null : brandselected,
                              category: selectedCategory == 'Select a category' ? null : selectedCategory,
                              product: selectedProduct == 'Select a product' ? null : selectedProduct,
                              allottedTo: selectedEmployee,
                              servicetype: requesttype,
                              source: source,
                            );
                          },
                          child: const Text('Search Complaints'),
                        ),],
                      ),

                      const SizedBox(height: 24),
                      if (!notifier.isLoading)
            // print("[DEBUG UI] Showing CircularProgressIndicator.");
           const Center(child: CircularProgressIndicator())

                      else if (notifier.orderedRows.isEmpty)

            // print("[DEBUG UI] Showing 'No complaints found'."); // <-- ADD THIS
            Center(child: Text("No complaints found for the selected filters."))
            // const Center(child: Text("No complaints found for the selected filters."))
            else
            SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
            columns: const [
            DataColumn(label: Text('Customer')),
            DataColumn(label: Text('Allotted To')),
            DataColumn(label: Text('Status')),
            DataColumn(label: Text('Brand')),
            DataColumn(label: Text('Category')),
            DataColumn(label: Text('Product')),
            DataColumn(label: Text('Warranty Date')),
            DataColumn(label: Text('Purchase Date')),
            DataColumn(label: Text('Dealer')),
            DataColumn(label: Text('Location')),
            ],
            rows: notifier.orderedRows.map((rowState) => _buildDataRow(context, rowState)).toList(),
            ),

            ),



                // Add Employee Tab
                AddEmployee(token: widget.token),
                // Other Allotments Tab
                // const Center(child: Text('Other Allotments content will go here.')),
              ],
            ))]);
          },
        ),
      );
  }

  Widget _buildDropdown({
    required String? value,
    required List<String> items,
    required String hint,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonHideUnderline(
      child: DropdownButton2<String>(
        isExpanded: true,
        hint: Text(
          value ?? hint,
          style: TextStyle(fontSize: 14, color: Theme.of(context).hintColor),
        ),
        items: items.map((item) => DropdownMenuItem(
          value: item,
          child: Text(item, style: const TextStyle(fontSize: 14)),
        )).toList(),
        value: value,
        onChanged: onChanged,
        buttonStyleData: const ButtonStyleData(
          padding: EdgeInsets.symmetric(horizontal: 16),
          height: 40,
          width: double.infinity,
        ),
        menuItemStyleData: const MenuItemStyleData(height: 40),
      ),
    );
  }

  DataRow _buildDataRow(BuildContext context, RowState state) {

    return DataRow(cells: [
    DataCell(
    CellWidget<String>(
    isTextField: true,
      value: state.nameController.text,
      controller: state.nameController,
      onChanged: state.updateName,
    ),
    ),
    DataCell(
Consumer<ComplaintDataNotifier>(
      builder: (context, notifier, _) {

        final employeeOptions = List<String>.from(notifier.employees);
        if (!employeeOptions.contains(state.employee)) {
          employeeOptions.add(state.employee);
        }
        print(employeeOptions);
      return CellWidget<String>(
      isDropdown: true,
      value: state.employee,
      options: employeeOptions,
      onChanged: state.updateEmployee,
      );
      },
      ),
    ),

    DataCell(
    Consumer<RowState>(
      builder: (context, state, _) {
        return CellWidget<String>(
          isDropdown: true,
          value: state.status,
          options: const ['Open', 'In Progress', 'Resolved'],
          onChanged: state.updateStatus,
        );
      },
    ),
    ),
    DataCell(

       Consumer<ComplaintDataNotifier>(
      builder: (context, notifier, _) {
      return CellWidget<String>(
      isDropdown: true,
      value: state.brand,
      options: notifier.brands,
      onChanged: state.updateBrand,
      );
      },
      ),
    ),

    DataCell(

      Consumer<RowState>(
      builder: (context, state, _) {
      if (state.isLoadingCategories) {
      return const Center(child: SizedBox(
      width: 15, height: 15,
      child: CircularProgressIndicator(strokeWidth: 2),
      ));
      }
      // Ensure current category is in options
      final categoryOptions = List<String>.from(state.fetchedCategories);
      if (!categoryOptions.contains(state.category)) {
        categoryOptions.add(state.category);
      }

      return CellWidget<String>(
      isDropdown: true,
      value: state.category,
      options: categoryOptions,
      onChanged: state.updateCategory,
      );
      },
      ),
    ),

    DataCell(
    ChangeNotifierProvider.value(
      value: state,
      child: Consumer<RowState>(
      builder: (context, state, _) {
      if (state.isLoadingProducts) {
      return const Center(child: SizedBox(
      width: 15, height: 15,
      child: CircularProgressIndicator(strokeWidth: 2),
      ));
      }
      final productOptions = List<String>.from(state.fetchedProducts);
      if (!productOptions.contains(state.product)) {
        productOptions.add(state.product);
      }

      return CellWidget<String>(
      isDropdown: true,
      value: state.product,
      options: productOptions,
      onChanged: state.updateProduct,
      );
      },
      ),
    ),
    ),

    DataCell(
    InkWell(
    onTap: () => _selectDate(context, state.warrantyDateController),
    child: AbsorbPointer(
    child: TextField(
    controller: state.warrantyDateController,
    readOnly: true,
    decoration: const InputDecoration(
    border: InputBorder.none,
    isDense: true,
    contentPadding: EdgeInsets.symmetric(vertical: 8),
    ),
    ),
    ),
    )),
    DataCell(
    InkWell(
    onTap: () => _selectDate(context, state.purchaseDateController),
    child: AbsorbPointer(
    child: TextField(
    controller: state.purchaseDateController,
    readOnly: true,
    decoration: const InputDecoration(
    border: InputBorder.none,
    isDense: true,
    contentPadding: EdgeInsets.symmetric(vertical: 8),
    ),
    ),
    ),
    )),

    DataCell(

      Consumer<RowState>(
        builder: (context, state, _) {
          return CellWidget<String>(
            isDropdown: true,
            value: state.village,
            options: state.fetchedLocations,
            onChanged: state.updateVillage,
          );
        },
      ),
    )
    ,

      DataCell(

           Consumer<RowState>(
            builder: (context, state, _) {
              return CellWidget<String>(
                isDropdown: true,
                value: state.dealer,
                options: state.fetchedDealers,
                onChanged: state.updateDealer,
              );
            },
          ),
        )


    ]);

  }
}

// Placeholder for AddEmployee
// class AddEmployee extends StatelessWidget {
//   final String token;
//
//   const AddEmployee({super.key, required this.token});
//
//   @override
//   Widget build(BuildContext context) {
//     return const Center(child: Text('Add Employee functionality'));
//   }
// }
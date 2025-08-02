// import 'package:flutter/material.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:lmrepaircrmadmin/addemployee.dart';
// import 'package:dropdown_button2/dropdown_button2.dart';
// import 'package:auto_size_text/auto_size_text.dart';
// //import 'package:lmrepaircrmadmin/allotments.dart';
// import 'allotments3.dart';
// //import 'allotments.dart';
// //import 'dealerfetcher.dart';
//
// class CRMDashboard extends StatefulWidget {
//
//   final String token;
//
//   CRMDashboard({required this.token});
//
//   @override
//   State<CRMDashboard> createState() => _CRMDashboardState();
// }
//
// class _CRMDashboardState extends State<CRMDashboard> with SingleTickerProviderStateMixin {
//   String? selectedStatus;
//   String? selectedDealer;
//   String? selectedCity;
//   String? selectedEmployee;
//   String? selectedCategory;
//   String? selectedProduct;
//   String? brandselected;
//   DateTime? selectedDate;
//   String? requesttype;
//   String? source;
//   String? byd;
//   var requesttypes=['Installation','Demo','Service','Complain'];
//   var bydate=['CompDate','SchedDate','VisitDate','SolveDate'];
//
//   List<String> employees = ['Select an employee'];
//   List<String> products = ['Select a product'];
//   List<String> locations = ['Select a location'];
//   List<String> dealerNames = ['Select a dealer'];
//   List<String> categories = ['Select a category'];
//   List<String> brand=['Select a brand'];
//
//   //final TextEditingController dateController = TextEditingController();
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
//     fetchLocation();
//     fetchBrands();
//     fetchEmployees();
//   }
//
//
//   Future<void> fetchEmployees() async {
//     final response = await http.get(
//       Uri.parse('https://limsonvercelapi2.vercel.app/api/fsemployeeservice?getKarigars=true'),
//       headers: {'Content-Type': 'application/json',
//         'Authorization': 'Bearer ${widget.token}'},
//     );
//     if (response.statusCode == 200) {
//       final List<dynamic> empList = json.decode(response.body);
//       setState(() {
//         employees.addAll(empList.map((emp) => emp['First name'].toString()));
//         selectedEmployee=employees[0];
//       });
//     }
//   }
// Future<void> fetchBrands() async {
//     final response = await http.get(
//       Uri.parse('https://limsonvercelapi2.vercel.app/api/fsproductservice?level=brands'),
//       headers: {'Content-Type': 'application/json',
//         'Authorization': 'Bearer ${widget.token}'},
//     );
//     if (response.statusCode == 200) {
//       final List<dynamic> brandList = json.decode(response.body);
//       setState(() {
//         brand.addAll(brandList.map((brand) => brand.toString()));
//         brandselected=brand[0];
//        // selectedProduct = products[0];
//       });
//     }
//   }
//   Future<void> fetchCategories(String Brand) async {
//     final response = await http.get(
//       Uri.parse('https://limsonvercelapi2.vercel.app/api/fsproductservice?level=categories&brand=$Brand'),
//       headers: {'Content-Type': 'application/json',
//         'Authorization': 'Bearer ${widget.token}'},
//     );
//     if (response.statusCode == 200) {
//       print(jsonDecode(response.body));
//       final List<dynamic> categoryList = jsonDecode(response.body);
//       setState(() {
//         categories.addAll(categoryList.map((category) => category.toString()));
//         selectedCategory=categories[0];
//       });
//     }
//   }
//
//   Future<void> fetchProductsForCategory(String Brand,String categoryId) async {
//     final response = await http.get(
//       Uri.parse('https://limsonvercelapi2.vercel.app/api/fsproductservice?level=products&brand=$Brand&category=$categoryId'),
//       headers: {'Content-Type': 'application/json',
//         'Authorization': 'Bearer ${widget.token}'},
//     );
//     if (response.statusCode == 200) {
//       final List<dynamic> productList = json.decode(response.body);
//       setState(() {
//         print(productList);
//         products.addAll(productList.map((e) => e['name'].toString()));
//
//         selectedProduct = products[0];
//       });
//     }
//   }
//
//   Future<void> fetchLocation() async {
//     final response = await http.get(
//       Uri.parse('https://limsonvercelapi2.vercel.app/api/fsdealerservice?getLocations=true'),
//       headers: {'Content-Type': 'application/json',
//         'Authorization': 'Bearer ${widget.token}'},
//     );
//     if (response.statusCode == 200) {
//       final List<dynamic> locationList = json.decode(response.body);
//       setState(() {
//         locations.addAll(locationList.map((location) => location.toString()));
//         locations.sort((a, b) => a.compareTo(b));
//         selectedCity=locations[0];
//       });
//     }
//   }
//
//   Future<void> fetchDealer(String loc) async {
//     final response = await http.get(
//       Uri.parse("https://limsonvercelapi2.vercel.app/api/fsdealerservice?locality=$loc"),
//       headers: {'Content-Type': 'application/json',
//         'Authorization': 'Bearer ${widget.token}'},
//     );
//     if (response.statusCode == 200) {
//       final List<dynamic> dealers = json.decode(response.body);
//       print(dealers);
//       setState(() {
//         dealerNames.addAll(dealers.map((dealer) => dealer['Dealer name'].toString()));
//         selectedDealer = dealerNames[0];
//       });
//     }
//   }
//
//   Future<void> selectDate(BuildContext context, TextEditingController controller) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2100),
//       initialDate: selectedDate ?? DateTime.now(),
//     );
//     if (picked != null) {
//       setState(() {
//         selectedDate = picked;
//         controller.text = "${picked.toLocal()}".split(' ')[0];
//       });
//     }
//   }
//
//
//   Future<void> Searchcomplaints({
//     String? fromdate,
//     String? todate,
//     String? name,
//     String? phone,
//     String? village,
//     String? dealer,
//     String? category,
//     String? product,
//     String? allotedto,
//     String? servicetype,
//     String? source,
//   }) async {
//     // Create a flat map for query parameters
//     var query = {
//       if (fromdate != null && fromdate.isNotEmpty) "fromdate": fromdate,
//       if (todate != null && todate.isNotEmpty) "todate": todate,
//       if (name != null && name.isNotEmpty) "Customer name": name,
//       if (phone != null && phone.isNotEmpty) "Phone Number": phone,
//       if (village != null && village.isNotEmpty) "Location": village,
//       if (dealer != null && dealer.isNotEmpty) "Dealer": dealer,
//       if (category != null && category.isNotEmpty) "productcategory": category,
//       if (product != null && product.isNotEmpty) "productname": product,
//       if (allotedto != null && allotedto.isNotEmpty) "allotment": allotedto,
//       if (servicetype != null && servicetype.isNotEmpty) "Service type": servicetype,
//       if (source != null && source.isNotEmpty) "Source by": source,
//     };
//
//     // Construct the URI correctly without leading slash in the path
//     final urlq = Uri.https("limsonvercelapi2.vercel.app", "/api/fscomplaintfiltering", query
//     );
//
//     // Perform the HTTP GET request
//     final response = await http.get(urlq, headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer ${widget.token}'});
//
//     // Handle the response as needed
//     print(response.body);
//   }
//   @override
//   void dispose() {
//     _tabController?.dispose();
//     super.dispose();
//   }
//
//   // bool validateInput() {
//   //   if (nameController.text.isEmpty ||
//   //       mobileController.text.length != 10 ||
//   //       selectedCity == null ||
//   //       selectedDealer == null ||
//   //       selectedCategory == null ||
//   //       selectedProduct == null ||
//   //       selectedEmployee == null) {
//   //     return false;
//   //   }
//   //   return true;
//   // }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Admin Dashboard'),
//         bottom: TabBar(
//           controller: _tabController,
//           tabs: [
//             Tab(icon: Icon(Icons.person), text: "Employee"),
//             Tab(icon: Icon(Icons.filter_list_rounded), text: "Complaints & Requests Filtering"),
//             Tab(icon:Icon(Icons.comment),text:"View and allot complaints")
//           ],
//         ),
//       ),
//       body: TabBarView(
//         controller: _tabController,
//         children: [
//           Center(child: AddEmployee(token:widget.token)),
//           SingleChildScrollView(
//             padding: EdgeInsets.all(16.0),
//             child: Column(
//               children: [
//                 Row(
//                   children: [
//                     Expanded(
//                       child: Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: TextFormField(
//                           controller: fromDateController,
//                           decoration: InputDecoration(
//                             labelText: 'From Date',
//                             border: OutlineInputBorder(),
//                           ),
//                           readOnly: true,
//                           onTap: () => selectDate(context, fromDateController),
//                         ),
//                       ),
//                     ),
//                     Expanded(
//                       child: Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: TextFormField(
//                           controller: toDateController,
//                           decoration: InputDecoration(
//                             labelText: 'To Date',
//                             border: OutlineInputBorder(),
//                           ),
//                           readOnly: true,
//                           onTap: () => selectDate(context, toDateController),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child:
//                         SizedBox(
//                           width: 125,
//                           child: Padding(
//                             padding: const EdgeInsets.all(8.0),
//                             child:  DropdownButton(
//                                 value:byd,
//                                 items:[
//                                   DropdownMenuItem(value:'Complain Date',child: Text('Compdate'),),
//                                   DropdownMenuItem(value:'SolveDate',child: Text('SolveDate'),),
//                                   DropdownMenuItem(value:'VisitDate',child: Text('VisitDate')),
//                                   DropdownMenuItem(value:'Scheduled date',child:Text('SchedDate')),
//                                 ] , onChanged:(b){
//
//                                     setState(() {
//                                       byd = b;
//                                     });
//
//                             } ),
//                           ),
//                         ),
//                       ),
//                     ),
//                     Expanded(
//                       child: Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: DropdownButtonFormField<String>(
//                           hint: Text('Complaint Status'),
//                           value: selectedStatus,
//                           onChanged: (value)
//                           {
//
//                                 selectedStatus=value;
//
//                           },
//                           decoration: InputDecoration(
//                             border: OutlineInputBorder(),
//                             contentPadding: EdgeInsets.symmetric(horizontal: 10),
//                           ),
//                           items: ['Pending', 'In progress', 'Closed']
//                               .map((status) => DropdownMenuItem(
//                             child: Text(status),
//                             value: status,
//                           ),
//                           )
//                               .toList(),
//
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: TextFormField(
//                     controller: nameController,
//                     decoration: InputDecoration(
//                       labelText: 'Name',
//                       border: OutlineInputBorder(),
//                       errorText: nameController.text.isEmpty ? 'Name is required' : null,
//                     ),
//                   ),
//                 ),
//                 Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: TextFormField(
//                     controller: mobileController,
//                     keyboardType: TextInputType.phone,
//                     decoration: InputDecoration(
//                       labelText: 'Mobile Number',
//                       border: OutlineInputBorder(),
//                       errorText: mobileController.text.length != 10 ? 'Enter a valid 10-digit number' : null,
//                     ),
//                   ),
//                 ),
//                 Row(
//                   children: [
//                     Wrap(
//                       direction: Axis.horizontal,
//                       children:[ ConstrainedBox(
//                         constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width*0.2,maxHeight: 170),
//
//                         child: Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: DropdownButtonFormField2(
//                             value: selectedCity,
//                             isExpanded: true,
//                             decoration: InputDecoration(border: OutlineInputBorder()),
//                             onChanged: (newValue) {
//                               setState(() {
//                                 selectedCity = newValue;
//                                 fetchDealer(selectedCity!);
//                               });
//                             },
//                             items: locations
//                                 .map((location) => DropdownMenuItem(
//                               value: location,
//                               child: Text(location,overflow: TextOverflow.visible),
//                             ))
//                                 .toList(),
//                           ),
//                         ),
//                       ),
//                         ConstrainedBox
//                           (
//                           constraints:BoxConstraints(maxWidth: MediaQuery.of(context).size.width*0.20,maxHeight: 170),
//                           child: Padding(
//                             padding: const EdgeInsets.all(8.0),
//                             child:DropdownButtonFormField2(
//                               value: selectedDealer,
//                               isExpanded: true,
//                               decoration: InputDecoration(border: OutlineInputBorder()),
//                               onChanged: (value) => setState(() => selectedDealer = value!),
//                               items: dealerNames
//                                   .map((dealer) => DropdownMenuItem(
//                                 value: dealer,
//                                 child: AutoSizeText(dealer, overflow: TextOverflow.visible),
//                               ))
//                                   .toList(),
//                             ),
//                           ),
//                         ),
//     ]
//                     ),
//                     ConstrainedBox
//                       (constraints:BoxConstraints(maxWidth: MediaQuery.of(context).size.width*0.2,maxHeight: 170),
//                       child: Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: DropdownButtonFormField2(
//                           decoration: InputDecoration(labelText: 'Brands', border: OutlineInputBorder()),
//                           value: brandselected,
//                           isExpanded: true,
//                           items: brand.map((c) => DropdownMenuItem(value: c, child: Text(c,overflow: TextOverflow.visible))).toList(),
//                           onChanged: (newValue) {
//                             setState(() {
//                               brandselected = newValue as String?;
//                               if (newValue != null) fetchCategories(newValue);
//                             });
//                           },
//                         ),
//                       ),
//                     ),
//                     ConstrainedBox
//                       (constraints:BoxConstraints(maxWidth: MediaQuery.of(context).size.width*0.2,maxHeight: 170),
//                       child: Padding(
//                         padding: const EdgeInsets.all(8.0),
//                         child: DropdownButtonFormField2(
//                           decoration: InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
//                           value: selectedCategory,
//                           isExpanded: true,
//                           items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c,overflow: TextOverflow.visible))).toList(),
//                           onChanged: (newValue) {
//                             setState(() {
//                               selectedCategory = newValue as String?;
//                               if (newValue != null) fetchProductsForCategory(brandselected!,selectedCategory!);
//                             });
//                           },
//                         ),
//                       ),
//                     ),
//
//                   ],
//                 ),
//                 Row(
//                 children:[
//                   ConstrainedBox
//                     (constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width*0.2,maxHeight: 170),
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(vertical: 8),
//                       child: DropdownButtonFormField2(
//                           value: selectedProduct,
//                           isExpanded: true,
//                           //    dropdownStyleData: DropdownStyleData(maxHeight: 150),
//                           items:products.map((String product){
//                             return DropdownMenuItem(value:product,child:AutoSizeText(product,overflow: TextOverflow.visible));}).toList()
//                           , onChanged:(productselected)
//                       {
//                         setState(() {
//                           selectedProduct=productselected;
//                         });
//                       }
//                       ),
//                     ),
//                   ),
//                 SizedBox(
//                   width: MediaQuery.of(context).size.width * 0.2,
//                   child: Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: DropdownButton(
//                         value: selectedEmployee,
//                         isExpanded: true,
//                         items:employees.map((String emp){
//                           return DropdownMenuItem(value:emp,child:AutoSizeText(emp,overflow: TextOverflow.ellipsis));}).toList()
//                         , onChanged:(employi)
//                     {
//                       setState(() {
//                         selectedEmployee=employi;
//                       });
//                     }
//                     ),
//                   )
//                 ),
//                     SizedBox(
//                     width: 125,
//                     child: Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child:  DropdownButton(
//                     value:source ,
//                     items:[
//                     DropdownMenuItem(value:'phone',child: Text('phone'),),
//                     DropdownMenuItem(value:'whatsapp',child: Text('whatsapp'),),
//
//     ] , onChanged:(s) {
//
//                         setState(() {
//                           source = s;
//                         });
//                       }
//
//                     ),
//     ),
//     )
//
//                   ,
//                   SizedBox(
//                     width: 125,
//                     child: Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child:  DropdownButton(
//     value:requesttype ,
//     items:[
//     DropdownMenuItem(value:'Complain',child: Text('Complain'),),
//     DropdownMenuItem(value:'Service',child: Text('Service'),),
//     DropdownMenuItem(value:'Installation',child: Text('Installation')),
//     DropdownMenuItem(value:'demo',child:Text('demo')),
//     ] , onChanged:(servicetype) {
//
//                           setState(() {
//                             requesttype = servicetype;
//                           });
//                         }
//
//     ),
//                     ),
//                     ),
//                     ]
//                 ),
//
//                 ElevatedButton(onPressed: (){
//                   Searchcomplaints(
//                   //     fromDateController.text,toDateController.text,nameController.text,mobileController.text,selectedCity!,selectedDealer!,selectedCategory!,selectedProduct!,selectedEmployee!,requesttype!,source!
//                   //
//                       fromdate: fromDateController.text.isNotEmpty ? fromDateController.text : null,
//                       todate: toDateController.text.isNotEmpty ? toDateController.text : null,
//                       name: nameController.text.isNotEmpty ? nameController.text : null,
//                       phone: mobileController.text.length == 10 ? mobileController.text : null, // Ensure valid phone number
//                       village: selectedCity?.isNotEmpty == true ? selectedCity : null,
//                       dealer: selectedDealer?.isNotEmpty == true ? selectedDealer : null,
//                       category: selectedCategory?.isNotEmpty == true ? selectedCategory : null,
//                       product: selectedProduct?.isNotEmpty == true ? selectedProduct : null,
//                       allotedto: selectedEmployee?.isNotEmpty == true ? selectedEmployee : null,
//                       servicetype: requesttype?.isNotEmpty == true ? requesttype : null,
//                       source: source?.isNotEmpty == true ? source : null
//                       );
//                 }, child:Text("Search request"))
//               ],
//             ),
//           ),
//           AllotComplaint1(token: widget.token),
//         ],
//       ),
//     );
//   }
// }
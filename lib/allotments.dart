import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lmrepaircrmadmin/rowstate.dart';

class AllotComplaint extends StatefulWidget {
  const AllotComplaint({super.key, required this.token});
  final String token;
  @override
  State<AllotComplaint> createState() => _AllotComplaintState();
}
class _AllotComplaintState extends State<AllotComplaint> {

  final _formKey = GlobalKey<FormState>();
  DateTime? selectedDate;
  DateTime? selectedDate2;

  late List<Map<String, dynamic>> complaints;

// Map<String, Map<String, dynamic>> pendingUpdates = {};
  late List<String> recordid;
  late Future<void> _fetchDataFuture;

  List<Map<String, dynamic>>? records;
  List<Map<dynamic, dynamic>> allotments = [];
  List<String>? allotment;
  Map<String, String>? a;
  List<String>? statuses;
  String? selectedCategory;
  String? selectedProduct;
  String? brandselected;
  Map<String, RowState> rowStates = {};
  List<Map<String, dynamic>> newValues = [];


  List<String> selectedRecords = [];
  List<String> recordIds = [];


  var selectedEmployee;
  List<String> employees = [];
  String? allottedemployee;
  List<String> products = [];
  List<String> categories=[];
  //
  List<String> brand=[];
  String? status;
  Map<String, TextEditingController> wdateControllers = {};
  Map<String, TextEditingController> pdateControllers = {};


  @override
  void initState() {
    super.initState();
    _fetchDataFuture = fetchAllData();

    setState(() {
      allottedemployee = employees.isNotEmpty ? employees[0] : null;
      status = "Open";
      brandselected = brand.isNotEmpty ? brand[0] : null;
      // selectedCategory = categories.isNotEmpty ? categories[0] : null;
      // selectedProduct = products.isNotEmpty ? products[0] : null;

    });

  }
  @override
  void dispose() {
    wdateControllers.values.forEach((controller)=>controller.dispose());
    pdateControllers.values.forEach((controller)=>controller.dispose());
    super.dispose();
  }
  Future<void> fetchBrands() async {
    final response = await http.get(
      Uri.parse('https://limsonvercelapi2.vercel.app/api/fsproductservice?level=brands'),
      headers: {'Content-Type': 'application/json',
        'Authorization': 'Bearer ${widget.token}'},
    );
    if (response.statusCode == 200) {

      final List<dynamic> brandList = json.decode(response.body);
      print(brandList);
      setState(() {
        brand.addAll(brandList.map((brand) => brand.toString()));
        brandselected=brand[0];
        // selectedProduct = products[0];
      });
    }
    print(123);
    //print(brand);
  }
  Future<List<String>> fetchCategories(String Brand) async {
    final response = await http.get(
      Uri.parse('https://limsonvercelapi2.vercel.app/api/fsproductservice?level=categories&brand=$Brand'),
      headers: {'Content-Type': 'application/json',
        'Authorization': 'Bearer ${widget.token}'},
    );

    if (response.statusCode == 200) {
      print(2);
      //print(jsonDecode(response.body));
      final List<dynamic> categoryList = jsonDecode(response.body);

      return categoryList.map((category) => category.toString()).toList();
      // setState(() {
      //   categories.clear();
      //   categories.addAll(categoryList.map((category) => category.toString()));
      //   selectedCategory=categories[0];
      //   products.clear();
      //
      //
      // });

    }
    else
    {
      throw Exception('Failed to load categories');
    }

    //  print(categories);
  }

  Future<void> fetchProductsForCategory(String Brand,String categoryId) async {
    final response = await http.get(
      Uri.parse('https://limsonvercelapi2.vercel.app/api/fsproductservice?level=products&brand=$Brand&category=$categoryId'),
      headers: {'Content-Type': 'application/json',
        'Authorization': 'Bearer ${widget.token}'},
    );
    if (response.statusCode == 200) {
      final List<dynamic> productList = json.decode(response.body);
      setState(() {
        print(1);
        print(productList);
        products.addAll(productList.map((e) => e['name'].toString()));

        selectedProduct = products[0];
      });
    }
  }


  Future<void> updaterecord(String recordId) async
  {
    var url = "https://limsonvercelapi2.vercel.app/api/fsupdaterecord";

    Map<String, dynamic> fieldsToUpdate = {};
    for (var value in newValues) {
      fieldsToUpdate.addAll(value);
    }

    final body = {
      "id": recordId,
      "fields": fieldsToUpdate,
    };
    print(newValues);
    print(fieldsToUpdate);
    // print(1);
    // print(body);
    var resp = await http.patch(
        Uri.parse(url), headers: {'Content-Type': 'application/json','Authorization': 'Bearer ${widget.token}'},
        body: jsonEncode(body)
    );
    print(resp.statusCode);
  }

  Future<void> getCurrentallotmentandStatus(List<String> ids) async
  {
    var query = ids.join(',');
    var url = "https://limsonvercelapi2.vercel.app/api/fsupdaterecord?recordIds=$query";
    // final body = {
    //   "ids": ids,
    // };
    var resp = await http.get(Uri.parse(url),
      headers: {'Content-Type': 'application/json','Authorization': 'Bearer ${widget.token}'},

    );
    if (resp.statusCode == 200) {
      print(resp.body);
      Map<dynamic, dynamic> response = jsonDecode(resp.body);
      //print(response['currentDetails'].toString());
      List<dynamic> currentDetails = response['currentDetails'];
// Accessing the data
      for (var detail in currentDetails) {
        print(detail);
        allotments.add({
          {'id': detail['recordId']}: {
            'allotment': detail['currentAllotment'],
            'status': detail['currentStatus']
          }
        });
        //    print(6);

      }

    }

  }

  Future<void> fetchallemployees() async
  {
    var url = "https://limsonvercelapi2.vercel.app/api/fsemployeeservice?getKarigars=true";
    var resp = await http.get(Uri.parse(url),
      headers: {'Content-Type': 'application/json',
        'Authorization': 'Bearer ${widget.token}'},
    );

    if (resp.statusCode == 200) {
      final List<dynamic> empList = json.decode(resp.body);
      setState(() {
        employees.addAll(empList.map((emp) => emp['First name'].toString()));
        //    allottedemployee=employees[0];
      });
    }
    // try
    print(allotments);
    //     }
  }

  Future<void> fetchallrequests() async
  {
    var url = "https://limsonvercelapi2.vercel.app/api/fsfetchcomplaints";
    var resp = await http.get(Uri.parse(url),
      headers: {'Content-Type': 'application/json',
        'Authorization': 'Bearer ${widget.token}'},
    );
    // print(allotments);
    try {
      if (resp.statusCode == 200) {
        List<dynamic> jsonData = json.decode(resp.body);
        print(jsonData);
        records = jsonData.map((rec) {
          return {
            "id": rec["id"],
            "fields": {
              "Name": rec['fields']['Customer name'],
              "Brand": rec['fields']['Brand'],
              "product": rec['fields']['Product name'],
              "Category": rec['fields']['Category'],
              "phone": rec['fields']['Phone'],
              "city": rec['fields']['City'],
              "Purchase date": rec['fields']['Purchase date'],
              "warranty expiry date": rec['fields']['warranty expiry date']
            }
          };
        }).toList();
        recordid = jsonData.map((id) =>
            id['id'].toString()
        ).toList();
        // print(recordid);
        complaints =
            jsonData.map((data) => data['fields'] as Map<String, dynamic>)
                .toList();
      //  recordIds = data.map<String>((item) => item['id'].toString()).toList();

        // Fetch current statuses and allotments
        final currentValues = await fetchCurrentAllotments(recordid);

        // Initialize row states with fresh values
        initializeRowStates(jsonData, currentValues);


        //print(complaints['fields']);
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      throw Exception('Error fetching data: $e');
    }
  }

  Future<void> _selectwarrantyDate(BuildContext context,String id,DateTime Registerdate) async {
    final DateTime? picked = await showDatePicker(
      //     fieldLabelText: 'warranty expiry date',
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDate: Registerdate,

      initialDatePickerMode: DatePickerMode.day,
    );
    if (picked != null) {
      setState(() {
        selectedDate2 = picked;
        wdateControllers[id]!.text = "${picked.toLocal()}".split(' ')[0]; // Update the text field with the selected date
//updaterecord(id, fieldName, newValues)
        updateNewValues(id, {"warranty expiry date": "${picked.toLocal()}".split(' ')[0]});

//        newValues[id] = {"warranty expiry date": "${picked.toLocal()}".split(' ')[0]};
      });
    }
  }

  void updateNewValues(String recordId, Map<String, String> newValue) {
    if (!recordIds.contains(recordId)) {
      recordIds.add(recordId);
    }
    print(newValue);
    newValues.add({"id": recordId, ...newValue});
  }


  Future<void> _selectpurchaseDate(BuildContext context,String id,DateTime Registerdate) async {
    final DateTime? picked = await showDatePicker(
      //     fieldLabelText: 'warranty expiry date',
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      initialDate: Registerdate,

      initialDatePickerMode: DatePickerMode.day,
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
        pdateControllers[id]!.text = "${picked.toLocal()}".split(' ')[0];
        updateNewValues(id, {"Purchase Date": "${picked.toLocal()}".split(' ')[0]});

//        newValues.add(complaints[id],{"Purchase Date": "${picked.toLocal()}".split(' ')[0]});
//      newValues[id] = {"Purchase Date": "${picked.toLocal()}".split(' ')[0]};



        // Update the text field with the selected date
      });
    }
  }
  Future<Map<String, Map<String, String>>> fetchCurrentAllotments(List<String> ids) async {
    final response = await http.get(
      Uri.parse('https://limsonvercelapi2.vercel.app/api/fsupdaterecord?recordIds=${ids.join(',')}'),
        headers: {'Content-Type': 'application/json','Authorization': 'Bearer ${widget.token}'},

    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Map<String, Map<String, String>>.fromEntries(
        data['currentDetails'].map<MapEntry<String, Map<String, String>>>(
              (item) => MapEntry(
            item['recordId'].toString(),
            {
              'allotment': item['currentAllotment'].toString(),
              'status': item['currentStatus'].toString(),
            },
          ),
        ),
      );
    }
    return {};
  }
  Future<void> fetchAllData() async {
    //print(1);
    await fetchBrands();
    await fetchallemployees();
    await fetchallrequests();
   // await getCurrentallotmentandStatus(recordid);

    //initializeCategories();

  }
  void initializeRowStates(
      List<dynamic> complaintsData,
      Map<String, Map<String, String>> currentValues,
      ) {
    for (var complaint in complaintsData) {
      final id = complaint['id'].toString();
      final fields = complaint['fields'];

      rowStates[id] = RowState(
        selectedBrand: fields['Brand'] ?? '',
        phone: fields['Phone'] ?? '',
        initialWarrantyDate: fields['warranty expiry date'] ?? '',
        initialPurchaseDate: fields['Purchase date'] ?? '',
        currentAllotment: currentValues[id]?['allotment'] ?? employees.firstOrNull ?? '',
        currentStatus: currentValues[id]?['status'] ?? 'Open',
        selectedCategory: fields['Category'] ?? '',
        selectedProduct: fields['Product name'] ?? '',
        customerName: fields['Customer name'] ?? '',
        city: fields['city'] ?? '',
      );
    }
  }

  List<DataColumn> _buildColumns() {
    return const [
      DataColumn(label: Text('Customer Name')),
      DataColumn(label: Text('Allotted To')),
      DataColumn(label: Text('Status')),
      DataColumn(label: Text('Brand')),
      DataColumn(label: Text('Category')),
      DataColumn(label: Text('Product')),
      DataColumn(label: Text('Warranty Date')),
      DataColumn(label: Text('Purchase Date')),
    ];
  }
  DataRow _buildRow(String id) {
    final state = rowStates[id]!;
    return DataRow(cells: [
      DataCell(TextFormField(
        initialValue: state.customerName,
        onChanged: (value) => updateNewValues(id, {'Customer name': value}),
      )),
      DataCell(DropdownButton<String>(
        value: state.currentAllotment,
        items: employees.map((e) =>
            DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: (value) => setState(() {
          state.currentAllotment = value!;
          updateNewValues(id, {'allotted to': value});
        }),
      )),
      DataCell(DropdownButton<String>(
        value: state.currentStatus,
        items: ['Open', 'In Progress', 'Resolved'].map((status) =>
            DropdownMenuItem(value: status, child: Text(status))).toList(),
        onChanged: (value) => setState(() {
          state.currentStatus = value!;
          updateNewValues(id, {'Status': value});
        }),
      )),
            DataCell (
              StatefulBuilder(builder: (context, setState)  {
                if (brand.isEmpty) return CircularProgressIndicator(); // Wait for brands to load
                final currentBrand = state.selectedBrand;
                final validBrand = brand.contains(currentBrand) ? currentBrand : null;
                brandselected=validBrand;
                //List<String> newCategories = [];


                // final newCategories = await fetchCategories(newBrand);



                // Future<void> initializeCategories() async {
                //   newCategories = await fetchCategories(brandselected!);
                //   setState(() {
                //     categories = newCategories;
                //   });
                //   print(categories);
                // }
                //
                // if (validBrand != null && categories.isEmpty) {
                //   initializeCategories();
                // }
                //
                // print(validBrand);

                return DropdownButton(
                  value: validBrand,
                  items: brand.map((brand1) => DropdownMenuItem(
                    value: brand1,
                    child: Text(brand1),
                  )).toList(),
                  onChanged: (newBrand) {
                    setState(() {
                      state.selectedBrand = newBrand!;
                      state.categories = categories;
                      state.selectedCategory = categories.first;
                      state.products = products;
                      state.selectedProduct = products.first;

                      updateNewValues(id, {
                        'Brand': newBrand,
                        'Category': categories.first,
                        'Product': products.first,
                      });
                    });
                  },
                );
              }),
            ),
            DataCell(
              StatefulBuilder(builder: (context, setState) {
                print(3);
                //print(complaint['fields']['Category']);
                final currentCategory = state.selectedCategory;
                final validCategory = categories.contains(currentCategory) ? currentCategory : (categories.isNotEmpty ? categories[0] : 'No Category Available');
                selectedCategory = validCategory;
                print(validCategory);
                print(categories);
                // print(categories);
                return DropdownButton(
                  value:validCategory ,
                  items:categories.isNotEmpty
                      ? categories.map((category) => DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  )).toList() : [DropdownMenuItem(value: selectedCategory, child:Text(selectedCategory.toString()))],
                  onChanged: (newCategory) {
                    setState(() {
                      updateNewValues(id, {"Category": newCategory.toString()});
                      fetchProductsForCategory(brandselected!, newCategory.toString()); // Fetch products based on selected category
                    });
                  },
                );
              }),
            ),

            DataCell(
              StatefulBuilder(builder: (context, setState) {
                final currentProduct = state.selectedProduct;
                final validProduct = products.contains(currentProduct) ? currentProduct : (products.isNotEmpty ? products[0] : 'No Product Available');
                selectedProduct = validProduct;
                return DropdownButton(
                  value: validProduct,
                  items: products.isNotEmpty
                      ? products.map((product) => DropdownMenuItem(
                    value: product,
                    child: Text(product),
                  )).toList()
                      : [DropdownMenuItem(value: selectedProduct, child: Text(selectedProduct.toString()))],
                  onChanged: (newProduct) {
                    setState(() {
                      updateNewValues(id, {"product": newProduct.toString()});
                    });
                  },
                );
              }),
            ),
            DataCell(TextFormField(
              initialValue: state.phone,
              onChanged: (newvalue) {
                updateNewValues(id, {"phone": newvalue!});
                //     newValues.add({"id":complaint['id'],"phone": newvalue});

                //  newValues[complaint['id']] = {"phone": newvalue};
              },
            )),
            DataCell(Text(state.city)),
            DataCell(TextFormField(
                controller: wdateControllers[id],
                readOnly: true,
                onTap:()=>_selectwarrantyDate(context,id,DateTime.parse(state.initialWarrantyDate)))),

            DataCell(TextFormField(
                controller: pdateControllers[id],
                readOnly: true,
                onTap:()=>_selectpurchaseDate(context,id,DateTime.parse(state.initialPurchaseDate)))),

          ],
        );
      }


      // ... [Other cells same as before] ...


  @override
  Widget build(BuildContext context) {
    List<String> categories = [];


    return Scaffold(
        appBar: AppBar(title: Text('Allot Complaints'),
          actions: [
            ElevatedButton(
              onPressed: () {

                for(var id in recordIds) {
                  updaterecord(id);
                }
                // Update records with new values
                // for (var entry in newValues) {
                //
                //   if (selectedRecords.contains(entry.key))
                //     print(entry.value.keys);
                //     print(entry.value.values);
                //     updaterecord(entry.key);
                // }
              },
              child: Text('Save'),
            ),
          ],
        ),
        body: FutureBuilder<void>(
          future: fetchAllData(), // Use the future initialized in initState
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // print(2);
              //print(snapshot.connectionState.s\\)
              return Center(child: CircularProgressIndicator()); // Loading
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}')); // Error
              // Empty data
            }
            // else if (!snapshot.hasData || records!.isEmpty) {
            //   return Center(child: Text('No data available'));
            // }
            else {
              // Success: Build the DataTable
              //  List<Map<String, dynamic>> data = snapshot.data!;
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: DataTable(
                    columns: _buildColumns()
                      //DataColumn(label: Text('actions'))
                    ,
rows: recordid.map((id) => _buildRow(id)).toList(),
//                     rows: records!.map((complaint) {
//                       var allotment1 = allotments.firstWhere((a1) =>
//                       a1.keys.first['id'] == complaint['id'], orElse: () => {});
// //                print(allotment1);
//                       var currentAllotment = allotment1.isNotEmpty ? allotment1
//                           .values.first['allotment'] : null;
//                       var currentStatus = allotment1.isNotEmpty ? allotment1
//                           .values.first['status'] : null;
//
//                       if (!wdateControllers.containsKey(complaint['id'])) {
//                         wdateControllers[complaint['id']] = TextEditingController(text: complaint['fields']['warranty expiry date']);
//                       }
//
//                       if (!pdateControllers.containsKey(complaint['id'])) {
//                         pdateControllers[complaint['id']] = TextEditingController(text: complaint['fields']['Purchase date']);
//                       }

                    //   return DataRow(
                    //
                    //     cells: [
                    //
                    //       DataCell(TextFormField(
                    //         initialValue: complaint['fields']['Name'],
                    //         onChanged: (newvalue) {
                    //
                    //           updateNewValues(complaint['id'], {"Customer name": newvalue});
                    //
                    //
                    //
                    //         },
                    //
                    //       )),
                    //       DataCell(
                    //           StatefulBuilder(builder: (context, setState) {
                    //             return DropdownButton(
                    //                 value: currentAllotment ?? allottedemployee,
                    //                 //getCurrentallotmentandStatus(complaint['fields']),
                    //                 items: employees.map((emp) =>
                    //                     DropdownMenuItem(
                    //                         value: emp, child: Text(emp)))
                    //                     .toList(),
                    //                 onChanged: (newemp) {
                    //                   setState(() {
                    //                     allottedemployee = newemp as String;
                    //                     updateNewValues(complaint['id'], {"allotted to": allottedemployee!});
                    //
                    //                     // updaterecord(complaint['id'],'alloted to',allottedemployee!);
                    //                     //        newValues.add({"id":complaint["id"],"allotted to": allottedemployee!});
                    //                   });
                    //                   setState(() {
                    //                     currentAllotment = allottedemployee;
                    //                   });
                    //                 });
                    //           }
                    //           )),
                    //       DataCell(
                    //           StatefulBuilder(builder: (context, setState) {
                    //             if (currentStatus == null) {
                    //               currentStatus = "Open";
                    //             }
                    //             return DropdownButton(
                    //                 value: currentStatus.toString() ?? status,
                    //                 items: [
                    //                   DropdownMenuItem(
                    //                       child: Text("Open"), value: "Open"),
                    //                   DropdownMenuItem(
                    //                       child: Text("In progress"),
                    //                       value: "In progress"),
                    //                   DropdownMenuItem(
                    //                       child: Text("Resolved"),
                    //                       value: "Resolved")
                    //                 ],
                    //                 onChanged: (String? newStatus) {
                    //                   status = newStatus;
                    //                   updateNewValues(complaint['id'], {"Status": status!});
                    //                   //     newValues.add({"id":complaint["id"],"Status": status!});
                    //
                    //                   // newValues[complaint['id']] =
                    //                   // {"Status": status!};
                    //                   //updaterecord(complaint['id'],'Status', newStatus!);
                    //                   setState(() {
                    //                     currentStatus = status;
                    //                   });
                    //                 });
                    //           }
                    //           )),
                    //       DataCell (
                    //         StatefulBuilder(builder: (context, setState)  {
                    //           if (brand.isEmpty) return CircularProgressIndicator(); // Wait for brands to load
                    //           final currentBrand = complaint['fields']['Brand'] ?? '';
                    //           final validBrand = brand.contains(currentBrand) ? currentBrand : null;
                    //           brandselected=validBrand;
                    //           List<String> newCategories = [];
                    //
                    //
                    //           // final newCategories = await fetchCategories(newBrand);
                    //
                    //
                    //
                    //           Future<void> initializeCategories() async {
                    //             newCategories = await fetchCategories(brandselected!);
                    //             setState(() {
                    //               categories = newCategories;
                    //             });
                    //             print(categories);
                    //           }
                    //
                    //           if (validBrand != null && categories.isEmpty) {
                    //             initializeCategories();
                    //           }
                    //
                    //           print(validBrand);
                    //
                    //           return DropdownButton(
                    //             value: validBrand,
                    //             items: brand.map((brand1) => DropdownMenuItem(
                    //               value: brand1,
                    //               child: Text(brand1),
                    //             )).toList(),
                    //             onChanged: (newBrand) {
                    //               setState(() {
                    //                 updateNewValues(complaint['id'], {"Brand": newBrand.toString()});
                    //                 fetchCategories(newBrand.toString()); // Fetch categories based on selected brand
                    //               });
                    //             },
                    //           );
                    //         }),
                    //       ),
                    //       DataCell(
                    //         StatefulBuilder(builder: (context, setState) {
                    //           print(3);
                    //           print(complaint['fields']['Category']);
                    //           final currentCategory = complaint['fields']['Category'] ?? '';
                    //           final validCategory = categories.contains(currentCategory) ? currentCategory : (categories.isNotEmpty ? categories[0] : 'No Category Available');
                    //           selectedCategory = validCategory;
                    //           print(validCategory);
                    //           print(categories);
                    //           // print(categories);
                    //           return DropdownButton(
                    //             value:validCategory ,
                    //             items:categories.isNotEmpty
                    //                 ? categories.map((category) => DropdownMenuItem(
                    //               value: category,
                    //               child: Text(category),
                    //             )).toList() : [DropdownMenuItem(value: selectedCategory, child:Text(selectedCategory.toString()))],
                    //             onChanged: (newCategory) {
                    //               setState(() {
                    //                 updateNewValues(complaint['id'], {"Category": newCategory.toString()});
                    //                 fetchProductsForCategory(brandselected!, newCategory.toString()); // Fetch products based on selected category
                    //               });
                    //             },
                    //           );
                    //         }),
                    //       ),
                    //
                    //       DataCell(
                    //         StatefulBuilder(builder: (context, setState) {
                    //           final currentProduct = complaint['fields']['product'] ?? '';
                    //           final validProduct = products.contains(currentProduct) ? currentProduct : (products.isNotEmpty ? products[0] : 'No Product Available');
                    //           selectedProduct = validProduct;
                    //           return DropdownButton(
                    //             value: validProduct,
                    //             items: products.isNotEmpty
                    //                 ? products.map((product) => DropdownMenuItem(
                    //               value: product,
                    //               child: Text(product),
                    //             )).toList()
                    //                 : [DropdownMenuItem(value: selectedProduct, child: Text(selectedProduct.toString()))],
                    //             onChanged: (newProduct) {
                    //               setState(() {
                    //                 updateNewValues(complaint['id'], {"product": newProduct.toString()});
                    //               });
                    //             },
                    //           );
                    //         }),
                    //       ),
                    //       DataCell(TextFormField(
                    //         initialValue: complaint['fields']['phone'],
                    //         onChanged: (newvalue) {
                    //           updateNewValues(complaint['id'], {"phone": newvalue!});
                    //           //     newValues.add({"id":complaint['id'],"phone": newvalue});
                    //
                    //           //  newValues[complaint['id']] = {"phone": newvalue};
                    //         },
                    //       )),
                    //       DataCell(Text(complaint['fields']['city'])),
                    //       DataCell(TextFormField(
                    //           controller: wdateControllers[complaint['id']],
                    //           readOnly: true,
                    //           onTap:()=>_selectwarrantyDate(context,complaint['id'],DateTime.parse(complaint['fields']['warranty expiry date'].toString())))),
                    //
                    //       DataCell(TextFormField(
                    //           controller: pdateControllers[complaint['id']],
                    //           readOnly: true,
                    //           onTap:()=>_selectpurchaseDate(context,complaint['id'],DateTime.parse(complaint['fields']['Purchase date'].toString())))),
                    //
                    //     ],
                    //   );
                    // }).toList(),
                  ),
                ),
              );
            }
          },
        )
    );
  }
}
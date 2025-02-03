import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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

  List<String> selectedRecords = [];
  List<String> recordIds = [];
  //Map<String, Map<String, String>> newValues = {};
 // Map<String, List<Map<String, String>>> newValues = {};
  List<Map<String,String>> newValues=[];


  var selectedEmployee;
  List<String> employees = [];
  String? allottedemployee;
  List<String> products = ['Select a product'];
  List<String> categories = ['Select a category'];
  List<String> brand=['Select a brand'];
  String? status;
  Map<String, TextEditingController> wdateControllers = {};
  Map<String, TextEditingController> pdateControllers = {};


  @override
  void initState() {
    super.initState();
    _fetchDataFuture = fetchAllData();

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
      setState(() {
        brand.addAll(brandList.map((brand) => brand.toString()));
        brandselected=brand[0];
        // selectedProduct = products[0];
      });
    }
  }
  Future<void> fetchCategories(String Brand) async {
    final response = await http.get(
      Uri.parse('https://limsonvercelapi2.vercel.app/api/fsproductservice?level=categories&brand=$Brand'),
      headers: {'Content-Type': 'application/json',
      'Authorization': 'Bearer ${widget.token}'},
    );
    if (response.statusCode == 200) {
      print(jsonDecode(response.body));
      final List<dynamic> categoryList = jsonDecode(response.body);
      setState(() {
        categories.addAll(categoryList.map((category) => category.toString()));
        selectedCategory=categories[0];
      });
    }
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
    print(allotments);
    try {
      if (resp.statusCode == 200) {
        List<dynamic> jsonData = json.decode(resp.body);
        print(jsonData);
        records = jsonData.map((rec) {
          return {
            "id": rec["id"],
            "fields": {
              "Name": rec['fields']['Customer name'],
              "product": rec['fields']['Product name'],
              "category": rec['fields']['category'],
              "phone": rec['fields']['Phone'],
              "city": rec['fields']['City'],
              "Purchase Date": rec['fields']['Purchase Date'],
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
  Future<void> fetchAllData() async {
    //print(1);
    await fetchallemployees();
    await fetchallrequests();
    await getCurrentallotmentandStatus(recordid);
    await fetchBrands();
  //  print(1.5);
  }

  @override
  Widget build(BuildContext context) {
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
          future: _fetchDataFuture, // Use the future initialized in initState
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              print(2);
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
                    columns: const [
                    //  DataColumn(label: Text('Select')),
                      DataColumn(label: Text('Customer Name')),
                      DataColumn(label: Text('Allotted To')),
                      DataColumn(label: Text("Complain Status")),
                      DataColumn(label: Text('Brand Name', softWrap: true,
                        overflow: TextOverflow.ellipsis,)),
                      DataColumn(label: Text('category', softWrap: true,
                        overflow: TextOverflow.ellipsis,)),
                      DataColumn(label: Text('Product Name', softWrap: true,
                        overflow: TextOverflow.ellipsis,)),
                      DataColumn(label: Text('Phone Number')),
                      DataColumn(label: Text('City', softWrap: true,
                        overflow: TextOverflow.visible,)),
                      DataColumn(label: Text('Warranty Expiry', softWrap: true,
                        overflow: TextOverflow.ellipsis,)),
                      DataColumn(label: Text('Purchase Date', softWrap: true,
                        overflow: TextOverflow.ellipsis,)),
                      //DataColumn(label: Text('actions'))
                    ],
                    rows: records!.map((complaint) {
                      var allotment1 = allotments.firstWhere((a1) =>
                      a1.keys.first['id'] == complaint['id'], orElse: () => {});
//                print(allotment1);
                      var currentAllotment = allotment1.isNotEmpty ? allotment1
                          .values.first['allotment'] : null;
                      var currentStatus = allotment1.isNotEmpty ? allotment1
                          .values.first['status'] : null;

                      if (!wdateControllers.containsKey(complaint['id'])) {
                        wdateControllers[complaint['id']] = TextEditingController(text: complaint['fields']['warranty expiry date']);
                      }

                      if (!pdateControllers.containsKey(complaint['id'])) {
                        pdateControllers[complaint['id']] = TextEditingController(text: complaint['fields']['Purchase Date']);
                      }

                      return DataRow(

                        cells: [
                          // DataCell(Checkbox(
                          //   value: selectedRecords.contains(complaint['id']),
                          //   onChanged: (bool? value) {
                          //     setState(() {
                          //       if (value!) {
                          //         selectedRecords.add(complaint['id']);
                          //       } else {
                          //         selectedRecords.remove(complaint['id']);
                          //       }
                          //     });
                          //   },
                          // )),
                          // DataCell(Text(complaint['Customer name'])),
                          DataCell(TextFormField(
                            initialValue: complaint['fields']['Name'],
                            onChanged: (newvalue) {



                          //    newValues.add({"id":complaint['id'],"Customer name": newvalue!});
                              updateNewValues(complaint['id'], {"Customer name": newvalue});


                              // updaterecord(
                              //     complaint['id'], 'Customer name', newvalue);
                              //
                            },

                          )),
                          DataCell(
                              StatefulBuilder(builder: (context, setState) {
                                return DropdownButton(
                                    value: currentAllotment ?? allottedemployee,
                                    //getCurrentallotmentandStatus(complaint['fields']),
                                    items: employees.map((emp) =>
                                        DropdownMenuItem(
                                            value: emp, child: Text(emp)))
                                        .toList(),
                                    onChanged: (newemp) {
                                      setState(() {
                                        allottedemployee = newemp as String;
                                        updateNewValues(complaint['id'], {"allotted to": allottedemployee!});

                                        // updaterecord(complaint['id'],'alloted to',allottedemployee!);
                                //        newValues.add({"id":complaint["id"],"allotted to": allottedemployee!});
                                      });
                                      setState(() {
                                        currentAllotment = allottedemployee;
                                      });
                                    });
                              }
                              )),
                          DataCell(
                              StatefulBuilder(builder: (context, setState) {
                                return DropdownButton(
                                    value: currentStatus.toString() ?? status,
                                    items: [
                                      DropdownMenuItem(
                                          child: Text("Open"), value: "Open"),
                                      DropdownMenuItem(
                                          child: Text("In progress"),
                                          value: "In progress"),
                                      DropdownMenuItem(
                                          child: Text("Resolved"),
                                          value: "Resolved")
                                    ],
                                    onChanged: (String? newStatus) {
                                      status = newStatus;
                                      updateNewValues(complaint['id'], {"Status": status!});
                                 //     newValues.add({"id":complaint["id"],"Status": status!});

                                      // newValues[complaint['id']] =
                                      // {"Status": status!};
                                      //updaterecord(complaint['id'],'Status', newStatus!);
                                      setState(() {
                                        currentStatus = status;
                                      });
                                    });
                              }
                              )),
                          DataCell(
                            StatefulBuilder(builder: (context, setState) {
                              return DropdownButton(
                                value: complaint['fields']['brand'],
                                items: brand.map((brand) => DropdownMenuItem(
                                  value: brand,
                                  child: Text(brand),
                                )).toList(),
                                onChanged: (newBrand) {
                                  setState(() {
                                    updateNewValues(complaint['id'], {"brand": newBrand.toString()});
                                    fetchCategories(newBrand.toString()); // Fetch categories based on selected brand
                                  });
                                },
                              );
                            }),
                          ),
                          DataCell(
                            StatefulBuilder(builder: (context, setState) {
                              return DropdownButton(
                                value: complaint['fields']['category'],
                                items: categories.map((category) => DropdownMenuItem(
                                  value: category,
                                  child: Text(category),
                                )).toList(),
                                onChanged: (newCategory) {
                                  setState(() {
                                    updateNewValues(complaint['id'], {"category": newCategory.toString()});
                                    fetchProductsForCategory(brandselected!, newCategory.toString()); // Fetch products based on selected category
                                  });
                                },
                              );
                            }),
                          ),

                          DataCell(
                            StatefulBuilder(builder: (context, setState) {
                              return DropdownButton(
                                value: complaint['fields']['product'],
                                items: products.map((product) => DropdownMenuItem(
                                  value: product,
                                  child: Text(product),
                                )).toList(),
                                onChanged: (newProduct) {
                                  setState(() {
                                    updateNewValues(complaint['id'], {"product": newProduct.toString()});
                                  });
                                },
                              );
                            }),
                          ),
                          DataCell(TextFormField(
                            initialValue: complaint['fields']['phone'],
                            onChanged: (newvalue) {
                              updateNewValues(complaint['id'], {"phone": newvalue!});
                         //     newValues.add({"id":complaint['id'],"phone": newvalue});

                            //  newValues[complaint['id']] = {"phone": newvalue};
                            },
                          )),
                          DataCell(Text(complaint['fields']['city'])),
                          DataCell(TextFormField(
                              controller: wdateControllers[complaint['id']],
                      readOnly: true,
                              onTap:()=>_selectwarrantyDate(context,complaint['id'],DateTime.parse(complaint['fields']['warranty expiry date'].toString())))),

                          DataCell(TextFormField(
                              controller: pdateControllers[complaint['id']],
                              readOnly: true,
                              onTap:()=>_selectpurchaseDate(context,complaint['id'],DateTime.parse(complaint['fields']['warranty expiry date'].toString())))),

                        ],
                      );
                    }).toList(),
                  ),
                ),
              );
            }
          },
        )
    );
  }
}
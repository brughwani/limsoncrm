import 'dart:convert';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lmrepaircrmadmin/employeeprovider.dart';
import 'package:provider/provider.dart';
import 'dealerfetcher.dart';

class AddEmployee extends StatefulWidget {
  AddEmployee({super.key,required this.token});

  String token;

  @override
  State<AddEmployee> createState() => _AddEmployeeState();
}

class _AddEmployeeState extends State<AddEmployee> {
  TextEditingController mobile=TextEditingController();
  TextEditingController phoneNumber=TextEditingController();
  TextEditingController password=TextEditingController();
  TextEditingController Name=TextEditingController();
  TextEditingController firstName=TextEditingController();
  TextEditingController lastName=TextEditingController();
  TextEditingController address=TextEditingController();
  TextEditingController personalMobileNumber=TextEditingController();
  TextEditingController salary=TextEditingController();

  String? selectedValue;

  Future<List<Map<String, dynamic>>>? _futureEmployees;


  @override
  TabController? tabController;
  String? selecteddealer;
  String? selectedcity;
  List<String>? locations;
  List<String>? dealers;
  final List<String> options = [
    "First name",
    "Last name",
    "address",
    "Phone",
    "salary",
    "Role",
  ];



  @override
  void initState()
  {
    super.initState();
    loadlocations();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final employeeProvider = context.read<EmployeeProvider>();
      employeeProvider.loadInitialCheckboxStatuses(options);
    });
     }

  Future<void> loadlocations () async
  {
    try {
      var getlocations = await dealerfetcher.fetchLocation(widget.token);
      setState(() {
        locations=getlocations;
      });
    }
    catch(e)
    {
      AlertDialog(title: Text("location"),content: Text("Error in getting locations $e"),);
    }
  }

  Future<void> loaddealer (String loc) async
  {
    try
        {
          var getdealer=await dealerfetcher.fetchDealer(loc,widget.token);
          setState(() {
            dealers=getdealer;
          });
        }
        catch(e)
    {
      AlertDialog(title: Text("dealer"),content: Text("error in getting dealer data $e"));
    }
  }


  Future<void> createRecord(String firstName, String lastName, String address, String phoneNumber, String password, String personalMobileNumber, String salary, String role) async {
    final String url = 'https://limsonvercelapi2.vercel.app/api/fsemployeeservice';
    // Prepare the data to be sent
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${widget.token}',
      },
      body: jsonEncode(
        { "fields":
         {
          "First name": firstName,
          "Last name": lastName,
          "Address": address,
          "Phone Number": phoneNumber,
          "Password": password,
          "Personal Mobile Number": personalMobileNumber,
          "salary": salary,
          "Role": role,
        }
        }
      ),

    );
//
// print(jsonEncode({
//   "First Name": firstName,
//   "Last Name": lastName,
//   "Address": address,
//   "Phone Number": phoneNumber,
//   "Password": password,
//   "Personal Mobile Number": personalMobileNumber,
//   "Salary": salary,
// }));
    if (response.statusCode == 200) {
      
      print('Record created successfully: ${response.body}');
    } else {
      print('Failed to create record: ${response.statusCode} ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isVertical = MediaQuery.of(context).orientation == Orientation.portrait;

    return DefaultTabController(
      length: 2,
      child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child:TabBarView(
      controller: tabController,
      children:[
                  Column(
                    children: [
                      TextFormField(
                        controller:firstName,
                        decoration: InputDecoration(labelText: 'First Name')
                      ),
                      TextFormField(
                        controller:lastName,
                        decoration: InputDecoration(labelText: 'Last Name')),
                      TextFormField(
                        controller:phoneNumber,
                        decoration: InputDecoration(labelText: 'Mobile Number'),
                      keyboardType: TextInputType.phone),
                      TextFormField(
                        controller: address,
                        decoration: InputDecoration(labelText: 'Address'),
                      keyboardType: TextInputType.streetAddress),
                      TextFormField(
                        controller: password,
                        decoration: InputDecoration(labelText: 'password'),
                      keyboardType: TextInputType.visiblePassword),
                      TextFormField(
                        controller: personalMobileNumber,
                        decoration: InputDecoration(labelText: 'Personal Mobile Number'),
                      keyboardType: TextInputType.phone),
                      TextFormField(
                        controller: salary,
                        decoration: InputDecoration(labelText: 'Salary'),
                      keyboardType: TextInputType.number),
                       DropdownButton(
                        hint: Text('Select Role'),
                        value: selectedValue,
                        items: [
                        DropdownMenuItem(
                          child: Text('Karigar'),
                          value: 'Karigar',
                          ),
                        DropdownMenuItem(
                          child: Text('Support'),
                          value: 'Support',
                          ),

                                    ], onChanged: (value) {
                      setState(() {
                        selectedValue = value;
                      });
                                    },),

                      ElevatedButton(onPressed: (){
                        createRecord(firstName.text.toString(), lastName.text.toString(), address.text.toString(), phoneNumber.text.toString(), password.text.toString(), personalMobileNumber.text.toString(), salary.text.toString(), selectedValue.toString());
                      }, child: Text('Add Employee')),
                    ],
                  ),
        SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [

             Text("Fields to be used in filtering"),

    Consumer<EmployeeProvider>(
      builder:(context,employeeProvider,_)
      {
        return  Column(
        children: [
          SizedBox(
              width: 300,
              height: 300,
              child: ListView(
                children: options.map((option) {
                  return CheckboxListTile(
                    title: Text(option),
                    value: employeeProvider.selectedFields.contains(option),
                    onChanged: (bool? value) {
                      setState(() {
                        employeeProvider.toggleFieldSelection(option,value!);// print(item['label']);
                      }
                      );
                    },
                  );
                }).toList(),
              ),
            ),
          isVertical ? SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: FutureBuilder(
              future: _futureEmployees, // The async method
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || (snapshot.data as List).isEmpty) {
                  return const Center(child: Text('No employees found.'));
                }
                // Use the fetched employee data
                final employees = snapshot.data as List<Map<String, dynamic>>;
                return DataTable(
                  columns: employeeProvider.selectedFields
                      .map((field) => DataColumn(label: Text(field)))
                      .toList(),
                  rows: employees.map((emp) {
                    return DataRow(
                      cells: employeeProvider.selectedFields.map((field) {
                        return DataCell(
                          Text(emp[field]?.toString() ?? 'N/A'),
                        );
                      }).toList(),
                    );
                  }).toList(),
                );
              },
            ),


          ):

          SingleChildScrollView(

            child: FutureBuilder(
              future: _futureEmployees, // The async method
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || (snapshot.data as List).isEmpty) {
                  return const Center(child: Text('No employees found.'));
                }
                // Use the fetched employee data
                final employees = snapshot.data as List<Map<String, dynamic>>;
                return DataTable(
                  columns: employeeProvider.selectedFields
                      .map((field) => DataColumn(label: Text(field)))
                      .toList(),
                  rows: employees.map((emp) {
                    return DataRow(
                      cells: employeeProvider.selectedFields.map((field) {
                        return DataCell(
                          Text(emp[field]?.toString() ?? 'N/A'),
                        );
                      }).toList(),
                    );
                  }).toList(),
                );
              },
            ),
          ),
                 ElevatedButton(onPressed: (){


            _futureEmployees=employeeProvider.fetchEmployees(widget.token,employeeProvider.selectedFields) as Future<List<Map<String, dynamic>>>?;



           // print(selectedAttributes.runtimeType);

            //print(selectedItems.keys.groupListsBy(selectedItems.values.toList()[i]).);
          }, child:Text("Search Employee")),
        ],
      );

      } ,

    ),

            ],
          ),
        ),
      )
                  ],
                ),
              ),


    Material(
    color: Theme.of(context).primaryColor,
    child: TabBar(
    controller: tabController,
    labelColor: Colors.white,
    unselectedLabelColor: Colors.grey[300],
    tabs: const [
    Tab(icon: Icon(Icons.add), text: 'Add employee'),
    Tab(icon: Icon(Icons.search), text: 'Search employee'),
    ],
    )
    )
    ]
      )
    );
  }
}
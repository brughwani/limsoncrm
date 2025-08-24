import 'dart:js_interop';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/foundation.dart';
import 'addemployee.dart';
import 'package:excel/excel.dart';
import 'package:flutter/widgets.dart' as w;
//import 'dart:html' as html;
//import 'web_imports.dart';

// Assuming these files exist in your project
import 'package:lmrepaircrmadmin/addemployee.dart'; // AddEmployee widget
import 'complaintdatanotifier.dart'; // ComplaintDataNotifier class
import 'rowstate.dart'; // RowState class
import 'cellwidget.dart'; // CellWidget class
import 'package:web/web.dart';
import 'package:web/src/dom.dart' as web;


class CRMDashboard extends StatefulWidget {
  final String token;

  CRMDashboard({required this.token});

  @override
  State<CRMDashboard> createState() => _CRMDashboardState();
}

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

  bool _isDownloading = false;




  var requesttypes = ['Installation', 'Demo', 'Service', 'Complain'];



// Lists for UI dropdowns

  List<String> employeesforUI = ['Select an employee', 'Not assigned'];

  List<String> productsForUI = ['Select a product'];

  List<String> locationsForUI = ['Select a location'];

  List<String> dealerNamesForUI = ['Select a dealer'];

  List<String> categoriesForUI = ['Select a category'];

  List<String> brandsForUI = ['Select a brand'];

  
  final TextEditingController phone=TextEditingController();

  final TextEditingController fromDateController = TextEditingController();

  final TextEditingController toDateController = TextEditingController();

  final TextEditingController nameController = TextEditingController();

  final TextEditingController mobileController = TextEditingController();



  TabController? _tabController;


  String? _selectedSortKey;
  bool _isSortAscending = true; // Default to ascending

// Add a list of sortable keys
  final List<String> _sortableKeys = ['Date of Complaint', 'Visit Date', 'Solve Date'];


  @override

  void initState() {

    super.initState();

    _tabController = TabController(length: 2, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {

      final notifier = Provider.of<ComplaintDataNotifier>(context, listen: false);

// notifier.fetchInitialData(widget.token);

      notifier.fetchInitialData(widget.token).then((_) {

// Apply filters AFTER data is loaded - ADD THIS

        notifier.applyFilters();

      });

// print(1);

    });

    fetchLocationForUI();

    fetchCategoriesForUI('Select a brand');

//fetchEmployees();

  }

// Future<void> fetchEmployees() async {

// final response = await http.get(

// Uri.parse('https://limsonvercelapi2.vercel.app/api/fsemployeeservice?getKarigars=true'),

// headers: {'Content-Type': 'application/json',

// 'Authorization': 'Bearer ${widget.token}'},

// );

// if (response.statusCode == 200) {

// final List<dynamic> empList = json.decode(response.body);

// setState(() {

// employeesforUI.addAll(empList.map((emp) => emp['First name'].toString()));

// selectedEmployee=employeesforUI[0];

// });

// }

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

    await fetchLocationForUI(); // Locations

    if (brandsForUI.isNotEmpty) {

      await fetchCategoriesForUI(brandsForUI[0]);

    }



// Reapply empty filters

// final notifier = Provider.of<ComplaintDataNotifier>(context, listen: false);

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
  Future<void> _downloadExcel(List<RowState> data) async {
    if (data.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: w.Text('No data to download.')),
      );
      return;
    }

    setState(() {
      _isDownloading = true;
    });

    try {
      // 1. Create the Excel file in memory
      final excel = Excel.createExcel();
      final sheet = excel['Sheet1'];

      // 2. Define and add the header row
      final headers = [
        'Customer', 'Phone Number', 'Allotted To', 'Status', 'Brand', 'Category',
        'Product', 'Warranty Date', 'Purchase Date', 'Date of Complaint', 'Dealer', 'Location'
      ];
      sheet.insertRowIterables(headers.map((h) => TextCellValue(h)).toList(), 0);

      // 3. Add data rows from your state
      for (var i = 0; i < data.length; i++) {
        final row = data[i];
        final rowData = [
          row.name, row.phoneNumber, row.employee, row.status, row.brand,
          row.category, row.product, row.warrantyDate, row.purchaseDate,
          row.complaintDate, row.dealer, row.village
        ];
        // Convert all data to TextCellValue to prevent formatting issues
        final dataCells = rowData.map((cell) => TextCellValue(cell ?? '')).toList();
        sheet.insertRowIterables(dataCells, i + 1);
      }

      // 4. Encode the file into bytes
      final excelBytes = excel.encode();
      if (excelBytes == null) {
        throw Exception('Error encoding the Excel file.');
      }

      // 5. Trigger the download using the `package:web` library
      if (kIsWeb) {
        final fileName = 'crm_data_${DateFormat('yyyy-MM-dd').format(DateTime.now())}.xlsx';

        // Create a Blob from the byte data with the correct MIME type
        final blob = Blob(
          [excelBytes.toJSBox].toJS,
          BlobPropertyBag(type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'),
        );

        // Create a URL for the Blob
        final url =URL.createObjectURL(blob);

        // Create an anchor element to trigger the download
        final anchor = document.createElement('a') as HTMLAnchorElement
          ..href = url
          ..style.display = 'none'
          ..download = fileName;

        // Append to the DOM, click, and then remove
        document.body!.append(anchor);
        anchor.click();
        document.body!.removeChild(anchor);

        // Release the object URL
        URL.revokeObjectURL(url);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: w.Text('Download complete!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: w.Text('Download is only supported on the web.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: w.Text('Failed to download: $e')),
      );
    } finally {
      setState(() {
        _isDownloading = false;
      });
    }
  }


  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {

    final DateTime? picked = await showDatePicker(

      context: context,

      firstDate: DateTime(2000),

      lastDate: DateTime(2100),

      initialDate: DateTime.tryParse(controller.text) ?? DateTime.now(),

    );

    if (picked != null) {

      controller.text = DateFormat('dd-MM-yyyy').format(picked);

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

    return Scaffold(

      appBar: AppBar(

        title: const w.Text('CRM Dashboard'),

        actions: [

          Consumer<ComplaintDataNotifier>(

            builder: (context, notifier, child) {

              return IconButton(

                icon: notifier.isSaving

                    ? const SizedBox(

                    width: 20, height: 20,

                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.blue))

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

                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.blue))

                    : const Icon(Icons.refresh),

                onPressed: notifier.isLoading ? null : () => notifier.fetchInitialData(widget.token),

              );

            },

          ),
          // --- NEW DOWNLOAD BUTTON ---
          Consumer<ComplaintDataNotifier>(
            builder: (context, notifier, child) {
              return IconButton(
                icon: _isDownloading
                    ? const SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.blue))
                    : const Icon(Icons.download),
                onPressed: _isDownloading || notifier.orderedRows.isEmpty
                    ? null
                    : () => _downloadExcel(notifier.orderedRows),
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
          // CRITICAL: Force a unique print string to ensure this code path is executing
          print("******** NEW CONSUMER BUILD DETECTED ********");
          print("[UI-DEBUG-CONSUMER] BUILD triggered. Consumer's Notifier Hash: ${notifier.hashCode}");
          print("[UI-DEBUG-CONSUMER]   notifier.isLoading: ${notifier.isLoading}"); // THIS IS THE KEY VALUE
          print("[UI-DEBUG-CONSUMER]   notifier.orderedRows.length: ${notifier.orderedRows.length}");
          print("*********************************************");



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

                    const w.Text('Search Filters:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

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

                    _buildDropdown(
                      value: _selectedSortKey,
                      items: _sortableKeys,
                      hint: 'Sort by date',
                      onChanged: (value) {
                        setState(() {
                          _selectedSortKey = value;
                          if (value != null) {
                            // Call the new sort method in the notifier
                            notifier.sortComplaints(_selectedSortKey!, _isSortAscending);
                          }
                        });
                      },
                    ),

                    Row(

                      children: [

                        ElevatedButton(onPressed: _clearFilters, child: w.Text("Clear filters")),

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

                          child: const w.Text('Search Complaints'),

                        ),],

                    ),



                    const SizedBox(height: 24),

                    if (notifier.isLoading)

                      const Center(child: CircularProgressIndicator())

                    else if (notifier.orderedRows.isEmpty)

                      const Center(child: w.Text("No complaints found for the selected filters."))

                    else

                      SingleChildScrollView(

                        scrollDirection: Axis.horizontal,

                        child: DataTable(

                          columns: const [

                            DataColumn(label: w.Text('Customer')),

                            DataColumn(label: w.Text('Address')),
                            DataColumn(label: w.Text('Phone')),


                            DataColumn(label: w.Text('Allotted To')),

                            DataColumn(label: w.Text('Status')),

                            DataColumn(label: w.Text('Brand')),

                            DataColumn(label: w.Text('Category')),

                            DataColumn(label: w.Text('Product')),

                            DataColumn(label: w.Text('Warranty Date')),

                            DataColumn(label: w.Text('Purchase Date')),
                            DataColumn(label: w.Text('Date of Complaint')),

                            DataColumn(label: w.Text('Visit Date')),
                            DataColumn(label: w.Text('Solve Date')),


                            DataColumn(label: w.Text('Dealer')),

                            DataColumn(label: w.Text('Location')),

                          ],

                          rows: notifier.orderedRows.map((rowState) => _buildDataRow(context, rowState)).toList(),

                        ),

                      ),

                  ],

                ),

              ),

    // Add Employee Tab

              AddEmployee(token: widget.token),

    // Other Allotments Tab

    // const Center(child: Text('Other Allotments content will go here.')),

            ],

          );

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

        hint: w.Text(

          value ?? hint,

          style: TextStyle(fontSize: 14, color: Theme.of(context).hintColor),

        ),

        items: items.map((item) => DropdownMenuItem(

          value: item,

          child: w.Text(item, style: const TextStyle(fontSize: 14)),

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

    String _formatDate(String dateString) {
      if (dateString == null || dateString.isEmpty) {
        return '';
      }
      try {
        final date = DateTime.tryParse(dateString);
        if (date != null) {
          return DateFormat('dd-MM-yyyy').format(date);
        }
      } catch (e) {
        // Handle parsing errors gracefully
        print('Error formatting date: $e');
      }
      return dateString; // Return original string if parsing fails
    }



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
          CellWidget<String>(
            isTextField: true,

            value: state.address,

            controller: state.addressController,

            onChanged: state.updateaddress,

          )
      ),

      DataCell(
       CellWidget<String>(
         isTextField: true,

         value: state.phoneNumber,

         controller: state.phoneController,

         onChanged: state.updatephone,

       )
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

        Consumer<ComplaintDataNotifier>(

          builder: (context,notifier, _) {

            return CellWidget<String>(

              isDropdown: true,
              value: notifier.orderedRows.contains(state) ? state.status : 'Open',

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
        ChangeNotifierProvider.value(value: state,



       child: Consumer<RowState>(

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

      )),



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
       ChangeNotifierProvider.value(value: state,
        child: Consumer<RowState>(

          builder: (context, state, _) {

            return CellWidget(

              // isTextField: true,
               isenabled: false,
              isDate: true,
              value: _formatDate(state.complaintDate),
              // onChanged: (state.updateComplaintDate),

              // isDate: true,

            );

          },

        ),
      )),

      // DataCell for Visit Date (now using a controller)
      DataCell(
        InkWell(
          onTap: () => _selectDate(context, state.visitDateController), // Now can be edited
          child: AbsorbPointer(
            child: TextField(
              controller: state.visitDateController,
              readOnly: true,
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
        ),
      ),

      // DataCell for Solve Date (now using a controller)
      DataCell(
        InkWell(
          onTap: () => _selectDate(context, state.solveDateController), // Now can be edited
          child: AbsorbPointer(
            child: TextField(
              controller: state.solveDateController,
              readOnly: true,
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
        ),
      ),

      DataCell(

        ChangeNotifierProvider.value(

          value: state,

     child:Consumer<RowState>(

          builder: (context, state, _) {

            return CellWidget<String>(
            // isenabled: true,

              isDropdown: true,

              value: state.village,

              options: state.fetchedLocations,

              onChanged: state.updateVillage,

            );

          },

        ),

      ))

      ,



      DataCell(

        ChangeNotifierProvider.value(

          value: state,



   child:     Consumer<RowState>(

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


      )


      ]);



  }

}
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'rowstate.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// Import your RowState model

class ComplaintDataNotifier extends ChangeNotifier {
  final String token;
  Map<String, RowState> _rowStates = {};
  List<String> _employees = [];
  List<String> _brands = [];

  List<String> _recordIds = []; // Store the order
  bool _isLoading = false;
  bool _isSaving = false;
  final List<Map<String, dynamic>> newValues = []; // Keep track of changes

  ComplaintDataNotifier({required this.token}) {
    fetchInitialData(); // Fetch data on creation
  }

  // Getters
  Map<String, RowState> get rowStates => _rowStates;
  List<RowState> get orderedRows => _recordIds.map((id) => _rowStates[id]!).toList();
  List<String> get employees => _employees;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  List<String> get brands => _brands;


  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token'
  };


  // --- Fetching Logic ---
  Future<void> fetchInitialData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Fetch employees first (or pass them if fetched globally)
      await Future.wait([
        _fetchEmployees(),
        _fetchBrands(), // <-- Call fetch brands here
      ]);

      // Then fetch complaints which might depend on employees list for defaulting
      await _fetchComplaints();

    } catch (e) {
      print("Error fetching initial data: $e");
      // Handle error state appropriately
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _fetchEmployees() async {
    // Your existing _fetchEmployees logic
    try {
      final response = await http.get(
        Uri.parse('https://limsonvercelapi2.vercel.app/api/fsemployeeservice?getKarigars=true'),
        headers: _headers,
      );
      if(response.statusCode == 200) {
        _employees = List<String>.from(json.decode(response.body).map((e) => e['First name'].toString()).toList());
      } else {
        _employees = ['Error'];
      }

    } catch (e) {
      print("Error fetching employees: $e");
      _employees = ['Error'];
    }
  }

  Future<void> _fetchComplaints() async {
    // String warrantyDate = '';
    // String purchaseDate = '';
    try {
      final response = await http.get(
        Uri.parse('https://limsonvercelapi2.vercel.app/api/fsfetchcomplaints'),
        headers: _headers,
      );
      if(response.statusCode == 200) {
        final data = json.decode(response.body);
        _recordIds = data.map<String>((item) => item['id'].toString()).toList();
        final newRowStates = <String, RowState>{};
        //print(data);

        for (final item in data) {
          // print(">>> Raw item data for this iteration: $item");
          final fields = item['fields'];
          final recordId = item['id'].toString();
          //print(fields);

          // if(fields['warranty expiry date'] is Timestamp || fields['purchase date'] is Timestamp) {
          //   warrantyDate = dateformatter(
          //       fields['warranty expiry date']);
          //   purchaseDate = dateformatter(fields['Purchase date']);
          // }
          //print(fields);

          String nameValue = '';
          String brandValue = '';
          String categoryValue = '';
          String productValue = '';
          String employeeValue = 'Not assigned'; // Use default
          String warrantyDateValue = '';
          String purchaseDateValue = '';
          String statusValue = '';


          try {
            // --- Isolate each calculation step ---

            nameValue =
                (fields['Customer name'] ?? fields['Customer Name']) ?? '';


            brandValue = fields['Brand']?.toString() ?? '';

            categoryValue = fields['Category']?.toString() ?? '';

            productValue = fields['Product name']?.toString() ?? '';

            employeeValue = fields['allotted to']?.toString() ?? 'Not assigned';

            warrantyDateValue = dateformatter(fields['warranty expiry date']);

            purchaseDateValue = dateformatter(fields['Purchase date']);

            statusValue = _validateStatus(fields['Status']);


            newRowStates[recordId] = RowState(
              id: recordId,
              token: token,
              name: nameValue,
              brand: brandValue,
              category: categoryValue,
              product: productValue,
              warrantyDate: warrantyDateValue, // Use calculated safe value
              purchaseDate: purchaseDateValue, // Use calculated safe value
              employee: employeeValue,
              status: statusValue,             // Use calculated safe value
            );
            print("  RowState CREATED successfully.");
          } catch (e, s) {
            // This block will execute if RowState creation fails for THIS record
            print("!!!!!!!! ERROR Creating RowState for ID $recordId !!!!!!!!");
            print("  Error Message: $e");

          }
        }
          // Create RowState ChangeNotifier instance
        _rowStates = newRowStates;
      // Replace the map

      } else {
        _recordIds = [];
        _rowStates = {};
        // Handle error
      }

    } catch (e) {
      print("Error fetching complaints: $e");
      _recordIds = [];
      _rowStates = {};
      // Handle error
    }
  }

  String _validateStatus(dynamic status) {
    print("Validating status: $status");
    const validOptions = ['Open', 'In Progress', 'Resolved'];
    return validOptions.contains(status?.toString()) ? status.toString() : 'Open';
  }

  // --- Update and Save Logic ---
  void updateNewValues(String recordId, Map<String, dynamic> values) {
    final existingIndex = newValues.indexWhere((item) => item['id'] == recordId);
    if (existingIndex != -1) {
      newValues[existingIndex].addAll(values);
    } else {
      final updateData = {'id': recordId, ...values};
      print(updateData);
      newValues.add(updateData);
    }
    // Maybe notify if save button should be enabled/disabled?
    notifyListeners();
  }

  String dateformatter(dynamic dateValue)
  {

    if (dateValue == null) {
      // Handle null input
      return ''; // Or 'N/A' or however you want to display null dates
    } else if (dateValue is Timestamp) {
      // Handle Timestamp input
      DateTime dateTime = dateValue.toDate();
      String formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);
      return formattedDate;
    } else if (dateValue is String) {

      try {
        // Adjust the parsing format if needed, e.g., if time part can exist
        DateTime dateTime = DateFormat('yyyy-MM-dd').parseStrict(dateValue.split('T')[0]);
        return DateFormat('yyyy-MM-dd').format(dateTime);
      } catch (e) {
        print("  [dateformatter] Error parsing date string '$dateValue': $e");
        return 'Invalid Date String'; // Fallback for bad string format
      }
    } else if (dateValue is Map && dateValue.containsKey('_seconds')) {
      // Handle Map representation of Timestamp (often from JSON)
      try {
        DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(dateValue['_seconds'] * 1000);
        return DateFormat('yyyy-MM-dd').format(dateTime);
      } catch (e) {
        print("  [dateformatter] Error processing date map '$dateValue': $e");
        return 'Invalid Date Map';
      }
    } else {
      // Handle any other unexpected type
      print("  [dateformatter] Received unexpected date type: ${dateValue?.runtimeType}");
      return 'Invalid Date Type';
    }
  }

  Future<void> _fetchBrands() async {
    try {
      final response = await http.get(
        // Use the correct endpoint for fetching all brands
        Uri.parse('https://limsonvercelapi2.vercel.app/api/fsproductservice?level=brands'),
        headers: _headers,
      );
      if(response.statusCode == 200) {
        // Assuming the API returns a simple JSON array of strings
        _brands = List<String>.from(json.decode(response.body));
      } else {
        print("Error fetching brands: Status code ${response.statusCode}");
        _brands = ['Error']; // Handle error case
      }
    } catch (e) {
      print("Error fetching brands: $e");
      _brands = ['Error']; // Handle error case
    }
    // No notifyListeners() needed here typically, as fetchInitialData handles it at the end.
  }


  Future<void> saveAll() async {
    if (newValues.isEmpty || _isSaving) return;

    _isSaving = true;
    notifyListeners(); // Show saving indicator

    // Use Future.wait for potential parallel saving
    List<Future> saveFutures = [];
    for (final update in newValues) {
      final fieldsToUpdate = Map<String, dynamic>.from(update);
      fieldsToUpdate.remove('id'); // API expects 'fields' object

      saveFutures.add(
          http.patch(
            Uri.parse('https://limsonvercelapi2.vercel.app/api/fsupdaterecord'),
            headers: _headers,
            body: json.encode({
              'id': update['id'],
              'fields': fieldsToUpdate,
            }),
          ).catchError((e) {
            print("Error saving record ${update['id']}: $e");
            // Handle individual save errors (e.g., collect errors)
            return null; // Or throw to stop Future.wait
          })
      );
    }

    try {
      await Future.wait(saveFutures);
      newValues.clear(); // Clear changes after successful save
      print("Save successful");
      // Optionally refetch data or update UI state
    } catch (e) {
      print("Error during save operation: $e");
      // Handle aggregate errors if needed
    } finally {
      _isSaving = false;
      notifyListeners(); // Hide saving indicator, update UI
    }
  }

  // Dispose all RowState notifiers when the main provider is disposed
  @override
  void dispose() {
    for (var state in _rowStates.values) {
      state.dispose();
    }
    super.dispose();
  }
}
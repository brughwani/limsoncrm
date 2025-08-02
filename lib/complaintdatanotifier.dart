import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'rowstate.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// Import your RowState model
//
// class ComplaintDataNotifier extends ChangeNotifier {
//   final String token;
//   Map<String, RowState> _rowStates = {};
//   List<String> _employees = [];
//   List<String> _brands = [];
//
//   List<String> _recordIds = []; // Store the order
//   bool _isLoading = false;
//   bool _isSaving = false;
//   final List<Map<String, dynamic>> newValues = []; // Keep track of changes
//
//   ComplaintDataNotifier({required this.token}) {
//     fetchInitialData(); // Fetch data on creation
//   }
//
//   // Getters
//   Map<String, RowState> get rowStates => _rowStates;
//   List<RowState> get orderedRows => _recordIds.map((id) => _rowStates[id]!).toList();
//   List<String> get employees => _employees;
//   bool get isLoading => _isLoading;
//   bool get isSaving => _isSaving;
//   List<String> get brands => _brands;
//
//
//   Map<String, String> get _headers => {
//     'Content-Type': 'application/json',
//     'Authorization': 'Bearer $token'
//   };
//
//
//   // --- Fetching Logic ---
//   Future<void> fetchInitialData() async {
//     _isLoading = true;
//     notifyListeners();
//
//     try {
//       // Fetch employees first (or pass them if fetched globally)
//       await Future.wait([
//         _fetchEmployees(),
//         _fetchBrands(), // <-- Call fetch brands here
//       ]);
//
//       // Then fetch complaints which might depend on employees list for defaulting
//       await _fetchComplaints();
//
//     } catch (e) {
//       print("Error fetching initial data: $e");
//       // Handle error state appropriately
//     } finally {
//       _isLoading = false;
//       notifyListeners();
//     }
//   }
//
//   Future<void> _fetchEmployees() async {
//     // Your existing _fetchEmployees logic
//     try {
//       final response = await http.get(
//         Uri.parse('https://limsonvercelapi2.vercel.app/api/fsemployeeservice?getKarigars=true'),
//         headers: _headers,
//       );
//       if(response.statusCode == 200) {
//         _employees = List<String>.from(json.decode(response.body).map((e) => e['First name'].toString()).toList());
//       } else {
//         _employees = ['Error'];
//       }
//
//     } catch (e) {
//       print("Error fetching employees: $e");
//       _employees = ['Error'];
//     }
//   }
//
//   Future<void> _fetchComplaints() async {
//     // String warrantyDate = '';
//     // String purchaseDate = '';
//     try {
//       final response = await http.get(
//         Uri.parse('https://limsonvercelapi2.vercel.app/api/fsfetchcomplaints'),
//         headers: _headers,
//       );
//       if(response.statusCode == 200) {
//         final data = json.decode(response.body);
//         _recordIds = data.map<String>((item) => item['id'].toString()).toList();
//         final newRowStates = <String, RowState>{};
//         //print(data);
//
//         for (final item in data) {
//           // print(">>> Raw item data for this iteration: $item");
//           final fields = item['fields'];
//           final recordId = item['id'].toString();
//           //print(fields);
//
//           // if(fields['warranty expiry date'] is Timestamp || fields['purchase date'] is Timestamp) {
//           //   warrantyDate = dateformatter(
//           //       fields['warranty expiry date']);
//           //   purchaseDate = dateformatter(fields['Purchase date']);
//           // }
//           //print(fields);
//
//           String nameValue = '';
//           String brandValue = '';
//           String categoryValue = '';
//           String productValue = '';
//           String employeeValue = 'Not assigned'; // Use default
//           String warrantyDateValue = '';
//           String purchaseDateValue = '';
//           String statusValue = '';
//
//
//           try {
//             // --- Isolate each calculation step ---
//
//             nameValue =
//                 (fields['Customer name'] ?? fields['Customer Name']) ?? '';
//
//
//             brandValue = fields['Brand']?.toString() ?? '';
//
//             categoryValue = fields['Category']?.toString() ?? '';
//
//             productValue = fields['Product name']?.toString() ?? '';
//
//             employeeValue = fields['allotted to']?.toString() ?? 'Not assigned';
//
//             warrantyDateValue = dateformatter(fields['warranty expiry date']);
//
//             purchaseDateValue = dateformatter(fields['Purchase date']);
//
//             statusValue = _validateStatus(fields['Status']);
//
//
//             newRowStates[recordId] = RowState(
//               id: recordId,
//               token: token,
//               name: nameValue,
//               brand: brandValue,
//               category: categoryValue,
//               product: productValue,
//               warrantyDate: warrantyDateValue, // Use calculated safe value
//               purchaseDate: purchaseDateValue, // Use calculated safe value
//               employee: employeeValue,
//               status: statusValue,             // Use calculated safe value
//             );
//             print("  RowState CREATED successfully.");
//           } catch (e, s) {
//             // This block will execute if RowState creation fails for THIS record
//             print("!!!!!!!! ERROR Creating RowState for ID $recordId !!!!!!!!");
//             print("  Error Message: $e");
//
//           }
//         }
//           // Create RowState ChangeNotifier instance
//         _rowStates = newRowStates;
//       // Replace the map
//
//       } else {
//         _recordIds = [];
//         _rowStates = {};
//         // Handle error
//       }
//
//     } catch (e) {
//       print("Error fetching complaints: $e");
//       _recordIds = [];
//       _rowStates = {};
//       // Handle error
//     }
//   }
//
//   String _validateStatus(dynamic status) {
//     print("Validating status: $status");
//     const validOptions = ['Open', 'In Progress', 'Resolved'];
//     return validOptions.contains(status?.toString()) ? status.toString() : 'Open';
//   }
//
//   // --- Update and Save Logic ---
//   void updateNewValues(String recordId, Map<String, dynamic> values) {
//     print(newValues);
//     final existingIndex = newValues.indexWhere((item) => item['id'] == recordId);
//     if (existingIndex != -1) {
//       newValues[existingIndex].addAll(values);
//     } else {
//       final updateData = {'id': recordId, ...values};
//       print(updateData);
//       newValues.add(updateData);
//     }
//     // Maybe notify if save button should be enabled/disabled?
//     notifyListeners();
//   }
//
//   String dateformatter(dynamic dateValue)
//   {
//
//     if (dateValue == null) {
//       // Handle null input
//       return ''; // Or 'N/A' or however you want to display null dates
//     } else if (dateValue is Timestamp) {
//       // Handle Timestamp input
//       DateTime dateTime = dateValue.toDate();
//       String formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);
//       return formattedDate;
//     } else if (dateValue is String) {
//
//       try {
//         // Adjust the parsing format if needed, e.g., if time part can exist
//         DateTime dateTime = DateFormat('yyyy-MM-dd').parseStrict(dateValue.split('T')[0]);
//         return DateFormat('yyyy-MM-dd').format(dateTime);
//       } catch (e) {
//         print("  [dateformatter] Error parsing date string '$dateValue': $e");
//         return 'Invalid Date String'; // Fallback for bad string format
//       }
//     } else if (dateValue is Map && dateValue.containsKey('_seconds')) {
//       // Handle Map representation of Timestamp (often from JSON)
//       try {
//         DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(dateValue['_seconds'] * 1000);
//         return DateFormat('yyyy-MM-dd').format(dateTime);
//       } catch (e) {
//         print("  [dateformatter] Error processing date map '$dateValue': $e");
//         return 'Invalid Date Map';
//       }
//     } else {
//       // Handle any other unexpected type
//       print("  [dateformatter] Received unexpected date type: ${dateValue?.runtimeType}");
//       return 'Invalid Date Type';
//     }
//   }
//
//   Future<void> _fetchBrands() async {
//     try {
//       final response = await http.get(
//         // Use the correct endpoint for fetching all brands
//         Uri.parse('https://limsonvercelapi2.vercel.app/api/fsproductservice?level=brands'),
//         headers: _headers,
//       );
//       if(response.statusCode == 200) {
//         // Assuming the API returns a simple JSON array of strings
//         _brands = List<String>.from(json.decode(response.body));
//       } else {
//         print("Error fetching brands: Status code ${response.statusCode}");
//         _brands = ['Error']; // Handle error case
//       }
//     } catch (e) {
//       print("Error fetching brands: $e");
//       _brands = ['Error']; // Handle error case
//     }
//     // No notifyListeners() needed here typically, as fetchInitialData handles it at the end.
//   }
//
//
//   Future<void> saveAll() async {
//     if (newValues.isEmpty || _isSaving) return;
//
//     _isSaving = true;
//     notifyListeners(); // Show saving indicator
//
//     // Use Future.wait for potential parallel saving
//     List<Future> saveFutures = [];
//     for (final update in newValues) {
//       final fieldsToUpdate = Map<String, dynamic>.from(update);
//       fieldsToUpdate.remove('id'); // API expects 'fields' object
//
//       saveFutures.add(
//           http.patch(
//             Uri.parse('https://limsonvercelapi2.vercel.app/api/fsupdaterecord'),
//             headers: _headers,
//             body: json.encode({
//               'id': update['id'],
//               'fields': fieldsToUpdate,
//             }),
//           ).catchError((e) {
//             print("Error saving record ${update['id']}: $e");
//             // Handle individual save errors (e.g., collect errors)
//             throw e; // Or throw to stop Future.wait
//           })
//       );
//     }
//
//     try {
//       await Future.wait(saveFutures);
//       newValues.clear(); // Clear changes after successful save
//       print("Save successful");
//       // Optionally refetch data or update UI state
//     } catch (e) {
//       print("Error during save operation: $e");
//       // Handle aggregate errors if needed
//     } finally {
//       _isSaving = false;
//       notifyListeners(); // Hide saving indicator, update UI
//     }
//   }
//
//   // Dispose all RowState notifiers when the main provider is disposed
//   @override
//   void dispose() {
//     for (var state in _rowStates.values) {
//       state.dispose();
//     }
//     super.dispose();
//   }
// }
class ComplaintDataNotifier extends ChangeNotifier {
  // final String token;
  List<RowState> _allComplaints = [];
  List<RowState> _orderedRows = [];
  List<String> _employees = ['Select an employee', 'Not assigned'];
  List<String> _brands = ['Select a brand'];
  bool _isLoading = false;
  bool _isSaving = false;
  Map<String, Map<String, dynamic>> _pendingUpdates = {};
  Map<String, String?> _currentFilterParams = {};


  List<RowState> get orderedRows => _orderedRows;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  List<String> get employees => _employees;
  List<String> get brands => _brands;
  bool get hasPendingUpdates => _pendingUpdates.isNotEmpty;


  @override
  void notifyListeners() {
   // print("📢📢📢 NOTIFY LISTENERS CALLED! Notifier Hash: $hashCode, _isLoading: $_isLoading, orderedRows.length: ${_orderedRows.length} 📢📢📢");


   // print("📢📢📢 NOTIFY LISTENERS CALLED! Current _isLoading: $_isLoading, orderedRows.length: ${_orderedRows.length} 📢📢📢");
    super.notifyListeners(); // Call the actual base implementation
  }

  void setLoading(bool value) {
    if (_isLoading != value) {
      _isLoading = value;
      _forceNotify();
    }
  }
  void _forceNotify() {
    // Workaround for notifyListeners issues
    try {
      notifyListeners();
    } catch (_) {
      Future.delayed(Duration.zero, () {
        try {
          notifyListeners();
        } catch (_) {
          // Last resort
          WidgetsBinding.instance.addPostFrameCallback((_) {
            notifyListeners();
          });
        }
      });
    }
  }



  // Future<void> fetchInitialData(String token) async {
  //   // if (_isLoading) return;
  //
  //   print("Starting data fetch...");
  //
  //   if (_isLoading) {
  //     print("[FETCH] Already loading, skipping");
  //     return;
  //   }
  //
  //
  //   //_isLoading = false;
  //   else {
  //     setLoading(true);
  //
  //     print("[LOADING] Set to TRUE");
  //   //  notifyListeners();
  //     // _isLoading = true;
  //     // notifyListeners();
  //     try {
  //       print("[FETCH] Loading employees and brands");
  //       await Future.wait([
  //         _fetchEmployees(token),
  //         _fetchBrands(token),
  //       ]);
  //
  //       print("[FETCH] Loading complaints");
  //       await _loadAllComplaints(token);
  //
  //       print("[DATA] Loaded ${_allComplaints.length} complaints");
  //       _orderedRows = List.from(_allComplaints);
  //     } catch (e, stack) {
  //       _allComplaints = [];
  //       _orderedRows = [];
  //
  //       print("[ERROR] Fetch failed: $e\n$stack");
  //     } finally {
  //       _isLoading = false;
  //       print("[LOADING] Set to FALSE");
  //       notifyListeners();
  //       print("[FETCH] Completed. Notified listeners");
  //     }
  //   }

    // try {
    //   // Fetch data
    //   await _fetchEmployees(token);
    //   await _fetchBrands(token);
    //   await _loadAllComplaints(token);
    //
    //   _orderedRows = List.from(_allComplaints);
    //   // notifyListeners();
    // } catch (e) {
    //   _allComplaints = [];
    //   _orderedRows = [];
    // } finally {
    //   _isLoading = false;
    //   notifyListeners();
    // }

Future<void> fetchInitialData(String token) async {
  print("[DEBUG NOTIFIER] fetchInitialData START"); // <-- ADD THIS
  if (_isLoading) {
    print("[DEBUG NOTIFIER] Already loading, skipping. _isLoading: $_isLoading"); // <-- ADD THIS
    return;
  }

  _isLoading = true;
 // print("[DEBUG NOTIFIER] Setting _isLoading to TRUE. Notifying listeners for loading start."); // <-- ADD THIS
  notifyListeners(); // Notify listeners that loading has started

  try {
 //   print("[DEBUG NOTIFIER] Fetching employees and brands..."); // <-- ADD THIS
    await Future.wait([
      _fetchEmployees(token),
      _fetchBrands(token),
    ]);
  //  print("[DEBUG NOTIFIER] Employees and brands fetched."); // <-- ADD THIS

  //  print("[DEBUG NOTIFIER] Loading complaints..."); // <-- ADD THIS
    await _loadAllComplaints(token); // This populates _allComplaints
 //   print("[DEBUG NOTIFIER] Complaints loaded. _allComplaints.length: ${_allComplaints.length}"); // <-- ADD THIS

    _orderedRows = List.from(_allComplaints);
  //  print("[DEBUG NOTIFIER] _orderedRows initialized. Length: ${_orderedRows.length}"); // <-- ADD THIS

  } catch (e, stack) {
    _allComplaints = [];
    _orderedRows = [];
 //   print("[DEBUG NOTIFIER] ERROR in fetchInitialData: $e\n$stack"); // <-- ADD THIS
  } finally {
    _isLoading = false; // Set loading state to false
 //   print("[DEBUG NOTIFIER] Setting _isLoading to FALSE. Notifying listeners for loading end."); // <-- ADD THIS
    notifyListeners(); // Notify listeners that loading has completed and data is ready
  //  print("[DEBUG NOTIFIER] fetchInitialData END (notifyListeners called)."); // <-- ADD THIS
  }
}
  Future<void> _fetchEmployees(String token) async {
    try {
      final response = await http.get(
        Uri.parse('https://limsonvercelapi2.vercel.app/api/fsemployeeservice?getKarigars=true'),
        headers: {'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final List<dynamic> empList = json.decode(response.body);
        _employees = [
          'Select an employee',
          'Not assigned',
          ...empList.map((e) => e['First name'].toString())
        ];
      }
    } catch (e) {
      _employees = ['Error loading employees'];
    }
  }

  Future<void> _fetchBrands(String token) async {
    try {
      final response = await http.get(
        Uri.parse('https://limsonvercelapi2.vercel.app/api/fsproductservice?level=brands'),
        headers: {'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        _brands = ['Select a brand', ...List<String>.from(json.decode(response.body))];
      }
    } catch (e) {
      _brands = ['Error loading brands'];
    }
  }

  Future<void> _loadAllComplaints(String token) async {
    try {
      final response = await http.get(
        Uri.parse('https://limsonvercelapi2.vercel.app/api/fsfetchcomplaints'),
        headers: {'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'},
      ).timeout(Duration(seconds: 30));

  //    print(3.3);

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
    //    print(data);
        _allComplaints = data.map<RowState>((item) {
          return RowState.fromJson(item, token, updateNewValues);
        }).toList();
      //  print(_allComplaints);
      }
    } catch (e) {
      _allComplaints = [];
    }
  }

  String _dateFormatter(dynamic dateValue) {
    if (dateValue == null) return '';
    try {
      if (dateValue is Timestamp) {
        return DateFormat('yyyy-MM-dd').format(dateValue.toDate());
      } else if (dateValue is String) {
        return DateFormat('yyyy-MM-dd').format(DateTime.parse(dateValue.split('T')[0]));
      } else if (dateValue is Map && dateValue.containsKey('_seconds')) {
        return DateFormat('yyyy-MM-dd').format(
            DateTime.fromMillisecondsSinceEpoch(dateValue['_seconds'] * 1000)
        );
      }
      return 'Invalid Date';
    } catch (e) {
      return 'Invalid Date';
    }
  }

  void applyFilters({
    String? fromdate,
    String? todate,
    String? name,
    String? phone,
    String? village,
    String? dealer,
    String? brandName,
    String? category,
    String? product,
    String? allottedTo,
    String? servicetype,
    String? source,
  }) {
    _currentFilterParams = {
      'fromdate': fromdate, 'todate': todate, 'name': name, 'phone': phone,
      'village': village, 'dealer': dealer, 'brandName': brandName,
      'category': category, 'product': product, 'allottedTo': allottedTo,
      'servicetype': servicetype, 'source': source,
    };

  //   _orderedRows = _allComplaints.where((complaint) {
  //     // Create a list to store filter results
  //     final List<bool> filterResults = [];
  //
  //     // Helper function to add filter results
  //     void addFilterResult(bool result) {
  //       filterResults.add(result);
  //     }
  //
  //     // 1. Date Range Filters
  //     addFilterResult(_passesDateFilter(
  //         complaint.complaintDate,
  //         fromdate,
  //         todate
  //     ));
  //
  //     // 2. Text Field Filters
  //     addFilterResult(_passesTextFilter(
  //         complaint.nameController.text,
  //         name
  //     ));
  //
  //     addFilterResult(_passesTextFilter(
  //         complaint.phoneNumber,
  //         phone
  //     ));
  //
  //     // 3. Dropdown Filters
  //     addFilterResult(_passesDropdownFilter(
  //         complaint.village,
  //         village,
  //         placeholder: 'Select a location'
  //     ));
  //
  //     addFilterResult(_passesDropdownFilter(
  //         complaint.dealer,
  //         dealer,
  //         placeholder: 'Select a dealer'
  //     ));
  //
  //     addFilterResult(_passesDropdownFilter(
  //         complaint.brand,
  //         brandName,
  //         placeholder: 'Select a brand'
  //     ));
  //
  //     addFilterResult(_passesDropdownFilter(
  //         complaint.category,
  //         category,
  //         placeholder: 'Select a category'
  //     ));
  //
  //     addFilterResult(_passesDropdownFilter(
  //         complaint.product,
  //         product,
  //         placeholder: 'Select a product'
  //     ));
  //
  //     // 4. Employee Filter
  //     addFilterResult(_passesEmployeeFilter(
  //         complaint.employee,
  //         allottedTo
  //     ));
  //
  //     // 5. Service Type and Source
  //     addFilterResult(_passesTextFilter(
  //         complaint.serviceType,
  //         servicetype
  //     ));
  //
  //     addFilterResult(_passesTextFilter(
  //         complaint.source,
  //         source
  //     ));
  //
  //     // Apply AND logic: All active filters must pass
  //     return !filterResults.contains(false);
  //   }).toList();
  //
  //   final clearAll = fromdate == null && todate == null && name == null &&
  //       phone == null && village == null && dealer == null &&
  //       brandName == null && category == null && product == null &&
  //       allottedTo == null && servicetype == null && source == null;
  //
  //   if (clearAll) {
  //     _orderedRows = List.from(_allComplaints);
  //     notifyListeners();
  //     return;
  //   }
  //
  //   notifyListeners();
  // }
    _orderedRows = _allComplaints.where((complaint) {
      // 1. Date Range Filters - Early exit if fails
      if (!_passesDateFilter(complaint.complaintDate, fromdate, todate)) {
        return false;
      }

      // 2. Text Field Filters - Case insensitive with null safety
      if (!_passesTextFilter(complaint.nameController.text, name)) return false;
      if (!_passesTextFilter(complaint.phoneNumber, phone)) return false;

      // 3. Dropdown Filters - Standardized placeholder handling
      if (!_passesDropdownFilter(complaint.village, village, 'Select a location')) return false;
      if (!_passesDropdownFilter(complaint.dealer, dealer, 'Select a dealer')) return false;
      if (!_passesDropdownFilter(complaint.brand, brandName, 'Select a brand')) return false;
      if (!_passesDropdownFilter(complaint.category, category, 'Select a category')) return false;
      if (!_passesDropdownFilter(complaint.product, product, 'Select a product')) return false;

      // 4. Employee Filter - Improved null handling
      if (!_passesEmployeeFilter(complaint.employee, allottedTo)) return false;

      // 5. Service Type and Source
      if (!_passesTextFilter(complaint.serviceType, servicetype)) return false;
      if (!_passesTextFilter(complaint.source, source)) return false;

      return true;
    }).toList();

    notifyListeners();
  }
// Helper methods for each filter type
  bool _passesDateFilter(String complaintDate, String? from, String? to) {
    if (from == null && to == null) return true;

    final date = DateTime.tryParse(complaintDate);
    if (date == null) return false;

    final fromDate = from != null ? DateTime.tryParse(from) : null;
    final toDate = to != null ? DateTime.tryParse(to) : null;

    if (fromDate != null && date.isBefore(fromDate)) return false;
    if (toDate != null && date.isAfter(toDate)) return false;

    return true;
  }

  bool _passesTextFilter(String value, String? filter) {
    if (filter == null || filter.isEmpty) return true;
    return value.toLowerCase().contains(filter.toLowerCase());
  }
  bool _passesDropdownFilter(String value, String? filter, String placeholder) {
    if (filter == null || filter.isEmpty || filter == placeholder) return true;
    if (value.isEmpty) return false; // Handle empty values
    return value.toLowerCase() == filter.toLowerCase();
  }
  // bool _passesDropdownFilter(String value, String? filter, {String? placeholder}) {
  //   if (filter == null || filter.isEmpty || filter == placeholder) return true;
  //   return value.toLowerCase() == filter.toLowerCase();
  // }

  bool _passesEmployeeFilter(String employee, String? filter) {
    if (filter == null || filter.isEmpty || filter == 'Select an employee') {
      return true;
    }

    if (filter == 'Not assigned') {
      return employee.isEmpty || employee == 'Not assigned';
    }

    return employee.toLowerCase() == filter.toLowerCase();
  }

  void updateNewValues(String recordId, Map<String, dynamic> values) {
    _pendingUpdates.putIfAbsent(recordId, () => {});
    _pendingUpdates[recordId]!.addAll(values);
    notifyListeners();
  }

  Future<void> saveAll(String token) async {
    if (_pendingUpdates.isEmpty || _isSaving) return;

    _isSaving = true;
    notifyListeners();

    try {
      final saveFutures = _pendingUpdates.entries.map((entry) {
        return http.patch(
          Uri.parse('https://limsonvercelapi2.vercel.app/api/fsupdaterecord'),
          headers: {'Content-Type': 'application/json',
            'Authorization': 'Bearer $token'},
          body: json.encode({
            'id': entry.key,
            'fields': entry.value,
          }),
        );
      });

      await Future.wait(saveFutures);
      _pendingUpdates.clear();
      applyFilters();
    } catch (e) {
      print("Save error: $e");
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    for (final state in _allComplaints) {
      state.dispose();
    }
    super.dispose();
  }
}
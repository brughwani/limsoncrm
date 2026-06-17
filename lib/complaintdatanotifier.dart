import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'rowstate.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  String? _currentSortKey;
  bool _isSortAscending = true;

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

<<<<<<< HEAD
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
      print(
          "[DEBUG NOTIFIER] Already loading, skipping. _isLoading: $_isLoading"); // <-- ADD THIS
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
      _sortOrderedRowsPendingFirst();
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

=======


Future<void> fetchInitialData(String token) async {
  print("[DEBUG NOTIFIER] fetchInitialData START"); // <-- ADD THIS
  if (_isLoading) {
    print("[DEBUG NOTIFIER] Already loading, skipping. _isLoading: $_isLoading"); // <-- ADD THIS
    return;
  }

  _isLoading = true;
   notifyListeners(); // Notify listeners that loading has started


  try {
    await Future.wait([
      _fetchEmployees(token),
      _fetchBrands(token),
    ]);
    await _loadAllComplaints(token); // This populates _allComplaints

    _orderedRows = List.from(_allComplaints);

  } catch (e, stack) {
    _allComplaints = [];
    _orderedRows = [];
   } finally {
    _isLoading = false; // Set loading state to false
    notifyListeners(); // Notify listeners that loading has completed and data is ready

  }
}
>>>>>>> ef7322ab7c9ac2128c723dc72a1775edbac96ad8
  Future<void> _fetchEmployees(String token) async {
    try {
      final response = await http.get(
        Uri.parse(
            'https://limsonvercelapi2.vercel.app/api/fsemployeeservice?getKarigars=true'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
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
        Uri.parse(
            'https://limsonvercelapi2.vercel.app/api/fsproductservice?level=brands'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
      );
      if (response.statusCode == 200) {
        _brands = [
          'Select a brand',
          ...List<String>.from(json.decode(response.body))
        ];
      }
    } catch (e) {
      _brands = ['Error loading brands'];
    }
  }

  Future<void> _loadAllComplaints(String token) async {
    try {
      final response = await http.get(
        Uri.parse('https://limsonvercelapi2.vercel.app/api/fsfetchcomplaints'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
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
        return DateFormat('dd-MM-yyyy').format(dateValue.toDate());
      } else if (dateValue is String) {
        return DateFormat('dd-MM-yyyy')
            .format(DateTime.parse(dateValue.split('T')[0]));
      } else if (dateValue is Map && dateValue.containsKey('_seconds')) {
        return DateFormat('dd-MM-yyyy').format(
            DateTime.fromMillisecondsSinceEpoch(dateValue['_seconds'] * 1000));
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
      'fromdate': fromdate,
      'todate': todate,
      'name': name,
      'phone': phone,
      'village': village,
      'dealer': dealer,
      'brandName': brandName,
      'category': category,
      'product': product,
      'allottedTo': allottedTo,
      'servicetype': servicetype,
      'source': source,
    };

<<<<<<< HEAD
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
=======
>>>>>>> ef7322ab7c9ac2128c723dc72a1775edbac96ad8

    final fromDateParsed = (fromdate != null && fromdate.isNotEmpty)
        ? DateTime.tryParse(fromdate)
        : null;
    final toDateParsed = (todate != null && todate.isNotEmpty)
        ? DateTime.tryParse(todate)
        : null;

    _orderedRows = _allComplaints.where((complaint) {

      final complaintDateParsed = (complaint.complaintDate.isNotEmpty)
          ? DateFormat('dd-MM-yyyy').parse(complaint.complaintDate)
          : null;

      // If the complaint date is invalid, it fails the date filter.
      if (complaintDateParsed == null) {
        return false;
      }

      // Now we call the new, clean helper function with the DateTime objects.
      if (!_passesDateFilter(
          complaintDateParsed, fromDateParsed, toDateParsed)) {
        return false;
      }

      // 2. Text Field Filters - Case insensitive with null safety
      if (!_passesTextFilter(complaint.nameController.text, name)) return false;
      if (!_passesTextFilter(complaint.phoneNumber, phone)) return false;

      // 3. Dropdown Filters - Standardized placeholder handling
      if (!_passesDropdownFilter(
          complaint.village, village, 'Select a location')) return false;
      if (!_passesDropdownFilter(complaint.dealer, dealer, 'Select a dealer'))
        return false;
      if (!_passesDropdownFilter(complaint.brand, brandName, 'Select a brand'))
        return false;
      if (!_passesDropdownFilter(
          complaint.category, category, 'Select a category')) return false;
      if (!_passesDropdownFilter(
          complaint.product, product, 'Select a product')) return false;

      // 4. Employee Filter - Improved null handling
      if (!_passesEmployeeFilter(complaint.employee, allottedTo)) return false;

      // 5. Service Type and Source
      if (!_passesTextFilter(complaint.serviceType, servicetype)) return false;
      if (!_passesTextFilter(complaint.source, source)) return false;

      return true;
    }).toList();

    _sortOrderedRowsPendingFirst(
      sortKey: _currentSortKey,
      ascending: _isSortAscending,
    );
    notifyListeners();
  }

// Helper methods for each filter type
<<<<<<< HEAD
  bool _passesDateFilter(
      DateTime complaintDate, DateTime? fromDate, DateTime? toDate) {
//     if (from == null && to == null) return true;
//
//     // final date = DateTime.tryParse(complaintDate);
//     // if (date == null) return false;
//     DateTime? date;
//     try {
//        date = DateFormat('dd-MM-yyyy').parseStrict(complaintDate);
//     } catch (e) {
//       // If parsing fails, the complaint does not pass the date filter.
//       return false;
//     }
//     if (date == null) return false;
//     final fromDate = from != null ? DateTime.tryParse(from) : null;
//     final toDate = to != null ? DateTime.tryParse(to) : null;
//
// // Check if the complaint date is before the "from" date.
//     if (fromDate != null && date.isBefore(fromDate)) return false;
//
//     // Check if the complaint date is after the "to" date.
//     // We add a day to the 'to' date to make the filter inclusive of the entire day.
//     if (toDate != null) {
//       final adjustedToDate = toDate.add(const Duration(days: 1));
//       if (date.isAfter(adjustedToDate)) {
//         return false;
//       }
//     }
//
//     return true;
=======
  bool _passesDateFilter(DateTime complaintDate, DateTime? fromDate, DateTime? toDate) {
>>>>>>> ef7322ab7c9ac2128c723dc72a1775edbac96ad8

    if (fromDate == null && toDate == null) {
      return true;
    }

    // The complaint date is already a valid DateTime object.
    if (fromDate != null && complaintDate.isBefore(fromDate)) {
      return false;
    }

    // Add one day to the 'to' date to make the filter inclusive of the entire day.
    if (toDate != null) {
      final adjustedToDate = toDate.add(const Duration(days: 1));
      if (complaintDate.isAfter(adjustedToDate)) {
        return false;
      }
    }

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
  void sortComplaints(String key, bool ascending) {
    _currentSortKey = key;
    _isSortAscending = ascending;
    _sortOrderedRowsPendingFirst(sortKey: key, ascending: ascending);
    notifyListeners();
  }

  void _sortOrderedRowsPendingFirst({String? sortKey, bool ascending = true}) {
    final indexedRows = _orderedRows.asMap().entries.toList();

    indexedRows.sort((a, b) {
      final statusComparison = _compareComplaintStatus(a.value, b.value);
      if (statusComparison != 0) return statusComparison;

      if (sortKey != null) {
        final dateComparison =
            _compareComplaintDates(a.value, b.value, sortKey, ascending);
        if (dateComparison != 0) return dateComparison;
      }

      return a.key.compareTo(b.key);
    });

    _orderedRows = indexedRows.map((entry) => entry.value).toList();
  }

  int _compareComplaintStatus(RowState a, RowState b) {
    final aResolved = _isResolved(a);
    final bResolved = _isResolved(b);

    if (aResolved == bResolved) return 0;
    return aResolved ? 1 : -1;
  }

  bool _isResolved(RowState complaint) {
    return complaint.status.trim().toLowerCase() == 'resolved';
  }

  int _compareComplaintDates(
      RowState a, RowState b, String sortKey, bool ascending) {
    final dateA = _getDateFromRowState(a, sortKey);
    final dateB = _getDateFromRowState(b, sortKey);

    if (dateA == null && dateB == null) return 0;
    if (dateA == null) return ascending ? 1 : -1;
    if (dateB == null) return ascending ? -1 : 1;

    final comparison = dateA.compareTo(dateB);
    return ascending ? comparison : -comparison;
  }

  DateTime? _getDateFromRowState(RowState rowState, String sortKey) {
    String dateString;
    switch (sortKey) {
      case 'Date of Complaint':
        dateString = rowState.complaintDate;
        break;
      case 'Visit Date':
        dateString = rowState.visitdate ?? '';
        break;
      case 'Solve Date':
        dateString = rowState.solvedate ?? '';
        break;
      default:
        return null;
    }
    try {
      if (dateString.isNotEmpty) {
        return DateFormat('dd-MM-yyyy').parse(dateString);
      }
    } catch (e) {
      print('Error parsing date string "$dateString" for sorting: $e');
    }
    return null;
  }

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
    if (values.containsKey('Status')) {
      _sortOrderedRowsPendingFirst(
        sortKey: _currentSortKey,
        ascending: _isSortAscending,
      );
    }
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
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token'
          },
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

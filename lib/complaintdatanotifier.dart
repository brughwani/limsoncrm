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
  Map<String, String> _productKarigarMap = {};
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
  Map<String, String> get productKarigarMap => _productKarigarMap;
  bool get hasPendingUpdates => _pendingUpdates.isNotEmpty;

  String? getKarigarForProduct(String productName) {
    if (productName.isEmpty ||
        productName == 'Select a product' ||
        productName == 'Select a category' ||
        productName == 'Select Category' ||
        productName == 'Select Brand') return null;

    final nameLower = productName.trim().toLowerCase();
    String? matchedKarigarName;

    // Specific product/category assignment rules:
    // Ceiling Fan / Cooler -> Samir
    // Gas Stove -> Sachin
    if (nameLower.contains('ceiling fan') ||
        nameLower.contains('cooler') ||
        nameLower.contains('fan')) {
      matchedKarigarName = 'samir';
    } else if (nameLower.contains('gas stove') ||
        nameLower.contains('stove') ||
        nameLower.contains('chulha') ||
        nameLower.contains('gas')) {
      matchedKarigarName = 'sachin';
    } else {
      matchedKarigarName = _productKarigarMap[productName] ??
          _productKarigarMap[productName.trim()] ??
          _productKarigarMap[nameLower];
    }

    if (matchedKarigarName != null && matchedKarigarName.isNotEmpty) {
      for (final emp in _employees) {
        if (emp.toLowerCase() == matchedKarigarName.toLowerCase() ||
            emp.toLowerCase().contains(matchedKarigarName.toLowerCase())) {
          return emp;
        }
      }
      return matchedKarigarName[0].toUpperCase() + matchedKarigarName.substring(1);
    }

    return null;
  }

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

  Future<void> fetchInitialData(String token) async {
    print("[DEBUG NOTIFIER] fetchInitialData START"); // <-- ADD THIS
    if (_isLoading) {
      print(
          "[DEBUG NOTIFIER] Already loading, skipping. _isLoading: $_isLoading"); // <-- ADD THIS
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
      _sortOrderedRowsPendingFirst();
    } catch (e, stack) {
      _allComplaints = [];
      _orderedRows = [];
    } finally {
      _isLoading = false; // Set loading state to false
      notifyListeners(); // Notify listeners that loading has completed and data is ready
    }
  }
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

        _productKarigarMap.clear();
        for (var emp in empList) {
          if (emp is Map<String, dynamic>) {
            String empName = emp['First name']?.toString() ??
                (emp['fields'] is Map ? emp['fields']['First name']?.toString() : null) ??
                '';
            if (empName.isNotEmpty) {
              var prods = emp['products'] ??
                  emp['product'] ??
                  emp['Products'] ??
                  emp['Product'] ??
                  emp['specialization'] ??
                  emp['category'] ??
                  (emp['fields'] is Map
                      ? emp['fields']['product'] ?? emp['fields']['products']
                      : null);
              if (prods != null) {
                if (prods is List) {
                  for (var p in prods) {
                    if (p != null && p.toString().trim().isNotEmpty) {
                      _productKarigarMap[p.toString().trim()] = empName;
                      _productKarigarMap[p.toString().trim().toLowerCase()] = empName;
                    }
                  }
                } else if (prods is String) {
                  for (var p in prods.split(',')) {
                    if (p.trim().isNotEmpty) {
                      _productKarigarMap[p.trim()] = empName;
                      _productKarigarMap[p.trim().toLowerCase()] = empName;
                    }
                  }
                }
              }
            }
          }
        }
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



    final fromDateParsed = (fromdate != null && fromdate.isNotEmpty)
        ? DateTime.tryParse(fromdate)
        : null;
    final toDateParsed = (todate != null && todate.isNotEmpty)
        ? DateTime.tryParse(todate)
        : null;

    _orderedRows = _allComplaints.where((complaint) {
      // 1. Date filter (only apply if fromdate or todate is specified)
      if (fromDateParsed != null || toDateParsed != null) {
        DateTime? complaintDateParsed;
        if (complaint.complaintDate.isNotEmpty) {
          try {
            complaintDateParsed = DateFormat('yyyy-MM-dd').parse(complaint.complaintDate);
          } catch (_) {
            try {
              complaintDateParsed = DateFormat('dd-MM-yyyy').parse(complaint.complaintDate);
            } catch (_) {
              complaintDateParsed = DateTime.tryParse(complaint.complaintDate);
            }
          }
        }
        if (complaintDateParsed == null) return false;
        if (!_passesDateFilter(complaintDateParsed, fromDateParsed, toDateParsed)) {
          return false;
        }
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
  bool _passesDateFilter(DateTime complaintDate, DateTime? fromDate, DateTime? toDate) {

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

    final empLower = employee.trim().toLowerCase();
    final filterLower = filter.trim().toLowerCase();

    if (filterLower == 'not assigned') {
      return empLower.isEmpty || empLower == 'not assigned';
    }

    return empLower == filterLower ||
        empLower.contains(filterLower) ||
        filterLower.contains(empLower);
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

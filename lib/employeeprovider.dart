import 'dart:convert';

import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class EmployeeProvider with ChangeNotifier {
  List<String> _selectedFields = []; // List to store selected fields
  List<Map<String, dynamic>> _employees = []; // List to store employee data
  Map<String, bool> _checkboxStatuses = {}; // Current statuses of checkboxes

  List<String> get selectedFields => _selectedFields;

  List<Map<String, dynamic>> get employees => _employees;

  Future<void> loadInitialCheckboxStatuses(List<String> fields) async {
    for (var field in fields) {
      _checkboxStatuses[field] = false; // Default status is unchecked
    }
    // Example: Pre-select certain fields
    // _checkboxStatuses['Employee Name'] = true;
    notifyListeners();
  }


  // Method to toggle field selection
  void toggleFieldSelection(String field, bool isSelected) {
    if (isSelected) {
      _selectedFields.add(field); // Add to list if selected
    } else {
      _selectedFields.remove(field); // Remove from list if deselected
    }
    notifyListeners(); // Notify listeners (UI) to rebuild
  }

  Future<List<Map<String, dynamic>>> fetchEmployees(List<String> fields) async {
    final url = "https://limsonvercelapi2.vercel.app/api/fsemployeeservice?fields=${fields}";
    final response = await http.get(
        Uri.parse(url), headers: {'Content-Type': 'application/json'});

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      final List<Map<String, dynamic>> fetchedEmployees = jsonData.map((
          e) => Map<String, dynamic>.from(e)).toList();

      // Update internal state
      _employees = fetchedEmployees;
      notifyListeners(); // Update UI
      return fetchedEmployees; // Return fetched data
    } else {
      throw Exception('Failed to fetch employee data');
    }
  }
}
  // Method to fetch employees based on selected fields
//   Future<void> fetchEmployees(List<String> fields) async {
//     final url = "https://crmvercelfun.vercel.app/api/getallemployee?fields[]=${fields}";
//     final response = await http.get(Uri.parse(url), headers: {'Content-Type': 'application/json'});
//
//     if (response.statusCode == 200) {
//       final List<dynamic> jsonData = jsonDecode(response.body);
//       _employees = jsonData.map((e) => Map<String, dynamic>.from(e)).toList();
//       notifyListeners(); // Notify listeners to rebuild the UI with new data
//     } else {
//       throw Exception('Failed to fetch employee data');
//     }
//   }
// }
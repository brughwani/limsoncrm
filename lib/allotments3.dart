// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'package:intl/intl.dart';
// import 'package:provider/provider.dart';
// // Import your models and providers
// import 'complaintdatanotifier.dart';
// import 'rowstate.dart';
// import 'cellwidget.dart'; // Assuming CellWidget remains mostly the same structurally
//
// class AllotComplaint1 extends StatelessWidget { // Changed to StatelessWidget
//   final String token;
//   const AllotComplaint1({super.key, required this.token});
//
//   @override
//   Widget build(BuildContext context) {
//     // Provide the main ComplaintDataNotifier
//     return ChangeNotifierProvider(
//       create: (_) => ComplaintDataNotifier(token: token),
//       child: Scaffold(
//         appBar: AppBar(
//           title: const Text('Complaint Allotment'),
//           actions: [
//             // Consumer to react to saving state for the button
//             Consumer<ComplaintDataNotifier>(
//               builder: (context, notifier, child) {
//                 return IconButton(
//                   icon: notifier.isSaving
//                       ? const SizedBox( // Show progress indicator while saving
//                       width: 20, height: 20,
//                       child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
//                       : const Icon(Icons.save),
//                   // Disable button while saving or if no changes
//                   onPressed : notifier.isSaving || notifier.newValues.isEmpty
//                       ? null
//                       : () => notifier.saveAll(),
//                 );
//               },
//             )
//           ],
//         ),
//         // Consumer to react to loading state and data changes
//         body: Consumer<ComplaintDataNotifier>(
//           builder: (context, notifier, child) {
//           //  print(notifier.orderedRows);
//
//             if (notifier.isLoading) {
//               return const Center(child: CircularProgressIndicator());
//             }
//            else if (notifier.orderedRows.isEmpty) {
//               return const Center(child: Text("No complaints found."));
//             }
//
//            else {
//               // Get the update callback reference once
//               final updateCallback = notifier.updateNewValues;
//              // print(notifier.orderedRows);
//
//               return SingleChildScrollView(
//                 scrollDirection: Axis.horizontal,
//                 child: SingleChildScrollView( // For vertical scroll if needed
//                   child: DataTable(
//                     columns: const [
//                       DataColumn(label: Text('Customer')),
//                       DataColumn(label: Text('Allotted To')),
//                       DataColumn(label: Text('Status')),
//                       DataColumn(label: Text('Brand')),
//                       DataColumn(label: Text('Category')),
//                       DataColumn(label: Text('Product')),
//                       DataColumn(label: Text('Warranty Date')),
//                       DataColumn(label: Text('Purchase Date')),
//                     ],
//                     // Map over the ordered rows from the notifier
//                     rows: notifier.orderedRows.map((rowState) {
//                       return _buildDataRow(context, rowState, updateCallback);
//                       // Provide the specific RowState instance for this row
//                       // return ChangeNotifierProvider.value(
//                       //     value: rowState,
//                       //     // Use Builder or Consumer to get context with RowState provider
//                       //     child: Builder(
//                       //         builder: (rowContext) => _buildDataRow(rowContext, updateCallback)
//                       //     )
//                       // );
//                     }).toList(),
//                   ),
//                 ),
//               );
//             }
//             },
//         ),
//       ),
//     );
//   }
//   DataRow _buildDataRow(
//       BuildContext context, // Context that has ComplaintDataNotifier
//       RowState state,      // The specific state for THIS row
//       Function(String, Map<String, dynamic>) updateCallback) {
//     return DataRow(cells: [
//       // --- Customer Name Cell ---
//       DataCell(
//         // Option 1: Wrap cell content with Provider + Consumer/Builder
//         ChangeNotifierProvider.value(
//           value: state, // Provide the specific RowState
//           child: Consumer<RowState>( // Use Consumer to get context/state
//             builder: (cellContext, rowStateFromConsumer, _) {
//               return CellWidget<String>(
//                 isTextField: true,
//                 // Use data from the consumed RowState
//                 value: rowStateFromConsumer.nameController.text,
//                 controller: rowStateFromConsumer.nameController,
//                 onChanged: (newValue) {
//                   // Use the state's id and the passed callback
//                   updateCallback(
//                       rowStateFromConsumer.id, {'Customer name': newValue});
//                 },
//               );
//             },
//           ),
//         ),
//       ),
//       DataCell(
//         // Wrap cell content with Provider + Consumer/Builder
//         ChangeNotifierProvider.value(
//           value: state,
//           child: Consumer<RowState>(
//             builder: (cellContext, rowStateFromConsumer, _) {
//               // Access the main notifier via the original context passed to _buildDataRow
//               final allEmployees = Provider.of<ComplaintDataNotifier>(context, listen: false).employees;
//               final currentEmployee = rowStateFromConsumer.employee;
//               // final valueToShow = allEmployees.contains(currentEmployee)
//               //     ? currentEmployee
//               //     : (allEmployees.isNotEmpty ? allEmployees.first : '');
//               final valueToShow=state.employee;
//               return CellWidget<String>(
//                 isDropdown: true,
//                 value: currentEmployee!,
//                 options: ['Not assigned',...allEmployees],
//                 onChanged: (newValue) {
//                   if (newValue != null && newValue != 'Not assigned') {
//                     // Call update method on the specific RowState
//                     rowStateFromConsumer.updateEmployee(newValue, updateNewValuesCallback: updateCallback);
//                   }
//                   else if(newValue == 'Not assigned') {
//                     // Handle the case where 'Not Allocated' is selected
//                     rowStateFromConsumer.updateEmployee('Not assigned', updateNewValuesCallback: updateCallback);
//                   }
//                 },
//               );
//             },
//           ),
//         ),
//       ),
//
//       // --- Status Cell ---
//       DataCell(
//           ChangeNotifierProvider.value(
//               value: state,
//               child: Consumer<RowState>(
//                   builder: (cellContext, rowStateFromConsumer, _) {
//                     const statusOptions = ['Open', 'In Progress', 'Resolved'];
//                     return CellWidget<String>(
//                       value: rowStateFromConsumer.status, // Status from the specific state
//                       options: statusOptions,
//                       isDropdown: true,
//                       onChanged: (newValue) {
//                         if (newValue != null) {
//                           rowStateFromConsumer.updateStatus(newValue, updateNewValuesCallback: updateCallback);
//                         }
//                       },
//                     );
//                   }
//               )
//           )
//       ),
//
//       // --- Brand Cell ---
//       DataCell(
//           ChangeNotifierProvider.value(
//               value: state,
//               child: Consumer<RowState>( // Use Consumer to listen to brand changes etc.
//                   builder: (cellContext, rowStateFromConsumer, _) {
//                     // Assuming brands are fetched/stored in ComplaintDataNotifier
//                     final availableBrands = Provider.of<ComplaintDataNotifier>(context, listen: false).brands; // You need to add this getter/list
//                     final valueToShow = availableBrands.contains(rowStateFromConsumer.brand)
//                         ? rowStateFromConsumer.brand
//                         : (availableBrands.isNotEmpty ? availableBrands.first : '');
//
//                     // Add loading indicator if needed based on a flag in RowState
//                     // if (rowStateFromConsumer.isLoadingBrands) return CircularProgressIndicator();
//
//                     return CellWidget<String>(
//                         isDropdown: true,
//                         options: availableBrands.isNotEmpty ? availableBrands : ['Loading...'],
//                         value: valueToShow,
//                         onChanged:(newValue) {
//                           if (newValue != null) {
//                             rowStateFromConsumer.updateBrand(newValue, updateNewValuesCallback: updateCallback);
//                           }
//                         }
//                     );
//                   }
//               )
//           )
//       ),
//
//
//       // --- Category Cell ---
//       DataCell(
//           ChangeNotifierProvider.value(
//               value: state,
//               child: Consumer<RowState>( // Consumer rebuilds when fetchedCategories/isLoading changes
//                   builder: (cellContext, rowStateFromConsumer, _) {
//                     if (rowStateFromConsumer.isLoadingCategories) {
//                       return const Center(child: SizedBox(width: 15, height: 15, child: CircularProgressIndicator(strokeWidth: 2)));
//                     }
//                     final categories = rowStateFromConsumer.fetchedCategories;
//                     final valueToShow = categories.contains(rowStateFromConsumer.category)
//                         ? rowStateFromConsumer.category
//                         : (categories.isNotEmpty ? categories.first : '');
//
//                     return CellWidget<String>(
//                       isDropdown: true,
//                       value: valueToShow,
//                       options: categories.isNotEmpty ? categories : ['Select Brand'],
//                       onChanged: (newValue) {
//                         if (newValue != null) {
//                           rowStateFromConsumer.updateCategory(newValue, updateNewValuesCallback: updateCallback);
//                         }
//                       },
//                     );
//                   }
//               )
//           )
//       ),
//
//       // --- Product Cell ---
//       DataCell(
//           ChangeNotifierProvider.value(
//               value: state,
//               child: Consumer<RowState>( // Consumer rebuilds when fetchedProducts/isLoading changes
//                   builder: (cellContext, rowStateFromConsumer, _) {
//                     if (rowStateFromConsumer.isLoadingProducts) {
//                       return const Center(child: SizedBox(width: 15, height: 15, child: CircularProgressIndicator(strokeWidth: 2)));
//                     }
//                     final products = rowStateFromConsumer.fetchedProducts;
//                    // String valueToShow;
//                     // if (products.isEmpty) {
//                     //   valueToShow = null; // Or a default value like 'Loading...'
//                     // } else if (products.contains(rowStateFromConsumer.product)) {
//                     //   valueToShow = rowStateFromConsumer.product;
//                     // } else {
//                     //   valueToShow = products.first; // Fallback to the first product if current is not in the list
//                     // }
//                     final valueToShow = products.contains(rowStateFromConsumer.product)
//                         ? rowStateFromConsumer.product
//                         : (products.isNotEmpty ? products.first : 'Select Category');
//
//                     return CellWidget<String>(
//                       isDropdown: true,
//                       value: valueToShow,
//                       options: products.isNotEmpty ? products : ['Select Category'],
//                       onChanged: (newValue) {
//                         if (newValue != null) {
//                           rowStateFromConsumer.updateProduct(newValue, updateNewValuesCallback: updateCallback);
//                         }
//                       },
//                     );
//                   }
//               )
//           )
//       ),
//
//
//       // --- Warranty Date Cell ---
//       // (TextField doesn't strictly need Provider wrapper if just using controller)
//       DataCell(
//           _dateField(state.warrantyDateController, () => _selectDate(context, state.warrantyDateController, state.id, updateCallback, true))
//       ),
//       // --- Purchase Date Cell ---
//       DataCell(
//           _dateField(state.purchaseDateController, () => _selectDate(context, state.purchaseDateController, state.id, updateCallback, false))
//       )
//     ]);
//
//
//   }
//   // --- Employee Cell ---
//
// }
//
// // --- Helper for Date Field (Doesn't need its own provider) ---
// Widget _dateField(TextEditingController controller, VoidCallback onTap) {
//   return TextField(
//     controller: controller,
//     readOnly: true,
//     onTap: onTap,
//     decoration: const InputDecoration(border: InputBorder.none), // Keep it simple
//   );
// }
//
// // --- Helper for Date Picker (Needs context to show dialog) ---
// Future<void> _selectDate(
//     BuildContext context,         // Context to show DatePicker
//     TextEditingController controller,
//     String recordId,
//     Function(String, Map<String, dynamic>) updateCallback,
//     bool isWarranty) async {
//
//   final date = await showDatePicker(
//     context: context,
//     initialDate: DateTime.tryParse(controller.text) ?? DateTime.now(),
//     firstDate: DateTime(2000),
//     lastDate: DateTime(2100),
//   );
//   if (date != null) {
//     final formatted = DateFormat('yyyy-MM-dd').format(date);
//     controller.text = formatted; // Update controller directly
//     // Record change for saving
//     final fieldName = isWarranty ? 'warranty expiry date' : 'Purchase date';
//     updateCallback(recordId, {fieldName: formatted});
//   }
// }
//
//   // Build DataRow - Needs context to access the RowState provider for this row
//   // DataRow _buildDataRow(BuildContext context, Function(String, Map<String, dynamic>) updateCallback) {
//   //   // Access the specific RowState for this row using read or watch
//   //   // Using read here as the DataRow structure itself doesn't change based on RowState
//   //   final state = context.read<RowState>();
//   //
//   //   return DataRow(cells: [
//   //     // Customer Name Cell
//   //     DataCell(
//   //         CellWidget<String>(
//   //           isTextField: true,
//   //           value: state.nameController.text, // Read directly from controller
//   //           controller: state.nameController, // Pass controller
//   //           onChanged: (newValue) {
//   //             // No need to call state.updateName if just modifying controller
//   //             // But DO record the change for saving
//   //             updateCallback(state.id, {'Customer name': newValue});
//   //           },
//   //         )
//   //     ),
//   //
//   //     // Employee Cell (Uses main notifier for employee list)
//   //     DataCell(
//   //         _employeeDropdownCell(context, updateCallback) // Pass context
//   //     ),
//   //
//   //     // Status Cell
//   //     DataCell(
//   //         _statusDropdownCell(context, updateCallback) // Pass context
//   //     ),
//   //     // Brand Cell
//   //     DataCell(
//   //         _brandDropdownCell(context, updateCallback) // Pass context
//   //     ),
//   //     // Category Cell
//   //     DataCell(
//   //         _categoryDropdownCell(context, updateCallback) // Pass context
//   //     ),
//   //     // Product Cell
//   //     DataCell(
//   //         _productDropdownCell(context, updateCallback) // Pass context
//   //     ),
//   //
//   //     // Warranty Date Cell
//   //     DataCell(
//   //         _dateField(context, state.warrantyDateController, () => _selectDate(context, state.warrantyDateController, state.id, updateCallback, true) )
//   //     ),
//   //     // Purchase Date Cell
//   //     DataCell(
//   //         _dateField(context, state.purchaseDateController, () => _selectDate(context, state.purchaseDateController, state.id, updateCallback, false))
//   //     )
//   //   ]);
//   // }
//
//   // --- Cell Widget Builders ---
//   // These now need context to access RowState and potentially ComplaintDataNotifier
//
// //   // Employee Dropdown (Needs employee list from main notifier)
// //   Widget _employeeDropdownCell(BuildContext context, Function(String, Map<String, dynamic>) updateCallback) {
// //     // Watch the specific RowState for its current employee value
// //     final currentEmployee = context.select((RowState s) => s.employee);
// //     // Read the main notifier for the list of all employees
// //     final allEmployees = context.read<ComplaintDataNotifier>().employees;
// //     // Find a valid value (handle cases where saved employee might not be in the list)
// //     final valueToShow = allEmployees.contains(currentEmployee)
// //         ? currentEmployee
// //         : (allEmployees.isNotEmpty ? allEmployees.first : '');
// //
// //     return CellWidget<String>(
// //       isDropdown: true,
// //       value: valueToShow,
// //       options: allEmployees.isNotEmpty ? allEmployees : ['No employees'],
// //       onChanged: (newValue) {
// //         if (newValue != null) {
// //           // Call update method on the RowState via context.read
// //           context.read<RowState>().updateEmployee(newValue, updateNewValuesCallback: updateCallback);
// //         }
// //       },
// //     );
// //   }
// //
// //   // Status Dropdown
// //   Widget _statusDropdownCell(BuildContext context, Function(String, Map<String, dynamic>) updateCallback) {
// //     // Watch the specific RowState for its status
// //     final currentStatus = context.select((RowState s) => s.status);
// //     const statusOptions = ['Open', 'In Progress', 'Resolved'];
// //
// //     return CellWidget<String>(
// //       value: currentStatus, // Already validated in RowState
// //       options: statusOptions,
// //       isDropdown: true,
// //       onChanged: (newValue) {
// //         if (newValue != null) {
// //           context.read<RowState>().updateStatus(newValue, updateNewValuesCallback: updateCallback);
// //         }
// //       },
// //     );
// //   }
// //
// //   // Brand Dropdown (No external dependencies needed, uses RowState)
// //   Widget _brandDropdownCell(BuildContext context, Function(String, Map<String, dynamic>) updateCallback) {
// //     // Watch RowState for current brand and loading state
// //     final state = context.watch<RowState>();
// //     // Read available brands (Assuming fetched globally or passed down if needed,
// //     // otherwise RowState would need to fetch them - Let's assume static for now or fetch in main provider)
// //     // For simplicity, let's assume a fixed list or fetch it in ComplaintDataNotifier
// //     // final availableBrands = context.read<ComplaintDataNotifier>().availableBrands;
// //     // --- OR --- Fetch dynamically if needed (more complex)
// //     // Example: Fetching brands within RowState (adjust RowState accordingly)
// //     // if (!state.hasFetchedBrands) { // Add a flag in RowState
// //     //    state.fetchBrands(); // Add fetchBrands method to RowState
// //     //    return CircularProgressIndicator();
// //     // }
// //     // final availableBrands = state.fetchedBrands;
// //
// //     // *** Simplified Approach: Fetch brands ONCE in ComplaintDataNotifier ***
// //     // (Add _fetchBrands and List<String> _brands to ComplaintDataNotifier)
// //     final availableBrands = context.read<ComplaintDataNotifier>().brands; // Assuming you added this
// //
// //     // Handle loading state if fetching brands dynamically within RowState
// //     // if (state.isLoadingBrands) return CircularProgressIndicator();
// //
// //     final valueToShow = availableBrands.contains(state.brand)
// //         ? state.brand
// //         : (availableBrands.isNotEmpty ? availableBrands.first : '');
// //
// //     return CellWidget<String>(
// //         isDropdown: true,
// //         // TODO: Add logic to fetch availableBrands if dynamic
// //         options: availableBrands.isNotEmpty ? availableBrands : ['Loading...'],
// //         value: valueToShow,
// //         onChanged:(newValue) {
// //           if (newValue != null) {
// //             context.read<RowState>().updateBrand(newValue, updateNewValuesCallback: updateCallback);
// //           }
// //         }
// //     );
// //   }
// //
// //
// //   // Category Dropdown (Depends on RowState's fetched categories)
// //   Widget _categoryDropdownCell(BuildContext context, Function(String, Map<String, dynamic>) updateCallback) {
// //     // Watch the RowState for category list, selected value, and loading state
// //     final state = context.watch<RowState>();
// //
// //     if (state.isLoadingCategories) {
// //       return const Center(child: SizedBox(width: 15, height: 15, child: CircularProgressIndicator(strokeWidth: 2)));
// //     }
// //
// //     final categories = state.fetchedCategories;
// //     final valueToShow = categories.contains(state.category)
// //         ? state.category
// //         : (categories.isNotEmpty ? categories.first : ''); // Default if current invalid or list empty
// //
// //
// //     return CellWidget<String>(
// //       isDropdown: true,
// //       value: valueToShow,
// //       options: categories.isNotEmpty ? categories : ['Select Brand First'], // Handle empty/error states
// //       onChanged: (newValue) {
// //         if (newValue != null) {
// //           context.read<RowState>().updateCategory(newValue, updateNewValuesCallback: updateCallback);
// //         }
// //       },
// //     );
// //   }
// //
// //
// //   // Product Dropdown (Depends on RowState's fetched products)
// //   Widget _productDropdownCell(BuildContext context, Function(String, Map<String, dynamic>) updateCallback) {
// //     // Watch the RowState for product list, selected value, and loading state
// //     final state = context.watch<RowState>();
// //
// //     if (state.isLoadingProducts) {
// //       return const Center(child: SizedBox(width: 15, height: 15, child: CircularProgressIndicator(strokeWidth: 2)));
// //     }
// //
// //     final products = state.fetchedProducts;
// //     final valueToShow = products.contains(state.product)
// //         ? state.product
// //         : (products.isNotEmpty ? products.first : ''); // Default if current invalid or list empty
// //
// //
// //     return CellWidget<String>(
// //       isDropdown: true,
// //       value: valueToShow,
// //       options: products.isNotEmpty ? products : ['Select Category First'], // Handle empty/error states
// //       onChanged: (newValue) {
// //         if (newValue != null) {
// //           context.read<RowState>().updateProduct(newValue, updateNewValuesCallback: updateCallback);
// //         }
// //       },
// //     );
// //   }
// //
// //
// // // Date Field (Uses TextField controller from RowState)
// //   Widget _dateField(BuildContext context, TextEditingController controller, VoidCallback onTap) {
// //     // No need to watch RowState here as controller handles the text
// //     return TextField(
// //       controller: controller,
// //       readOnly: true,
// //       onTap: onTap,
// //       decoration: const InputDecoration(border: InputBorder.none), // Minimal look
// //     );
// //   }
// //
// //   // Date Picker Function (Needs context and access to RowState update method)
// //   Future<void> _selectDate(BuildContext context, TextEditingController controller, String recordId, Function(String, Map<String, dynamic>) updateCallback, bool isWarranty) async {
// //     final date = await showDatePicker(
// //       context: context,
// //       initialDate: DateTime.tryParse(controller.text) ?? DateTime.now(), // Use current date if parse fails
// //       firstDate: DateTime(2000),
// //       lastDate: DateTime(2100),
// //     );
// //     if (date != null) {
// //       final formatted = DateFormat('yyyy-MM-dd').format(date);
// //       // Update using the correct method in RowState via context.read
// //       // (We need to pass the callback down or access the main provider)
// //       if (isWarranty) {
// //         // Option 1: Call RowState method (if you add date updates there)
// //         // context.read<RowState>().updateWarrantyDate(formatted, updateNewValuesCallback: updateCallback);
// //         // Option 2: Update controller directly and call global updateCallback
// //         controller.text = formatted;
// //         updateCallback(recordId, {'warranty expiry date': formatted});
// //       } else {
// //         // context.read<RowState>().updatePurchaseDate(formatted, updateNewValuesCallback: updateCallback);
// //         controller.text = formatted;
// //         updateCallback(recordId, {'Purchase date': formatted});
// //       }
// //     }
// //   }
// // }
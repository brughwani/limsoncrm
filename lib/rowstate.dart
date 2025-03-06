import 'package:flutter/material.dart';

class RowState {
  String selectedBrand;
  List<String> categories;
  String selectedCategory;
  List<String> products;
  String selectedProduct;
  String? currentAllotment;
  String? currentStatus;
  String customerName;
  String phone;
  String city;


  final TextEditingController warrantyDateController;
  final TextEditingController purchaseDateController;
  String initialWarrantyDate; // Pass initial values
  String initialPurchaseDate;



  RowState({
    required this.selectedBrand,
    required this.city,
    required this.initialWarrantyDate,
    required this.initialPurchaseDate,


    this.categories = const [],
    this.selectedCategory = '',
    this.products = const [],
    this.selectedProduct = '',
    this.currentAllotment,
    this.currentStatus,

    this.customerName = '',
    required this.phone,

  }):
        warrantyDateController = TextEditingController(text: initialWarrantyDate),
        purchaseDateController = TextEditingController(text: initialPurchaseDate);
}
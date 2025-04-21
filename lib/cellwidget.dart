import 'package:flutter/material.dart';

class CellWidget<T> extends StatefulWidget {
  final T value;
  final List<T>? options; // For dropdowns
  final Function(T newValue) onChanged; // Callback for value changes
  final bool isDropdown; // Indicates whether this cell is a dropdown or not
  final bool isTextField;
  final bool isDate;// Indicates if it's a TextField (optional)
  TextEditingController? controller;

 CellWidget({
    required this.value,
    required this.onChanged,
    this.options,
  this.controller,
    this.isDropdown = false,
    this.isTextField = false,
    this.isDate=false,

   // Key? key, required Future<void> Function() onTapped,
  }) : super();

  @override
  _CellWidgetState<T> createState() => _CellWidgetState<T>();
}

class _CellWidgetState<T> extends State<CellWidget<T>> {
  late T currentValue;

  @override
  void initState() {
    super.initState();
    currentValue = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isDropdown) {
      return DropdownButton<T>(
        value: currentValue,
        items: widget.options
            ?.map((option) => DropdownMenuItem<T>(
          value: option,
          child: Text(option.toString()),
        ))
            .toList(),
        onChanged: (newValue) {
          if (newValue == null) return;
          setState(() {
            currentValue = newValue;
          });
          widget.onChanged(newValue);
        },
      );
    } else if (widget.isTextField) {
      return TextField(
        controller: TextEditingController(text: currentValue.toString()),
        onChanged: (newValue) {
          widget.onChanged(newValue as T); // Cast to T
        },
      );
    } else {
      return Text(currentValue.toString());
    }
  }
}
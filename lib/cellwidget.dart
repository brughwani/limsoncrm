import 'package:flutter/material.dart';

// class CellWidget<T> extends StatefulWidget {
//   final T value;
//   final List<T>? options; // For dropdowns
//   final Function(T newValue) onChanged; // Callback for value changes
//   final bool isDropdown; // Indicates whether this cell is a dropdown or not
//   final bool isTextField;
//   final bool isDate;// Indicates if it's a TextField (optional)
//   TextEditingController? controller;
//
//  CellWidget({
//     required this.value,
//     required this.onChanged,
//     this.options,
//   this.controller,
//     this.isDropdown = false,
//     this.isTextField = false,
//     this.isDate=false,
//
//    // Key? key, required Future<void> Function() onTapped,
//   }) : super();
//
//   @override
//   _CellWidgetState<T> createState() => _CellWidgetState<T>();
// }
//
// class _CellWidgetState<T> extends State<CellWidget<T>> {
//   late T currentValue;
//
//   @override
//   void initState() {
//     super.initState();
//     currentValue = widget.value;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (widget.isDropdown) {
//       return DropdownButton<T>(
//         value: currentValue,
//         items: widget.options
//             ?.map((option) => DropdownMenuItem<T>(
//           value: option,
//           child: Text(option.toString()),
//         ))
//             .toList(),
//         onChanged: (newValue) {
//           if (newValue == null) return;
//           setState(() {
//             currentValue = newValue;
//           });
//           widget.onChanged(newValue);
//         },
//       );
//     } else if (widget.isTextField) {
//       return TextField(
//         controller: TextEditingController(text: currentValue.toString()),
//         onChanged: (newValue) {
//           widget.onChanged(newValue as T); // Cast to T
//         },
//       );
//     } else {
//       return Text(currentValue.toString());
//     }
//   }
// }

class CellWidget<T> extends StatefulWidget {
  final T value;
  final List<T>? options;
  final Function(T newValue)? onChanged;
  final bool isDropdown;
  final bool isTextField;
  final bool isDate;
  final bool isenabled; // Default to enabled
  final TextEditingController? controller;

  const CellWidget({
    super.key,
    required this.value,
     this.onChanged,
    this.options,
    this.controller,
    this.isDropdown = false,
    this.isTextField = false,
    this.isDate = false,
    this.isenabled= true, // Default to enabled
  });

  @override
  _CellWidgetState<T> createState() => _CellWidgetState<T>();
}

class _CellWidgetState<T> extends State<CellWidget<T>> {
  late T _dropdownCurrentValue;

  @override
  void initState() {
    super.initState();
    _dropdownCurrentValue = widget.value;
  }

  @override
  void didUpdateWidget(covariant CellWidget<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != _dropdownCurrentValue && widget.isDropdown) {
      setState(() {
        _dropdownCurrentValue = widget.value;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isDropdown) {
      T? displayValue = widget.options?.contains(_dropdownCurrentValue) == true
          ? _dropdownCurrentValue
          : (widget.options != null && widget.options!.isNotEmpty
          ? widget.options!.first
          : null);

      return DropdownButton<T>(
        value: displayValue,
        hint: Text(
          widget.options == null || widget.options!.isEmpty
              ? 'Loading...'
              : 'Select...',
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).hintColor,
          ),
        ),
        items: widget.options
            ?.map((option) => DropdownMenuItem<T>(
          value: option,
          child: Text(
            option.toString(),
            overflow: TextOverflow.ellipsis,
          ),
        ))
            .toList(),
        onChanged: (newValue) {
          if (newValue == null) return;
          setState(() {
            _dropdownCurrentValue = newValue;
          });
          widget.onChanged!(newValue);
        },
        isExpanded: true,
        underline: const SizedBox(),
      );
    } else if (widget.isTextField) {
      if(widget.isenabled==false)
        {
          return TextField(
            controller: widget.controller,
            readOnly: widget.isDate,
            onChanged: (newValue) {
              widget.onChanged!(newValue as T);
            },
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 8),
            ),
          );
        }
      else {
        return TextField(
          controller: widget.controller,
          readOnly: widget.isDate,
          onChanged: (newValue) {
            widget.onChanged!(newValue as T);
          },
          decoration: const InputDecoration(
            border: InputBorder.none,
            isDense: true,
            contentPadding: EdgeInsets.symmetric(vertical: 8),
          ),
        );
      }
    } else {
      return Text(
        widget.value.toString(),
        overflow: TextOverflow.ellipsis,
      );
    }
  }
}
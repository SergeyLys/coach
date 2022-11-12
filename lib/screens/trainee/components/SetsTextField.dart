import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class SetsTextField extends StatefulWidget {
  final String initialValue;
  final Function(String value) onChangeCallback;
  final String placeholder;
  const SetsTextField({Key? key,
    required this.initialValue,
    required this.onChangeCallback,
    required this.placeholder
  }) : super(key: key);

  @override
  State<SetsTextField> createState() => _SetsTextFieldState();
}

class _SetsTextFieldState extends State<SetsTextField> {
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  onTextChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      widget.onChangeCallback(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      keyboardType: TextInputType.number,
      style: TextStyle(fontSize: 14),
      initialValue: widget.initialValue,
      decoration: InputDecoration(
        label: Text(
            widget.placeholder, style: TextStyle(fontSize: 10)),
      ),
      onChanged: onTextChanged,
    );
  }
}

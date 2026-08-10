import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';

class BmTextField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final int maxLines;
  final bool readOnly;
  final VoidCallback? onTap;

  const BmTextField({
    Key? key,
    required this.label,
    required this.hint,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.readOnly = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDark ? Tok.text2 : Tok.text2Light,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            readOnly: readOnly,
            onTap: onTap,
            style: TextStyle(fontSize: 14, color: isDark ? Tok.text : Tok.textLight),
            decoration: InputDecoration(
              hintText: hint,
            ),
          ),
        ],
      ),
    );
  }
}

class BmDropdown<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;

  const BmDropdown({
    Key? key,
    required this.label,
    required this.items,
    this.value,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDark ? Tok.text2 : Tok.text2Light,
            ),
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<T>(
            value: value,
            items: items,
            onChanged: onChanged,
            icon: Icon(Icons.arrow_drop_down, color: isDark ? Tok.text3 : Tok.text3Light),
            style: TextStyle(fontSize: 14, color: isDark ? Tok.text : Tok.textLight),
            decoration: const InputDecoration(),
            dropdownColor: isDark ? Tok.card2 : Tok.card2Light,
          ),
        ],
      ),
    );
  }
}

class BmDateSelect extends StatelessWidget {
  final String label;
  final String selectedDateStr;
  final VoidCallback onTap;

  const BmDateSelect({
    Key? key,
    required this.label,
    required this.selectedDateStr,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BmTextField(
      label: label,
      hint: '',
      controller: TextEditingController(text: selectedDateStr),
      readOnly: true,
      onTap: onTap,
    );
  }
}

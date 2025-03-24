import 'package:flutter/material.dart';

class SimpleDropdownWidget extends StatelessWidget {
  final String fieldName;
  final String hint;
  final Map<String, String> options;
  final Map<String, String> displayNames;
  final Map<String, String?> selectedValues;
  final Function(String, String?) onChanged;

  const SimpleDropdownWidget({
    super.key,
    required this.fieldName,
    required this.hint,
    required this.options,
    required this.displayNames,
    required this.selectedValues,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            displayNames[fieldName]!,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            isExpanded: true,
            value: selectedValues[fieldName],
            hint: Text(hint),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            items: options.entries.map((entry) {
              return DropdownMenuItem<String>(
                value: entry.key,
                child: Text(entry.value),
              );
            }).toList(),
            onChanged: (value) {
              onChanged(fieldName, value);
            },
            dropdownColor: Colors.white,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

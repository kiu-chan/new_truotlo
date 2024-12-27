// widgets/detail_row.dart
import 'package:flutter/material.dart';

class DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool showDivider;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;

  const DetailRow({
    super.key,
    required this.label,
    required this.value,
    this.showDivider = true,
    this.labelStyle,
    this.valueStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 100,
                child: Text(
                  label,
                  style: labelStyle ?? const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  value,
                  style: valueStyle ?? TextStyle(
                    fontSize: 13,
                    color: value == 'Chưa có dữ liệu' 
                        ? Colors.grey 
                        : Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            thickness: 0.5,
            color: Colors.grey.withOpacity(0.2),
          ),
      ],
    );
  }
}
import 'package:flutter/material.dart';

class DemoDataBanner extends StatelessWidget {
  const DemoDataBanner({
    required this.message,
    super.key,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4EA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFDCE6D8)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: Color(0xFF49684E),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF405747),
                    height: 1.4,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

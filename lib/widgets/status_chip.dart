import 'package:flutter/material.dart';

import '../models/laundry_order.dart';

/// Compact status pill used across customer and staff screens.
class StatusChip extends StatelessWidget {
  const StatusChip({required this.status, super.key});

  final LaundryStatus status;

  static const _palette = <LaundryStatus, ({Color background, Color text})>{
    LaundryStatus.received: (
      background: Color(0xFFEDF1EC),
      text: Color(0xFF4B5F52),
    ),
    LaundryStatus.washing: (
      background: Color(0xFFE7EFF8),
      text: Color(0xFF2F6690),
    ),
    LaundryStatus.drying: (
      background: Color(0xFFFFF3E2),
      text: Color(0xFF9A6519),
    ),
    LaundryStatus.readyForPickup: (
      background: Color(0xFFE3F0E4),
      text: Color(0xFF25603C),
    ),
    LaundryStatus.claimed: (
      background: Color(0xFFE9EFE7),
      text: Color(0xFF4A5B50),
    ),
  };

  @override
  Widget build(BuildContext context) {
    final colors = _palette[status]!;
    final isClaimed = status == LaundryStatus.claimed;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isClaimed ? Icons.check_circle_rounded : Icons.circle,
            size: isClaimed ? 15 : 9,
            color: colors.text,
          ),
          const SizedBox(width: 7),
          Text(
            status.label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: colors.text,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

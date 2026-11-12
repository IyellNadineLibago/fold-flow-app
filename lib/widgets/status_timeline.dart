import 'package:flutter/material.dart';

import '../models/laundry_order.dart';

class StatusTimeline extends StatelessWidget {
  const StatusTimeline({
    required this.currentStatus,
    super.key,
  });

  final LaundryStatus currentStatus;

  static const _statuses = LaundryStatus.values;

  @override
  Widget build(BuildContext context) {
    final currentIndex = _statuses.indexOf(currentStatus);

    return Column(
      children: [
        for (var index = 0; index < _statuses.length; index++)
          _TimelineRow(
            status: _statuses[index],
            isComplete: index < currentIndex,
            isCurrent: index == currentIndex,
            isLast: index == _statuses.length - 1,
          ),
      ],
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.status,
    required this.isComplete,
    required this.isCurrent,
    required this.isLast,
  });

  final LaundryStatus status;
  final bool isComplete;
  final bool isCurrent;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final color = isComplete || isCurrent
        ? const Color(0xFF356B4F)
        : const Color(0xFFD7DED8);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 34,
            child: Column(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: isCurrent ? color : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: color, width: 2),
                  ),
                  child: isComplete
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : isCurrent
                          ? const Icon(
                              Icons.circle,
                              size: 9,
                              color: Colors.white,
                            )
                          : null,
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 3),
                      color: isComplete
                          ? color
                          : const Color(0xFFE2E7E2),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Padding(
            padding: const EdgeInsets.only(top: 3, bottom: 22),
            child: Text(
              status.label,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: isCurrent
                        ? const Color(0xFF214A3A)
                        : isComplete
                            ? const Color(0xFF526159)
                            : const Color(0xFF87918A),
                    fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

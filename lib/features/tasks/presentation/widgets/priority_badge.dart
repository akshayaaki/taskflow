import 'package:flutter/material.dart';
import '../../../../domain/models/priority_enum.dart';

class PriorityBadge extends StatelessWidget {
  final TaskPriority priority;
  final bool isCompact;

  const PriorityBadge({
    super.key,
    required this.priority,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isCompact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: priority.color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: priority.color.withValues(alpha: 0.4),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(priority.icon, size: 12, color: priority.color),
            const SizedBox(width: 3),
            Text(
              priority.label,
              style: TextStyle(
                color: priority.color,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: priority.color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: priority.color.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(priority.icon, size: 16, color: priority.color),
          const SizedBox(width: 6),
          Text(
            priority.label,
            style: TextStyle(
              color: priority.color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

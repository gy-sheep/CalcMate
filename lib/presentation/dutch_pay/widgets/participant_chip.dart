import 'package:flutter/material.dart';

import '../../../core/theme/app_design_tokens.dart';

class ParticipantChip extends StatelessWidget {
  const ParticipantChip({
    super.key,
    required this.label,
    required this.bg,
    required this.fg,
    this.showDelete = false,
    this.isSelected = false,
    this.showSelectIndicator = false,
    this.onTap,
    this.onDelete,
  });

  final String label;
  final Color bg;
  final Color fg;
  final bool showDelete;
  final bool isSelected;
  final bool showSelectIndicator;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(
          horizontal: showDelete ? 8 : 12,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: isSelected ? fg.withValues(alpha: 0.15) : bg,
          borderRadius: BorderRadius.circular(CmTab.radius),
          border: Border.all(
            color: isSelected ? fg : fg.withValues(alpha: 0.3),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showSelectIndicator) ...[
              Icon(
                isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                size: CmTab.iconSize,
                color: isSelected ? fg : fg.withValues(alpha: 0.4),
              ),
              const SizedBox(width: 4),
            ],
            Icon(
              Icons.person,
              size: CmTab.iconSize,
              color: isSelected ? fg : fg.withValues(alpha: 0.6),
            ),
            const SizedBox(width: 2),
            Text(
              label,
              style: CmTab.text.copyWith(
                color: isSelected ? fg : fg.withValues(alpha: 0.6),
                fontWeight: FontWeight.w700,
              ),
            ),
            if (showDelete) ...[
              const SizedBox(width: 4),
              GestureDetector(
                onTap: onDelete,
                child: Icon(Icons.close, size: CmTab.iconSize, color: fg),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BadgeChip extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final IconData? icon;

  const BadgeChip({
    super.key,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    this.icon,
  });

  factory BadgeChip.success(String label, {IconData? icon}) {
    return BadgeChip(
      label: label,
      backgroundColor: const Color(0xFFD1FAE5),
      textColor: const Color(0xFF065F46),
      icon: icon,
    );
  }

  factory BadgeChip.danger(String label, {IconData? icon}) {
    return BadgeChip(
      label: label,
      backgroundColor: const Color(0xFFFEE2E2),
      textColor: const Color(0xFF991B1B),
      icon: icon,
    );
  }

  factory BadgeChip.warning(String label, {IconData? icon}) {
    return BadgeChip(
      label: label,
      backgroundColor: const Color(0xFFFEF3C7),
      textColor: const Color(0xFF92400E),
      icon: icon,
    );
  }

  factory BadgeChip.info(String label, {IconData? icon}) {
    return BadgeChip(
      label: label,
      backgroundColor: const Color(0xFFE0E7FF),
      textColor: const Color(0xFF3730A3),
      icon: icon,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: textColor),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

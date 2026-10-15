import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_text_styles.dart';

/// Bộ tăng/giảm số lượng [-] n [+]
class QuantityStepper extends StatelessWidget {
  final int quantity;
  final VoidCallback? onDecrement;
  final VoidCallback? onIncrement;

  const QuantityStepper({
    super.key,
    required this.quantity,
    this.onDecrement,
    this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppDimens.r12),
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepButton(
            icon: Icons.remove_rounded,
            tooltip: 'Giảm số lượng',
            onTap: onDecrement,
            filled: false,
          ),
          SizedBox(
            width: 34,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              transitionBuilder: (child, animation) => ScaleTransition(
                scale: animation,
                child: child,
              ),
              child: Text(
                '$quantity',
                key: ValueKey(quantity),
                textAlign: TextAlign.center,
                style: AppTextStyles.subtitle.copyWith(fontSize: 15),
              ),
            ),
          ),
          _StepButton(
            icon: Icons.add_rounded,
            tooltip: 'Tăng số lượng',
            onTap: onIncrement,
            filled: true,
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;
  final bool filled;

  const _StepButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    required this.filled,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    final bg = filled
        ? (enabled ? AppColors.primary : AppColors.lightBorder)
        : Colors.white;
    final fg = filled
        ? Colors.white
        : (enabled ? AppColors.textPrimary : AppColors.textLight);

    return Tooltip(
      message: tooltip,
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(AppDimens.r8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimens.r8),
          child: SizedBox(
            width: 30,
            height: 30,
            child: Icon(icon, size: 18, color: fg),
          ),
        ),
      ),
    );
  }
}

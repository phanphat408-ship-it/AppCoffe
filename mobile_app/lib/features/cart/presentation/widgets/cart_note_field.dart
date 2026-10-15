import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_text_styles.dart';

/// Ô ghi chú cho quán ("Ít đá", "Nhiều sữa"...) kèm các gợi ý chọn nhanh.
class CartNoteField extends StatefulWidget {
  final String initialValue;
  final int maxLength;
  final ValueChanged<String> onChanged;
  final bool enabled;

  const CartNoteField({
    super.key,
    required this.initialValue,
    required this.maxLength,
    required this.onChanged,
    this.enabled = true,
  });

  @override
  State<CartNoteField> createState() => _CartNoteFieldState();
}

class _CartNoteFieldState extends State<CartNoteField> {
  static const _suggestions = ['Ít đá', 'Không đá', 'Ít ngọt', 'Nhiều sữa', 'Mang đi'];

  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool _hasSuggestion(String s) =>
      _controller.text.split(',').map((e) => e.trim()).contains(s);

  /// Bật/tắt một gợi ý trong ghi chú (phân tách bằng dấu phẩy)
  void _toggleSuggestion(String s) {
    final parts = _controller.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    if (parts.contains(s)) {
      parts.remove(s);
    } else {
      parts.add(s);
    }

    final text = parts.join(', ');
    if (text.length > widget.maxLength) return; // Không cho vượt giới hạn

    _controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
    widget.onChanged(text);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimens.r16),
        border: Border.all(color: AppColors.lightBorder, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.edit_note_rounded, color: AppColors.primary, size: 22),
              const SizedBox(width: 8),
              Text('Ghi chú cho quán', style: AppTextStyles.subtitle.copyWith(fontSize: 14)),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _controller,
            enabled: widget.enabled,
            maxLength: widget.maxLength,
            minLines: 1,
            maxLines: 3,
            textInputAction: TextInputAction.done,
            style: AppTextStyles.bodyMedium,
            onChanged: (value) {
              widget.onChanged(value);
              setState(() {}); // Cập nhật trạng thái chip gợi ý
            },
            decoration: InputDecoration(
              isDense: true,
              hintText: 'Ví dụ: Ít đá, nhiều sữa...',
              hintStyle: AppTextStyles.bodyMediumSecondary,
              filled: true,
              fillColor: AppColors.background,
              counterStyle: AppTextStyles.caption,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimens.r12),
                borderSide: const BorderSide(color: AppColors.lightBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimens.r12),
                borderSide: const BorderSide(color: AppColors.lightBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimens.r12),
                borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _suggestions.map((s) {
              final selected = _hasSuggestion(s);
              return GestureDetector(
                onTap: widget.enabled ? () => _toggleSuggestion(s) : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.primary : AppColors.secondary.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(AppDimens.rFull),
                  ),
                  child: Text(
                    s,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: selected ? Colors.white : AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

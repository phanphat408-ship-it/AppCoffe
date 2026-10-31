import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../data/models/checkout_models.dart';

/// BottomSheet chọn hoặc nhập mã khuyến mãi (Voucher)
class VoucherSelectionSheet extends StatefulWidget {
  final int orderSubtotal;
  final VoucherModel? currentVoucher;

  const VoucherSelectionSheet({
    super.key,
    required this.orderSubtotal,
    this.currentVoucher,
  });

  static Future<VoucherModel?> show(
    BuildContext context, {
    required int orderSubtotal,
    VoucherModel? currentVoucher,
  }) {
    return showModalBottomSheet<VoucherModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => VoucherSelectionSheet(
        orderSubtotal: orderSubtotal,
        currentVoucher: currentVoucher,
      ),
    );
  }

  @override
  State<VoucherSelectionSheet> createState() => _VoucherSelectionSheetState();
}

class _VoucherSelectionSheetState extends State<VoucherSelectionSheet> {
  final TextEditingController _customCodeController = TextEditingController();
  VoucherModel? _selectedVoucher;

  @override
  void initState() {
    super.initState();
    _selectedVoucher = widget.currentVoucher;
  }

  @override
  void dispose() {
    _customCodeController.dispose();
    super.dispose();
  }

  void _applyCustomCode() {
    final code = _customCodeController.text.trim().toUpperCase();
    if (code.isEmpty) return;

    final found = VoucherModel.availableVouchers.firstWhere(
      (v) => v.code == code,
      orElse: () => VoucherModel(
        code: code,
        title: 'Mã đặc biệt $code',
        description: 'Giảm 10% tối đa 15.000đ',
        discountAmount: 15000,
      ),
    );

    if (widget.orderSubtotal < found.minOrderAmount) {
      AppSnackBar.error(
        context,
        'Đơn hàng chưa đạt mức tối thiểu ${CurrencyFormatter.vnd(found.minOrderAmount)} để dùng mã này.',
      );
      return;
    }

    setState(() => _selectedVoucher = found);
    Navigator.of(context).pop(found);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.78,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimens.r24)),
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10, bottom: 8),
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.lightBorder,
                borderRadius: BorderRadius.circular(AppDimens.rFull),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 6, 16, 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Chọn Mã Khuyến Mãi', style: AppTextStyles.subtitle.copyWith(fontSize: 16)),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                  onPressed: () => Navigator.of(context).pop(_selectedVoucher),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: AppColors.divider),

          // Ô nhập mã thủ công
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _customCodeController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      hintText: 'Nhập mã giảm giá (ví dụ: FREESHIP)',
                      hintStyle: AppTextStyles.caption.copyWith(color: AppColors.textLight),
                      filled: true,
                      fillColor: AppColors.background,
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
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _applyCustomCode,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimens.r12),
                    ),
                  ),
                  child: const Text('Áp dụng', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),

          // Danh sách Voucher có sẵn
          Expanded(
            child: ListView.separated(
              cacheExtent: 300,
              addRepaintBoundaries: true,
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
              itemCount: VoucherModel.availableVouchers.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final voucher = VoucherModel.availableVouchers[index];
                final isSelected = _selectedVoucher?.code == voucher.code;
                final isEligible = widget.orderSubtotal >= voucher.minOrderAmount;

                return InkWell(
                  onTap: isEligible
                      ? () {
                          setState(() => _selectedVoucher = voucher);
                          Navigator.of(context).pop(voucher);
                        }
                      : null,
                  borderRadius: BorderRadius.circular(AppDimens.r16),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary.withValues(alpha: 0.06)
                          : (isEligible ? Colors.white : AppColors.background),
                      borderRadius: BorderRadius.circular(AppDimens.r16),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : (isEligible ? AppColors.lightBorder : AppColors.divider),
                        width: isSelected ? 1.5 : 1.0,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Icon vé ưu đãi
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: voucher.isFreeship
                                ? const Color(0xFF00A651).withValues(alpha: 0.12)
                                : AppColors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(AppDimens.r12),
                          ),
                          child: Icon(
                            voucher.isFreeship ? Icons.local_shipping_rounded : Icons.local_offer_rounded,
                            color: voucher.isFreeship ? const Color(0xFF00A651) : AppColors.primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    voucher.title,
                                    style: AppTextStyles.subtitle.copyWith(
                                      fontSize: 14,
                                      color: isEligible ? AppColors.textPrimary : AppColors.textLight,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: AppColors.background,
                                      borderRadius: BorderRadius.circular(AppDimens.r4),
                                      border: Border.all(color: AppColors.lightBorder),
                                    ),
                                    child: Text(
                                      voucher.code,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: isEligible ? AppColors.primary : AppColors.textLight,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              Text(
                                voucher.description,
                                style: AppTextStyles.caption.copyWith(
                                  color: isEligible ? AppColors.textSecondary : AppColors.textLight,
                                  fontSize: 11.5,
                                ),
                              ),
                              if (!isEligible) ...[
                                const SizedBox(height: 3),
                                Text(
                                  'Cần mua thêm ${CurrencyFormatter.vnd(voucher.minOrderAmount - widget.orderSubtotal)} để dùng mã',
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.error,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.primary
                                  : (isEligible ? AppColors.lightBorder : Colors.black12),
                              width: isSelected ? 6 : 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

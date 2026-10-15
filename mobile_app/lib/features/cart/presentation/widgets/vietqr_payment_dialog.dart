import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_network_image.dart';

/// Modal / Dialog Thanh toán Chuyển khoản VietQR động chuyên nghiệp
/// Sử dụng API VietQR động (img.vietqr.io) với đầy đủ thông tin:
/// - Ảnh mã QR thật
/// - Số tài khoản, Ngân hàng, Chủ tài khoản, Số tiền, Nội dung
/// - Nút Sao chép tiện lợi
/// - Đồng hồ đếm ngược 10 phút
/// - Nút xác nhận "Tôi đã chuyển khoản"
class VietQrPaymentDialog extends StatefulWidget {
  final String orderCode;
  final int totalAmount;
  final String bankName;
  final String accountNumber;
  final String accountName;
  final VoidCallback onPaymentConfirmed;

  const VietQrPaymentDialog({
    super.key,
    required this.orderCode,
    required this.totalAmount,
    this.bankName = 'MB Bank (Ngân Hàng Quân Đội)',
    this.accountNumber = '0123456789',
    this.accountName = 'COFFEE SHOP VIETNAM',
    required this.onPaymentConfirmed,
  });

  static Future<bool?> show({
    required BuildContext context,
    required String orderCode,
    required int totalAmount,
    required VoidCallback onPaymentConfirmed,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => VietQrPaymentDialog(
        orderCode: orderCode,
        totalAmount: totalAmount,
        onPaymentConfirmed: onPaymentConfirmed,
      ),
    );
  }

  @override
  State<VietQrPaymentDialog> createState() => _VietQrPaymentDialogState();
}

class _VietQrPaymentDialogState extends State<VietQrPaymentDialog> {
  late int _remainingSeconds;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = 600; // 10 phút
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds <= 1) {
        timer.cancel();
        setState(() => _remainingSeconds = 0);
      } else {
        setState(() => _remainingSeconds--);
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  String get _formattedTime {
    final minutes = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  String get _transferContent => 'THANHTOAN ${widget.orderCode}';

  String get _vietQrUrl {
    final safeContent = Uri.encodeComponent(_transferContent);
    final safeAccount = Uri.encodeComponent(widget.accountName);
    return 'https://img.vietqr.io/image/MB-${widget.accountNumber}-compact2.png?amount=${widget.totalAmount}&addInfo=$safeContent&accountName=$safeAccount';
  }

  void _copyToClipboard(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    AppSnackBar.success(context, 'Đã sao chép $label: "$text"');
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.r24),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 420),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimens.r24),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 1. Header & Huy hiệu VietQR
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF003B70).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(AppDimens.r12),
                        ),
                        child: const Icon(Icons.qr_code_2_rounded, color: Color(0xFF003B70), size: 24),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Thanh Toán VietQR',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF003B70),
                            ),
                          ),
                          Text(
                            'Mã đơn: #${widget.orderCode}',
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // 2. Đồng hồ đếm ngược 10 phút
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF4E5),
                  borderRadius: BorderRadius.circular(AppDimens.r12),
                  border: Border.all(color: const Color(0xFFFFB74D)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.timer_outlined, color: Color(0xFFE65100), size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Mã QR hết hạn sau: ',
                      style: AppTextStyles.caption.copyWith(
                        color: const Color(0xFFE65100),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      _formattedTime,
                      style: const TextStyle(
                        color: Color(0xFFE65100),
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // 3. Hình ảnh mã VietQR thật nét căng
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppDimens.r16),
                  border: Border.all(color: AppColors.lightBorder, width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppDimens.r12),
                  child: AppNetworkImage(
                    imageUrl: _vietQrUrl,
                    width: 220,
                    height: 220,
                    fit: BoxFit.contain,
                    fallbackIcon: Icons.qr_code_scanner_rounded,
                    cacheWidth: 700,
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // 4. Bảng thông tin chuyển khoản với nút Sao chép nhanh
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(AppDimens.r14),
                  border: Border.all(color: AppColors.lightBorder),
                ),
                child: Column(
                  children: [
                    _buildInfoRow(
                      context: context,
                      label: 'Ngân hàng',
                      value: widget.bankName,
                      showCopy: false,
                    ),
                    const Divider(height: 16, color: AppColors.lightBorder),
                    _buildInfoRow(
                      context: context,
                      label: 'Số tài khoản',
                      value: widget.accountNumber,
                      copyValue: widget.accountNumber,
                      showCopy: true,
                      isHighlight: true,
                    ),
                    const Divider(height: 16, color: AppColors.lightBorder),
                    _buildInfoRow(
                      context: context,
                      label: 'Chủ tài khoản',
                      value: widget.accountName,
                      showCopy: false,
                    ),
                    const Divider(height: 16, color: AppColors.lightBorder),
                    _buildInfoRow(
                      context: context,
                      label: 'Số tiền cần chuyển',
                      value: CurrencyFormatter.vnd(widget.totalAmount),
                      copyValue: widget.totalAmount.toString(),
                      showCopy: true,
                      isPrice: true,
                    ),
                    const Divider(height: 16, color: AppColors.lightBorder),
                    _buildInfoRow(
                      context: context,
                      label: 'Nội dung chuyển khoản',
                      value: _transferContent,
                      copyValue: _transferContent,
                      showCopy: true,
                      isHighlight: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Lưu ý
              Text(
                '💡 Vui lòng giữ nguyên nội dung chuyển khoản để hệ thống tự động xác nhận đơn hàng.',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 18),

              // 5. Nút xác nhận "Tôi đã chuyển khoản"
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                    widget.onPaymentConfirmed();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF003B70),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimens.r14),
                    ),
                  ),
                  icon: const Icon(Icons.check_circle_rounded, size: 20),
                  label: const Text(
                    'Tôi Đã Chuyển Khoản',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                ),
              ),

              const SizedBox(height: 6),

              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  'Đổi phương thức thanh toán khác',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required BuildContext context,
    required String label,
    required String value,
    String? copyValue,
    bool showCopy = false,
    bool isHighlight = false,
    bool isPrice = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 4,
          child: Text(
            label,
            style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
          ),
        ),
        Expanded(
          flex: 6,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: isPrice ? 15 : 13,
                    fontWeight: (isHighlight || isPrice) ? FontWeight.w700 : FontWeight.w500,
                    color: isPrice
                        ? AppColors.primary
                        : (isHighlight ? const Color(0xFF003B70) : AppColors.textPrimary),
                  ),
                  textAlign: TextAlign.end,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (showCopy && copyValue != null) ...[
                const SizedBox(width: 4),
                InkWell(
                  onTap: () => _copyToClipboard(context, copyValue, label),
                  borderRadius: BorderRadius.circular(AppDimens.r6),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppDimens.r6),
                    ),
                    child: const Icon(
                      Icons.copy_rounded,
                      size: 14,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

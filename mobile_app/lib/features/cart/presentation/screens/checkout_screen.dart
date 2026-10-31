import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../branches/presentation/controllers/branch_notifier.dart';
import '../../../main/presentation/screens/main_screen.dart';
import '../../../orders/presentation/controllers/order_tracking_notifier.dart';
import '../../data/models/cart_item.dart';
import '../../data/models/checkout_models.dart';
import '../../data/models/order_models.dart';
import '../../data/repositories/order_repository.dart';
import '../controllers/cart_notifier.dart';
import '../controllers/checkout_notifier.dart';
import '../widgets/vietqr_payment_dialog.dart';
import '../widgets/voucher_selection_sheet.dart';
import '../../../profile/presentation/controllers/saved_addresses_notifier.dart';
import '../../../profile/data/models/saved_address_model.dart';

/// Màn hình Xác nhận đơn hàng (Checkout Screen) chuẩn siêu ứng dụng Grab / Be / Xanh SM
class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  DeliveryType _deliveryType = DeliveryType.delivery;
  PaymentMethod _paymentMethod = PaymentMethod.vietqr;
  VoucherModel? _appliedVoucher;
  late final TextEditingController _addressController;
  late final TextEditingController _noteController;
  bool _isEditingAddress = false;
  bool _isSubmittingOrder = false;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController(
      text: ref.read(cartNoteProvider),
    );
    final saved = ref.read(savedAddressesProvider);
    final defaultAddr = saved.firstWhere(
      (a) => a.isDefault,
      orElse: () => saved.isNotEmpty
          ? saved.first
          : const SavedAddress(
              id: 'addr_1',
              title: 'Nhà riêng',
              recipientName: 'Khách hàng',
              phone: '0901 234 567',
              fullAddress: '123 Lê Lợi, Phường Bến Nghé, Quận 1, TP. Hồ Chí Minh',
            ),
    );
    _addressController = TextEditingController(text: defaultAddr.fullAddress);
  }

  @override
  void dispose() {
    _addressController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  int get _deliveryFee {
    if (_deliveryType == DeliveryType.takeaway || _deliveryType == DeliveryType.dineIn) {
      return 0;
    }
    if (_appliedVoucher?.isFreeship == true) {
      return 0;
    }
    return CartConfig.deliveryFee;
  }

  int get _discountAmount {
    if (_appliedVoucher == null) return 0;
    if (_appliedVoucher!.isFreeship) {
      return CartConfig.deliveryFee;
    }
    return _appliedVoucher!.discountAmount;
  }

  int _calculateGrandTotal(int subtotal) {
    final rawTotal = subtotal + _deliveryFee - _discountAmount;
    return rawTotal > 0 ? rawTotal : 0;
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(cartNotifierProvider);
    final subtotal = ref.watch(cartTotalProvider);
    final grandTotal = _calculateGrandTotal(subtotal);
    final selectedBranch = ref.watch(branchNotifierProvider.select((s) => s.effectiveOrderBranch));
    final isSubmitting = ref.watch(
      checkoutNotifierProvider.select((s) => s.isSubmitting),
    ) || _isSubmittingOrder;

    if (items.isEmpty && !_isSubmittingOrder) {
      return Scaffold(
        appBar: AppBar(title: const Text('Xác Nhận Đơn Hàng')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.shopping_cart_outlined, size: 64, color: AppColors.textLight),
              const SizedBox(height: 14),
              Text('Giỏ hàng của bạn đang trống', style: AppTextStyles.subtitle),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go(AppRoutes.home),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                child: const Text('Xem Thực Đơn', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 0.5,
        centerTitle: true,
        title: Text(
          'Xác Nhận Đơn Hàng',
          style: AppTextStyles.h3.copyWith(fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: isSubmitting ? null : () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Tùy chọn Nhận hàng: Giao tận nơi vs Tự đến lấy
            _buildDeliveryTypeSelector(),

            const SizedBox(height: 14),

            // 2. Khu vực Địa chỉ nhận hàng & Chi nhánh quán
            _buildLocationSection(selectedBranch),

            const SizedBox(height: 14),

            // 3. Tóm tắt món ăn trong giỏ
            _buildItemsSummaryCard(items),

            const SizedBox(height: 14),

            // 4. Ghi chú cho quán
            _buildStoreNoteCard(),

            const SizedBox(height: 14),

            // 5. Chọn Mã khuyến mãi (Voucher)
            _buildVoucherSection(subtotal),

            const SizedBox(height: 14),

            // 6. Chọn Phương thức thanh toán (COD / VietQR / Ví điện tử)
            _buildPaymentMethodsSection(),

            const SizedBox(height: 14),

            // 7. Bảng Chi tiết thanh toán (Tạm tính + Phí ship - Giảm giá = Tổng cộng)
            _buildBillingCard(subtotal, grandTotal),

            const SizedBox(height: 20),
          ],
        ),
      ),

      // Bottom Bar: Tổng thanh toán & Nút Đặt đơn hàng
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              Expanded(
                flex: 5,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tổng thanh toán', style: AppTextStyles.caption),
                    Text(
                      CurrencyFormatter.vnd(grandTotal),
                      style: AppTextStyles.price.copyWith(
                        fontSize: 20,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 6,
                child: AppButton(
                  title: _paymentMethod == PaymentMethod.vietqr
                      ? 'Thanh Toán QR'
                      : 'Đặt Đơn Hàng',
                  isLoading: isSubmitting,
                  icon: Icon(
                    _paymentMethod == PaymentMethod.vietqr
                        ? Icons.qr_code_2_rounded
                        : Icons.check_circle_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: isSubmitting
                      ? null
                      : () {
                          // Bọc an toàn sự kiện bấm nút để tránh xung đột chu kỳ build
                          Future.microtask(() {
                            if (!mounted) return;
                            _handlePlaceOrder(grandTotal, selectedBranch);
                          });
                        },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Bộ chọn: Giao tận nơi 🛵 vs Tự đến lấy 🛍️
  Widget _buildDeliveryTypeSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimens.r14),
        border: Border.all(color: AppColors.lightBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTypeTab(
              type: DeliveryType.delivery,
              label: '🛵 Giao tận nơi',
              isSelected: _deliveryType == DeliveryType.delivery,
            ),
          ),
          Expanded(
            child: _buildTypeTab(
              type: DeliveryType.takeaway,
              label: '🛍️ Tự đến lấy',
              isSelected: _deliveryType == DeliveryType.takeaway,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeTab({
    required DeliveryType type,
    required String label,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => setState(() => _deliveryType = type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(AppDimens.r12),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  /// Khu vực Chi nhánh & Địa chỉ nhận hàng
  Widget _buildLocationSection(dynamic selectedBranch) {
    final branchName = selectedBranch?.name ?? 'Chi Nhánh Quận 1 - Nguyễn Huệ';
    final branchAddress = selectedBranch?.address ?? '68 Nguyễn Huệ, P. Bến Nghé, Quận 1, TP.HCM';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimens.r16),
        border: Border.all(color: AppColors.lightBorder),
        boxShadow: [AppColors.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Quán chuẩn bị (Chi nhánh)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.storefront_rounded, color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quán pha chế món',
                      style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                    ),
                    Text(
                      branchName,
                      style: AppTextStyles.subtitle.copyWith(fontSize: 14),
                    ),
                    Text(
                      branchAddress,
                      style: AppTextStyles.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1, color: AppColors.lightBorder),
          ),

          // 2. Địa chỉ giao đến của khách
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF00A651).withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.location_on_rounded, color: Color(0xFF00A651), size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _deliveryType == DeliveryType.delivery ? 'Giao đến cho bạn' : 'Địa chỉ quán bạn đến lấy',
                          style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
                        ),
                        if (_deliveryType == DeliveryType.delivery)
                          InkWell(
                            onTap: () {
                              if (_isEditingAddress) {
                                setState(() => _isEditingAddress = false);
                              } else {
                                _showAddressPickerSheet();
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(AppDimens.r6),
                              ),
                              child: Text(
                                _isEditingAddress ? 'Xong' : 'Thay đổi',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (_isEditingAddress) ...[
                      const SizedBox(height: 6),
                      TextField(
                        controller: _addressController,
                        style: const TextStyle(fontSize: 13),
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppDimens.r8)),
                          hintText: 'Nhập địa chỉ nhận hàng tại TP.HCM...',
                        ),
                      ),
                    ] else ...[
                      const SizedBox(height: 2),
                      Text(
                        _addressController.text,
                        style: AppTextStyles.bodyMedium.copyWith(fontSize: 13.5, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 3. Badges: Thời gian dự kiến & Khoảng cách
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppDimens.r10),
            ),
            child: Row(
              children: [
                const Icon(Icons.bolt_rounded, color: AppColors.rating, size: 18),
                const SizedBox(width: 6),
                Text(
                  'Dự kiến: ${selectedBranch?.formattedEta ?? "15 - 20 phút"}',
                  style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                const Icon(Icons.directions_bike_rounded, color: AppColors.primary, size: 16),
                const SizedBox(width: 4),
                Text(
                  selectedBranch?.distanceInKm != null
                      ? 'Cách ${selectedBranch!.formattedDistance}'
                      : 'Khu vực TP.HCM',
                  style: AppTextStyles.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Mở bottom sheet chọn nhanh địa chỉ từ Sổ địa chỉ TP.HCM hoặc gõ mới
  void _showAddressPickerSheet() {
    final savedAddresses = ref.read(savedAddressesProvider);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimens.r20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('Địa chỉ nhận hàng tại TP.HCM', style: AppTextStyles.h3),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    cacheExtent: 300,
                    addRepaintBoundaries: true,
                    itemCount: savedAddresses.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (_, index) {
                      final item = savedAddresses[index];
                      final isSelected = _addressController.text.trim() == item.fullAddress.trim();
                      return Material(
                        color: Colors.transparent,
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(vertical: 4),
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primary.withValues(alpha: 0.15) : AppColors.background,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              item.title.contains('Nhà') ? Icons.home_rounded : Icons.business_rounded,
                              color: isSelected ? AppColors.primary : AppColors.textSecondary,
                              size: 20,
                            ),
                          ),
                          title: Row(
                            children: [
                              Text(item.title, style: AppTextStyles.subtitle.copyWith(fontSize: 14)),
                              if (item.isDefault) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text('Mặc định', style: AppTextStyles.caption.copyWith(color: AppColors.primary, fontSize: 10)),
                                ),
                              ],
                            ],
                          ),
                          subtitle: Text(item.fullAddress, style: AppTextStyles.bodySmall, maxLines: 2),
                          trailing: isSelected ? const Icon(Icons.check_circle_rounded, color: AppColors.primary) : null,
                          onTap: () {
                            setState(() {
                              _addressController.text = item.fullAddress;
                              _isEditingAddress = false;
                            });
                            Navigator.pop(ctx);
                          },
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                Material(
                  color: Colors.transparent,
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppColors.background,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.edit_location_alt_rounded, color: AppColors.primary, size: 20),
                    ),
                    title: Text('Nhập địa chỉ tùy chỉnh khác', style: AppTextStyles.subtitle.copyWith(fontSize: 14, color: AppColors.primary)),
                    onTap: () {
                      Navigator.pop(ctx);
                      setState(() => _isEditingAddress = true);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Danh sách món tóm tắt
  Widget _buildItemsSummaryCard(List<dynamic> items) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimens.r16),
        border: Border.all(color: AppColors.lightBorder),
        boxShadow: [AppColors.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Món đã chọn (${items.length})', style: AppTextStyles.subtitle.copyWith(fontSize: 15)),
              InkWell(
                onTap: () => context.pop(),
                child: const Text('Thêm món >', style: TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (final item in items) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppDimens.r8),
                    child: SizedBox(
                      width: 46,
                      height: 46,
                      child: AppNetworkImage(
                        imageUrl: item.product.imageUrl,
                        width: 46,
                        height: 46,
                        fit: BoxFit.cover,
                        cacheWidth: 100,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${item.quantity}x ${item.product.name}',
                          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600, fontSize: 13.5),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (item.optionsSummary.isNotEmpty)
                          Text(
                            item.optionsSummary,
                            style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary, fontSize: 11),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    item.formattedLineTotal,
                    style: AppTextStyles.subtitle.copyWith(fontSize: 13.5),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Ghi chú cho quán
  Widget _buildStoreNoteCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimens.r16),
        border: Border.all(color: AppColors.lightBorder),
        boxShadow: [AppColors.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.edit_note_rounded, color: AppColors.primary, size: 20),
              const SizedBox(width: 6),
              Text('Ghi chú cho quán', style: AppTextStyles.subtitle.copyWith(fontSize: 14)),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _noteController,
            decoration: InputDecoration(
              hintText: 'Ví dụ: Ít ngọt, lấy thêm muỗng & ống hút giấy...',
              hintStyle: AppTextStyles.caption.copyWith(color: AppColors.textLight),
              filled: true,
              fillColor: AppColors.background,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppDimens.r10),
                borderSide: const BorderSide(color: AppColors.lightBorder),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Khu vực Voucher
  Widget _buildVoucherSection(int subtotal) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimens.r16),
        border: Border.all(color: AppColors.lightBorder),
        boxShadow: [AppColors.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () async {
              final selected = await VoucherSelectionSheet.show(
                context,
                orderSubtotal: subtotal,
                currentVoucher: _appliedVoucher,
              );
              if (selected != null) {
                setState(() => _appliedVoucher = selected);
              }
            },
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFB74D).withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.local_offer_rounded, color: Color(0xFFE65100), size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Mã khuyến mãi / Voucher', style: AppTextStyles.subtitle.copyWith(fontSize: 14)),
                      Text(
                        _appliedVoucher != null
                            ? 'Đã áp dụng: ${_appliedVoucher!.title} (-${CurrencyFormatter.vnd(_discountAmount)})'
                            : 'Chọn hoặc nhập mã giảm giá',
                        style: AppTextStyles.caption.copyWith(
                          color: _appliedVoucher != null ? const Color(0xFF00A651) : AppColors.textSecondary,
                          fontWeight: _appliedVoucher != null ? FontWeight.w700 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_appliedVoucher != null)
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.textSecondary),
                    onPressed: () => setState(() => _appliedVoucher = null),
                  )
                else
                  const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textSecondary),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Khu vực Chọn Phương thức thanh toán (COD / VietQR / Ví điện tử)
  Widget _buildPaymentMethodsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimens.r16),
        border: Border.all(color: AppColors.lightBorder),
        boxShadow: [AppColors.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.account_balance_wallet_rounded, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text('Phương thức thanh toán', style: AppTextStyles.subtitle.copyWith(fontSize: 15)),
            ],
          ),
          const SizedBox(height: 12),
          for (final method in PaymentMethod.values) ...[
            _buildPaymentMethodTile(method),
            if (method != PaymentMethod.values.last)
              const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentMethodTile(PaymentMethod method) {
    final isSelected = _paymentMethod == method;

    return InkWell(
      onTap: () => setState(() => _paymentMethod = method),
      borderRadius: BorderRadius.circular(AppDimens.r12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.06) : AppColors.background,
          borderRadius: BorderRadius.circular(AppDimens.r12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.lightBorder,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: method.badgeColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppDimens.r8),
              ),
              child: Icon(method.icon, color: method.badgeColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        method.title,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          fontSize: 13.5,
                        ),
                      ),
                      if (method.isRecommended) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: const Color(0xFF003B70),
                            borderRadius: BorderRadius.circular(AppDimens.r4),
                          ),
                          child: const Text(
                            'Khuyên dùng',
                            style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    method.subtitle,
                    style: AppTextStyles.caption.copyWith(fontSize: 11),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.lightBorder,
                  width: isSelected ? 6 : 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Bảng Chi tiết thanh toán
  Widget _buildBillingCard(int subtotal, int grandTotal) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimens.r16),
        border: Border.all(color: AppColors.lightBorder),
        boxShadow: [AppColors.cardShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Chi tiết thanh toán', style: AppTextStyles.subtitle.copyWith(fontSize: 15)),
          const SizedBox(height: 12),
          _buildBillingRow('Tạm tính tiền món', CurrencyFormatter.vnd(subtotal)),
          const SizedBox(height: 8),
          _buildBillingRow(
            'Phí giao hàng',
            _deliveryFee == 0 ? 'Miễn phí' : CurrencyFormatter.vnd(_deliveryFee),
            isFree: _deliveryFee == 0,
          ),
          if (_discountAmount > 0) ...[
            const SizedBox(height: 8),
            _buildBillingRow(
              'Giảm giá voucher',
              '-${CurrencyFormatter.vnd(_discountAmount)}',
              isDiscount: true,
            ),
          ],
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1, color: AppColors.lightBorder),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Tổng thanh toán', style: AppTextStyles.subtitle.copyWith(fontSize: 15)),
              Text(
                CurrencyFormatter.vnd(grandTotal),
                style: AppTextStyles.price.copyWith(fontSize: 18, color: AppColors.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBillingRow(String label, String value, {bool isDiscount = false, bool isFree = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.bodyMediumSecondary.copyWith(fontSize: 13)),
        Text(
          value,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w600,
            color: isDiscount
                ? const Color(0xFF00A651)
                : (isFree ? const Color(0xFF00A651) : AppColors.textPrimary),
          ),
        ),
      ],
    );
  }

  /// Xử lý bấm Đặt đơn hàng
  Future<void> _handlePlaceOrder(int grandTotal, dynamic selectedBranch) async {
    if (_isSubmittingOrder) return;

    final now = DateTime.now();
    final randomCode = 'CF${now.millisecondsSinceEpoch.toString().substring(7)}';

    if (_paymentMethod == PaymentMethod.vietqr) {
      // 1. Mở Modal Thanh toán VietQR động
      await VietQrPaymentDialog.show(
        context: context,
        orderCode: randomCode,
        totalAmount: grandTotal,
        onPaymentConfirmed: () => _finalizeOrder(grandTotal, selectedBranch),
      );
    } else {
      // 2. Tiền mặt (COD) hoặc Ví điện tử -> Đặt trực tiếp
      await _finalizeOrder(grandTotal, selectedBranch);
    }
  }

  Future<void> _finalizeOrder(int grandTotal, dynamic selectedBranch) async {
    if (_isSubmittingOrder) return;

    final items = List<CartItem>.from(ref.read(cartNotifierProvider));
    if (items.isEmpty) {
      AppSnackBar.error(context, 'Giỏ hàng của bạn đang trống.');
      return;
    }

    setState(() => _isSubmittingOrder = true);

    final branchName = (selectedBranch?.name as String?) ?? 'Chi Nhánh Quận 1 - Nguyễn Huệ';
    final branchId = (selectedBranch?.id as int?) ?? 1;
    final shippingAddress = _addressController.text.trim();
    final note = _noteController.text.trim();
    final saved = ref.read(savedAddressesProvider);
    final phone = saved.isNotEmpty ? saved.first.phone : '0901234567';

    final orderRequest = OrderRequest(
      items: items,
      subtotal: grandTotal - _deliveryFee + _discountAmount,
      deliveryFee: _deliveryFee,
      discount: _discountAmount,
      total: grandTotal,
      note: note.isNotEmpty ? note : null,
      deliveryType: _deliveryType,
      branchId: branchId,
      branchName: branchName,
      shippingAddress: _deliveryType == DeliveryType.delivery
          ? (shippingAddress.isNotEmpty ? shippingAddress : '123 Hai Bà Trưng, P. Bến Nghé, Quận 1, TP.HCM')
          : (selectedBranch?.address as String? ?? '68 Nguyễn Huệ, P. Bến Nghé, Quận 1, TP.HCM'),
      contactPhone: phone,
      paymentMethod: _paymentMethod,
      voucherCode: _appliedVoucher?.code,
    );

    try {
      // BẮT BUỘC gọi API sang Backend và kiểm tra HTTP statusCode
      final orderResult = await ref.read(orderRepositoryProvider).submitOrder(orderRequest);

      // TUYỆT ĐỐI CHỈ KHI API THÀNH CÔNG (HTTP 200/201) MỚI TIẾN HÀNH BÁO THÀNH CÔNG VÀ CHUYỂN TRANG
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        // 1. Gửi đơn hàng vào hệ thống theo dõi đơn hàng thời gian thực
        ref.read(orderTrackingNotifierProvider.notifier).addNewOrder(orderResult);

        // 2. Làm sạch giỏ hàng & ghi chú an toàn ngoài chu kỳ build
        ref.read(cartNotifierProvider.notifier).clearCart();
        ref.read(cartNoteProvider.notifier).clear();

        // 3. Đổi tab sang Tab Đơn hàng (index 1)
        ref.read(mainTabIndexProvider.notifier).setTab(1);

        // 4. Hiển thị thông báo thành công
        AppSnackBar.success(context, '🎉 Đặt hàng thành công! Mã đơn: #${orderResult.orderCode}');

        // 5. Điều hướng an toàn sang màn hình Theo dõi đơn hàng
        context.go(AppRoutes.orders);
      });
    } catch (e) {
      // TUYỆT ĐỐI KHÔNG hiển thị "Đặt hàng thành công" nếu API trả về lỗi
      if (mounted) {
        setState(() => _isSubmittingOrder = false);
        final errorMessage = e is OrderException ? e.message : 'Đặt hàng thất bại: ${e.toString()}';
        AppSnackBar.error(context, errorMessage);
      }
    }
  }
}

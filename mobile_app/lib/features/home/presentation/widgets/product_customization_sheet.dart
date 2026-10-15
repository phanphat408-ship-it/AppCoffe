import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../cart/presentation/controllers/cart_notifier.dart';
import '../../data/models/product_model.dart';

/// BottomSheet tùy biến Size (S/M/L), Mức đường, Mức đá, Topping và Ghi chú
/// Chuẩn UX như các ứng dụng đặt nước hiện nay (GrabFood, ShopeeFood, The Coffee House).
class ProductCustomizationSheet extends ConsumerStatefulWidget {
  final ProductModel product;

  const ProductCustomizationSheet({
    super.key,
    required this.product,
  });

  static Future<void> show(BuildContext context, ProductModel product) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProductCustomizationSheet(product: product),
    );
  }

  @override
  ConsumerState<ProductCustomizationSheet> createState() =>
      _ProductCustomizationSheetState();
}

class _ProductCustomizationSheetState
    extends ConsumerState<ProductCustomizationSheet> {
  int _quantity = 1;
  final TextEditingController _noteController = TextEditingController();

  // Size Options
  late String _selectedSize;
  int _sizeExtraPrice = 6000; // Mặc định Size M (+6.000đ)

  // Sugar & Ice Options (cho đồ uống)
  String _selectedSugar = '100% Đường';
  String _selectedIce = '100% Đá';

  // Bakery / Snack specific options
  String _selectedServing = 'Dùng ngay nóng giòn';

  // Selected Toppings (tên -> giá)
  final Set<String> _selectedToppings = {};

  final List<({String name, int extraPrice})> _sizeOptions = const [
    (name: 'Size Nhỏ (S)', extraPrice: 0),
    (name: 'Size Vừa (M)', extraPrice: 6000),
    (name: 'Size Lớn (L)', extraPrice: 12000),
  ];

  final List<String> _sugarOptions = const [
    '100% Đường',
    '70% Đường',
    '50% Đường',
    '30% Đường',
    'Không đường',
  ];

  final List<String> _iceOptions = const [
    '100% Đá',
    '70% Đá',
    '50% Đá',
    'Không đá',
    'Uống nóng',
  ];

  final List<String> _servingOptions = const [
    'Dùng ngay nóng giòn',
    'Hâm nóng trước khi giao',
    'Để riêng tương ớt & tương cà',
  ];

  final List<({String name, int price})> _toppingOptions = const [
    (name: 'Trân châu trắng giòn', price: 8000),
    (name: 'Trân châu hoàng kim', price: 8000),
    (name: 'Kem Phô Mai Macchiato', price: 12000),
    (name: 'Thạch Sương Sáo', price: 6000),
    (name: 'Đào miếng giòn', price: 10000),
    (name: 'Hạt sen bùi', price: 10000),
  ];

  bool get _isFoodOrBakery {
    final cat = widget.product.categoryName?.toLowerCase() ?? '';
    final name = widget.product.name.toLowerCase();
    return cat.contains('bánh') ||
        cat.contains('ăn vặt') ||
        name.contains('bánh') ||
        name.contains('gà') ||
        name.contains('khoai tây');
  }

  @override
  void initState() {
    super.initState();
    _selectedSize = _sizeOptions[1].name; // Default: Size M
    _sizeExtraPrice = _sizeOptions[1].extraPrice;
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  int get _toppingExtraPrice {
    var sum = 0;
    for (final t in _toppingOptions) {
      if (_selectedToppings.contains(t.name)) {
        sum += t.price;
      }
    }
    return sum;
  }

  int get _unitPrice {
    final base = widget.product.price.round();
    if (_isFoodOrBakery) {
      return base;
    }
    return base + _sizeExtraPrice + _toppingExtraPrice;
  }

  int get _totalPrice => _unitPrice * _quantity;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      constraints: BoxConstraints(
        maxHeight: screenHeight * 0.88,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimens.r24),
        ),
      ),
      child: Column(
        children: [
          // Drag handle bar
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

          // Header: Thông tin món ăn + Nút đóng
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 16, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppDimens.r12),
                  child: SizedBox(
                    width: 76,
                    height: 76,
                    child: AppNetworkImage(
                      imageUrl: widget.product.imageUrl,
                      width: 76,
                      height: 76,
                      fit: BoxFit.cover,
                      fallbackIcon: Icons.local_cafe_rounded,
                      cacheWidth: 700,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.product.name,
                        style: AppTextStyles.subtitle.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        CurrencyFormatter.vnd(_unitPrice),
                        style: AppTextStyles.price.copyWith(
                          fontSize: 16,
                          color: AppColors.primary,
                        ),
                      ),
                      if (widget.product.description != null) ...[
                        const SizedBox(height: 3),
                        Text(
                          widget.product.description!,
                          style: AppTextStyles.caption.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: AppColors.divider),

          // Body: Danh sách tùy chọn có thể cuộn
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
              children: [
                if (!_isFoodOrBakery) ...[
                  // 1. Chọn Size (Bắt buộc chọn 1)
                  _buildSectionHeader('Chọn Size', isRequired: true),
                  const SizedBox(height: 8),
                  for (final size in _sizeOptions)
                    _buildRadioTile(
                      title: size.name,
                      extraPrice: size.extraPrice,
                      isSelected: _selectedSize == size.name,
                      onTap: () {
                        setState(() {
                          _selectedSize = size.name;
                          _sizeExtraPrice = size.extraPrice;
                        });
                      },
                    ),

                  const SizedBox(height: 18),

                  // 2. Chọn mức đường
                  _buildSectionHeader('Chọn Mức Đường', isRequired: true),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _sugarOptions.map((sugar) {
                      final isSelected = _selectedSugar == sugar;
                      return _buildSelectableChip(
                        label: sugar,
                        isSelected: isSelected,
                        onTap: () => setState(() => _selectedSugar = sugar),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 18),

                  // 3. Chọn mức đá
                  _buildSectionHeader('Chọn Mức Đá', isRequired: true),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _iceOptions.map((ice) {
                      final isSelected = _selectedIce == ice;
                      return _buildSelectableChip(
                        label: ice,
                        isSelected: isSelected,
                        onTap: () => setState(() => _selectedIce = ice),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 18),

                  // 4. Chọn Topping
                  _buildSectionHeader('Thêm Topping', subtitle: 'Chọn tối đa 4 loại'),
                  const SizedBox(height: 8),
                  for (final topping in _toppingOptions)
                    _buildCheckboxTile(
                      title: topping.name,
                      price: topping.price,
                      isSelected: _selectedToppings.contains(topping.name),
                      onChanged: (val) {
                        setState(() {
                          if (val == true) {
                            if (_selectedToppings.length < 4) {
                              _selectedToppings.add(topping.name);
                            }
                          } else {
                            _selectedToppings.remove(topping.name);
                          }
                        });
                      },
                    ),
                ] else ...[
                  // Tùy chọn phục vụ cho bánh ngọt & ăn vặt
                  _buildSectionHeader('Cách Phục Vụ'),
                  const SizedBox(height: 8),
                  for (final opt in _servingOptions)
                    _buildRadioTile(
                      title: opt,
                      extraPrice: 0,
                      isSelected: _selectedServing == opt,
                      onTap: () => setState(() => _selectedServing = opt),
                    ),
                ],

                const SizedBox(height: 18),

                // 5. Ghi chú cho quán
                _buildSectionHeader('Ghi Chú Cho Quán'),
                const SizedBox(height: 8),
                TextField(
                  controller: _noteController,
                  maxLength: 100,
                  decoration: InputDecoration(
                    hintText: 'Ví dụ: Mang ly giấy, ít ngọt, giao trước 12h...',
                    hintStyle: AppTextStyles.caption.copyWith(color: AppColors.textLight),
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppDimens.r12),
                      borderSide: BorderSide(color: AppColors.lightBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppDimens.r12),
                      borderSide: BorderSide(color: AppColors.lightBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppDimens.r12),
                      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
              ],
            ),
          ),

          // Bottom Bar: Bộ chọn số lượng + Nút Thêm vào giỏ hàng nổi bật
          Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: Row(
              children: [
                // Bộ chọn số lượng
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(AppDimens.r12),
                    border: Border.all(color: AppColors.lightBorder),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_rounded, size: 20),
                        color: _quantity > 1 ? AppColors.textPrimary : AppColors.textLight,
                        onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                      ),
                      Text(
                        '$_quantity',
                        style: AppTextStyles.subtitle.copyWith(fontSize: 16),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_rounded, size: 20),
                        color: AppColors.primary,
                        onPressed: () => setState(() => _quantity++),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 14),

                // Nút Thêm vào giỏ hàng
                Expanded(
                  child: ElevatedButton(
                    onPressed: _handleAddToCart,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimens.r14),
                      ),
                    ),
                    child: Text(
                      'Thêm • ${CurrencyFormatter.vnd(_totalPrice)}',
                      style: AppTextStyles.button.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, {bool isRequired = false, String? subtitle}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              title,
              style: AppTextStyles.subtitle.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (isRequired) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppDimens.r6),
                ),
                child: Text(
                  'Bắt buộc',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ],
        ),
        if (subtitle != null)
          Text(
            subtitle,
            style: AppTextStyles.caption.copyWith(color: AppColors.textSecondary),
          ),
      ],
    );
  }

  Widget _buildRadioTile({
    required String title,
    required int extraPrice,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimens.r10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
              color: isSelected ? AppColors.primary : AppColors.textLight,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            if (extraPrice > 0)
              Text(
                '+${CurrencyFormatter.vnd(extraPrice)}',
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectableChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.12) : AppColors.background,
          borderRadius: BorderRadius.circular(AppDimens.r10),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.lightBorder,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: isSelected ? AppColors.primary : AppColors.textPrimary,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildCheckboxTile({
    required String title,
    required int price,
    required bool isSelected,
    required ValueChanged<bool?> onChanged,
  }) {
    return InkWell(
      onTap: () => onChanged(!isSelected),
      borderRadius: BorderRadius.circular(AppDimens.r10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
              color: isSelected ? AppColors.primary : AppColors.textLight,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            Text(
              '+${CurrencyFormatter.vnd(price)}',
              style: AppTextStyles.caption.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleAddToCart() {
    final cart = ref.read(cartNotifierProvider.notifier);
    final userNote = _noteController.text.trim();

    try {
      if (_isFoodOrBakery) {
        cart.addCustomizedItem(
          product: widget.product,
          quantity: _quantity,
          selectedSize: 'Tiêu chuẩn',
          sizeExtraPrice: 0,
          selectedSugar: null,
          selectedIce: null,
          selectedToppings: const [],
          toppingExtraPrice: 0,
          note: userNote.isNotEmpty ? '$_selectedServing; $userNote' : _selectedServing,
        );
      } else {
        cart.addCustomizedItem(
          product: widget.product,
          quantity: _quantity,
          selectedSize: _selectedSize,
          sizeExtraPrice: _sizeExtraPrice,
          selectedSugar: _selectedSugar,
          selectedIce: _selectedIce,
          selectedToppings: _selectedToppings.toList(),
          toppingExtraPrice: _toppingExtraPrice,
          note: userNote.isNotEmpty ? userNote : null,
        );
      }

      Navigator.of(context).pop();

      AppSnackBar.success(
        context,
        'Đã thêm "$_quantity x ${widget.product.name}" vào giỏ hàng!',
      );
    } on CartException catch (e) {
      AppSnackBar.error(context, e.message);
    }
  }
}

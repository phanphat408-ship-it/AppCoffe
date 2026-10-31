import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../home/data/models/product_model.dart';

/// BottomSheet Quản Lý Thực Đơn dành cho Admin (Thêm / Sửa / Xóa / Ẩn món)
class AdminMenuManagementSheet extends StatefulWidget {
  const AdminMenuManagementSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AdminMenuManagementSheet(),
    );
  }

  @override
  State<AdminMenuManagementSheet> createState() => _AdminMenuManagementSheetState();
}

class _AdminMenuManagementSheetState extends State<AdminMenuManagementSheet> {
  final TextEditingController _searchController = TextEditingController();
  int _selectedCategoryFilter = 0; // 0: Tất cả

  // Danh sách thực đơn quản lý (có thể thêm, sửa, xóa, ẩn món cục bộ phục vụ demo)
  late List<ProductModel> _menuItems;

  final List<String> _categories = [
    'Tất cả',
    'Cà Phê Việt',
    'Trà Trái Cây & Trà Sữa',
    'Đá Xay & Matcha',
    'Bánh Ngọt & Ăn Vặt',
  ];

  @override
  void initState() {
    super.initState();
    _menuItems = [
      const ProductModel(
        id: 101,
        name: 'Cà Phê Sữa Đá Sài Gòn',
        description: 'Cà phê Robusta Đắk Lắk pha phin nguyên chất kết hợp sữa đặc béo ngậy.',
        price: 29000,
        imageUrl: 'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?auto=format&fit=crop&w=600&q=80',
        categoryId: 1,
        categoryName: 'Cà Phê Việt',
        isAvailable: true,
      ),
      const ProductModel(
        id: 102,
        name: 'Bạc Xỉu Sữa Tươi 3 Tầng',
        description: 'Hương vị hòa quyện giữa vị đắng nhẹ của cà phê phin và lớp sữa tươi béo thơm.',
        price: 32000,
        imageUrl: 'https://images.unsplash.com/photo-1534778101976-62847782c213?auto=format&fit=crop&w=600&q=80',
        categoryId: 1,
        categoryName: 'Cà Phê Việt',
        isAvailable: true,
      ),
      const ProductModel(
        id: 103,
        name: 'Cà Phê Muối Xứ Huế',
        description: 'Lớp kem béo mặn nhẹ đậm đà hòa quyện cùng vị cà phê nồng nàn.',
        price: 35000,
        imageUrl: 'https://images.unsplash.com/photo-1517701550927-30cf4ba1dba5?auto=format&fit=crop&w=600&q=80',
        categoryId: 1,
        categoryName: 'Cà Phê Việt',
        isAvailable: true,
      ),
      const ProductModel(
        id: 104,
        name: 'Trà Đào Cam Sả Tươi',
        description: 'Trà hoa quả giải nhiệt thanh mát với miếng đào giòn và sả thơm dịu.',
        price: 42000,
        imageUrl: 'https://images.unsplash.com/photo-1556679343-c7306c1976bc?auto=format&fit=crop&w=600&q=80',
        categoryId: 2,
        categoryName: 'Trà Trái Cây & Trà Sữa',
        isAvailable: true,
      ),
      const ProductModel(
        id: 105,
        name: 'Trà Sữa Trân Châu Đường Đen',
        description: 'Trân châu dẻo nấu cùng sốt đường đen kết hợp hồng trà sữa béo thơm.',
        price: 45000,
        imageUrl: 'https://images.unsplash.com/photo-1541658016709-82535e94bc69?auto=format&fit=crop&w=600&q=80',
        categoryId: 2,
        categoryName: 'Trà Trái Cây & Trà Sữa',
        isAvailable: false, // Ví dụ món đang bị ẩn
      ),
      const ProductModel(
        id: 106,
        name: 'Matcha Uji Đá Xay Kem Cheese',
        description: 'Bột matcha thượng hạng nhập khẩu kết hợp lớp kem phô mai béo mịn.',
        price: 49000,
        imageUrl: 'https://images.unsplash.com/photo-1572490122747-3968b75cc699?auto=format&fit=crop&w=600&q=80',
        categoryId: 3,
        categoryName: 'Đá Xay & Matcha',
        isAvailable: true,
      ),
      const ProductModel(
        id: 107,
        name: 'Bánh Sừng Trâu Bơ Pháp (Croissant)',
        description: 'Bánh nướng bơ ngàn lớp thơm lừng, giòn xốp bên ngoài, mềm ngậy bên trong.',
        price: 35000,
        imageUrl: 'https://images.unsplash.com/photo-1555507036-ab1f4038808a?auto=format&fit=crop&w=600&q=80',
        categoryId: 4,
        categoryName: 'Bánh Ngọt & Ăn Vặt',
        isAvailable: true,
      ),
    ];
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<ProductModel> get _filteredItems {
    var list = _menuItems;
    if (_selectedCategoryFilter > 0) {
      list = list.where((p) => p.categoryId == _selectedCategoryFilter).toList();
    }
    final q = _searchController.text.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list
          .where((p) =>
              p.name.toLowerCase().contains(q) ||
              (p.description?.toLowerCase().contains(q) ?? false))
          .toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredItems;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.92,
      ),
      decoration: const BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppDimens.r24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            // Header Top
            Container(
              padding: const EdgeInsets.fromLTRB(20, 14, 16, 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(AppDimens.r24)),
              ),
              child: Column(
                children: [
                  Center(
                    child: Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.lightBorder,
                        borderRadius: BorderRadius.circular(AppDimens.rFull),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE65100).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(AppDimens.r12),
                        ),
                        child: const Icon(
                          Icons.restaurant_menu_rounded,
                          color: Color(0xFFE65100),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Quản Lý Thực Đơn',
                              style: AppTextStyles.h3.copyWith(fontSize: 18),
                            ),
                            Text(
                              'Thêm, sửa giá, ẩn hoặc xóa món ăn',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 11.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Nút Thêm Món Mới
                      ElevatedButton.icon(
                        onPressed: () => _showAddProductDialog(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppDimens.r12),
                          ),
                        ),
                        icon: const Icon(Icons.add_rounded, size: 18),
                        label: const Text(
                          'Thêm món',
                          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        icon: const Icon(Icons.close_rounded,
                            color: AppColors.textSecondary),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Thanh tìm kiếm món
                  TextField(
                    controller: _searchController,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Tìm kiếm tên món ăn...',
                      hintStyle: AppTextStyles.bodyMediumSecondary.copyWith(fontSize: 13),
                      prefixIcon: const Icon(Icons.search_rounded, size: 20, color: AppColors.textSecondary),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {});
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: AppColors.background,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppDimens.r12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Lọc theo Danh mục
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(_categories.length, (idx) {
                        final isSelected = _selectedCategoryFilter == idx;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            selected: isSelected,
                            showCheckmark: false,
                            label: Text(_categories[idx]),
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : AppColors.textPrimary,
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            ),
                            backgroundColor: Colors.white,
                            selectedColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppDimens.rFull),
                              side: BorderSide(
                                color: isSelected ? AppColors.primary : AppColors.lightBorder,
                              ),
                            ),
                            onSelected: (_) {
                              setState(() => _selectedCategoryFilter = idx);
                            },
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),

            // Danh sách món ăn
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.fastfood_outlined,
                              size: 48, color: AppColors.textSecondary),
                          const SizedBox(height: 8),
                          Text('Không tìm thấy món ăn nào', style: AppTextStyles.subtitle),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
                      itemCount: filtered.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final product = filtered[index];
                        return _buildProductCard(product);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(ProductModel product) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimens.r16),
        border: Border.all(
          color: product.isAvailable
              ? AppColors.lightBorder
              : AppColors.error.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Ảnh món
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppDimens.r12),
                child: Image.network(
                  product.imageUrl,
                  width: 70,
                  height: 70,
                  fit: BoxFit.cover,
                  cacheWidth: 150,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 70,
                    height: 70,
                    color: AppColors.secondary.withValues(alpha: 0.4),
                    child: const Icon(Icons.coffee_rounded, color: AppColors.primary),
                  ),
                ),
              ),
              if (!product.isAvailable)
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(AppDimens.r12),
                  ),
                  child: const Center(
                    child: Text(
                      'ĐÃ ẨN',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(width: 12),

          // Tên món + Giá + Danh mục
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: AppTextStyles.subtitle.copyWith(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  product.categoryName ?? 'Cà Phê',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 11.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  CurrencyFormatter.vnd(product.price),
                  style: AppTextStyles.subtitle.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Nút Ẩn/Hiện + Sửa + Xóa
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Switch Ẩn/Hiện
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    product.isAvailable ? 'Đang bán' : 'Đã ẩn',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: product.isAvailable
                          ? const Color(0xFF2E7D32)
                          : AppColors.error,
                    ),
                  ),
                  Transform.scale(
                    scale: 0.75,
                    child: Switch(
                      value: product.isAvailable,
                      activeColor: const Color(0xFF2E7D32),
                      onChanged: (val) {
                        _toggleAvailability(product);
                      },
                    ),
                  ),
                ],
              ),

              // Cụm Sửa & Xóa
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: () => _showEditProductDialog(product),
                    borderRadius: BorderRadius.circular(AppDimens.r6),
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1976D2).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppDimens.r6),
                      ),
                      child: const Icon(
                        Icons.edit_outlined,
                        size: 16,
                        color: Color(0xFF1976D2),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  InkWell(
                    onTap: () => _confirmDeleteProduct(product),
                    borderRadius: BorderRadius.circular(AppDimens.r6),
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(AppDimens.r6),
                      ),
                      child: const Icon(
                        Icons.delete_outline_rounded,
                        size: 16,
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _toggleAvailability(ProductModel product) {
    setState(() {
      final index = _menuItems.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        final newStatus = !_menuItems[index].isAvailable;
        final updated = ProductModel(
          id: product.id,
          name: product.name,
          description: product.description,
          price: product.price,
          imageUrl: product.imageUrl,
          categoryId: product.categoryId,
          categoryName: product.categoryName,
          isAvailable: newStatus,
          rating: product.rating,
          isBestSeller: product.isBestSeller,
        );
        _menuItems[index] = updated;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newStatus
                  ? '✅ Đã mở bán lại món: ${product.name}'
                  : '⏸️ Đã ẩn món: ${product.name} khỏi thực đơn của khách',
            ),
            backgroundColor: newStatus ? const Color(0xFF2E7D32) : AppColors.error,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    });
  }

  void _confirmDeleteProduct(ProductModel product) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.r18)),
        title: const Text('Xác nhận xóa món?'),
        content: Text('Bạn có chắc chắn muốn xóa "${product.name}" khỏi hệ thống menu không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _menuItems.removeWhere((p) => p.id == product.id);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('🗑️ Đã xóa món "${product.name}" khỏi thực đơn'),
                  backgroundColor: AppColors.error,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Xóa món'),
          ),
        ],
      ),
    );
  }

  void _showEditProductDialog(ProductModel product) {
    final nameController = TextEditingController(text: product.name);
    final priceController = TextEditingController(text: product.price.toInt().toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.r20)),
        title: Row(
          children: [
            const Icon(Icons.edit_note_rounded, color: AppColors.primary),
            const SizedBox(width: 8),
            Text('Sửa Thông Tin Món', style: AppTextStyles.h3.copyWith(fontSize: 17)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Tên món',
                isDense: true,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Giá bán (VNĐ)',
                isDense: true,
                border: OutlineInputBorder(),
                suffixText: 'đ',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              final newName = nameController.text.trim();
              final newPrice = double.tryParse(priceController.text.trim()) ?? product.price;

              if (newName.isNotEmpty) {
                setState(() {
                  final index = _menuItems.indexWhere((p) => p.id == product.id);
                  if (index != -1) {
                    _menuItems[index] = ProductModel(
                      id: product.id,
                      name: newName,
                      description: product.description,
                      price: newPrice,
                      imageUrl: product.imageUrl,
                      categoryId: product.categoryId,
                      categoryName: product.categoryName,
                      isAvailable: product.isAvailable,
                      rating: product.rating,
                      isBestSeller: product.isBestSeller,
                    );
                  }
                });
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('✨ Đã cập nhật thông tin món ăn thành công!'),
                    backgroundColor: AppColors.primary,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Lưu thay đổi'),
          ),
        ],
      ),
    );
  }

  void _showAddProductDialog() {
    final nameController = TextEditingController();
    final priceController = TextEditingController(text: '39000');
    int selectedCatId = 1;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.r20)),
          title: Row(
            children: [
              const Icon(Icons.add_circle_outline_rounded, color: AppColors.primary),
              const SizedBox(width: 8),
              Text('Thêm Món Ăn Mới', style: AppTextStyles.h3.copyWith(fontSize: 17)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Tên món ăn / thức uống',
                    hintText: 'VD: Cà Phê Cốt Dừa Đá Xay',
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: priceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Giá bán (VNĐ)',
                    isDense: true,
                    border: OutlineInputBorder(),
                    suffixText: 'đ',
                  ),
                ),
                const SizedBox(height: 12),
                const Text('Danh mục món:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const SizedBox(height: 6),
                DropdownButtonFormField<int>(
                  value: selectedCatId,
                  decoration: const InputDecoration(
                    isDense: true,
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 1, child: Text('Cà Phê Việt')),
                    DropdownMenuItem(value: 2, child: Text('Trà Trái Cây & Trà Sữa')),
                    DropdownMenuItem(value: 3, child: Text('Đá Xay & Matcha')),
                    DropdownMenuItem(value: 4, child: Text('Bánh Ngọt & Ăn Vặt')),
                  ],
                  onChanged: (val) {
                    if (val != null) setDialogState(() => selectedCatId = val);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                final price = double.tryParse(priceController.text.trim()) ?? 35000;

                if (name.isNotEmpty) {
                  final newId = 200 + DateTime.now().millisecondsSinceEpoch % 800;
                  final catNames = {
                    1: 'Cà Phê Việt',
                    2: 'Trà Trái Cây & Trà Sữa',
                    3: 'Đá Xay & Matcha',
                    4: 'Bánh Ngọt & Ăn Vặt',
                  };
                  final newProduct = ProductModel(
                    id: newId,
                    name: name,
                    description: 'Món mới được tạo bởi quản trị viên cửa hàng.',
                    price: price,
                    imageUrl: 'https://images.unsplash.com/photo-1514432324607-a09d9b4aefdd?auto=format&fit=crop&w=600&q=80',
                    categoryId: selectedCatId,
                    categoryName: catNames[selectedCatId],
                    isAvailable: true,
                  );

                  setState(() {
                    _menuItems.insert(0, newProduct);
                  });
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('🎉 Đã thêm "$name" vào thực đơn bán hàng!'),
                      backgroundColor: const Color(0xFF2E7D32),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Thêm Món'),
            ),
          ],
        ),
      ),
    );
  }
}

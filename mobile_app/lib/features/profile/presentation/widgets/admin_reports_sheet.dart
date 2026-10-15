import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_text_styles.dart';

/// BottomSheet Thống Kê & Báo Cáo Doanh Thu dành cho Admin / Quản lý cửa hàng
class AdminReportsSheet extends StatefulWidget {
  const AdminReportsSheet({super.key});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AdminReportsSheet(),
    );
  }

  @override
  State<AdminReportsSheet> createState() => _AdminReportsSheetState();
}

class _AdminReportsSheetState extends State<AdminReportsSheet> {
  int _selectedPeriod = 0; // 0: Hôm nay, 1: 7 ngày qua, 2: Tháng này

  final List<String> _periodTitles = ['Hôm nay', '7 ngày qua', 'Tháng này'];

  // Dữ liệu mô phỏng theo 3 mốc thời gian
  final List<Map<String, dynamic>> _periodData = [
    {
      'revenue': '8.450.000 đ',
      'growth': '+18.5% so với hôm qua',
      'isPositive': true,
      'totalOrders': 68,
      'completedOrders': 66,
      'averageOrder': '124.200 đ',
      'newCustomers': 24,
      'chartData': [
        {'label': '7h-9h', 'value': 0.45, 'amount': '1.350k'},
        {'label': '9h-12h', 'value': 0.85, 'amount': '2.550k'},
        {'label': '12h-15h', 'value': 0.60, 'amount': '1.800k'},
        {'label': '15h-18h', 'value': 0.70, 'amount': '2.100k'},
        {'label': '18h-21h', 'value': 0.95, 'amount': '2.850k'},
        {'label': '21h-23h', 'value': 0.30, 'amount': '900k'},
      ],
      'topProducts': [
        {'name': 'Cà Phê Sữa Đá Sài Gòn', 'sales': '42 ly', 'revenue': '1.218.000 đ', 'rank': 1},
        {'name': 'Bạc Xỉu Sữa Tươi 3 Tầng', 'sales': '28 ly', 'revenue': '896.000 đ', 'rank': 2},
        {'name': 'Trà Đào Cam Sả Tươi', 'sales': '24 ly', 'revenue': '1.008.000 đ', 'rank': 3},
        {'name': 'Croissant Bơ Pháp', 'sales': '18 cái', 'revenue': '630.000 đ', 'rank': 4},
        {'name': 'Matcha Uji Đá Xay Kem Cheese', 'sales': '15 ly', 'revenue': '735.000 đ', 'rank': 5},
      ],
    },
    {
      'revenue': '54.280.000 đ',
      'growth': '+12.3% so với tuần trước',
      'isPositive': true,
      'totalOrders': 442,
      'completedOrders': 430,
      'averageOrder': '122.800 đ',
      'newCustomers': 158,
      'chartData': [
        {'label': 'T2', 'value': 0.55, 'amount': '6.800k'},
        {'label': 'T3', 'value': 0.65, 'amount': '7.200k'},
        {'label': 'T4', 'value': 0.60, 'amount': '7.100k'},
        {'label': 'T5', 'value': 0.70, 'amount': '8.200k'},
        {'label': 'T6', 'value': 0.90, 'amount': '9.800k'},
        {'label': 'T7', 'value': 1.00, 'amount': '11.500k'},
        {'label': 'CN', 'value': 0.85, 'amount': '9.680k'},
      ],
      'topProducts': [
        {'name': 'Cà Phê Sữa Đá Sài Gòn', 'sales': '285 ly', 'revenue': '8.265.000 đ', 'rank': 1},
        {'name': 'Trà Đào Cam Sả Tươi', 'sales': '196 ly', 'revenue': '8.232.000 đ', 'rank': 2},
        {'name': 'Bạc Xỉu Sữa Tươi 3 Tầng', 'sales': '174 ly', 'revenue': '5.568.000 đ', 'rank': 3},
        {'name': 'Matcha Uji Đá Xay', 'sales': '120 ly', 'revenue': '5.880.000 đ', 'rank': 4},
        {'name': 'Croissant Bơ Pháp', 'sales': '112 cái', 'revenue': '3.920.000 đ', 'rank': 5},
      ],
    },
    {
      'revenue': '215.600.000 đ',
      'growth': '+15.8% so với tháng trước',
      'isPositive': true,
      'totalOrders': 1750,
      'completedOrders': 1712,
      'averageOrder': '123.200 đ',
      'newCustomers': 620,
      'chartData': [
        {'label': 'Tuần 1', 'value': 0.75, 'amount': '48.500k'},
        {'label': 'Tuần 2', 'value': 0.82, 'amount': '52.100k'},
        {'label': 'Tuần 3', 'value': 0.90, 'amount': '57.800k'},
        {'label': 'Tuần 4', 'value': 0.95, 'amount': '61.200k'},
      ],
      'topProducts': [
        {'name': 'Cà Phê Sữa Đá Sài Gòn', 'sales': '1.140 ly', 'revenue': '33.060.000 đ', 'rank': 1},
        {'name': 'Trà Đào Cam Sả Tươi', 'sales': '780 ly', 'revenue': '32.760.000 đ', 'rank': 2},
        {'name': 'Bạc Xỉu Sữa Tươi 3 Tầng', 'sales': '690 ly', 'revenue': '22.080.000 đ', 'rank': 3},
        {'name': 'Matcha Uji Đá Xay', 'sales': '510 ly', 'revenue': '24.990.000 đ', 'rank': 4},
        {'name': 'Croissant Bơ Pháp', 'sales': '440 cái', 'revenue': '15.400.000 đ', 'rank': 5},
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    final current = _periodData[_selectedPeriod];
    final chartList = current['chartData'] as List<Map<String, dynamic>>;
    final topProducts = current['topProducts'] as List<Map<String, dynamic>>;

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
                          color: const Color(0xFF1976D2).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(AppDimens.r12),
                        ),
                        child: const Icon(
                          Icons.bar_chart_rounded,
                          color: Color(0xFF1976D2),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Thống Kê & Báo Cáo',
                              style: AppTextStyles.h3.copyWith(fontSize: 18),
                            ),
                            Text(
                              'Doanh thu, số lượng đơn & hiệu suất bán hàng',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.textSecondary,
                                fontSize: 11.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded,
                            color: AppColors.textSecondary),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Bộ chuyển thời gian: Hôm nay | 7 ngày qua | Tháng này
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(AppDimens.r12),
                    ),
                    child: Row(
                      children: List.generate(_periodTitles.length, (idx) {
                        final isSelected = _selectedPeriod == idx;
                        return Expanded(
                          child: InkWell(
                            onTap: () => setState(() => _selectedPeriod = idx),
                            borderRadius: BorderRadius.circular(AppDimens.r8),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.white : Colors.transparent,
                                borderRadius: BorderRadius.circular(AppDimens.r8),
                                boxShadow: isSelected
                                    ? [
                                        BoxShadow(
                                          color: Colors.black.withValues(alpha: 0.06),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Text(
                                _periodTitles[idx],
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight:
                                      isSelected ? FontWeight.w700 : FontWeight.w500,
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),

            // Nội dung chi tiết cuộn được
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Card Doanh thu chính lớn
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2C241E), Color(0xFF4A3E36)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(AppDimens.r20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'TỔNG DOANH THU',
                                style: AppTextStyles.caption.copyWith(
                                  color: Colors.white70,
                                  letterSpacing: 1.0,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2E7D32).withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(AppDimens.rFull),
                                  border: Border.all(
                                    color: const Color(0xFF81C784),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  current['growth'] as String,
                                  style: const TextStyle(
                                    color: Color(0xFF81C784),
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text(
                            current['revenue'] as String,
                            style: AppTextStyles.h1.copyWith(
                              color: const Color(0xFFFFD700),
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 14),
                          const Divider(height: 1, color: Colors.white24),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildMiniStat(
                                label: 'Tổng đơn hàng',
                                value: '${current['totalOrders']} đơn',
                              ),
                              _buildMiniStat(
                                label: 'Đơn thành công',
                                value: '${current['completedOrders']} đơn',
                              ),
                              _buildMiniStat(
                                label: 'Khách hàng mới',
                                value: '+${current['newCustomers']}',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Biểu đồ doanh thu dạng thanh trực quan (Interactive Bar Chart)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppDimens.r18),
                        border: Border.all(color: AppColors.lightBorder),
                        boxShadow: [AppColors.cardShadow],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Biểu Đồ Doanh Thu',
                                style: AppTextStyles.subtitle.copyWith(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                'Giá trị trung bình: ${current['averageOrder']}',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          // Custom Bar Chart
                          SizedBox(
                            height: 140,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: chartList.map((item) {
                                final ratio = (item['value'] as num).toDouble();
                                final label = item['label'] as String;
                                final amount = item['amount'] as String;
                                final isHighest = ratio >= 0.9;

                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      amount,
                                      style: TextStyle(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w700,
                                        color: isHighest
                                            ? AppColors.primary
                                            : AppColors.textSecondary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    AnimatedContainer(
                                      duration: const Duration(milliseconds: 300),
                                      width: 22,
                                      height: (100 * ratio).clamp(16.0, 100.0),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: isHighest
                                              ? [AppColors.primary, const Color(0xFFE65100)]
                                              : [
                                                  AppColors.secondary,
                                                  AppColors.secondary.withValues(alpha: 0.7),
                                                ],
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(AppDimens.r6),
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      label,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: isHighest
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                        color: isHighest
                                            ? AppColors.textPrimary
                                            : AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Top 5 Món Bán Chạy Nhất (Ranking List)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppDimens.r18),
                        border: Border.all(color: AppColors.lightBorder),
                        boxShadow: [AppColors.cardShadow],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.workspace_premium_rounded,
                                  color: Color(0xFFFFD700), size: 20),
                              const SizedBox(width: 8),
                              Text(
                                'Top Món Bán Chạy Nhất',
                                style: AppTextStyles.subtitle.copyWith(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ...topProducts.map((p) {
                            final rank = p['rank'] as int;
                            final name = p['name'] as String;
                            final sales = p['sales'] as String;
                            final rev = p['revenue'] as String;

                            Color rankColor = AppColors.textSecondary;
                            if (rank == 1) rankColor = const Color(0xFFFFD700);
                            if (rank == 2) rankColor = const Color(0xFFC0C0C0);
                            if (rank == 3) rankColor = const Color(0xFFCD7F32);

                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 7),
                              child: Row(
                                children: [
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: rankColor.withValues(alpha: 0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Center(
                                      child: Text(
                                        '$rank',
                                        style: TextStyle(
                                          color: rank <= 3
                                              ? const Color(0xFF8D6E63)
                                              : AppColors.textSecondary,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          name,
                                          style: AppTextStyles.subtitle.copyWith(
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          sales,
                                          style: AppTextStyles.caption.copyWith(
                                            color: AppColors.textSecondary,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    rev,
                                    style: AppTextStyles.subtitle.copyWith(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Cơ cấu phương thức thanh toán
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(AppDimens.r18),
                        border: Border.all(color: AppColors.lightBorder),
                        boxShadow: [AppColors.cardShadow],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Phương Thức Thanh Toán',
                            style: AppTextStyles.subtitle.copyWith(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildPaymentBar(
                            title: 'Chuyển khoản VietQR',
                            percent: 0.65,
                            percentText: '65%',
                            color: const Color(0xFF1976D2),
                          ),
                          const SizedBox(height: 10),
                          _buildPaymentBar(
                            title: 'Ví điện tử MoMo',
                            percent: 0.23,
                            percentText: '23%',
                            color: const Color(0xFFC2185B),
                          ),
                          const SizedBox(height: 10),
                          _buildPaymentBar(
                            title: 'Tiền mặt khi nhận hàng (COD)',
                            percent: 0.12,
                            percentText: '12%',
                            color: const Color(0xFF2E7D32),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMiniStat({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.caption.copyWith(color: Colors.white60, fontSize: 11),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentBar({
    required String title,
    required double percent,
    required String percentText,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: AppTextStyles.caption.copyWith(color: AppColors.textPrimary, fontSize: 12)),
            Text(percentText, style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppDimens.rFull),
          child: LinearProgressIndicator(
            value: percent,
            backgroundColor: AppColors.background,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}

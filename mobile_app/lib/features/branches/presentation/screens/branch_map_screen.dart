import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart' hide Path;
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimens.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/utils/app_snackbar.dart';
import '../../../main/presentation/screens/main_screen.dart';
import '../../data/models/branch_model.dart';
import '../../data/repositories/branch_repository.dart';
import '../controllers/branch_notifier.dart';
import '../controllers/branch_state.dart';
import '../widgets/branch_info_panel.dart';

/// Màn hình Bản đồ chi nhánh dùng flutter_map + CartoDB Voyager (OpenStreetMap).
/// Không cần API Key / Billing nên luôn hiển thị đầy đủ đường phố thật tại TP. Hồ Chí Minh.
class BranchMapScreen extends ConsumerStatefulWidget {
  const BranchMapScreen({super.key});

  @override
  ConsumerState<BranchMapScreen> createState() => _BranchMapScreenState();
}

class _BranchMapScreenState extends ConsumerState<BranchMapScreen>
    with TickerProviderStateMixin {
  /// Tile OpenStreetMap chuẩn – miễn phí hoàn toàn, không yêu cầu API Key
  static const String _tileUrl =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  /// Tọa độ trung tâm mặc định: vị trí người dùng tại trung tâm TP. Hồ Chí Minh
  static const LatLng _defaultCenter = LatLng(
    BranchRepository.defaultUserLat,
    BranchRepository.defaultUserLng,
  );

  static const double _minZoom = 10;
  static const double _maxZoom = 19;

  /// Chiều cao xấp xỉ của card thông tin chi nhánh phía đáy
  static const double _panelHeight = 232;

  final MapController _mapController = MapController();
  late final AnimationController _pulseController;
  AnimationController? _moveController;
  bool _mapReady = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _moveController?.dispose();
    _pulseController.dispose();
    _mapController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // CAMERA
  // ---------------------------------------------------------------------------

  /// Camera lướt mượt (animated move) đến [dest] với mức zoom [destZoom]
  void _animatedMove(LatLng dest, double destZoom) {
    if (!_mapReady) return;

    _moveController?.dispose();

    final camera = _mapController.camera;
    final latTween = Tween<double>(begin: camera.center.latitude, end: dest.latitude);
    final lngTween = Tween<double>(begin: camera.center.longitude, end: dest.longitude);
    final zoomTween = Tween<double>(
      begin: camera.zoom,
      end: destZoom.clamp(_minZoom, _maxZoom).toDouble(),
    );

    final controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    final animation = CurvedAnimation(parent: controller, curve: Curves.easeInOutCubic);

    controller.addListener(() {
      _mapController.move(
        LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
        zoomTween.evaluate(animation),
      );
    });

    _moveController = controller;
    controller.forward();
  }

  /// Dịch tâm camera xuống phía nam một đoạn [pixels] để điểm cần xem nằm
  /// phía trên card thông tin (không bị card che khuất).
  LatLng _offsetCenter(LatLng target, double zoom, {double pixels = 90}) {
    final metersPerPixel =
        156543.03392 * math.cos(target.latitude * math.pi / 180) / math.pow(2, zoom);
    final deltaLat = (pixels * metersPerPixel) / 111320.0;
    return LatLng(target.latitude - deltaLat, target.longitude);
  }

  /// Zoom khít cả vị trí người dùng và chi nhánh đang chọn
  void _fitUserAndBranch(BranchState s) {
    if (!_mapReady) return;

    final user = LatLng(
      s.userLat ?? BranchRepository.defaultUserLat,
      s.userLng ?? BranchRepository.defaultUserLng,
    );
    final branch = s.selectedBranch;

    if (branch == null) {
      _animatedMove(user, 14);
      return;
    }

    final fit = CameraFit.coordinates(
      coordinates: [user, LatLng(branch.lat, branch.lng)],
      padding: const EdgeInsets.fromLTRB(56, 190, 56, 300),
      maxZoom: 16,
    ).fit(_mapController.camera);

    _animatedMove(fit.center, fit.zoom);
  }

  /// Chọn chi nhánh và lướt camera đến đúng tọa độ chi nhánh
  void _animateToBranch(BranchModel branch) {
    ref.read(branchNotifierProvider.notifier).selectBranch(branch);
    const zoom = 16.0;
    _animatedMove(_offsetCenter(LatLng(branch.lat, branch.lng), zoom), zoom);
  }

  void _zoomBy(double delta) {
    if (!_mapReady) return;
    final camera = _mapController.camera;
    _animatedMove(camera.center, camera.zoom + delta);
  }

  // ---------------------------------------------------------------------------
  // ACTIONS
  // ---------------------------------------------------------------------------

  /// Nút "Vị trí của tôi": đưa tâm bản đồ về vị trí người dùng tại TP.HCM
  Future<void> _handleLocateUser() async {
    final notifier = ref.read(branchNotifierProvider.notifier);

    final result = await notifier.locateUserAndFindNearest();
    if (!mounted) return;

    const zoom = 15.5;
    final user = LatLng(result.lat, result.lng);
    _animatedMove(_offsetCenter(user, zoom, pixels: 60), zoom);

    final nearest = ref.read(branchNotifierProvider).nearestBranch;
    if (nearest != null) {
      AppSnackBar.success(
        context,
        result.isFallback
            ? 'Vị trí của bạn: TP. Hồ Chí Minh • Quán gần nhất: ${nearest.shortName} (${nearest.formattedDistance})'
            : 'Quán gần bạn nhất: ${nearest.shortName} (${nearest.formattedDistance})',
        actionLabel: 'XEM QUÁN',
        onAction: () => _animateToBranch(nearest),
      );
    }
  }

  /// Nút "Chọn đặt món": lưu chi nhánh vào trạng thái đặt hàng và về màn hình Menu
  void _handleSelectBranch(BranchModel branch) {
    ref.read(branchNotifierProvider.notifier).confirmOrderBranch(branch);
    ref.read(mainTabIndexProvider.notifier).setTab(0);

    AppSnackBar.success(context, 'Đã chọn ${branch.name} – hãy chọn món bạn thích nhé!');
    context.go(AppRoutes.home);
  }

  // ---------------------------------------------------------------------------
  // MAP LAYERS
  // ---------------------------------------------------------------------------

  List<Marker> _buildMarkers(BranchState s) {
    final markers = <Marker>[];

    // Ghim chi nhánh (vẽ trước để ghim "Vị trí của bạn" nằm phía trên)
    for (final branch in s.branches) {
      final isSelected = s.selectedBranch?.id == branch.id;
      markers.add(
        Marker(
          point: LatLng(branch.lat, branch.lng),
          width: 76,
          height: 92,
          alignment: Alignment.topCenter,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => _animateToBranch(branch),
            child: _BranchPin(
              isSelected: isSelected,
              isNearest: s.nearestBranch?.id == branch.id,
            ),
          ),
        ),
      );
    }

    // Nhãn khoảng cách / thời gian ở giữa đường nối
    final selected = s.selectedBranch;
    if (selected != null && s.hasUserLocation && selected.distanceInKm != null) {
      markers.add(
        Marker(
          point: LatLng(
            (s.userLat! + selected.lat) / 2,
            (s.userLng! + selected.lng) / 2,
          ),
          width: 150,
          height: 32,
          child: IgnorePointer(
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppDimens.rFull),
                  border: Border.all(color: AppColors.primary, width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  '${selected.formattedDistance} • ${selected.formattedEta}',
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 11.5,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Ghim "Vị trí của bạn" với vòng tròn tỏa sóng
    if (s.hasUserLocation) {
      markers.add(
        Marker(
          point: LatLng(s.userLat!, s.userLng!),
          width: 84,
          height: 84,
          child: IgnorePointer(child: _UserLocationPin(animation: _pulseController)),
        ),
      );
    }

    return markers;
  }

  @override
  Widget build(BuildContext context) {
    final branchState = ref.watch(branchNotifierProvider);
    final branches = branchState.branches;
    final selectedBranch = branchState.selectedBranch;
    final nearestBranch = branchState.nearestBranch;

    // Khi danh sách chi nhánh tải xong lần đầu -> zoom khít vị trí người dùng & quán gần nhất
    ref.listen<BranchState>(branchNotifierProvider, (prev, next) {
      final firstLoad = (prev?.branches.isEmpty ?? true) && next.branches.isNotEmpty;
      if (firstLoad) _fitUserAndBranch(next);
    });

    final panelVisible = selectedBranch != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // 1. Bản đồ đường phố thật (OpenStreetMap / CartoDB Voyager)
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _defaultCenter,
              initialZoom: 13.5,
              minZoom: _minZoom,
              maxZoom: _maxZoom,
              backgroundColor: const Color(0xFFE9EEF2),
              interactionOptions: const InteractionOptions(
                flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
              ),
              onMapReady: () {
                _mapReady = true;
                _fitUserAndBranch(ref.read(branchNotifierProvider));
              },
              onTap: (tapPosition, point) {
                // Chạm vào khoảng trống bản đồ để đóng card
                ref.read(branchNotifierProvider.notifier).clearSelectedBranch();
              },
            ),
            children: [
              TileLayer(
                urlTemplate: _tileUrl,
                userAgentPackageName: 'com.coffeeshop.mobile_app',
                maxNativeZoom: 19,
                maxZoom: _maxZoom,
                panBuffer: 2,
              ),

              // Đường nối từ "Vị trí của tôi" đến "Chi nhánh đang chọn"
              if (selectedBranch != null && branchState.hasUserLocation)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: [
                        LatLng(branchState.userLat!, branchState.userLng!),
                        LatLng(selectedBranch.lat, selectedBranch.lng),
                      ],
                      strokeWidth: 4.5,
                      color: AppColors.primary,
                      pattern: StrokePattern.dashed(segments: const [10, 9]),
                      strokeCap: StrokeCap.round,
                    ),
                  ],
                ),

              MarkerLayer(markers: _buildMarkers(branchState)),
            ],
          ),

          // 2. Top Bar (Nút quay lại, Tiêu đề và Danh sách chi nhánh ngang)
          SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Material(
                        color: Colors.white,
                        elevation: 3,
                        shadowColor: Colors.black26,
                        borderRadius: BorderRadius.circular(AppDimens.r12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(AppDimens.r12),
                          onTap: () => context.canPop() ? context.pop() : context.go(AppRoutes.home),
                          child: const SizedBox(
                            width: 44,
                            height: 44,
                            child: Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          height: 44,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(AppDimens.r12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          alignment: Alignment.centerLeft,
                          child: Row(
                            children: [
                              const Icon(Icons.location_on_rounded, color: AppColors.primary, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Chi Nhánh Tại TP. Hồ Chí Minh',
                                  style: AppTextStyles.subtitle.copyWith(fontSize: 14),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (branchState.isLoading)
                                const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Chip lọc nhanh các chi nhánh
                if (branches.isNotEmpty)
                  SizedBox(
                    height: 40,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      itemCount: branches.length,
                      separatorBuilder: (context, index) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final branch = branches[index];
                        final isSelected = selectedBranch?.id == branch.id;
                        final isNearest = nearestBranch?.id == branch.id;

                        return GestureDetector(
                          onTap: () => _animateToBranch(branch),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primary : Colors.white,
                              borderRadius: BorderRadius.circular(AppDimens.rFull),
                              border: Border.all(
                                color: isSelected ? AppColors.primary : AppColors.lightBorder,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.06),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isNearest) ...[
                                  const Icon(Icons.near_me_rounded, size: 14, color: Colors.amber),
                                  const SizedBox(width: 4),
                                ],
                                Text(
                                  branch.shortName,
                                  style: AppTextStyles.caption.copyWith(
                                    color: isSelected ? Colors.white : AppColors.textPrimary,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                  ),
                                ),
                                if (branch.distanceInKm != null) ...[
                                  const SizedBox(width: 6),
                                  Text(
                                    '(${branch.formattedDistance})',
                                    style: AppTextStyles.caption.copyWith(
                                      color: isSelected ? AppColors.secondary : AppColors.textSecondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),

          // 3. Nhóm nút bên phải: Zoom + "Vị trí của tôi"
          Positioned(
            right: 16,
            bottom: panelVisible ? _panelHeight + 20 : 32,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _MapRoundButton(
                  icon: Icons.add_rounded,
                  tooltip: 'Phóng to',
                  onTap: () => _zoomBy(1),
                ),
                const SizedBox(height: 8),
                _MapRoundButton(
                  icon: Icons.remove_rounded,
                  tooltip: 'Thu nhỏ',
                  onTap: () => _zoomBy(-1),
                ),
                const SizedBox(height: 12),
                FloatingActionButton.extended(
                  heroTag: 'my_location_fab',
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primary,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimens.r16),
                    side: const BorderSide(color: AppColors.lightBorder),
                  ),
                  onPressed: branchState.isLocating ? null : _handleLocateUser,
                  icon: branchState.isLocating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                        )
                      : const Icon(Icons.my_location_rounded, color: AppColors.primary),
                  label: Text(
                    branchState.isLocating ? 'Đang định vị...' : 'Vị trí của tôi',
                    style: AppTextStyles.subtitle.copyWith(fontSize: 14, color: AppColors.primary),
                  ),
                ),
              ],
            ),
          ),

          // 4. Ghi nguồn bản đồ (theo điều khoản OpenStreetMap / CARTO)
          Positioned(
            left: 10,
            bottom: panelVisible ? _panelHeight + 6 : 8,
            child: IgnorePointer(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(AppDimens.r4),
                ),
                child: Text(
                  '© OpenStreetMap contributors',
                  style: AppTextStyles.caption.copyWith(fontSize: 9.5, color: AppColors.textSecondary),
                ),
              ),
            ),
          ),

          // 5. Card thông tin chi nhánh (Bottom Card nổi)
          if (selectedBranch != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: BranchInfoPanel(
                branch: selectedBranch,
                isNearest: nearestBranch?.id == selectedBranch.id,
                onClose: () => ref.read(branchNotifierProvider.notifier).clearSelectedBranch(),
                onDirectionsTap: () => _animateToBranch(selectedBranch),
                onSelectBranch: () => _handleSelectBranch(selectedBranch),
              ),
            ),
        ],
      ),
    );
  }
}

/// Nút tròn nhỏ trên bản đồ (zoom +/-)
class _MapRoundButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _MapRoundButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 3,
      shadowColor: Colors.black26,
      shape: const CircleBorder(side: BorderSide(color: AppColors.lightBorder)),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Tooltip(
          message: tooltip,
          child: SizedBox(
            width: 40,
            height: 40,
            child: Icon(icon, color: AppColors.textPrimary, size: 22),
          ),
        ),
      ),
    );
  }
}

/// Ghim chi nhánh quán: icon ly cà phê, chi nhánh đang chọn được phóng to
class _BranchPin extends StatelessWidget {
  final bool isSelected;
  final bool isNearest;

  const _BranchPin({required this.isSelected, required this.isNearest});

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? const Color(0xFFE5532D) : AppColors.primary;

    return AnimatedScale(
      scale: isSelected ? 1.0 : 0.72,
      alignment: Alignment.bottomCenter,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutBack,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withValues(alpha: 0.82)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.45),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(Icons.local_cafe_rounded, color: Colors.white, size: 28),
              ),
              if (isNearest)
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(color: Colors.amber, shape: BoxShape.circle),
                    child: const Icon(Icons.near_me_rounded, color: Colors.white, size: 12),
                  ),
                ),
            ],
          ),
          // Mũi nhọn của ghim
          ClipPath(
            clipper: _PinTipClipper(),
            child: Container(width: 16, height: 12, color: color),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _PinTipClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

/// Ghim "Vị trí của bạn": chấm xanh dương có vòng tròn tỏa sóng
class _UserLocationPin extends StatelessWidget {
  final Animation<double> animation;

  const _UserLocationPin({required this.animation});

  @override
  Widget build(BuildContext context) {
    const blue = Color(0xFF1A73E8);

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final t = animation.value;
        return Stack(
          alignment: Alignment.center,
          children: [
            // Hai vòng sóng lệch pha
            for (final phase in const [0.0, 0.5])
              Builder(builder: (context) {
                final p = (t + phase) % 1.0;
                return Container(
                  width: 84 * (0.25 + 0.75 * p),
                  height: 84 * (0.25 + 0.75 * p),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: blue.withValues(alpha: 0.28 * (1 - p)),
                  ),
                );
              }),
            child!,
          ],
        );
      },
      child: Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color: blue,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3.5),
          boxShadow: [
            BoxShadow(
              color: blue.withValues(alpha: 0.5),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      ),
    );
  }
}

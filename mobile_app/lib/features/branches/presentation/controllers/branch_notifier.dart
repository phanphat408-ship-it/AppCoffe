import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../data/models/branch_model.dart';
import '../../data/repositories/branch_repository.dart';
import 'branch_state.dart';

final branchNotifierProvider =
    NotifierProvider<BranchNotifier, BranchState>(BranchNotifier.new);

/// Kết quả định vị người dùng (luôn có tọa độ – hoặc GPS thật, hoặc mặc định TP.HCM)
class UserLocationResult {
  final double lat;
  final double lng;
  final bool isFallback;

  const UserLocationResult({
    required this.lat,
    required this.lng,
    required this.isFallback,
  });
}

class BranchNotifier extends Notifier<BranchState> {
  late final BranchRepository _repository;

  /// Thời gian tối đa chờ GPS – quá hạn lập tức dùng vị trí mặc định TP.HCM
  static const Duration gpsTimeout = Duration(seconds: 2);

  @override
  BranchState build() {
    _repository = ref.read(branchRepositoryProvider);
    Future.microtask(() {
      if (ref.mounted) {
        loadBranches();
      }
    });
    // Vị trí người dùng luôn có sẵn tại trung tâm TP.HCM ngay từ đầu
    return const BranchState(
      isLoading: true,
      userLat: BranchRepository.defaultUserLat,
      userLng: BranchRepository.defaultUserLng,
    );
  }

  /// Tải danh sách các chi nhánh (kèm khoảng cách từ vị trí hiện tại của người dùng)
  Future<void> loadBranches() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    List<BranchModel> branches;
    String? warning;
    try {
      branches = await _repository.getBranches();
    } catch (e) {
      debugPrint('>> Lỗi khi tải chi nhánh: $e');
      branches = BranchRepository.mockBranches;
      warning = 'Không thể kết nối đến máy chủ. Đang hiển thị chi nhánh mẫu.';
    }

    if (!ref.mounted) return;

    final withDistance = _repository.calculateDistances(
      branches: branches,
      userLat: state.userLat ?? BranchRepository.defaultUserLat,
      userLng: state.userLng ?? BranchRepository.defaultUserLng,
    );
    final nearest = _repository.findNearestBranch(withDistance);

    state = state.copyWith(
      isLoading: false,
      branches: withDistance,
      nearestBranch: nearest,
      selectedBranch: nearest ?? withDistance.firstOrNull,
      errorMessage: warning,
    );
  }

  /// Xác định vị trí người dùng. KHÔNG BAO GIỜ treo luồng chính:
  /// - Chờ GPS tối đa [gpsTimeout]
  /// - GPS tắt / bị từ chối / lỗi / timeout / nằm ngoài TP.HCM (vd: máy ảo trỏ sang Mỹ)
  ///   => lập tức dùng vị trí mặc định tại trung tâm TP.HCM.
  Future<UserLocationResult> locateUserAndFindNearest() async {
    state = state.copyWith(isLocating: true, errorMessage: null, locationStatusMessage: null);

    double lat = BranchRepository.defaultUserLat;
    double lng = BranchRepository.defaultUserLng;
    var isFallback = true;

    try {
      final position = await _readDevicePosition().timeout(gpsTimeout);
      if (position != null && _isInHoChiMinhCity(position.latitude, position.longitude)) {
        lat = position.latitude;
        lng = position.longitude;
        isFallback = false;
      } else if (position != null) {
        debugPrint('>> GPS ngoài TP.HCM (${position.latitude}, ${position.longitude}) -> dùng vị trí mặc định TP.HCM');
      }
    } catch (e) {
      debugPrint('>> Không lấy được GPS ($e) -> dùng vị trí mặc định TP.HCM');
    }

    if (!ref.mounted) {
      return UserLocationResult(lat: lat, lng: lng, isFallback: isFallback);
    }

    final withDistance = _repository.calculateDistances(
      branches: state.branches,
      userLat: lat,
      userLng: lng,
    );
    final nearest = _repository.findNearestBranch(withDistance);

    state = state.copyWith(
      isLocating: false,
      userLat: lat,
      userLng: lng,
      isUserLocationFallback: isFallback,
      branches: withDistance,
      nearestBranch: nearest,
      selectedBranch: nearest,
      locationStatusMessage: nearest != null
          ? 'Quán gần bạn nhất: ${nearest.shortName} (${nearest.formattedDistance})'
          : 'Đã xác định vị trí của bạn.',
    );

    return UserLocationResult(lat: lat, lng: lng, isFallback: isFallback);
  }

  /// Đọc vị trí thiết bị (trả về null nếu GPS tắt hoặc không có quyền)
  Future<Position?> _readDevicePosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.medium,
        timeLimit: gpsTimeout,
      ),
    );
  }

  bool _isInHoChiMinhCity(double lat, double lng) =>
      lat >= 10.3 && lat <= 11.2 && lng >= 106.3 && lng <= 107.1;

  /// Chọn một chi nhánh cụ thể để xem thông tin
  void selectBranch(BranchModel branch) {
    state = state.copyWith(selectedBranch: branch);
  }

  /// Đóng Card thông tin chi nhánh
  void clearSelectedBranch() {
    state = state.copyWith(clearSelectedBranch: true);
  }

  /// Lưu chi nhánh khách chọn để đặt món (dùng cho Giỏ hàng / Checkout / Đơn hàng)
  void confirmOrderBranch(BranchModel branch) {
    state = state.copyWith(orderBranch: branch, selectedBranch: branch);
  }
}

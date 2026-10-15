import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/branch_model.dart';

final branchRepositoryProvider = Provider<BranchRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return BranchRepository(dio);
});

class BranchRepository {
  final Dio _dio;

  BranchRepository(this._dio);

  /// Vị trí mặc định của người dùng: trung tâm TP. Hồ Chí Minh (giáp ranh Quận 1 - Bình Thạnh)
  static const double defaultUserLat = 10.7900;
  static const double defaultUserLng = 106.7050;

  /// Giờ mở cửa mặc định khi API không trả về
  static const String defaultOpeningHours = '07:00 - 22:30';

  /// Ảnh đại diện chi nhánh (dùng khi API không trả về imageUrl)
  static const List<String> _branchImages = [
    'https://images.unsplash.com/photo-1554118811-1e0d58224f24?w=600',
    'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?w=600',
    'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=600',
    'https://images.unsplash.com/photo-1445116572660-236099ec97a0?w=600',
    'https://images.unsplash.com/photo-1442512595331-e89e73853f31?w=600',
  ];

  /// Danh sách 5 chi nhánh quán cà phê tại các khu vực sầm uất của TP. Hồ Chí Minh
  static const List<BranchModel> mockBranches = [
    BranchModel(
      id: 1,
      name: 'Chi Nhánh Quận 1 - Nguyễn Huệ',
      address: '68 Nguyễn Huệ, Phường Bến Nghé, Quận 1, TP. Hồ Chí Minh',
      lat: 10.7745,
      lng: 106.7035,
      phone: '028 3822 1144',
      openingHours: '07:00 - 22:30',
      imageUrl: 'https://images.unsplash.com/photo-1554118811-1e0d58224f24?w=600',
    ),
    BranchModel(
      id: 2,
      name: 'Chi Nhánh Quận 3 - Hồ Con Rùa',
      address: 'Công trường Quốc Tế, Phường Võ Thị Sáu, Quận 3, TP. Hồ Chí Minh',
      lat: 10.7827,
      lng: 106.6959,
      phone: '028 3822 5566',
      openingHours: '06:30 - 23:00',
      imageUrl: 'https://images.unsplash.com/photo-1501339847302-ac426a4a7cbb?w=600',
    ),
    BranchModel(
      id: 3,
      name: 'Chi Nhánh Bình Thạnh - Landmark 81',
      address: '475A Điện Biên Phủ, Phường 25, Quận Bình Thạnh, TP. Hồ Chí Minh',
      lat: 10.8017,
      lng: 106.7145,
      phone: '028 3512 0081',
      openingHours: '07:00 - 22:00',
      imageUrl: 'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=600',
    ),
    BranchModel(
      id: 4,
      name: 'Chi Nhánh TP. Thủ Đức - Xa Lộ Hà Nội',
      address: 'Khu Công Nghệ Cao, Phường Hiệp Phú, TP. Thủ Đức, TP. Hồ Chí Minh',
      lat: 10.8411,
      lng: 106.7869,
      phone: '028 3736 0099',
      openingHours: '06:30 - 22:00',
      imageUrl: 'https://images.unsplash.com/photo-1445116572660-236099ec97a0?w=600',
    ),
    BranchModel(
      id: 5,
      name: 'Chi Nhánh Quận 7 - Phú Mỹ Hưng',
      address: '105 Tôn Dật Tiên, Phường Tân Phú, Quận 7, TP. Hồ Chí Minh',
      lat: 10.7294,
      lng: 106.7218,
      phone: '028 5412 0077',
      openingHours: '07:00 - 23:00',
      imageUrl: 'https://images.unsplash.com/photo-1442512595331-e89e73853f31?w=600',
    ),
  ];

  /// Lấy danh sách chi nhánh (API backend kèm fallback Mock Data TP.HCM).
  /// Mọi chi nhánh nằm ngoài TP.HCM (vd: dữ liệu cũ ở Hà Nội) sẽ bị loại bỏ.
  Future<List<BranchModel>> getBranches() async {
    try {
      final response = await _dio
          .get(
            ApiEndpoints.branches,
            options: Options(extra: {'requiresAuth': false}),
          )
          .timeout(const Duration(seconds: 4));

      final responseData = response.data;
      if (responseData is Map<String, dynamic>) {
        final success = responseData['success'] as bool? ?? false;
        if (success && responseData['data'] is List) {
          final list = responseData['data'] as List;
          final branches = list
              .map((item) => BranchModel.fromJson(item as Map<String, dynamic>))
              .where((b) => b.isInHoChiMinhCity)
              .map(_enrich)
              .toList();
          if (branches.isNotEmpty) {
            return branches;
          }
        }
      }
    } catch (e) {
      debugPrint('>> API Branches offline hoặc lỗi: $e. Sử dụng Mock Data 5 chi nhánh TP.HCM');
    }

    // Fallback Mock Data
    return mockBranches;
  }

  /// Bổ sung ảnh & giờ mở cửa còn thiếu từ API
  BranchModel _enrich(BranchModel b) {
    return b.copyWith(
      openingHours: b.openingHours ?? defaultOpeningHours,
      imageUrl: b.imageUrl ?? _branchImages[(b.id - 1).abs() % _branchImages.length],
    );
  }

  /// Tính khoảng cách giữa vị trí hiện tại và từng chi nhánh (đơn vị: km)
  List<BranchModel> calculateDistances({
    required List<BranchModel> branches,
    required double userLat,
    required double userLng,
  }) {
    return branches.map((branch) {
      // Geolocator.distanceBetween trả về khoảng cách tính bằng mét (m)
      final distanceInMeters = Geolocator.distanceBetween(
        userLat,
        userLng,
        branch.lat,
        branch.lng,
      );
      final distanceInKm = distanceInMeters / 1000.0;
      return branch.copyWith(distanceInKm: distanceInKm);
    }).toList();
  }

  /// Tìm chi nhánh gần nhất từ danh sách đã tính khoảng cách
  BranchModel? findNearestBranch(List<BranchModel> branchesWithDistance) {
    if (branchesWithDistance.isEmpty) return null;
    final sorted = List<BranchModel>.from(branchesWithDistance)
      ..sort((a, b) => (a.distanceInKm ?? double.infinity)
          .compareTo(b.distanceInKm ?? double.infinity));
    return sorted.first;
  }
}

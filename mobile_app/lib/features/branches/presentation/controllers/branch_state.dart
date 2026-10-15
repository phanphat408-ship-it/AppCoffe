import '../../data/models/branch_model.dart';

/// Trạng thái của màn hình Bản đồ & Chi nhánh
class BranchState {
  final bool isLoading;
  final bool isLocating;
  final List<BranchModel> branches;

  /// Chi nhánh đang được chọn xem trên bản đồ
  final BranchModel? selectedBranch;

  /// Chi nhánh gần vị trí người dùng nhất
  final BranchModel? nearestBranch;

  /// Chi nhánh khách đã bấm "Chọn đặt món" – dùng cho giỏ hàng / Checkout / đơn hàng
  final BranchModel? orderBranch;

  /// Vị trí của người dùng (luôn có giá trị, mặc định tại trung tâm TP.HCM)
  final double? userLat;
  final double? userLng;

  /// true khi đang dùng vị trí mặc định TP.HCM thay vì GPS thật của thiết bị
  final bool isUserLocationFallback;

  final String? errorMessage;
  final String? locationStatusMessage;

  const BranchState({
    this.isLoading = false,
    this.isLocating = false,
    this.branches = const [],
    this.selectedBranch,
    this.nearestBranch,
    this.orderBranch,
    this.userLat,
    this.userLng,
    this.isUserLocationFallback = true,
    this.errorMessage,
    this.locationStatusMessage,
  });

  bool get hasUserLocation => userLat != null && userLng != null;

  /// Chi nhánh dùng để đặt món (ưu tiên: đã chọn đặt món -> đang xem -> gần nhất -> đầu tiên)
  BranchModel? get effectiveOrderBranch =>
      orderBranch ?? selectedBranch ?? nearestBranch ?? branches.firstOrNull;

  BranchState copyWith({
    bool? isLoading,
    bool? isLocating,
    List<BranchModel>? branches,
    BranchModel? selectedBranch,
    BranchModel? nearestBranch,
    BranchModel? orderBranch,
    double? userLat,
    double? userLng,
    bool? isUserLocationFallback,
    String? errorMessage,
    String? locationStatusMessage,
    bool clearSelectedBranch = false,
  }) {
    return BranchState(
      isLoading: isLoading ?? this.isLoading,
      isLocating: isLocating ?? this.isLocating,
      branches: branches ?? this.branches,
      selectedBranch: clearSelectedBranch ? null : (selectedBranch ?? this.selectedBranch),
      nearestBranch: nearestBranch ?? this.nearestBranch,
      orderBranch: orderBranch ?? this.orderBranch,
      userLat: userLat ?? this.userLat,
      userLng: userLng ?? this.userLng,
      isUserLocationFallback: isUserLocationFallback ?? this.isUserLocationFallback,
      errorMessage: errorMessage,
      locationStatusMessage: locationStatusMessage,
    );
  }
}

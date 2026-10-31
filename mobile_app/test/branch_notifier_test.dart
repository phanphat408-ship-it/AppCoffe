import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_app/features/branches/data/models/branch_model.dart';
import 'package:mobile_app/features/branches/data/repositories/branch_repository.dart';
import 'package:mobile_app/features/branches/presentation/controllers/branch_notifier.dart';

class FakeBranchRepository extends BranchRepository {
  FakeBranchRepository() : super(Dio());

  @override
  Future<List<BranchModel>> getBranches() async {
    return BranchRepository.mockBranches;
  }
}

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer(
      overrides: [
        branchRepositoryProvider.overrideWithValue(FakeBranchRepository()),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('BranchModel Tests', () {
    test('formattedDistance hiển thị chuẩn theo mét và km', () {
      const nearBranch = BranchModel(
        id: 1,
        name: 'Quán Gần',
        address: '123 Đ. A',
        lat: 10.77,
        lng: 106.69,
        distanceInKm: 0.35, // 350m
      );
      expect(nearBranch.formattedDistance, '350 m');

      const farBranch = BranchModel(
        id: 2,
        name: 'Quán Xa',
        address: '456 Đ. B',
        lat: 10.80,
        lng: 106.72,
        distanceInKm: 2.44, // 2.4km
      );
      expect(farBranch.formattedDistance, '2.4 km');

      const nullBranch = BranchModel(
        id: 3,
        name: 'Chưa có vị trí',
        address: '789 Đ. C',
        lat: 10.80,
        lng: 106.72,
      );
      expect(nullBranch.formattedDistance, '');
    });

    test('shortName, formattedEta và isInHoChiMinhCity hoạt động chuẩn xác', () {
      const b1 = BranchModel(
        id: 1,
        name: 'Chi Nhánh Quận 1 - Nguyễn Huệ',
        address: '68 Nguyễn Huệ, P. Bến Nghé, Quận 1, TP.HCM',
        lat: 10.7745,
        lng: 106.7035,
        distanceInKm: 2.5,
      );
      expect(b1.shortName, 'Nguyễn Huệ');
      expect(b1.isInHoChiMinhCity, isTrue);
      expect(b1.estimatedMinutes, greaterThanOrEqualTo(8));
      expect(b1.formattedEta, contains('phút'));

      const bHanoi = BranchModel(
        id: 99,
        name: 'Chi nhánh Hà Nội - Hoàn Kiếm',
        address: '1 Tràng Tiền, Hoàn Kiếm, Hà Nội',
        lat: 21.0285,
        lng: 105.8542,
      );
      expect(bHanoi.isInHoChiMinhCity, isFalse);
    });
  });

  group('BranchRepository Tests', () {
    test('Mock data chứa đủ 5 chi nhánh TP.HCM với tọa độ hợp lệ', () {
      const branches = BranchRepository.mockBranches;
      expect(branches.length, 5);

      for (final branch in branches) {
        expect(branch.name, isNotEmpty);
        expect(branch.address, isNotEmpty);
        expect(branch.lat, inInclusiveRange(10.0, 11.5)); // Thuộc TP.HCM
        expect(branch.lng, inInclusiveRange(106.0, 107.5));
        expect(branch.isInHoChiMinhCity, isTrue);
      }
    });

    test('calculateDistances và findNearestBranch tìm đúng chi nhánh gần nhất', () {
      final repo = container.read(branchRepositoryProvider);

      // Người dùng đứng ngay tại Phố đi bộ Nguyễn Huệ
      const userLat = 10.7745;
      const userLng = 106.7035;

      final branchesWithDistance = repo.calculateDistances(
        branches: BranchRepository.mockBranches,
        userLat: userLat,
        userLng: userLng,
      );

      expect(branchesWithDistance.length, 5);
      for (final b in branchesWithDistance) {
        expect(b.distanceInKm, isNotNull);
      }

      final nearest = repo.findNearestBranch(branchesWithDistance);
      expect(nearest, isNotNull);
      // Chi nhánh 1 (Quận 1 - Nguyễn Huệ) phải là chi nhánh gần nhất (< 0.05 km)
      expect(nearest!.id, 1);
      expect(nearest.distanceInKm! < 0.05, isTrue);
    });
  });

  group('BranchNotifier Tests', () {
    test('loadBranches nạp danh sách 5 chi nhánh thành công', () async {
      final notifier = container.read(branchNotifierProvider.notifier);
      await notifier.loadBranches();

      final state = container.read(branchNotifierProvider);
      expect(state.isLoading, isFalse);
      expect(state.branches.length, 5);
      expect(state.selectedBranch, isNotNull);
      expect(state.userLat, BranchRepository.defaultUserLat);
      expect(state.userLng, BranchRepository.defaultUserLng);
    });

    test('selectBranch, clearSelectedBranch và confirmOrderBranch cập nhật state đúng', () async {
      final notifier = container.read(branchNotifierProvider.notifier);
      await notifier.loadBranches();

      final branch3 = container.read(branchNotifierProvider).branches[2];
      notifier.selectBranch(branch3);
      expect(container.read(branchNotifierProvider).selectedBranch?.id, branch3.id);

      // Xác nhận chi nhánh đặt món
      notifier.confirmOrderBranch(branch3);
      expect(container.read(branchNotifierProvider).orderBranch?.id, branch3.id);
      expect(container.read(branchNotifierProvider).effectiveOrderBranch?.id, branch3.id);

      notifier.clearSelectedBranch();
      expect(container.read(branchNotifierProvider).selectedBranch, isNull);
      // effectiveOrderBranch vẫn trả về orderBranch đã xác nhận
      expect(container.read(branchNotifierProvider).effectiveOrderBranch?.id, branch3.id);
    });
  });
}

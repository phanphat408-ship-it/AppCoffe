import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/saved_address_model.dart';

/// Provider quản lý danh sách Địa chỉ đã lưu
final savedAddressesProvider =
    NotifierProvider<SavedAddressesNotifier, List<SavedAddress>>(
  SavedAddressesNotifier.new,
);

class SavedAddressesNotifier extends Notifier<List<SavedAddress>> {
  @override
  List<SavedAddress> build() {
    return const [
      SavedAddress(
        id: 'addr_1',
        title: 'Nhà riêng (Quận 1)',
        recipientName: 'Nguyễn Văn An',
        phone: '0901 234 567',
        fullAddress: '123 Lê Lợi, Phường Bến Nghé, Quận 1, TP. Hồ Chí Minh',
        note: 'Bấm chuông cửa số 3 hoặc gọi trước khi giao',
        isDefault: true,
      ),
      SavedAddress(
        id: 'addr_2',
        title: 'Căn hộ Landmark (Bình Thạnh)',
        recipientName: 'Nguyễn Văn An',
        phone: '0901 234 567',
        fullAddress: 'Tòa Landmark 81, 720A Điện Biên Phủ, Phường 22, Quận Bình Thạnh, TP. Hồ Chí Minh',
        note: 'Giao ở sảnh lễ tân tầng 1 tháp Park 2',
        isDefault: false,
      ),
      SavedAddress(
        id: 'addr_3',
        title: 'Công ty Công nghệ (TP. Thủ Đức)',
        recipientName: 'Nguyễn Văn An',
        phone: '0901 234 567',
        fullAddress: 'Khu Công Nghệ Cao, Xa Lộ Hà Nội, P. Hiệp Phú, TP. Thủ Đức, TP. Hồ Chí Minh',
        note: 'Giao tại cổng bảo vệ FPT Software',
        isDefault: false,
      ),
      SavedAddress(
        id: 'addr_4',
        title: 'Văn phòng chi nhánh (Quận 3)',
        recipientName: 'Nguyễn Văn An',
        phone: '0901 234 567',
        fullAddress: '42 Trần Quốc Thảo, Phường Võ Thị Sáu, Quận 3, TP. Hồ Chí Minh',
        note: 'Lên lầu 3 phòng 302',
        isDefault: false,
      ),
    ];
  }

  /// Thêm địa chỉ mới
  void addAddress({
    required String title,
    required String recipientName,
    required String phone,
    required String fullAddress,
    String note = '',
    bool isDefault = false,
  }) {
    final newAddress = SavedAddress(
      id: 'addr_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      recipientName: recipientName,
      phone: phone,
      fullAddress: fullAddress,
      note: note,
      isDefault: isDefault || state.isEmpty,
    );

    if (newAddress.isDefault) {
      state = [
        newAddress,
        ...state.map((a) => a.copyWith(isDefault: false)),
      ];
    } else {
      state = [...state, newAddress];
    }
  }

  /// Chỉnh sửa địa chỉ
  void updateAddress(SavedAddress updated) {
    if (updated.isDefault) {
      state = state.map((a) {
        if (a.id == updated.id) return updated;
        return a.copyWith(isDefault: false);
      }).toList();
    } else {
      state = state.map((a) => a.id == updated.id ? updated : a).toList();
    }
  }

  /// Xóa địa chỉ
  void deleteAddress(String id) {
    final wasDefault = state.firstWhere((a) => a.id == id, orElse: () => state.first).isDefault;
    final remaining = state.where((a) => a.id != id).toList();

    // Nếu vừa xóa địa chỉ mặc định mà còn địa chỉ khác, gán cái đầu tiên làm mặc định
    if (wasDefault && remaining.isNotEmpty) {
      remaining[0] = remaining[0].copyWith(isDefault: true);
    }
    state = remaining;
  }

  /// Đặt làm địa chỉ mặc định
  void setDefault(String id) {
    state = state.map((a) {
      return a.copyWith(isDefault: a.id == id);
    }).toList();
  }
}

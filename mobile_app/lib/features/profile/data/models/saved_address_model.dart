/// Model Địa chỉ giao hàng đã lưu trong Sổ địa chỉ
class SavedAddress {
  final String id;
  final String title; // "Nhà riêng", "Công ty", "Nhà bạn",...
  final String recipientName;
  final String phone;
  final String fullAddress;
  final String note;
  final bool isDefault;

  const SavedAddress({
    required this.id,
    required this.title,
    required this.recipientName,
    required this.phone,
    required this.fullAddress,
    this.note = '',
    this.isDefault = false,
  });

  SavedAddress copyWith({
    String? id,
    String? title,
    String? recipientName,
    String? phone,
    String? fullAddress,
    String? note,
    bool? isDefault,
  }) {
    return SavedAddress(
      id: id ?? this.id,
      title: title ?? this.title,
      recipientName: recipientName ?? this.recipientName,
      phone: phone ?? this.phone,
      fullAddress: fullAddress ?? this.fullAddress,
      note: note ?? this.note,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}

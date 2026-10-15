/// Model đại diện cho một chi nhánh quán cà phê
class BranchModel {
  final int id;
  final String name;
  final String address;
  final double lat;
  final double lng;
  final String? phone;
  final String? openingHours;
  final String? imageUrl;
  final double? distanceInKm;

  const BranchModel({
    required this.id,
    required this.name,
    required this.address,
    required this.lat,
    required this.lng,
    this.phone,
    this.openingHours,
    this.imageUrl,
    this.distanceInKm,
  });

  factory BranchModel.fromJson(Map<String, dynamic> json) {
    return BranchModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      address: json['address'] as String? ?? '',
      lat: (json['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (json['lng'] as num?)?.toDouble() ?? 0.0,
      phone: json['phone'] as String?,
      openingHours: json['openingHours'] as String?,
      imageUrl: json['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'lat': lat,
      'lng': lng,
      'phone': phone,
      'openingHours': openingHours,
      'imageUrl': imageUrl,
    };
  }

  BranchModel copyWith({
    int? id,
    String? name,
    String? address,
    double? lat,
    double? lng,
    String? phone,
    String? openingHours,
    String? imageUrl,
    double? distanceInKm,
  }) {
    return BranchModel(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      phone: phone ?? this.phone,
      openingHours: openingHours ?? this.openingHours,
      imageUrl: imageUrl ?? this.imageUrl,
      distanceInKm: distanceInKm ?? this.distanceInKm,
    );
  }

  /// Chi nhánh có nằm trong vùng TP. Hồ Chí Minh (bounding box) hay không
  bool get isInHoChiMinhCity =>
      lat >= 10.3 && lat <= 11.2 && lng >= 106.3 && lng <= 107.1;

  /// Tên rút gọn hiển thị trên các chip lọc nhanh (vd: "Nguyễn Huệ", "Quận 7")
  String get shortName {
    const keywords = <String>[
      'Nguyễn Huệ',
      'Hồ Con Rùa',
      'Bình Thạnh',
      'Thủ Đức',
      'Quận 7',
    ];
    for (final keyword in keywords) {
      if (name.contains(keyword)) return keyword;
    }
    final tail = name.split(' - ').last.trim();
    return tail.isEmpty ? name : tail;
  }

  /// Format khoảng cách hiển thị (vd: 350 m hoặc 2.4 km)
  String get formattedDistance {
    if (distanceInKm == null) return '';
    if (distanceInKm! < 1.0) {
      final meters = (distanceInKm! * 1000).round();
      return '$meters m';
    }
    return '${distanceInKm!.toStringAsFixed(1)} km';
  }

  /// Thời gian giao hàng dự kiến (phút): 8 phút pha chế + quãng đường ~25 km/h
  int? get estimatedMinutes {
    if (distanceInKm == null) return null;
    final rideMinutes = (distanceInKm! / 25.0 * 60).ceil();
    return 8 + rideMinutes;
  }

  /// Hiển thị thời gian giao hàng dự kiến (vd: ~15 phút)
  String get formattedEta {
    final minutes = estimatedMinutes;
    return minutes == null ? '' : '~$minutes phút';
  }
}

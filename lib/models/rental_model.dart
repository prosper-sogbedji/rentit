class RentalModel {
  final String id;
  final String userId;
  final String itemId;
  final DateTime startDate;
  final DateTime endDate;
  final int duration; // in hours
  final double totalPrice;
  final String status; // 'pending', 'confirmed', 'completed', 'cancelled'
  final DateTime createdAt;

  const RentalModel({
    required this.id,
    required this.userId,
    required this.itemId,
    required this.startDate,
    required this.endDate,
    required this.duration,
    required this.totalPrice,
    this.status = 'pending',
    required this.createdAt,
  });

  RentalModel copyWith({
    String? id,
    String? userId,
    String? itemId,
    DateTime? startDate,
    DateTime? endDate,
    int? duration,
    double? totalPrice,
    String? status,
    DateTime? createdAt,
  }) {
    return RentalModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      itemId: itemId ?? this.itemId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      duration: duration ?? this.duration,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'itemId': itemId,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'duration': duration,
      'totalPrice': totalPrice,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory RentalModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    DateTime parseDate(dynamic val) {
      if (val == null) return DateTime.now();
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      if (val.toDate != null) return val.toDate();
      return DateTime.now();
    }

    return RentalModel(
      id: docId ?? map['id'] ?? '',
      userId: map['userId'] ?? '',
      itemId: map['itemId'] ?? '',
      startDate: parseDate(map['startDate']),
      endDate: parseDate(map['endDate']),
      duration: (map['duration'] as num?)?.toInt() ?? 1,
      totalPrice: (map['totalPrice'] as num?)?.toDouble() ?? 0.0,
      status: map['status'] ?? 'pending',
      createdAt: parseDate(map['createdAt']),
    );
  }
}

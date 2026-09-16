enum RentalStatus { pending, confirmed, completed, cancelled }

class RentalModel {
  final String id;
  final String userId;
  final String itemId;
  final DateTime startDate;
  final DateTime endDate;
  final int duration; // in hours
  final double totalPrice;
  final RentalStatus status;
  final DateTime createdAt;

  const RentalModel({
    required this.id,
    required this.userId,
    required this.itemId,
    required this.startDate,
    required this.endDate,
    required this.duration,
    required this.totalPrice,
    this.status = RentalStatus.pending,
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
    RentalStatus? status,
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
      'status': status.name,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory RentalModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    DateTime parseDate(dynamic val) {
      if (val == null) return DateTime.now();
      if (val is DateTime) return val;
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
      try {
        return (val as dynamic).toDate() as DateTime;
      } catch (_) {
        return DateTime.now();
      }
    }

    return RentalModel(
      id: docId ?? map['id'] ?? '',
      userId: map['userId'] ?? '',
      itemId: map['itemId'] ?? '',
      startDate: parseDate(map['startDate']),
      endDate: parseDate(map['endDate']),
      duration: (map['duration'] as num?)?.toInt() ?? 1,
      totalPrice: (map['totalPrice'] as num?)?.toDouble() ?? 0.0,
      status: RentalStatus.values.firstWhere(
        (status) => status.name == map['status'],
        orElse: () => RentalStatus.pending,
      ),
      createdAt: parseDate(map['createdAt']),
    );
  }
}

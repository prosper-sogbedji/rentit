class ItemModel {
  final String id;
  final String name;
  final String description;
  final String categoryId;
  final String imageUrl;
  final double pricePerDay;
  final int quantity;
  final String status; // 'available', 'unavailable', 'maintenance'
  final DateTime createdAt;

  const ItemModel({
    required this.id,
    required this.name,
    required this.description,
    required this.categoryId,
    required this.imageUrl,
    required this.pricePerDay,
    required this.quantity,
    this.status = 'available',
    required this.createdAt,
  });

  ItemModel copyWith({
    String? id,
    String? name,
    String? description,
    String? categoryId,
    String? imageUrl,
    double? pricePerDay,
    int? quantity,
    String? status,
    DateTime? createdAt,
  }) {
    return ItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      imageUrl: imageUrl ?? this.imageUrl,
      pricePerDay: pricePerDay ?? this.pricePerDay,
      quantity: quantity ?? this.quantity,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'categoryId': categoryId,
      'imageUrl': imageUrl,
      'pricePerDay': pricePerDay,
      'quantity': quantity,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ItemModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    return ItemModel(
      id: docId ?? map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      categoryId: map['categoryId'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      pricePerDay: (map['pricePerDay'] as num?)?.toDouble() ?? 0.0,
      quantity: (map['quantity'] as num?)?.toInt() ?? 1,
      status: map['status'] ?? 'available',
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] is String
              ? DateTime.tryParse(map['createdAt']) ?? DateTime.now()
              : (map['createdAt'].toDate != null
                  ? map['createdAt'].toDate()
                  : DateTime.now()))
          : DateTime.now(),
    );
  }
}

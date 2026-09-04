class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role; // 'client', 'admin', 'partner', etc.
  final DateTime createdAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.createdAt,
  });

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? role,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, {String? docId}) {
    return UserModel(
      id: docId ?? map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      role: map['role'] ?? 'client',
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

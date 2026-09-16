import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/category_model.dart';
import '../../models/item_model.dart';
import '../../models/rental_model.dart';
import '../../models/user_model.dart';
import 'service_exception.dart';

/// Validate before using the shared models' permissive fromMap factories.
abstract final class ModelCodec {
  static Never _invalid(String field) => throw ServiceException(
    'invalid-data',
    'Champ absent ou invalide : $field.',
  );

  static Map<String, dynamic> _normalize(
    Map<String, dynamic> data, {
    required List<String> strings,
    List<String> dates = const [],
    List<String> numbers = const [],
  }) {
    final result = Map<String, dynamic>.from(data);
    for (final field in strings) {
      if (result[field] is! String) _invalid(field);
    }
    if ((result['id'] as String).isEmpty) _invalid('id');
    for (final field in numbers) {
      if (result[field] is! num || !(result[field] as num).isFinite) {
        _invalid(field);
      }
    }
    for (final field in dates) {
      final raw = result[field];
      final parsed = raw is Timestamp
          ? raw.toDate()
          : raw is String
          ? DateTime.tryParse(raw)
          : null;
      if (parsed == null) _invalid(field);
      result[field] = parsed.toUtc().toIso8601String();
    }
    return result;
  }

  static UserModel user(Map<String, dynamic> data) {
    final map = _normalize(
      data,
      strings: ['id', 'name', 'email', 'phone', 'role'],
      dates: ['createdAt'],
    );
    if (!['client', 'admin'].contains(map['role'])) _invalid('role');
    return UserModel.fromMap(map);
  }

  static CategoryModel category(Map<String, dynamic> data) =>
      CategoryModel.fromMap(
        _normalize(data, strings: ['id', 'name', 'imageUrl']),
      );

  static ItemModel item(Map<String, dynamic> data) {
    final map = _normalize(
      data,
      strings: [
        'id',
        'name',
        'description',
        'categoryId',
        'imageUrl',
        'status',
      ],
      dates: ['createdAt'],
      numbers: ['pricePerDay', 'quantity'],
    );
    if (!['available', 'unavailable', 'maintenance'].contains(map['status'])) {
      _invalid('status');
    }
    if (map['quantity'] is! int || (map['quantity'] as int) < 0) {
      _invalid('quantity');
    }
    if ((map['pricePerDay'] as num) <= 0) _invalid('pricePerDay');
    return ItemModel.fromMap(map);
  }

  static RentalModel rental(Map<String, dynamic> data) {
    final map = _normalize(
      data,
      strings: ['id', 'userId', 'itemId', 'status'],
      dates: ['createdAt', 'startDate', 'endDate'],
      numbers: ['duration', 'totalPrice'],
    );
    if (![
      'pending',
      'confirmed',
      'completed',
      'cancelled',
    ].contains(map['status'])) {
      _invalid('status');
    }
    if (map['duration'] is! int || (map['duration'] as int) < 1) {
      _invalid('duration');
    }
    if ((map['totalPrice'] as num) < 0) _invalid('totalPrice');
    final rental = RentalModel.fromMap(map);
    if (!rental.endDate.isAfter(rental.startDate)) _invalid('endDate');
    return rental;
  }
}

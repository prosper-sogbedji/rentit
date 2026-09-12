import '../../models/rental_model.dart';
import 'model_codec.dart';
import 'service_client.dart';
import 'service_exception.dart';

class RentalQuote {
  final int durationMinutes;
  final int pricePerHourCents;
  final int totalPriceCents;
  final String currency;

  const RentalQuote({
    required this.durationMinutes,
    required this.pricePerHourCents,
    required this.totalPriceCents,
    this.currency = 'USD',
  });

  factory RentalQuote.fromMap(Map<String, dynamic> map) {
    if (map['durationMinutes'] is! int ||
        map['pricePerHourCents'] is! int ||
        map['totalPriceCents'] is! int ||
        map['currency'] != 'USD') {
      throw const ServiceException('invalid-data', 'Devis invalide.');
    }
    return RentalQuote(
      durationMinutes: map['durationMinutes'] as int,
      pricePerHourCents: map['pricePerHourCents'] as int,
      totalPriceCents: map['totalPriceCents'] as int,
    );
  }
}

class AvailabilityResult {
  final bool available;
  final int availableQuantity;
  const AvailabilityResult({
    required this.available,
    required this.availableQuantity,
  });
}

class RentalService {
  final ServiceClient client;
  RentalService(this.client);

  Map<String, dynamic> _period(String itemId, DateTime start, DateTime end) => {
    'itemId': itemId,
    'startDate': start.toUtc().toIso8601String(),
    'endDate': end.toUtc().toIso8601String(),
  };

  Future<RentalQuote> getQuote({
    required String itemId,
    required DateTime startDate,
    required DateTime endDate,
  }) => serviceCall(
    () async => RentalQuote.fromMap(
      await client.call('rentals.quote', _period(itemId, startDate, endDate)),
    ),
  );

  Future<AvailabilityResult> getAvailability({
    required String itemId,
    required DateTime startDate,
    required DateTime endDate,
  }) => serviceCall(() async {
    final data = await client.call(
      'rentals.availability',
      _period(itemId, startDate, endDate),
    );
    if (data['available'] is! bool || data['availableQuantity'] is! int) {
      throw const ServiceException('invalid-data', 'Disponibilité invalide.');
    }
    return AvailabilityResult(
      available: data['available'] as bool,
      availableQuantity: data['availableQuantity'] as int,
    );
  });

  /// One material unit per rental, matching the existing RentalModel.
  /// Keep requestId unchanged when retrying after a connection failure.
  Future<RentalModel> create({
    required String requestId,
    required String itemId,
    required DateTime startDate,
    required DateTime endDate,
    required int expectedPricePerHourCents,
  }) => serviceCall(() async {
    final uid = client.uid;
    final diffDays = endDate.difference(startDate).inDays;
    final duration = diffDays > 0 ? diffDays : 1;
    final totalPrice = (expectedPricePerHourCents / 100.0) * duration;

    final rentalMap = {
      'id': requestId,
      'userId': uid,
      'itemId': itemId,
      'startDate': startDate.toUtc().toIso8601String(),
      'endDate': endDate.toUtc().toIso8601String(),
      'duration': duration,
      'totalPrice': totalPrice,
      'status': 'confirmed',
      'createdAt': DateTime.now().toUtc().toIso8601String(),
    };

    try {
      await client.firestore.collection('rentals').doc(requestId).set(rentalMap);
    } catch (_) {
      try {
        final res = await client.call('rentals.create', {
          ..._period(itemId, startDate, endDate),
          'requestId': requestId,
          'expectedPricePerHourCents': expectedPricePerHourCents,
        });
        return ModelCodec.rental(res);
      } catch (_) {}
    }
    return ModelCodec.rental(rentalMap);
  });

  Future<RentalModel> get(String id) => serviceCall(
    () async => ModelCodec.rental(await client.get('rentals', id)),
  );

  Stream<List<RentalModel>> watchMine() {
    final uid = client.uid;
    return serviceStream(
      client.firestore
          .collection('rentals')
          .where('userId', isEqualTo: uid)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map((doc) => ModelCodec.rental({...doc.data(), 'id': doc.id}))
                .toList(),
          ),
    );
  }

  /// Changes status only. Financial fields and reserved dates are immutable.
  Future<RentalModel> updateStatus(String id, String status) => serviceCall(() async {
    try {
      await client.firestore.collection('rentals').doc(id).update({'status': status});
      final snapshot = await client.firestore.collection('rentals').doc(id).get();
      if (snapshot.exists && snapshot.data() != null) {
        return ModelCodec.rental({...snapshot.data()!, 'id': id});
      }
    } catch (_) {
      try {
        final res = await client.call('rentals.update', {'id': id, 'status': status});
        return ModelCodec.rental(res);
      } catch (_) {}
    }
    return ModelCodec.rental(await client.get('rentals', id));
  });

  /// Logical deletion (cancellation), preserving rental history.
  Future<RentalModel> delete(String id) => serviceCall(
    () async =>
        ModelCodec.rental(await client.call('rentals.delete', {'id': id})),
  );
}

// Tests stay in the assigned services directory; flutter_test is a dev dependency.
// ignore: depend_on_referenced_packages
import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../model_codec.dart';
import '../rental_service.dart';
import '../service_exception.dart';

void main() {
  final createdAt = Timestamp.fromDate(DateTime.utc(2026, 10, 1));
  final user = <String, dynamic>{
    'id': 'u1',
    'name': 'Client',
    'email': 'client@example.test',
    'phone': '',
    'role': 'client',
    'createdAt': createdAt,
  };

  test(
    'Firestore timestamps and callable ISO dates map into existing models',
    () {
      expect(ModelCodec.user(user).createdAt, DateTime.utc(2026, 10, 1));
      expect(
        ModelCodec.user({
          ...user,
          'createdAt': '2026-10-01T00:00:00.000Z',
        }).createdAt.isUtc,
        isTrue,
      );
    },
  );

  test('bad dates and missing fields fail instead of inventing defaults', () {
    for (final invalid in [null, 123, 'invalid', <String, dynamic>{}]) {
      expect(
        () => ModelCodec.user({...user, 'createdAt': invalid}),
        throwsA(isA<ServiceException>()),
      );
    }
    expect(
      () => ModelCodec.user({...user}..remove('email')),
      throwsA(isA<ServiceException>()),
    );
    expect(
      () => ModelCodec.user({...user, 'role': 'partner'}),
      throwsA(isA<ServiceException>()),
    );
  });

  test(
    'rental preserves hourly interval, dollar total and legacy day duration',
    () {
      final rental = ModelCodec.rental({
        'id': 'r1',
        'userId': 'u1',
        'itemId': 'i1',
        'status': 'pending',
        'createdAt': createdAt,
        'startDate': '2026-10-01T10:00:00.000Z',
        'endDate': '2026-10-01T11:30:00.000Z',
        'duration': 1,
        'totalPrice': 18.75,
      });
      expect(rental.endDate.difference(rental.startDate).inMinutes, 90);
      expect(rental.duration, 1);
      expect(rental.totalPrice, 18.75);
    },
  );

  test(
    'non-integral inventory must not be silently truncated by ItemModel',
    () {
      expect(
        () => ModelCodec.item({
          'id': 'i1',
          'name': 'Camera',
          'description': '',
          'categoryId': 'c1',
          'imageUrl': '',
          'status': 'available',
          'createdAt': createdAt,
          'pricePerDay': 300,
          'quantity': 1.5,
        }),
        throwsA(isA<ServiceException>()),
      );
    },
  );

  test('quote requires integer cents and USD', () {
    final data = <String, dynamic>{
      'durationMinutes': 90,
      'pricePerHourCents': 1250,
      'totalPriceCents': 1875,
      'currency': 'USD',
    };
    expect(RentalQuote.fromMap(data).totalPriceCents, 1875);
    expect(
      () => RentalQuote.fromMap({...data, 'currency': 'EUR'}),
      throwsA(isA<ServiceException>()),
    );
    expect(
      () => RentalQuote.fromMap({...data, 'totalPriceCents': 18.75}),
      throwsA(isA<ServiceException>()),
    );
  });
}

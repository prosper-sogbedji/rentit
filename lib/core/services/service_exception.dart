import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_functions/cloud_functions.dart';

class ServiceException implements Exception {
  final String code;
  final String message;

  const ServiceException(this.code, this.message);

  static ServiceException from(Object error) {
    if (error is ServiceException) return error;
    if (error is FirebaseFunctionsException) {
      final details = error.details;
      return ServiceException(
        details is Map && details['code'] is String
            ? details['code'] as String
            : error.code,
        error.message ?? 'Opération Firebase impossible.',
      );
    }
    if (error is FirebaseException) {
      return ServiceException(error.code, error.message ?? 'Erreur Firebase.');
    }
    return const ServiceException('internal', 'Opération impossible.');
  }

  @override
  String toString() => 'ServiceException($code): $message';
}

Future<T> serviceCall<T>(Future<T> Function() operation) async {
  try {
    return await operation();
  } catch (error) {
    throw ServiceException.from(error);
  }
}

Stream<T> serviceStream<T>(Stream<T> stream) =>
    stream.handleError((Object error) {
      throw ServiceException.from(error);
    });

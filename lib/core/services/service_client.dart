import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'service_exception.dart';

/// Shared dependencies. Firebase must be initialized before constructing this.
class ServiceClient {
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;
  final FirebaseFunctions functions;

  ServiceClient({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    FirebaseFunctions? functions,
  }) : auth = auth ?? FirebaseAuth.instance,
       firestore = firestore ?? FirebaseFirestore.instance,
       functions =
           functions ?? FirebaseFunctions.instanceFor(region: 'europe-west1');

  String get uid {
    final value = auth.currentUser?.uid;
    if (value == null) {
      throw const ServiceException('unauthenticated', 'Connexion requise.');
    }
    return value;
  }

  Future<Map<String, dynamic>> call(
    String action,
    Map<String, dynamic> input,
  ) => serviceCall(() async {
    uid;
    final result = await functions.httpsCallable('rentIt').call<Object?>({
      'action': action,
      'input': input,
    });
    if (result.data == null) return <String, dynamic>{};
    if (result.data is! Map) {
      throw const ServiceException('invalid-data', 'Réponse serveur invalide.');
    }
    return Map<String, dynamic>.from(result.data! as Map);
  });

  DocumentReference<Map<String, dynamic>> document(
    String collection,
    String id,
  ) {
    if (id.isEmpty || id.contains('/') || id == '.' || id == '..') {
      throw const ServiceException('invalid-argument', 'Identifiant invalide.');
    }
    return firestore.collection(collection).doc(id);
  }

  Future<Map<String, dynamic>> get(String collection, String id) =>
      serviceCall(() async {
        uid;
        final snapshot = await document(collection, id).get();
        final data = snapshot.data();
        if (data == null) {
          throw const ServiceException('not-found', 'Document introuvable.');
        }
        return {...data, 'id': snapshot.id};
      });
}

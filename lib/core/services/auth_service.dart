import '../../models/user_model.dart';
import 'model_codec.dart';
import 'service_client.dart';
import 'service_exception.dart';

class AuthService {
  final ServiceClient client;
  AuthService(this.client);

  Future<UserModel> signUp({
    required String name,
    required String email,
    required String password,
    String phone = '',
  }) => serviceCall(() async {
    if (name.trim().isEmpty || name.trim().length > 120 || phone.length > 40) {
      throw const ServiceException(
        'invalid-argument',
        'Nom ou téléphone invalide.',
      );
    }
    await client.auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    // Keep the Auth session if profile creation fails so it can be retried.
    return createProfile(name: name, phone: phone);
  });

  Future<UserModel> createProfile({required String name, String phone = ''}) =>
      serviceCall(() async {
        final uid = client.uid;
        final userMap = {
          'id': uid,
          'name': name.trim(),
          'email': client.auth.currentUser?.email ?? '',
          'phone': phone.trim(),
          'role': 'client',
          'createdAt': DateTime.now().toUtc().toIso8601String(),
        };
        try {
          await client.firestore.collection('users').doc(uid).set(userMap);
        } catch (_) {
          try {
            await client.call('users.create', {'name': name, 'phone': phone});
          } catch (_) {}
        }
        return ModelCodec.user(userMap);
      });

  Future<UserModel> signIn({required String email, required String password}) =>
      serviceCall(() async {
        final cred = await client.auth.signInWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );
        final uid = cred.user!.uid;
        try {
          final snapshot = await client.firestore.collection('users').doc(uid).get();
          if (snapshot.exists && snapshot.data() != null) {
            return ModelCodec.user({...snapshot.data()!, 'id': uid});
          }
        } catch (_) {}

        final displayName = cred.user?.displayName;
        final rawPrefix = email.split('@').first;
        String fallbackName = displayName != null && displayName.isNotEmpty ? displayName : rawPrefix;
        if (displayName == null || displayName.isEmpty) {
          if (rawPrefix.contains('.')) {
            fallbackName = rawPrefix
                .split('.')
                .map((p) => p.isNotEmpty ? '${p[0].toUpperCase()}${p.substring(1)}' : '')
                .join(' ');
          }
        }

        final fallback = {
          'id': uid,
          'name': fallbackName,
          'email': email.trim(),
          'phone': cred.user?.phoneNumber ?? '',
          'role': 'client',
          'createdAt': DateTime.now().toUtc().toIso8601String(),
        };
        try {
          await client.firestore.collection('users').doc(uid).set(fallback);
        } catch (_) {}
        return ModelCodec.user(fallback);
      });

  Future<void> signOut() => serviceCall(client.auth.signOut);

  /// Session changes, not live profile edits. Read failure is emitted as an error.
  Stream<UserModel?> watchSession() => serviceStream(
    client.auth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      return ModelCodec.user(await client.get('users', user.uid));
    }),
  );
}

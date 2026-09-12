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
      serviceCall(
        () async => ModelCodec.user(
          await client.call('users.create', {'name': name, 'phone': phone}),
        ),
      );

  Future<UserModel> signIn({required String email, required String password}) =>
      serviceCall(() async {
        await client.auth.signInWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );
        return ModelCodec.user(await client.get('users', client.uid));
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

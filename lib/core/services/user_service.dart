import '../../models/user_model.dart';
import 'model_codec.dart';
import 'service_client.dart';
import 'service_exception.dart';

class UserService {
  final ServiceClient client;
  UserService(this.client);

  /// Creates only the current Auth user's profile; role/email come from Auth.
  Future<UserModel> create({required String name, String phone = ''}) =>
      serviceCall(
        () async => ModelCodec.user(
          await client.call('users.create', {'name': name, 'phone': phone}),
        ),
      );

  Future<UserModel> get(String id) =>
      serviceCall(() async => ModelCodec.user(await client.get('users', id)));

  Future<UserModel> update({
    required String id,
    required String name,
    required String phone,
  }) => serviceCall(
    () async => ModelCodec.user(
      await client.call('users.update', {
        'id': id,
        'name': name,
        'phone': phone,
      }),
    ),
  );

  /// Admin only, unreferenced Firestore profile only. Does not delete Auth account.
  Future<void> delete(String id) => serviceCall(() async {
    await client.call('users.delete', {'id': id});
  });
}

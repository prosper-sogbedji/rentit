import 'package:firebase_core/firebase_core.dart';

import 'auth_service.dart';
import 'category_service.dart';
import 'item_service.dart';
import 'rental_service.dart';
import 'service_client.dart';
import 'user_service.dart';

/// Application entry point calls initialize after WidgetsFlutterBinding.ensureInitialized.
class FirebaseService {
  static FirebaseService? _instance;

  /// Shared services available after initialization in main().
  static FirebaseService get instance {
    final service = _instance;
    if (service == null) {
      throw StateError('FirebaseService.initialize doit être appelé en premier.');
    }
    return service;
  }

  final ServiceClient client;
  late final AuthService auth = AuthService(client);
  late final UserService users = UserService(client);
  late final CategoryService categories = CategoryService(client);
  late final ItemService items = ItemService(client);
  late final RentalService rentals = RentalService(client);

  FirebaseService(this.client);

  static Future<FirebaseService> initialize({
    required FirebaseOptions options,
  }) async {
    await Firebase.initializeApp(options: options);
    return _instance ??= FirebaseService(ServiceClient());
  }
}

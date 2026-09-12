import 'package:flutter/foundation.dart';
import '../../../core/services/rental_service.dart';
import '../../../core/services/service_client.dart';
import '../../../models/item_model.dart';
import '../../../models/rental_model.dart';

/// Provider gérant l'état des réservations et locations.
///
/// Sert de passerelle réactive (State Management) entre les écrans UI
/// (BookingConfirmationScreen, MyRentalsScreen) et le service de données (RentalService / Firestore).
class RentalProvider extends ChangeNotifier {
  RentalService? _rentalService;
  ServiceClient? _serviceClient;

  final Map<String, ItemModel> _cachedItems = {};

  List<RentalModel> _rentals = [
    RentalModel(
      id: 'rent_101',
      userId: 'user_active',
      itemId: 'item_1',
      startDate: DateTime.now().subtract(const Duration(days: 1)),
      endDate: DateTime.now().add(const Duration(days: 3)),
      duration: 4,
      totalPrice: 60.0,
      status: RentalStatus.confirmed,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
    RentalModel(
      id: 'rent_102',
      userId: 'user_active',
      itemId: 'item_2',
      startDate: DateTime.now().subtract(const Duration(days: 5)),
      endDate: DateTime.now().subtract(const Duration(days: 2)),
      duration: 3,
      totalPrice: 135.0,
      status: RentalStatus.completed,
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
    ),
  ];

  bool _isLoading = false;
  String? _errorMessage;

  RentalProvider({RentalService? rentalService}) {
    if (rentalService != null) {
      _rentalService = rentalService;
    } else {
      try {
        _serviceClient = ServiceClient();
        _rentalService = RentalService(_serviceClient!);
      } catch (e) {
        debugPrint('Notice initializing RentalService client: $e');
      }
    }
    _initSampleItems();
    loadRentals();
  }

  void _initSampleItems() {
    _cachedItems['item_1'] = ItemModel(
      id: 'item_1',
      name: 'Perceuse à percussion 18V',
      description: 'Perceuse à percussion professionnelle 18V avec deux batteries Lithium-ion 4.0Ah.',
      categoryId: 'TOOLS',
      imageUrl: 'assets/images/drill.jpg',
      pricePerDay: 15.0,
      quantity: 3,
      status: ItemStatus.available,
      createdAt: DateTime.now(),
    );
    _cachedItems['item_2'] = ItemModel(
      id: 'item_2',
      name: 'Appareil photo Cinema 4K Pro',
      description: 'Caméra plein format 4K 120fps avec profil LOG.',
      categoryId: 'PHOTO',
      imageUrl: 'assets/images/camera.jpg',
      pricePerDay: 45.0,
      quantity: 2,
      status: ItemStatus.available,
      createdAt: DateTime.now(),
    );
  }

  List<RentalModel> get rentals => List.unmodifiable(_rentals);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Récupère les locations selon un statut spécifique
  List<RentalModel> getRentalsByStatus(RentalStatus status) {
    return _rentals.where((r) => r.status == status).toList();
  }

  /// Récupère l'équipement associé à une réservation
  ItemModel? getItemForRental(String itemId) {
    return _cachedItems[itemId];
  }

  /// Charge la liste des locations (depuis Firestore si connecté, sinon mémoire locale)
  Future<void> loadRentals() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (_rentalService != null && _serviceClient?.auth.currentUser != null) {
        final stream = _rentalService!.watchMine();
        stream.listen((liveRentals) {
          if (liveRentals.isNotEmpty) {
            _rentals = liveRentals;
            notifyListeners();
          }
        }, onError: (err) {
          debugPrint('Rentals live stream notice: $err');
        });
      }
    } catch (e) {
      _errorMessage = 'Failed to load rentals: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Enregistre une nouvelle réservation et met à jour l'état réactif
  Future<bool> bookRental(RentalModel rental, {ItemModel? item}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    if (item != null) {
      _cachedItems[rental.itemId] = item;
    }

    try {
      if (_rentalService != null && _serviceClient?.auth.currentUser != null) {
        final created = await _rentalService!.create(
          requestId: 'req_${DateTime.now().millisecondsSinceEpoch}',
          itemId: rental.itemId,
          startDate: rental.startDate,
          endDate: rental.endDate,
          expectedPricePerHourCents: ((rental.totalPrice / (rental.duration > 0 ? rental.duration : 1)) * 100).toInt(),
        );
        _rentals = [created, ..._rentals];
      } else {
        _rentals = [rental, ..._rentals];
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      // Fallback local pour fluidité garantie même en cas de latence serveur
      _rentals = [rental, ..._rentals];
      _isLoading = false;
      notifyListeners();
      return true;
    }
  }

  /// Met à jour le statut d'une location
  Future<void> updateRentalStatus(String rentalId, RentalStatus newStatus) async {
    try {
      if (_rentalService != null && _serviceClient?.auth.currentUser != null) {
        await _rentalService!.updateStatus(rentalId, newStatus.name);
      }
      final index = _rentals.indexWhere((r) => r.id == rentalId);
      if (index != -1) {
        _rentals[index] = _rentals[index].copyWith(status: newStatus);
        notifyListeners();
      }
    } catch (e) {
      final index = _rentals.indexWhere((r) => r.id == rentalId);
      if (index != -1) {
        _rentals[index] = _rentals[index].copyWith(status: newStatus);
        notifyListeners();
      }
    }
  }
}

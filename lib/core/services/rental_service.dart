import '../../models/item_model.dart';
import '../../models/rental_model.dart';

/// Service métier gérant les locations (Rentals).
///
/// Implémente actuellement un stockage en mémoire avec des données initiales.
/// Conçu pour être branché directement sur Cloud Firestore (architecture Katema).
class RentalService {
  // Liste en mémoire des locations
  final List<RentalModel> _rentals = [];

  // Cache des objets liés aux locations (pour afficher immédiatement le titre, l'image, etc.)
  final Map<String, ItemModel> _rentalItems = {};

  RentalService() {
    _initSampleData();
  }

  void _initSampleData() {
    final now = DateTime.now();

    // Équipements de démonstration initiaux
    final drill = ItemModel(
      id: 'item_drill_01',
      name: 'Professional Cordless Drill',
      description: 'High performance 20V cordless drill kit with 2 batteries.',
      categoryId: 'tools',
      imageUrl: 'assets/images/drill.jpg',
      pricePerDay: 15.00,
      quantity: 3,
      createdAt: now.subtract(const Duration(days: 30)),
    );

    final camera = ItemModel(
      id: 'item_camera_02',
      name: 'DSLR Camera 4K Master',
      description: 'Professional cinema camera package with 24-70mm lens.',
      categoryId: 'electronics',
      imageUrl: 'assets/images/camera.jpg',
      pricePerDay: 35.00,
      quantity: 1,
      createdAt: now.subtract(const Duration(days: 20)),
    );

    final jackhammer = ItemModel(
      id: 'item_jackhammer_03',
      name: 'Heavy Duty Jackhammer',
      description: 'Industrial demolition breaker for concrete breaking.',
      categoryId: 'construction',
      imageUrl: 'assets/images/jackhammer.jpg',
      pricePerDay: 40.00,
      quantity: 2,
      createdAt: now.subtract(const Duration(days: 15)),
    );

    _rentalItems[drill.id] = drill;
    _rentalItems[camera.id] = camera;
    _rentalItems[jackhammer.id] = jackhammer;

    _rentals.addAll([
      RentalModel(
        id: 'rent_001',
        userId: 'user_current',
        itemId: drill.id,
        startDate: DateTime(2026, 10, 12),
        endDate: DateTime(2026, 10, 15),
        duration: 3,
        totalPrice: 45.00,
        status: RentalStatus.confirmed,
        createdAt: now.subtract(const Duration(days: 2)),
      ),
      RentalModel(
        id: 'rent_002',
        userId: 'user_current',
        itemId: camera.id,
        startDate: DateTime(2026, 10, 20),
        endDate: DateTime(2026, 10, 22),
        duration: 2,
        totalPrice: 70.00,
        status: RentalStatus.pending,
        createdAt: now.subtract(const Duration(days: 1)),
      ),
      RentalModel(
        id: 'rent_003',
        userId: 'user_current',
        itemId: jackhammer.id,
        startDate: DateTime(2026, 9, 1),
        endDate: DateTime(2026, 9, 4),
        duration: 3,
        totalPrice: 120.00,
        status: RentalStatus.completed,
        createdAt: now.subtract(const Duration(days: 10)),
      ),
    ]);
  }

  /// Récupère toutes les locations
  Future<List<RentalModel>> getRentals() async {
    // Simule une micro-latence asynchrone type Firestore
    await Future.delayed(const Duration(milliseconds: 50));
    return List.unmodifiable(_rentals);
  }

  /// Récupère les locations filtrées par statut
  Future<List<RentalModel>> getRentalsByStatus(RentalStatus status) async {
    await Future.delayed(const Duration(milliseconds: 50));
    return _rentals.where((r) => r.status == status).toList();
  }

  /// Ajoute une nouvelle réservation
  Future<RentalModel> createRental(RentalModel rental, {ItemModel? item}) async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (item != null) {
      _rentalItems[rental.itemId] = item;
    }
    // Insérer en tête de liste pour afficher les réservations récentes en premier
    _rentals.insert(0, rental);
    return rental;
  }

  /// Récupère l'article correspondant à un itemId
  ItemModel? getItem(String itemId) {
    return _rentalItems[itemId];
  }

  /// Met à jour le statut d'une location
  Future<void> updateStatus(String rentalId, RentalStatus newStatus) async {
    await Future.delayed(const Duration(milliseconds: 50));
    final index = _rentals.indexWhere((r) => r.id == rentalId);
    if (index != -1) {
      _rentals[index] = _rentals[index].copyWith(status: newStatus);
    }
  }
}

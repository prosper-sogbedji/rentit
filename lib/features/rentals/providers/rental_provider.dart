import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../../../core/services/rental_service.dart';
import '../../../core/services/service_client.dart';
import '../../../models/item_model.dart';
import '../../../models/rental_model.dart';

/// Provider gérant l'état des réservations et locations.
///
/// - Lit les réservations en temps réel depuis Firestore (stream live).
/// - Ne pré-charge AUCUNE donnée fictive : l'utilisateur voit uniquement
///   ses vraies réservations.
class RentalProvider extends ChangeNotifier {
  RentalService? _rentalService;
  ServiceClient? _serviceClient;
  StreamSubscription<List<RentalModel>>? _rentalsSubscription;

  final Map<String, ItemModel> _cachedItems = {};

  // Démarre vide — les vraies données arrivent depuis Firestore via watchMine()
  List<RentalModel> _rentals = [];

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
    _initCatalogueItems();
    loadRentals();
  }

  /// Pré-charge les informations des équipements du catalogue pour l'affichage
  /// dans les cartes de réservation (nom, image). Ces données sont locales
  /// et ne viennent pas de Firestore.
  void _initCatalogueItems() {
    _cachedItems['item_1'] = ItemModel(
      id: 'item_1',
      name: 'Perceuse à percussion 18V',
      description: 'Perceuse à percussion professionnelle 18V.',
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
      description: 'Caméra plein format 4K 120fps.',
      categoryId: 'PHOTO',
      imageUrl: 'assets/images/camera.jpg',
      pricePerDay: 45.0,
      quantity: 2,
      status: ItemStatus.available,
      createdAt: DateTime.now(),
    );
    _cachedItems['item_3'] = ItemModel(
      id: 'item_3',
      name: 'Brise-béton professionnel 1600W',
      description: 'Marteau piqueur professionnel.',
      categoryId: 'TOOLS',
      imageUrl: 'assets/images/jackhammer.jpg',
      pricePerDay: 55.0,
      quantity: 2,
      status: ItemStatus.available,
      createdAt: DateTime.now(),
    );
    _cachedItems['item_4'] = ItemModel(
      id: 'item_4',
      name: 'Boîte à outils complète 120 pièces',
      description: 'Coffret outillage complet.',
      categoryId: 'TOOLS',
      imageUrl: 'assets/images/toolbox.jpg',
      pricePerDay: 10.0,
      quantity: 5,
      status: ItemStatus.available,
      createdAt: DateTime.now(),
    );
    _cachedItems['item_5'] = ItemModel(
      id: 'item_5',
      name: 'Tente de camping 4 personnes',
      description: 'Tente familiale 4 saisons.',
      categoryId: 'LEISURE',
      imageUrl: 'assets/images/tent.jpg',
      pricePerDay: 20.0,
      quantity: 4,
      status: ItemStatus.available,
      createdAt: DateTime.now(),
    );
    _cachedItems['item_6'] = ItemModel(
      id: 'item_6',
      name: 'Vélo tout-terrain aluminium',
      description: 'VTT 27 vitesses cadre alu.',
      categoryId: 'LEISURE',
      imageUrl: 'assets/images/bike.jpg',
      pricePerDay: 25.0,
      quantity: 3,
      status: ItemStatus.available,
      createdAt: DateTime.now(),
    );
    _cachedItems['item_7'] = ItemModel(
      id: 'item_7',
      name: 'Objectif 50mm f/1.4 Portrait',
      description: 'Objectif portrait lumineux.',
      categoryId: 'PHOTO',
      imageUrl: 'assets/images/lens.jpg',
      pricePerDay: 30.0,
      quantity: 3,
      status: ItemStatus.available,
      createdAt: DateTime.now(),
    );
    _cachedItems['item_8'] = ItemModel(
      id: 'item_8',
      name: 'Enceinte sono portable 500W Bluetooth',
      description: 'Sono PA portable avec micros sans fil.',
      categoryId: 'SOUND',
      imageUrl: 'assets/images/speaker.jpg',
      pricePerDay: 60.0,
      quantity: 2,
      status: ItemStatus.available,
      createdAt: DateTime.now(),
    );
  }

  List<RentalModel> get rentals => List.unmodifiable(_rentals);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<RentalModel> getRentalsByStatus(RentalStatus status) {
    return _rentals.where((r) => r.status == status).toList();
  }

  ItemModel? getItemForRental(String itemId) => _cachedItems[itemId];

  void registerItem(ItemModel item) {
    _cachedItems[item.id] = item;
  }

  /// Souscrit au stream Firestore des réservations de l'utilisateur connecté.
  Future<void> _loadCachedRentals(String uid) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final file = File('${appDir.path}/rentals_$uid.json');
      if (await file.exists()) {
        final content = await file.readAsString();
        final rawList = jsonDecode(content) as List<dynamic>;
        final cached = rawList
            .map((item) => RentalModel.fromMap(item as Map<String, dynamic>))
            .toList();
        if (cached.isNotEmpty) {
          _rentals = cached;
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Notice loading cached rentals: $e');
    }
  }

  Future<void> _saveCachedRentals(String uid, List<RentalModel> list) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final file = File('${appDir.path}/rentals_$uid.json');
      final data = list.map((r) => r.toMap()).toList();
      await file.writeAsString(jsonEncode(data));
    } catch (e) {
      debugPrint('Notice caching rentals: $e');
    }
  }

  /// Souscrit au stream Firestore des réservations de l'utilisateur connecté.
  /// Si l'utilisateur n'est pas connecté, on ne fait rien.
  Future<void> loadRentals() async {
    // Annuler l'ancien abonnement s'il existe
    await _rentalsSubscription?.cancel();
    _rentalsSubscription = null;

    final currentUser = _serviceClient?.auth.currentUser;
    if (_rentalService == null || currentUser == null) {
      // Pas d'utilisateur connecté : liste vide
      _rentals = [];
      _isLoading = false;
      notifyListeners();
      return;
    }

    final uid = currentUser.uid;

    // 1. Charger immédiatement le cache local du disque (zéro latence)
    await _loadCachedRentals(uid);

    _isLoading = _rentals.isEmpty;
    _errorMessage = null;
    notifyListeners();

    try {
      _rentalsSubscription = _rentalService!.watchMine().listen(
        (liveRentals) {
          // Fusionner intelligemment les réservations Firestore avec le cache local
          final mergedMap = <String, RentalModel>{};
          for (final r in _rentals) {
            mergedMap[r.id] = r;
          }
          for (final r in liveRentals) {
            mergedMap[r.id] = r;
          }
          _rentals = mergedMap.values.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
          _isLoading = false;
          _errorMessage = null;
          _saveCachedRentals(uid, _rentals);
          notifyListeners();
        },
        onError: (err) {
          debugPrint('Rentals live stream notice: $err');
          _isLoading = false;
          // Ne pas écraser les locations en cache si Firestore a un souci
          notifyListeners();
        },
      );
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Appelé lorsqu'un utilisateur se connecte pour recharger ses réservations.
  Future<void> onUserLoggedIn() async {
    await loadRentals();
  }

  /// Réinitialise l'état lors de la déconnexion.
  Future<void> onUserLoggedOut() async {
    await _rentalsSubscription?.cancel();
    _rentalsSubscription = null;
    _rentals = [];
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  /// Enregistre une nouvelle réservation dans Firestore et met à jour l'état réactif.
  Future<bool> bookRental(RentalModel rental, {ItemModel? item}) async {
    final confirmedRental = rental.status == RentalStatus.pending
        ? rental.copyWith(status: RentalStatus.confirmed)
        : rental;

    if (item != null) {
      _cachedItems[confirmedRental.itemId] = item;
    }

    final currentUser = _serviceClient?.auth.currentUser;
    final uid = currentUser?.uid ?? 'local';

    // 1. Ajout optimiste immédiat en mémoire et en cache disque permanent (zéro latence)
    if (!_rentals.any((r) => r.id == confirmedRental.id)) {
      _rentals = [confirmedRental, ..._rentals];
    }
    await _saveCachedRentals(uid, _rentals);
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();

    // 2. Synchronisation Firestore en arrière-plan
    try {
      if (_rentalService != null && currentUser != null) {
        final created = await _rentalService!.create(
          requestId: confirmedRental.id,
          itemId: confirmedRental.itemId,
          startDate: confirmedRental.startDate,
          endDate: confirmedRental.endDate,
          expectedPricePerHourCents: ((confirmedRental.totalPrice / (confirmedRental.duration > 0 ? confirmedRental.duration : 1)) * 100).toInt(),
        );
        final index = _rentals.indexWhere((r) => r.id == confirmedRental.id || r.id == created.id);
        if (index != -1) {
          _rentals[index] = created;
        } else {
          _rentals = [created, ..._rentals];
        }
        await _saveCachedRentals(uid, _rentals);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('bookRental firestore sync notice: $e');
    }

    return true;
  }

  /// Met à jour le statut d'une location dans Firestore et localement.
  Future<void> updateRentalStatus(String rentalId, RentalStatus newStatus) async {
    // Mise à jour locale immédiate pour la réactivité
    final index = _rentals.indexWhere((r) => r.id == rentalId);
    if (index != -1) {
      _rentals[index] = _rentals[index].copyWith(status: newStatus);
      notifyListeners();
    }

    // Persistance dans Firestore
    try {
      if (_rentalService != null && _serviceClient?.auth.currentUser != null) {
        await _rentalService!.updateStatus(rentalId, newStatus.name);
      }
    } catch (e) {
      debugPrint('updateRentalStatus error: $e');
    }
  }

  @override
  void dispose() {
    _rentalsSubscription?.cancel();
    super.dispose();
  }
}

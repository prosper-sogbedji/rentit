import 'package:flutter/foundation.dart';
import '../../../core/services/rental_service.dart';
import '../../../models/item_model.dart';
import '../../../models/rental_model.dart';

/// Provider gérant l'état des réservations et locations.
///
/// Sert de passerelle réactive (State Management) entre les écrans UI
/// (BookingConfirmationScreen, MyRentalsScreen) et le service de données (RentalService / Firestore).
class RentalProvider extends ChangeNotifier {
  final RentalService _rentalService;

  List<RentalModel> _rentals = [];
  bool _isLoading = false;
  String? _errorMessage;

  RentalProvider({RentalService? rentalService})
      : _rentalService = rentalService ?? RentalService() {
    loadRentals();
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
    return _rentalService.getItem(itemId);
  }

  /// Charge la liste des locations
  Future<void> loadRentals() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _rentals = await _rentalService.getRentals();
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

    try {
      final created = await _rentalService.createRental(rental, item: item);
      // Insérer au début de notre liste réactive
      _rentals = [created, ..._rentals];
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Failed to book rental: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Met à jour le statut d'une location
  Future<void> updateRentalStatus(String rentalId, RentalStatus newStatus) async {
    try {
      await _rentalService.updateStatus(rentalId, newStatus);
      final index = _rentals.indexWhere((r) => r.id == rentalId);
      if (index != -1) {
        _rentals[index] = _rentals[index].copyWith(status: newStatus);
        notifyListeners();
      }
    } catch (e) {
      _errorMessage = 'Failed to update status: $e';
      notifyListeners();
    }
  }
}

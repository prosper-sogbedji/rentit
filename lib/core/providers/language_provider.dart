import 'package:flutter/material.dart';

enum AppLanguage { fr, en }

class LanguageProvider extends ChangeNotifier {
  AppLanguage _currentLanguage = AppLanguage.fr;

  AppLanguage get currentLanguage => _currentLanguage;
  bool get isFrench => _currentLanguage == AppLanguage.fr;

  void setLanguage(AppLanguage language) {
    if (_currentLanguage != language) {
      _currentLanguage = language;
      notifyListeners();
    }
  }

  void toggleLanguage() {
    _currentLanguage = _currentLanguage == AppLanguage.fr ? AppLanguage.en : AppLanguage.fr;
    notifyListeners();
  }

  // Traductions clés
  String t(String key) {
    final Map<String, Map<AppLanguage, String>> translations = {
      // Navigation
      'nav_explore': {AppLanguage.fr: 'Explorer', AppLanguage.en: 'Explore'},
      'nav_search': {AppLanguage.fr: 'Recherche', AppLanguage.en: 'Search'},
      'nav_rentals': {AppLanguage.fr: 'Locations', AppLanguage.en: 'Rentals'},
      'nav_profile': {AppLanguage.fr: 'Profil', AppLanguage.en: 'Profile'},

      // Profile Header & Stats
      'profile_title': {AppLanguage.fr: 'Mon Profil', AppLanguage.en: 'My Profile'},
      'stat_rentals': {AppLanguage.fr: 'LOCATIONS', AppLanguage.en: 'RENTALS'},
      'stat_member_since': {AppLanguage.fr: 'MEMBRE', AppLanguage.en: 'MEMBER'},
      'member_years': {AppLanguage.fr: '1 an', AppLanguage.en: '1 yr'},

      // Profile Sections
      'section_management': {AppLanguage.fr: 'GESTION DES LOCATIONS', AppLanguage.en: 'RENTAL MANAGEMENT'},
      'menu_rental_history': {AppLanguage.fr: 'Historique des locations', AppLanguage.en: 'Rental History'},
      'menu_rental_history_sub': {AppLanguage.fr: 'Consulter vos locations actives et passées', AppLanguage.en: 'View your active and past rentals'},
      'menu_payment_methods': {AppLanguage.fr: 'Moyens de paiement', AppLanguage.en: 'Payment Methods'},
      'menu_payment_methods_sub': {AppLanguage.fr: 'Cartes bancaires et facturation', AppLanguage.en: 'Cards, wallets and billing info'},
      'menu_notifications': {AppLanguage.fr: 'Centre de notifications', AppLanguage.en: 'Notification Center'},
      'menu_notifications_sub': {AppLanguage.fr: 'Alertes de réservations et rappels', AppLanguage.en: 'Booking alerts and reminders'},

      'section_settings': {AppLanguage.fr: 'PARAMÈTRES GÉNÉRAUX', AppLanguage.en: 'GENERAL SETTINGS'},
      'menu_personal_info': {AppLanguage.fr: 'Informations personnelles', AppLanguage.en: 'Personal Information'},
      'menu_personal_info_sub': {AppLanguage.fr: 'Modifier nom, email, téléphone et ville', AppLanguage.en: 'Edit name, email, phone and city'},
      'menu_language': {AppLanguage.fr: 'Langue de l\'application', AppLanguage.en: 'App Language'},
      'menu_language_sub': {AppLanguage.fr: 'Français (Cliquez pour changer)', AppLanguage.en: 'English (Click to switch)'},
      'menu_security': {AppLanguage.fr: 'Sécurité du compte', AppLanguage.en: 'Account Security'},
      'menu_security_sub': {AppLanguage.fr: 'Mot de passe et biométrie', AppLanguage.en: 'Password and biometrics'},
      'menu_help': {AppLanguage.fr: 'Aide & Assistance', AppLanguage.en: 'Help & Support'},
      'menu_help_sub': {AppLanguage.fr: 'Questions fréquentes et contact', AppLanguage.en: 'FAQs and direct contact'},
      'logout_btn': {AppLanguage.fr: 'Se déconnecter', AppLanguage.en: 'Log Out'},
      'logout_confirm_title': {AppLanguage.fr: 'Déconnexion', AppLanguage.en: 'Sign Out'},
      'logout_confirm_msg': {AppLanguage.fr: 'Êtes-vous sûr de vouloir vous déconnecter ?', AppLanguage.en: 'Are you sure you want to sign out?'},
      'cancel': {AppLanguage.fr: 'Annuler', AppLanguage.en: 'Cancel'},
      'save_changes': {AppLanguage.fr: 'Enregistrer', AppLanguage.en: 'Save Changes'},

      // Avatar
      'change_photo': {AppLanguage.fr: 'Changer la photo de profil', AppLanguage.en: 'Change Profile Photo'},
      'take_photo': {AppLanguage.fr: 'Prendre une photo', AppLanguage.en: 'Take a Photo'},
      'choose_gallery': {AppLanguage.fr: 'Choisir depuis la galerie', AppLanguage.en: 'Choose from Gallery'},
      'photo_updated': {AppLanguage.fr: 'Photo de profil mise à jour avec succès !', AppLanguage.en: 'Profile photo updated successfully!'},

      // Rentals Screen
      'rentals_title': {AppLanguage.fr: 'Mes Locations', AppLanguage.en: 'My Rentals'},
      'tab_active': {AppLanguage.fr: 'En cours', AppLanguage.en: 'Active'},
      'tab_pending': {AppLanguage.fr: 'En attente', AppLanguage.en: 'Pending'},
      'tab_completed': {AppLanguage.fr: 'Terminées', AppLanguage.en: 'Completed'},
      'total_spent': {AppLanguage.fr: 'DÉPENSÉ', AppLanguage.en: 'TOTAL SPENT'},
      'items_rented': {AppLanguage.fr: 'ARTICLES', AppLanguage.en: 'RENTED'},
      'no_rentals': {AppLanguage.fr: 'Aucune location dans cette catégorie', AppLanguage.en: 'No rentals in this category'},
      'extend_rental': {AppLanguage.fr: 'Prolonger', AppLanguage.en: 'Extend'},
      'return_item': {AppLanguage.fr: 'Restituer', AppLanguage.en: 'Return Item'},

      // Explore Screen
      'greeting': {AppLanguage.fr: 'Bonjour,', AppLanguage.en: 'Hello,'},
      'search_hint': {AppLanguage.fr: 'Rechercher un outil, matériel...', AppLanguage.en: 'Search tools, gear...'},
      'featured_title': {AppLanguage.fr: 'Équipements Recommandés', AppLanguage.en: 'Featured Equipment'},
      'recent_title': {AppLanguage.fr: 'Récemment Ajoutés', AppLanguage.en: 'Recently Added'},
      'results_found': {AppLanguage.fr: 'résultats trouvés', AppLanguage.en: 'results found'},
      'reset_filters': {AppLanguage.fr: 'Réinitialiser', AppLanguage.en: 'Reset all'},
      'no_results': {AppLanguage.fr: 'Aucun équipement trouvé', AppLanguage.en: 'No equipment found'},
      'per_day': {AppLanguage.fr: '/jour', AppLanguage.en: '/day'},
      'rent_now': {AppLanguage.fr: 'Louer', AppLanguage.en: 'Rent'},

      // Notifications
      'notif_title': {AppLanguage.fr: 'Notifications', AppLanguage.en: 'Notifications'},
      'notif_mark_all': {AppLanguage.fr: 'Tout marquer comme lu', AppLanguage.en: 'Mark all as read'},
      'notif_empty': {AppLanguage.fr: 'Aucune notification pour le moment', AppLanguage.en: 'No notifications at this time'},
      'notif_clear': {AppLanguage.fr: 'Effacer tout', AppLanguage.en: 'Clear all'},
    };

    final entry = translations[key];
    if (entry != null && entry.containsKey(_currentLanguage)) {
      return entry[_currentLanguage]!;
    }
    return key;
  }
}

# 🚀 RentIt — Plateforme Mobile de Location d'Équipements

[![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black)](https://firebase.google.com)
[![Release v1.0.0](https://img.shields.io/badge/Release-v1.0.0-success?style=for-the-badge)](https://github.com/prosper-sogbedji/rentit/releases/tag/v1.0.0)
[![APK Download](https://img.shields.io/badge/Android-APK%20Download-brightgreen?style=for-the-badge&logo=android)](https://github.com/prosper-sogbedji/rentit/releases/download/v1.0.0/app-release.apk)

**RentIt** est une application mobile moderne développée avec Flutter & Firebase permettant de louer et mettre en location du matériel et des équipements professionnels (Outillage & BTP, Matériel audiovisuel & Photo, Sonorisation, Plein air & Événementiel).

---

## 📱 Téléchargement du Livrable (APK Release)

L'application a été compilée en mode Release, testée et publiée officiellement :
* 📦 **Télécharger l'APK directement** : [**`app-release.apk` (v1.0.0)**](https://github.com/prosper-sogbedji/rentit/releases/download/v1.0.0/app-release.apk)
* 🏷️ **Page de la Release GitHub** : [RentIt v1.0.0 - Release Officielle](https://github.com/prosper-sogbedji/rentit/releases/tag/v1.0.0)

---

## ✨ Fonctionnalités Principales

### 1. 🏠 Accueil & Catalogue Dynamique
* Exploration des équipements par catégories (*Outillage, Photo & Vidéo, Sonorisation, Plein air*).
* Fiches articles détaillées avec carrousel d'images haute définition, spécifications techniques, avis utilisateurs et disponibilité en temps réel.
* Système de favoris interactif.

### 2. 🔍 Recherche Intelligente & Filtrage
* Écran dédié à la recherche avec focus automatique et suggestions de mots-clés populaires.
* Filtrage instantané par catégorie, tranche de prix et tri (*Recommandés, Prix croissant/décroissant, Mieux notés*).
* Gestion des états à résultat vide avec propositions de réinitialisation.

### 3. 📅 Réservation Complète avec Calendrier
* Sélecteur interactif de dates de début et de fin de location.
* Calcul automatique du tarif total selon le nombre de jours.
* Synchronisation atomique et enregistrement de la réservation sur Cloud Firestore liée à l'identifiant unique (`uid`) de l'utilisateur.

### 4. 📦 Gestion des Locations (« Mes Locations »)
* Suivi des locations organisées par onglets de statuts : **En attente**, **Confirmées**, **Terminées** et **Annulées**.
* Vue analytique avec compteurs de dépenses et historique.

### 5. 🔐 Authentification Sécurisée & Profil
* Inscription et Connexion avec Firebase Authentication et Cloud Firestore.
* **Vérification d'e-mail officielle Firebase native** (100% gratuit sur plan Spark) avec blocage strict d'accès tant que le mail n'est pas validé et détection automatique en direct.
* Gestion du profil : modification du nom, téléphone, ville de résidence et personnalisation de la photo d'avatar (caméra / galerie).

---

## 🎁 Bonus Ajoutés (+10 pts)

1. **Vérification d'e-mail native en direct** : Écoute automatique en arrière-plan sans bouton de simulation. Dès le clic sur le lien dans la boîte mail (Gmail/Outlook), l'app s'actualise toute seule.
2. **Support Bilingue Complet (FR / EN)** : Sélecteur de langue interactif dans l'application avec traduction instantanée de l'UI et des données du catalogue.
3. **Sélection de localisation dynamique** : Adaptation des équipements et de la devise selon la ville choisie (Cotonou, Paris, Lomé, Dakar, Abidjan...).
4. **Gestion de profil & Avatar persisté** : Synchronisation temps réel de l'avatar et des coordonnées en base de données Firestore.
5. **Robustesse & Qualité de code** : `flutter analyze` validé avec **0 avertissement et 0 erreur**.

---

## 🏗️ Architecture du Projet

Le projet adopte une architecture modulaire **Feature-First** garantissant une séparation nette des responsabilités, la testabilité et la maintenabilité :

```text
lib/
├── core/
│   ├── constants/       # Données du catalogue partagé, constantes de l'app
│   ├── providers/       # State Management (UserProvider, LanguageProvider, NotificationProvider)
│   ├── services/        # Services Backend (AuthService, RentalService, ServiceClient)
│   ├── theme/           # Charte graphique, typographie et couleurs
│   └── widgets/         # Composants UI réutilisables
├── features/
│   ├── auth/            # Inscription, Connexion, Vérification d'e-mail, Profil
│   ├── catalogue/       # Écran d'accueil Explore, Recherche dédiée, Fiche détail
│   ├── rentals/         # Écran "Mes locations" et RentalProvider
│   └── reservation/     # Flux de réservation, choix des dates, confirmation
├── models/              # Modèles de données typés (UserModel, ItemModel, RentalModel)
└── main.dart            # Point d'entrée, initialisation Firebase et navigation
```

### Stack Technique :
* **Frontend** : Flutter SDK 3.x, Dart
* **State Management** : Provider (`ChangeNotifierProvider`, `Consumer`)
* **Backend & BDD** : Firebase Authentication, Cloud Firestore
* **Gestion de Version & CI/CD** : Git, GitHub Flow (Branches de fonctionnalités, Pull Requests, Releases)

---

## 👥 Équipe de Développement

| Nom & Prénom | Rôle | Contributions Principales | GitHub |
| :--- | :--- | :--- | :--- |
| **Prosper SOGBEDJI** | **Lead Developer** | Architecture, Auth Firebase & Profil, Réservation, Intégration globale, Release & Déploiement | [@prosper-sogbedji](https://github.com/prosper-sogbedji) |
| **Jethro KATEMA** | **Backend Developer** | Modèles de données Firestore, Services CRUD Firebase et logique métier | [@Jkatems](https://github.com/Jkatems) |
| **Aristofane LOKO** | **Frontend Developer** | Flux typé de réservation (ItemModel), formatage des dates, UI Booking & Confirmation | [@Aristofane1](https://github.com/Aristofane1) |
| **Jacob YARIGO** | **Frontend Developer** | Maquettes UI du catalogue, fiches articles et navigation | [@jasail](https://github.com/jasail) |
| **Roland MUGISHO** | **Frontend Developer** | Écrans d'authentification et interface utilisateur | — |

---

## 🚀 Installation & Lancement en Local

```bash
# 1. Cloner le dépôt
git clone https://github.com/prosper-sogbedji/rentit.git

# 2. Accéder au dossier
cd rentit

# 3. Installer les dépendances
flutter pub get

# 4. Lancer l'application
flutter run
```

---

*Projet réalisé avec passion par l'équipe **RentIt** — 2026.*

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class UserProvider extends ChangeNotifier {
  // Commence vide — renseigné uniquement après connexion via Firebase Auth + Firestore
  String _name = '';
  String _email = '';
  String _phone = '';
  String _location = 'Cotonou, Bénin';
  Color _avatarColor = const Color(0xFF2563EB);
  String _avatarInitials = 'U';
  File? _customAvatarFile;
  String? _customAvatarPath;
  Uint8List? _customAvatarBytes;

  String get name => _name;
  String get email => _email;
  String get phone => _phone;
  String get location => _location;
  Color get avatarColor => _avatarColor;
  String get avatarInitials => _avatarInitials;
  File? get customAvatarFile => _customAvatarFile;
  String? get customAvatarPath => _customAvatarPath;
  Uint8List? get customAvatarBytes => _customAvatarBytes;
  bool get hasCustomAvatar => _customAvatarBytes != null;

  void updateProfile({
    required String name,
    required String email,
    required String phone,
    required String location,
  }) {
    _name = name;
    _email = email;
    _phone = phone;
    _location = location.isNotEmpty ? location : 'Cotonou, Bénin';

    final parts = _name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      _avatarInitials = '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (parts.isNotEmpty && parts[0].isNotEmpty) {
      _avatarInitials = parts[0].substring(0, parts[0].length >= 2 ? 2 : 1).toUpperCase();
    } else {
      _avatarInitials = 'U';
    }
    notifyListeners();
  }

  void setAvatarColor(Color color) {
    _avatarColor = color;
    _customAvatarFile = null;
    _customAvatarPath = null;
    _customAvatarBytes = null;
    notifyListeners();
  }

  void setCustomAvatarFile(File? file) {
    _customAvatarFile = file;
    _customAvatarPath = file?.path;
    if (file != null && file.existsSync()) {
      try {
        _customAvatarBytes = file.readAsBytesSync();
      } catch (_) {}
    } else {
      _customAvatarBytes = null;
    }
    notifyListeners();
  }

  void setCustomAvatarBytes(Uint8List? bytes, {String? filePath}) {
    _customAvatarBytes = bytes;
    _customAvatarPath = filePath;
    if (filePath != null && filePath.isNotEmpty && File(filePath).existsSync()) {
      _customAvatarFile = File(filePath);
    } else {
      _customAvatarFile = null;
    }
    notifyListeners();
  }

  void setCustomAvatarPath(String? path) {
    _customAvatarPath = path;
    if (path != null && path.isNotEmpty && File(path).existsSync()) {
      _customAvatarFile = File(path);
      try {
        _customAvatarBytes = _customAvatarFile!.readAsBytesSync();
      } catch (_) {}
    } else {
      _customAvatarFile = null;
      _customAvatarBytes = null;
    }
    notifyListeners();
  }

  /// Synchronise l'avatar de l'utilisateur : mémoire, stockage local ET Firestore
  Future<void> syncUserAvatar(String uid, {String? avatarBase64, String? avatarPath}) async {
    // 1. Si les données Base64 sont déjà fournies (ex: retour de Firestore lors du login)
    if (avatarBase64 != null && avatarBase64.isNotEmpty) {
      try {
        final bytes = base64Decode(avatarBase64);
        _customAvatarBytes = bytes;
        final appDir = await getApplicationDocumentsDirectory();
        final avatarsDir = Directory('${appDir.path}/avatars');
        if (!await avatarsDir.exists()) await avatarsDir.create(recursive: true);
        final localFile = File('${avatarsDir.path}/avatar_$uid.jpg');
        await localFile.writeAsBytes(bytes);
        _customAvatarFile = localFile;
        _customAvatarPath = localFile.path;
        notifyListeners();
        return;
      } catch (e) {
        debugPrint('Notice decoding avatarBase64: $e');
      }
    }

    // 2. Vérifier les fichiers locaux existants sur l'appareil
    await loadLocalAvatar(uid);
    if (_customAvatarFile != null && _customAvatarBytes != null) {
      // Si présent localement mais peut-être pas encore sur Firestore, on l'envoie en arrière-plan
      if (avatarBase64 == null || avatarBase64.isEmpty) {
        try {
          final b64 = base64Encode(_customAvatarBytes!);
          FirebaseFirestore.instance.collection('users').doc(uid).set({
            'avatarBase64': b64,
            'avatarPath': _customAvatarPath,
          }, SetOptions(merge: true));
        } catch (_) {}
      }
      return;
    }

    // 3. Récupérer depuis Firestore si non trouvé localement
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final data = doc.data();
      final cloudB64 = data?['avatarBase64'] as String?;
      if (cloudB64 != null && cloudB64.isNotEmpty) {
        final bytes = base64Decode(cloudB64);
        _customAvatarBytes = bytes;
        final appDir = await getApplicationDocumentsDirectory();
        final avatarsDir = Directory('${appDir.path}/avatars');
        if (!await avatarsDir.exists()) await avatarsDir.create(recursive: true);
        final localFile = File('${avatarsDir.path}/avatar_$uid.jpg');
        await localFile.writeAsBytes(bytes);
        _customAvatarFile = localFile;
        _customAvatarPath = localFile.path;
        notifyListeners();
        return;
      }
    } catch (e) {
      debugPrint('Notice fetching avatar from Firestore: $e');
    }
  }

  /// Charge l'avatar stocké de manière permanente dans le dossier local de l'application.
  Future<void> loadLocalAvatar(String uid) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final avatarsDir = Directory('${appDir.path}/avatars');
      if (await avatarsDir.exists()) {
        final files = avatarsDir
            .listSync()
            .whereType<File>()
            .where((f) => f.path.contains('avatar_$uid'))
            .toList();
        if (files.isNotEmpty) {
          files.sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
          _customAvatarFile = files.first;
          _customAvatarPath = files.first.path;
          try {
            _customAvatarBytes = await files.first.readAsBytes();
          } catch (_) {}
          notifyListeners();
          return;
        }
      }
    } catch (e) {
      debugPrint('Notice loading local avatar: $e');
    }
    if (_customAvatarPath != null && _customAvatarPath!.isNotEmpty && File(_customAvatarPath!).existsSync()) {
      _customAvatarFile = File(_customAvatarPath!);
      try {
        _customAvatarBytes = await _customAvatarFile!.readAsBytes();
      } catch (_) {}
      notifyListeners();
    }
  }

  void setLocation(String loc) {
    _location = loc;
    notifyListeners();
  }

  void reset() {
    _name = '';
    _email = '';
    _phone = '';
    _location = 'Cotonou, Bénin';
    _avatarColor = const Color(0xFF2563EB);
    _avatarInitials = 'U';
    _customAvatarFile = null;
    _customAvatarPath = null;
    _customAvatarBytes = null;
    notifyListeners();
  }
}

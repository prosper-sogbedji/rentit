import 'dart:io';
import 'package:flutter/material.dart';

class UserProvider extends ChangeNotifier {
  String _name = 'Alex Johnson';
  String _email = 'alex.johnson@rentit.com';
  String _phone = '+1 (555) 234-5678';
  String _location = 'Paris, France';
  Color _avatarColor = const Color(0xFF2563EB);
  String _avatarInitials = 'AJ';
  File? _customAvatarFile;
  String? _customAvatarPath;

  String get name => _name;
  String get email => _email;
  String get phone => _phone;
  String get location => _location;
  Color get avatarColor => _avatarColor;
  String get avatarInitials => _avatarInitials;
  File? get customAvatarFile => _customAvatarFile;
  String? get customAvatarPath => _customAvatarPath;

  void updateProfile({
    required String name,
    required String email,
    required String phone,
    required String location,
  }) {
    _name = name;
    _email = email;
    _phone = phone;
    _location = location;

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
    notifyListeners();
  }

  void setCustomAvatarFile(File? file) {
    _customAvatarFile = file;
    _customAvatarPath = file?.path;
    notifyListeners();
  }

  void setCustomAvatarPath(String? path) {
    _customAvatarPath = path;
    if (path != null && path.isNotEmpty && File(path).existsSync()) {
      _customAvatarFile = File(path);
    } else {
      _customAvatarFile = null;
    }
    notifyListeners();
  }

  void setLocation(String loc) {
    _location = loc;
    notifyListeners();
  }

  void reset() {
    _name = '';
    _email = '';
    _phone = '';
    _location = 'Paris, France';
    _avatarColor = const Color(0xFF2563EB);
    _avatarInitials = 'U';
    _customAvatarFile = null;
    _customAvatarPath = null;
    notifyListeners();
  }
}

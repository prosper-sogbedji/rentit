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

  String get name => _name;
  String get email => _email;
  String get phone => _phone;
  String get location => _location;
  Color get avatarColor => _avatarColor;
  String get avatarInitials => _avatarInitials;
  File? get customAvatarFile => _customAvatarFile;

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

    final parts = _name.trim().split(' ');
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      _avatarInitials = '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    } else if (_name.isNotEmpty) {
      _avatarInitials = _name.substring(0, 1).toUpperCase();
    }
    notifyListeners();
  }

  void setAvatarColor(Color color) {
    _avatarColor = color;
    _customAvatarFile = null;
    notifyListeners();
  }

  void setCustomAvatarFile(File? file) {
    _customAvatarFile = file;
    notifyListeners();
  }

  void setLocation(String loc) {
    _location = loc;
    notifyListeners();
  }
}

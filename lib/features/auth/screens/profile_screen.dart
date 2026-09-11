import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/language_provider.dart';
import '../../../core/providers/notification_provider.dart';
import '../../notifications/screens/notifications_modal.dart';
import '../../rentals/providers/rental_provider.dart';
import '../../rentals/screens/my_rentals_screen.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback? onNavigateToRentals;

  const ProfileScreen({
    super.key,
    this.onNavigateToRentals,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // User Profile State
  String _name = 'Alex Johnson';
  String _email = 'alex.johnson@rentit.com';
  String _phone = '+1 (555) 234-5678';
  String _location = 'Paris, France';
  Color _avatarColor = const Color(0xFF2563EB);
  String _avatarInitials = 'AJ';
  File? _customAvatarFile;

  // Security Preferences
  bool _biometricEnabled = true;
  bool _twoFactorEnabled = false;

  // Payment Methods State
  final List<Map<String, dynamic>> _paymentMethods = [
    {
      'id': '1',
      'brand': 'Visa',
      'last4': '4242',
      'exp': '12/26',
      'isDefault': true,
      'color': const Color(0xFF1E3A8A),
    },
    {
      'id': '2',
      'brand': 'Mastercard',
      'last4': '8819',
      'exp': '08/25',
      'isDefault': false,
      'color': const Color(0xFF7C2D12),
    },
  ];

  void _showSnack(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? const Color(0xFFEF4444) : const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ──── 1. VRAIE SÉLECTION D'IMAGE (CAMÉRA & GALERIE NATIVES) ────
  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (picked != null) {
        setState(() {
          _customAvatarFile = File(picked.path);
        });
        if (mounted) {
          final isFr = context.read<LanguageProvider>().isFrench;
          _showSnack(isFr ? 'Photo de profil mise à jour avec succès !' : 'Profile photo updated successfully!');
        }
      }
    } catch (e) {
      if (mounted) {
        _showSnack('Erreur lors de la sélection : $e', isError: true);
      }
    }
  }

  void _showAvatarPicker() {
    final lang = context.read<LanguageProvider>();
    final isFr = lang.isFrench;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final avatarPresets = [
          {'initials': _avatarInitials, 'color': const Color(0xFF2563EB)},
          {'initials': _avatarInitials, 'color': const Color(0xFF10B981)},
          {'initials': _avatarInitials, 'color': const Color(0xFF7C3AED)},
          {'initials': _avatarInitials, 'color': const Color(0xFFF59E0B)},
          {'initials': _avatarInitials, 'color': const Color(0xFF0F172A)},
        ];

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  lang.t('change_photo'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  isFr ? 'Prenez une photo ou choisissez dans votre galerie' : 'Take a photo or pick from device gallery',
                  style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 20),

                // Palette presets
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: avatarPresets.map((preset) {
                    final color = preset['color'] as Color;
                    final isSelected = _avatarColor == color && _customAvatarFile == null;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _avatarColor = color;
                          _customAvatarFile = null;
                        });
                        Navigator.pop(ctx);
                        _showSnack(isFr ? 'Couleur d\'avatar mise à jour !' : 'Avatar color updated!');
                      },
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? const Color(0xFF2563EB) : Colors.transparent,
                            width: 2.5,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: color,
                          child: Text(
                            preset['initials'] as String,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 20),
                const Divider(height: 1),
                const SizedBox(height: 12),

                // Vraie caméra native
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.camera_alt_outlined, color: Color(0xFF2563EB)),
                  ),
                  title: Text(
                    lang.t('take_photo'),
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  subtitle: Text(
                    isFr ? 'Ouvrir l\'appareil photo' : 'Open phone camera',
                    style: const TextStyle(fontSize: 12),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickImage(ImageSource.camera);
                  },
                ),

                // Vraie galerie native
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.photo_library_outlined, color: Color(0xFF475569)),
                  ),
                  title: Text(
                    lang.t('choose_gallery'),
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  subtitle: Text(
                    isFr ? 'Sélectionner une photo du téléphone' : 'Pick from phone library',
                    style: const TextStyle(fontSize: 12),
                  ),
                  onTap: () {
                    Navigator.pop(ctx);
                    _pickImage(ImageSource.gallery);
                  },
                ),

                if (_customAvatarFile != null)
                  ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEE2E2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.delete_outline, color: Color(0xFFEF4444)),
                    ),
                    title: Text(
                      isFr ? 'Supprimer la photo' : 'Remove photo',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: Color(0xFFEF4444)),
                    ),
                    onTap: () {
                      setState(() {
                        _customAvatarFile = null;
                      });
                      Navigator.pop(ctx);
                      _showSnack(isFr ? 'Photo supprimée' : 'Photo removed');
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ──── 2. INFORMATIONS PERSONNELLES (ÉDITION PROPRE ET NATURELLE) ────
  void _showPersonalInfoModal() {
    final lang = context.read<LanguageProvider>();
    final isFr = lang.isFrench;
    final nameCtrl = TextEditingController(text: _name);
    final emailCtrl = TextEditingController(text: _email);
    final phoneCtrl = TextEditingController(text: _phone);
    final locationCtrl = TextEditingController(text: _location);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F3FF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.person_outline, color: Color(0xFF7C3AED)),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lang.t('menu_personal_info'),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          isFr ? 'Mettre à jour vos coordonnées' : 'Update your contact details',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                _buildFormField(label: isFr ? 'Nom complet' : 'Full Name', controller: nameCtrl, icon: Icons.badge_outlined),
                const SizedBox(height: 12),
                _buildFormField(
                  label: isFr ? 'Adresse e-mail' : 'Email Address',
                  controller: emailCtrl,
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                _buildFormField(
                  label: isFr ? 'Numéro de téléphone' : 'Phone Number',
                  controller: phoneCtrl,
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                _buildFormField(
                  label: isFr ? 'Ville de résidence' : 'City / Location',
                  controller: locationCtrl,
                  icon: Icons.location_on_outlined,
                ),
                const SizedBox(height: 24),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      if (nameCtrl.text.trim().isEmpty) return;
                      setState(() {
                        _name = nameCtrl.text.trim();
                        _email = emailCtrl.text.trim();
                        _phone = phoneCtrl.text.trim();
                        _location = locationCtrl.text.trim();
                        final parts = _name.split(' ');
                        if (parts.length >= 2) {
                          _avatarInitials = '${parts[0][0]}${parts[1][0]}'.toUpperCase();
                        } else if (_name.isNotEmpty) {
                          _avatarInitials = _name.substring(0, 1).toUpperCase();
                        }
                      });
                      Navigator.pop(ctx);
                      _showSnack(isFr ? 'Informations mises à jour !' : 'Information updated!');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(
                      lang.t('save_changes'),
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF475569),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A), fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 18, color: const Color(0xFF94A3B8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  // ──── 3. SÉLECTEUR DE LANGUE RAPIDE ────
  void _showLanguageSelector() {
    final lang = context.read<LanguageProvider>();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Choisir la langue / Select Language',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Text('🇫🇷', style: TextStyle(fontSize: 28)),
                  title: const Text('Français', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  subtitle: const Text('Langue de l\'application en français'),
                  trailing: lang.isFrench ? const Icon(Icons.check_circle, color: Color(0xFF2563EB)) : null,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: lang.isFrench ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0)),
                  ),
                  onTap: () {
                    lang.setLanguage(AppLanguage.fr);
                    Navigator.pop(ctx);
                    _showSnack('Langue changée en Français 🇫🇷');
                  },
                ),
                const SizedBox(height: 10),
                ListTile(
                  leading: const Text('🇬🇧', style: TextStyle(fontSize: 28)),
                  title: const Text('English', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  subtitle: const Text('App language in English'),
                  trailing: !lang.isFrench ? const Icon(Icons.check_circle, color: Color(0xFF2563EB)) : null,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: !lang.isFrench ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0)),
                  ),
                  onTap: () {
                    lang.setLanguage(AppLanguage.en);
                    Navigator.pop(ctx);
                    _showSnack('Language switched to English 🇬🇧');
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ──── 4. MOYENS DE PAIEMENT ────
  void _showPaymentMethodsModal() {
    final lang = context.read<LanguageProvider>();
    final isFr = lang.isFrench;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalContext, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFCBD5E1),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      lang.t('menu_payment_methods'),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                    ),
                    Text(
                      isFr ? 'Gérez vos cartes enregistrées' : 'Manage your saved cards',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 16),

                    ..._paymentMethods.map((pm) {
                      final isDefault = pm['isDefault'] as bool;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: pm['color'] as Color,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.credit_card, color: Colors.white, size: 28),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    pm['brand'] as String,
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '•••• •••• •••• ${pm['last4']}  (${pm['exp']})',
                                    style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            if (isDefault)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  isFr ? 'PAR DÉFAUT' : 'DEFAULT',
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 10),
                                ),
                              ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ──── 5. SÉCURITÉ ────
  void _showSecurityModal() {
    final lang = context.read<LanguageProvider>();
    final isFr = lang.isFrench;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFCBD5E1),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      lang.t('menu_security'),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                    ),
                    Text(
                      isFr ? 'Protégez votre compte RentIt' : 'Protect your RentIt account',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 20),

                    SwitchListTile(
                      activeThumbColor: const Color(0xFF059669),
                      contentPadding: EdgeInsets.zero,
                      title: Text(isFr ? 'Authentification biométrique' : 'Biometric Login', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      subtitle: Text(isFr ? 'Déverrouillage par empreinte ou Face ID' : 'Fingerprint or Face ID', style: const TextStyle(fontSize: 12)),
                      value: _biometricEnabled,
                      onChanged: (val) {
                        setModalState(() => _biometricEnabled = val);
                        setState(() => _biometricEnabled = val);
                      },
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      activeThumbColor: const Color(0xFF059669),
                      contentPadding: EdgeInsets.zero,
                      title: Text(isFr ? 'Validation en deux étapes (2FA)' : 'Two-Factor Auth (2FA)', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      subtitle: Text(isFr ? 'Code de confirmation par SMS' : 'SMS confirmation code', style: const TextStyle(fontSize: 12)),
                      value: _twoFactorEnabled,
                      onChanged: (val) {
                        setModalState(() => _twoFactorEnabled = val);
                        setState(() => _twoFactorEnabled = val);
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ──── 6. AIDE ET SUPPORT ────
  void _showHelpSupportModal() {
    final lang = context.read<LanguageProvider>();
    final isFr = lang.isFrench;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.65,
          maxChildSize: 0.85,
          minChildSize: 0.4,
          expand: false,
          builder: (_, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFCBD5E1),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    lang.t('menu_help'),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                  ),
                  Text(
                    isFr ? 'Assistance et foire aux questions' : 'Support and frequently asked questions',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 20),

                  ExpansionTile(
                    title: Text(
                      isFr ? 'Comment fonctionne la caution de location ?' : 'How does the security deposit work?',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Text(
                          isFr
                              ? 'La caution est une autorisation temporaire sur votre carte bancaire. Elle est libérée dans les 24h suivant le retour du matériel en bon état.'
                              : 'The deposit is a temporary hold on your card. It is released within 24h after returning the equipment in good condition.',
                          style: const TextStyle(fontSize: 13, color: Color(0xFF475569), height: 1.4),
                        ),
                      ),
                    ],
                  ),
                  ExpansionTile(
                    title: Text(
                      isFr ? 'Que faire en cas de retard de restitution ?' : 'What if equipment is returned late?',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Text(
                          isFr
                              ? 'Vous pouvez demander une prolongation directement dans l\'onglet "Mes Locations" avant l\'échéance de votre contrat.'
                              : 'You can request an extension directly from the My Rentals tab before the rental expires.',
                          style: const TextStyle(fontSize: 13, color: Color(0xFF475569), height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ──── 7. DÉCONNEXION ────
  void _confirmLogout() {
    final lang = context.read<LanguageProvider>();
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              const Icon(Icons.logout, color: Color(0xFFEF4444), size: 22),
              const SizedBox(width: 10),
              Text(lang.t('logout_confirm_title'), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
            ],
          ),
          content: Text(lang.t('logout_confirm_msg'), style: const TextStyle(fontSize: 14, color: Color(0xFF475569))),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(lang.t('cancel'), style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(lang.t('logout_btn'), style: const TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Color(0xFF64748B),
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Color iconColor = const Color(0xFF2563EB),
    Color iconBg = const Color(0xFFEFF6FF),
    Widget? trailingWidget,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.025),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ),
            trailingWidget ??
                const Icon(
                  Icons.chevron_right,
                  color: Color(0xFFCBD5E1),
                  size: 20,
                ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final notifProvider = context.watch<NotificationProvider>();
    final isFr = lang.isFrench;

    int userRentalsCount = 1;
    try {
      final rentalProvider = context.watch<RentalProvider>();
      userRentalsCount = rentalProvider.rentals.length;
    } catch (_) {}

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          lang.t('profile_title'),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
        actions: [
          // Switch de langue rapide dans l'appbar
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFBFDBFE)),
            ),
            child: InkWell(
              onTap: lang.toggleLanguage,
              borderRadius: BorderRadius.circular(20),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(isFr ? '🇫🇷' : '🇬🇧', style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 4),
                    Text(
                      isFr ? 'FR' : 'EN',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF2563EB),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),

          // Vraie cloche de notification avec badge
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_none_outlined,
                  color: Color(0xFF0F172A),
                ),
                tooltip: lang.t('notif_title'),
                onPressed: () => NotificationsModal.show(context),
              ),
              if (notifProvider.unreadCount > 0)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEF4444),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // ──── Profile Card Épurée (Sans badges IA artificiels) ────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Avatar interactif (caméra/galerie native)
                  GestureDetector(
                    onTap: _showAvatarPicker,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 46,
                          backgroundColor: _avatarColor,
                          backgroundImage: _customAvatarFile != null ? FileImage(_customAvatarFile!) : null,
                          child: _customAvatarFile == null
                              ? Text(
                                  _avatarInitials,
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2563EB),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2.5),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Nom réel
                  Text(
                    _name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Email & Ville (sobre et naturel)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF64748B)),
                      const SizedBox(width: 4),
                      Text(
                        _location,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '•',
                        style: TextStyle(color: Colors.grey.shade400),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _email,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // Statistiques réelles et sobres
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            children: [
                              Text(
                                '$userRentalsCount',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                lang.t('stat_rentals'),
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF64748B),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            children: [
                              Text(
                                lang.t('member_years'),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                lang.t('stat_member_since'),
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF64748B),
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ──── GESTION DES LOCATIONS ────
            _buildSectionTitle(lang.t('section_management')),
            _buildMenuTile(
              icon: Icons.history,
              title: lang.t('menu_rental_history'),
              subtitle: lang.t('menu_rental_history_sub'),
              onTap: () {
                if (widget.onNavigateToRentals != null) {
                  widget.onNavigateToRentals!();
                } else {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const MyRentalsScreen()),
                  );
                }
              },
            ),
            _buildMenuTile(
              icon: Icons.credit_card_outlined,
              title: lang.t('menu_payment_methods'),
              subtitle: lang.t('menu_payment_methods_sub'),
              onTap: _showPaymentMethodsModal,
            ),
            _buildMenuTile(
              icon: Icons.notifications_outlined,
              title: lang.t('menu_notifications'),
              subtitle: lang.t('menu_notifications_sub'),
              trailingWidget: notifProvider.unreadCount > 0
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${notifProvider.unreadCount}',
                        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                      ),
                    )
                  : null,
              onTap: () => NotificationsModal.show(context),
            ),

            const SizedBox(height: 8),

            // ──── PARAMÈTRES GÉNÉRAUX ────
            _buildSectionTitle(lang.t('section_settings')),
            _buildMenuTile(
              icon: Icons.person_outline,
              title: lang.t('menu_personal_info'),
              subtitle: lang.t('menu_personal_info_sub'),
              iconColor: const Color(0xFF7C3AED),
              iconBg: const Color(0xFFF5F3FF),
              onTap: _showPersonalInfoModal,
            ),
            _buildMenuTile(
              icon: Icons.translate,
              title: lang.t('menu_language'),
              subtitle: isFr ? 'Français (Appuyer pour changer)' : 'English (Tap to switch)',
              iconColor: const Color(0xFF2563EB),
              iconBg: const Color(0xFFEFF6FF),
              trailingWidget: Text(isFr ? '🇫🇷 FR' : '🇬🇧 EN', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF2563EB))),
              onTap: _showLanguageSelector,
            ),
            _buildMenuTile(
              icon: Icons.security_outlined,
              title: lang.t('menu_security'),
              subtitle: lang.t('menu_security_sub'),
              iconColor: const Color(0xFF059669),
              iconBg: const Color(0xFFECFDF5),
              onTap: _showSecurityModal,
            ),
            _buildMenuTile(
              icon: Icons.help_outline,
              title: lang.t('menu_help'),
              subtitle: lang.t('menu_help_sub'),
              iconColor: const Color(0xFFF59E0B),
              iconBg: const Color(0xFFFFFBEB),
              onTap: _showHelpSupportModal,
            ),

            const SizedBox(height: 16),

            // ──── Déconnexion ────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: _confirmLogout,
                icon: const Icon(
                  Icons.logout,
                  color: Color(0xFFEF4444),
                  size: 20,
                ),
                label: Text(
                  lang.t('logout_btn'),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFEF4444),
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFFECACA)),
                  backgroundColor: const Color(0xFFFFF5F5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Version Footer
            const Center(
              child: Text(
                'RentIt v1.0.0',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF94A3B8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

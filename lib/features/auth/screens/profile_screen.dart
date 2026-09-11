import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  String _location = 'San Francisco, CA';
  String _bio = 'Premium tools owner. Always keeping my gear in top shape for every rental.';
  Color _avatarColor = const Color(0xFF2563EB);
  String _avatarInitials = 'AJ';

  // Notification Preferences
  bool _pushBookingAlerts = true;
  bool _pushReminders = true;
  bool _promoOffers = false;
  bool _emailReceipts = true;
  bool _smsUpdates = true;

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
    {
      'id': '3',
      'brand': 'Apple Pay',
      'last4': 'Connected',
      'exp': 'N/A',
      'isDefault': false,
      'color': const Color(0xFF1F2937),
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

  // ──── 1. AVATAR PICKER MODAL ────
  void _showAvatarPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final avatarPresets = [
          {'initials': 'AJ', 'color': const Color(0xFF2563EB), 'label': 'Blue'},
          {'initials': 'AJ', 'color': const Color(0xFF10B981), 'label': 'Emerald'},
          {'initials': 'AJ', 'color': const Color(0xFF7C3AED), 'label': 'Purple'},
          {'initials': 'AJ', 'color': const Color(0xFFF59E0B), 'label': 'Amber'},
          {'initials': 'AJ', 'color': const Color(0xFF0F172A), 'label': 'Dark'},
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
                const Text(
                  'Change Profile Photo',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Select an avatar theme or upload a custom picture',
                  style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 20),

                // Palette presets
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: avatarPresets.map((preset) {
                    final color = preset['color'] as Color;
                    final isSelected = _avatarColor == color;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _avatarColor = color;
                        });
                        Navigator.pop(ctx);
                        _showSnack('Avatar theme updated!');
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
                          radius: 22,
                          backgroundColor: color,
                          child: Text(
                            preset['initials'] as String,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 24),
                const Divider(height: 1),
                const SizedBox(height: 12),

                // Action options
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.camera_alt_outlined, color: Color(0xFF2563EB)),
                  ),
                  title: const Text(
                    'Take a Photo',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  subtitle: const Text('Use camera to capture new photo', style: TextStyle(fontSize: 12)),
                  onTap: () {
                    Navigator.pop(ctx);
                    _showSnack('Camera simulated: Photo captured & updated!');
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.photo_library_outlined, color: Color(0xFF475569)),
                  ),
                  title: const Text(
                    'Choose from Gallery',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  subtitle: const Text('Pick from device photos', style: TextStyle(fontSize: 12)),
                  onTap: () {
                    Navigator.pop(ctx);
                    _showSnack('Gallery simulated: New picture applied!');
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ──── 2. PERSONAL INFORMATION MODAL ────
  void _showPersonalInfoModal() {
    final nameCtrl = TextEditingController(text: _name);
    final emailCtrl = TextEditingController(text: _email);
    final phoneCtrl = TextEditingController(text: _phone);
    final locationCtrl = TextEditingController(text: _location);
    final bioCtrl = TextEditingController(text: _bio);

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
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Personal Information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        Text(
                          'Update your profile details',
                          style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Name field
                _buildFormField(label: 'Full Name', controller: nameCtrl, icon: Icons.badge_outlined),
                const SizedBox(height: 12),

                // Email field
                _buildFormField(
                  label: 'Email Address',
                  controller: emailCtrl,
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),

                // Phone field
                _buildFormField(
                  label: 'Phone Number',
                  controller: phoneCtrl,
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),

                // Location field
                _buildFormField(
                  label: 'Location',
                  controller: locationCtrl,
                  icon: Icons.location_on_outlined,
                ),
                const SizedBox(height: 12),

                // Bio field
                _buildFormField(
                  label: 'Bio / Description',
                  controller: bioCtrl,
                  icon: Icons.description_outlined,
                  maxLines: 3,
                ),
                const SizedBox(height: 24),

                // Save button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      if (nameCtrl.text.trim().isEmpty) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                          const SnackBar(content: Text('Name cannot be empty')),
                        );
                        return;
                      }
                      setState(() {
                        _name = nameCtrl.text.trim();
                        _email = emailCtrl.text.trim();
                        _phone = phoneCtrl.text.trim();
                        _location = locationCtrl.text.trim();
                        _bio = bioCtrl.text.trim();
                        final parts = _name.split(' ');
                        if (parts.length >= 2) {
                          _avatarInitials = '${parts[0][0]}${parts[1][0]}'.toUpperCase();
                        } else if (_name.isNotEmpty) {
                          _avatarInitials = _name.substring(0, 1).toUpperCase();
                        }
                      });
                      Navigator.pop(ctx);
                      _showSnack('Personal information updated successfully!');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Save Changes',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
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
    int maxLines = 1,
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
          maxLines: maxLines,
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

  // ──── 3. PAYMENT METHODS MODAL ────
  void _showPaymentMethodsModal() {
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Payment Methods',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            Text(
                              'Manage your billing cards & wallets',
                              style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: () => _showAddCardDialog(modalContext, setModalState),
                          icon: const Icon(Icons.add_circle, color: Color(0xFF2563EB), size: 28),
                          tooltip: 'Add new card',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // List of cards
                    ..._paymentMethods.map((pm) {
                      final isDefault = pm['isDefault'] as bool;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: pm['color'] as Color,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
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
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    pm['last4'] == 'Connected'
                                        ? 'Apple Pay Wallet'
                                        : '•••• •••• •••• ${pm['last4']}  (${pm['exp']})',
                                    style: TextStyle(
                                      color: Colors.white.withValues(alpha: 0.8),
                                      fontSize: 12,
                                    ),
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
                                child: const Text(
                                  'DEFAULT',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 10,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              )
                            else
                              TextButton(
                                onPressed: () {
                                  setModalState(() {
                                    for (var item in _paymentMethods) {
                                      item['isDefault'] = false;
                                    }
                                    pm['isDefault'] = true;
                                  });
                                  setState(() {});
                                  _showSnack('${pm['brand']} is now your default payment method.');
                                },
                                child: const Text(
                                  'Set Default',
                                  style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                                ),
                              ),
                          ],
                        ),
                      );
                    }),

                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: () => _showAddCardDialog(modalContext, setModalState),
                        icon: const Icon(Icons.add, color: Color(0xFF2563EB)),
                        label: const Text(
                          'Add New Card',
                          style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.w700),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFBFDBFE)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                      ),
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

  void _showAddCardDialog(BuildContext parentCtx, StateSetter modalSetState) {
    final numberCtrl = TextEditingController();
    final expCtrl = TextEditingController();
    final cvvCtrl = TextEditingController();

    showDialog(
      context: parentCtx,
      builder: (dialogCtx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Add Payment Card', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: numberCtrl,
                keyboardType: TextInputType.number,
                maxLength: 16,
                decoration: InputDecoration(
                  labelText: 'Card Number',
                  counterText: '',
                  prefixIcon: const Icon(Icons.credit_card),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: expCtrl,
                      keyboardType: TextInputType.datetime,
                      maxLength: 5,
                      decoration: InputDecoration(
                        labelText: 'MM/YY',
                        counterText: '',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: cvvCtrl,
                      keyboardType: TextInputType.number,
                      maxLength: 3,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'CVV',
                        counterText: '',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
            ),
            ElevatedButton(
              onPressed: () {
                final num = numberCtrl.text.trim();
                if (num.length < 4) {
                  ScaffoldMessenger.of(parentCtx).showSnackBar(
                    const SnackBar(content: Text('Please enter a valid card number')),
                  );
                  return;
                }
                final last4 = num.substring(num.length - 4);
                modalSetState(() {
                  _paymentMethods.add({
                    'id': DateTime.now().millisecondsSinceEpoch.toString(),
                    'brand': num.startsWith('4') ? 'Visa' : 'Mastercard',
                    'last4': last4,
                    'exp': expCtrl.text.isNotEmpty ? expCtrl.text : '12/28',
                    'isDefault': false,
                    'color': const Color(0xFF0369A1),
                  });
                });
                setState(() {});
                Navigator.pop(dialogCtx);
                _showSnack('Card ending in $last4 added successfully!');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Add Card'),
            ),
          ],
        );
      },
    );
  }

  // ──── 4. NOTIFICATIONS MODAL ────
  void _showNotificationsModal() {
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
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.notifications_outlined, color: Color(0xFF2563EB)),
                        ),
                        const SizedBox(width: 12),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Notification Settings',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            Text(
                              'Choose how and when to receive alerts',
                              style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    SwitchListTile(
                      activeThumbColor: const Color(0xFF2563EB),
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Booking Alerts & Updates', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      subtitle: const Text('Instant notification when booking is approved or ready', style: TextStyle(fontSize: 12)),
                      value: _pushBookingAlerts,
                      onChanged: (val) {
                        setModalState(() => _pushBookingAlerts = val);
                        setState(() => _pushBookingAlerts = val);
                      },
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      activeThumbColor: const Color(0xFF2563EB),
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Rental Return Reminders', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      subtitle: const Text('Reminders 24h & 2h before rental period ends', style: TextStyle(fontSize: 12)),
                      value: _pushReminders,
                      onChanged: (val) {
                        setModalState(() => _pushReminders = val);
                        setState(() => _pushReminders = val);
                      },
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      activeThumbColor: const Color(0xFF2563EB),
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Email Receipts & Invoices', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      subtitle: const Text('Send PDF receipts directly to your email', style: TextStyle(fontSize: 12)),
                      value: _emailReceipts,
                      onChanged: (val) {
                        setModalState(() => _emailReceipts = val);
                        setState(() => _emailReceipts = val);
                      },
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      activeThumbColor: const Color(0xFF2563EB),
                      contentPadding: EdgeInsets.zero,
                      title: const Text('SMS Urgent Alerts', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      subtitle: const Text('Receive immediate SMS when owner accepts pickup', style: TextStyle(fontSize: 12)),
                      value: _smsUpdates,
                      onChanged: (val) {
                        setModalState(() => _smsUpdates = val);
                        setState(() => _smsUpdates = val);
                      },
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      activeThumbColor: const Color(0xFF2563EB),
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Promotions & Discounts', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      subtitle: const Text('Special rental offers and weekend discounts', style: TextStyle(fontSize: 12)),
                      value: _promoOffers,
                      onChanged: (val) {
                        setModalState(() => _promoOffers = val);
                        setState(() => _promoOffers = val);
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ──── 5. SECURITY MODAL ────
  void _showSecurityModal() {
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
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFECFDF5),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.security_outlined, color: Color(0xFF059669)),
                        ),
                        const SizedBox(width: 12),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Security & Privacy',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            Text(
                              'Protect your RentIt account',
                              style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    SwitchListTile(
                      activeThumbColor: const Color(0xFF059669),
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Biometric Authentication', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      subtitle: const Text('Unlock with Fingerprint or Face ID', style: TextStyle(fontSize: 12)),
                      value: _biometricEnabled,
                      onChanged: (val) {
                        setModalState(() => _biometricEnabled = val);
                        setState(() => _biometricEnabled = val);
                        _showSnack(val ? 'Biometrics activated' : 'Biometrics deactivated');
                      },
                    ),
                    const Divider(height: 1),
                    SwitchListTile(
                      activeThumbColor: const Color(0xFF059669),
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Two-Factor Authentication (2FA)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      subtitle: const Text('Require SMS code on unknown devices', style: TextStyle(fontSize: 12)),
                      value: _twoFactorEnabled,
                      onChanged: (val) {
                        setModalState(() => _twoFactorEnabled = val);
                        setState(() => _twoFactorEnabled = val);
                        _showSnack(val ? '2FA enabled on your account' : '2FA disabled');
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.lock_reset, color: Color(0xFF475569)),
                      title: const Text('Change Password', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      subtitle: const Text('Last changed 3 months ago', style: TextStyle(fontSize: 12)),
                      trailing: const Icon(Icons.chevron_right, color: Color(0xFF94A3B8)),
                      onTap: () {
                        Navigator.pop(ctx);
                        _showChangePasswordDialog();
                      },
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showChangePasswordDialog() {
    final oldPassCtrl = TextEditingController();
    final newPassCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Change Password', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: oldPassCtrl,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Current Password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: newPassCtrl,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  prefixIcon: const Icon(Icons.lock_reset),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
            ),
            ElevatedButton(
              onPressed: () {
                if (newPassCtrl.text.trim().length < 6) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(content: Text('Password must be at least 6 characters')),
                  );
                  return;
                }
                Navigator.pop(ctx);
                _showSnack('Password successfully updated!');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF059669),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  // ──── 6. HELP & SUPPORT MODAL ────
  void _showHelpSupportModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          maxChildSize: 0.9,
          minChildSize: 0.5,
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
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFFBEB),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.help_outline, color: Color(0xFFF59E0B)),
                      ),
                      const SizedBox(width: 12),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Help & Customer Support',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          Text(
                            '24/7 dedicated assistance for rentals',
                            style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Quick Contact Buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(ctx);
                            _showSnack('Starting live chat with RentIt Support...');
                          },
                          icon: const Icon(Icons.chat_bubble_outline, size: 18, color: Color(0xFF2563EB)),
                          label: const Text('Live Chat', style: TextStyle(color: Color(0xFF2563EB), fontSize: 13, fontWeight: FontWeight.w600)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFBFDBFE)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(ctx);
                            _showSnack('Call Hotline: +1 (800) 736-8481');
                          },
                          icon: const Icon(Icons.headset_mic_outlined, size: 18, color: Color(0xFF059669)),
                          label: const Text('Hotline', style: TextStyle(color: Color(0xFF059669), fontSize: 13, fontWeight: FontWeight.w600)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFA7F3D0)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  const Text(
                    'FREQUENTLY ASKED QUESTIONS',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B), letterSpacing: 0.8),
                  ),
                  const SizedBox(height: 10),

                  const ExpansionTile(
                    title: Text('How does the rental security deposit work?', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Text(
                          'The security deposit is temporarily authorized on your card when booking. It is fully released within 24 hours after the item is returned in good condition.',
                          style: TextStyle(fontSize: 13, color: Color(0xFF475569), height: 1.4),
                        ),
                      ),
                    ],
                  ),
                  const ExpansionTile(
                    title: Text('What if an item is returned late?', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Text(
                          'You can request a rental extension directly from the My Rentals tab before your period ends. Late returns without prior notice may incur an hourly overtime rate.',
                          style: TextStyle(fontSize: 13, color: Color(0xFF475569), height: 1.4),
                        ),
                      ),
                    ],
                  ),
                  const ExpansionTile(
                    title: Text('Are rented tools and gear insured?', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Text(
                          'Yes! All rentals include RentIt Basic Shield coverage against normal wear and unintentional equipment breakdown.',
                          style: TextStyle(fontSize: 13, color: Color(0xFF475569), height: 1.4),
                        ),
                      ),
                    ],
                  ),
                  const ExpansionTile(
                    title: Text('How do I become a VerifiedPro owner?', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Text(
                          'Complete at least 10 successful rentals with an average rating above 4.8 and submit your identity verification documents in Personal Information.',
                          style: TextStyle(fontSize: 13, color: Color(0xFF475569), height: 1.4),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ──── 7. LOGOUT CONFIRMATION ────
  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.logout, color: Color(0xFFEF4444), size: 22),
              SizedBox(width: 10),
              Text(
                'Log Out',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
              ),
            ],
          ),
          content: const Text(
            'Are you sure you want to sign out of your RentIt account?',
            style: TextStyle(fontSize: 14, color: Color(0xFF475569)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
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
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Log Out', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        );
      },
    );
  }

  // ──── 8. STAT CARD BUILDER ────
  Widget _buildStatCard({
    required String value,
    required String label,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              Icon(icon, color: const Color(0xFF2563EB), size: 22),
              const SizedBox(height: 6),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
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
    // Dynamically watch rental count if available
    int userRentalsCount = 42;
    try {
      final rentalProvider = context.watch<RentalProvider>();
      userRentalsCount = 42 + rentalProvider.rentals.length;
    } catch (_) {}

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'My Profile',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_none_outlined,
              color: Color(0xFF0F172A),
            ),
            tooltip: 'Notification settings',
            onPressed: _showNotificationsModal,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // ──── Profile Card ────
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
                  // Avatar + Camera Badge + VerifiedPro badge
                  GestureDetector(
                    onTap: _showAvatarPicker,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 44,
                          backgroundColor: _avatarColor,
                          child: Text(
                            _avatarInitials,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2563EB),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Name
                  Text(
                    _name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),

                  // VerifiedPro badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFBFDBFE)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.verified,
                          size: 13,
                          color: Color(0xFF2563EB),
                        ),
                        SizedBox(width: 4),
                        Text(
                          'VerifiedPro',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          '4.9',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        SizedBox(width: 2),
                        Icon(Icons.star, size: 12, color: Color(0xFFF59E0B)),
                        Text(
                          '(128)',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Description / Bio
                  Text(
                    _bio,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Stats Row: RENTALS | $1.2k EARNINGS | 2y MEMBER
                  Row(
                    children: [
                      _buildStatCard(
                        value: '$userRentalsCount',
                        label: 'RENTALS',
                        icon: Icons.calendar_today_outlined,
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
                      const SizedBox(width: 10),
                      _buildStatCard(
                        value: '\$1.2k',
                        label: 'EARNINGS',
                        icon: Icons.attach_money,
                        onTap: () => _showPaymentMethodsModal(),
                      ),
                      const SizedBox(width: 10),
                      _buildStatCard(
                        value: '2y',
                        label: 'MEMBER',
                        icon: Icons.access_time,
                        onTap: _showPersonalInfoModal,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ──── RENTAL MANAGEMENT ────
            _buildSectionTitle('RENTAL MANAGEMENT'),
            _buildMenuTile(
              icon: Icons.history,
              title: 'Rental History',
              subtitle: 'View your past and active rentals',
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
              title: 'Payment Methods',
              subtitle: 'Cards, Wallet, and Billing info',
              onTap: _showPaymentMethodsModal,
            ),
            _buildMenuTile(
              icon: Icons.notifications_outlined,
              title: 'Notifications',
              subtitle: 'Alerts for bookings and messages',
              onTap: _showNotificationsModal,
            ),

            const SizedBox(height: 8),

            // ──── GENERAL SETTINGS ────
            _buildSectionTitle('GENERAL SETTINGS'),
            _buildMenuTile(
              icon: Icons.person_outline,
              title: 'Personal Information',
              subtitle: 'Edit your name, email, and bio',
              iconColor: const Color(0xFF7C3AED),
              iconBg: const Color(0xFFF5F3FF),
              onTap: _showPersonalInfoModal,
            ),
            _buildMenuTile(
              icon: Icons.security_outlined,
              title: 'Security',
              subtitle: 'Password, 2FA, and Privacy',
              iconColor: const Color(0xFF059669),
              iconBg: const Color(0xFFECFDF5),
              onTap: _showSecurityModal,
            ),
            _buildMenuTile(
              icon: Icons.help_outline,
              title: 'Help & Support',
              subtitle: 'FAQs, Contact us, Terms of Service',
              iconColor: const Color(0xFFF59E0B),
              iconBg: const Color(0xFFFFFBEB),
              onTap: _showHelpSupportModal,
            ),

            const SizedBox(height: 16),

            // ──── Log Out ────
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
                label: const Text(
                  'Log Out',
                  style: TextStyle(
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

            const SizedBox(height: 16),

            // Version Footer
            const Center(
              child: Text(
                'RentIt v1.0.0 (Stable build)',
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFFCBD5E1),
                  fontWeight: FontWeight.w400,
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

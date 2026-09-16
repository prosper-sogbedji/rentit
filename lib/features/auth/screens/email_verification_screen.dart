import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/language_provider.dart';
import '../../../core/providers/notification_provider.dart';
import '../../../core/providers/user_provider.dart';
import '../../rentals/providers/rental_provider.dart';
import '../../../main.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String name;
  final String email;
  final String phone;
  final String password;

  const EmailVerificationScreen({
    super.key,
    required this.name,
    required this.email,
    required this.phone,
    this.password = '',
  });

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen>
    with SingleTickerProviderStateMixin {
  bool _isSuccess = false;
  int _resendTimerSeconds = 60;
  Timer? _countdownTimer;
  Timer? _autoCheckTimer;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _startCountdownTimer();
    _startAutoCheckTimer();
  }

  void _startCountdownTimer() {
    _countdownTimer?.cancel();
    setState(() => _resendTimerSeconds = 60);
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendTimerSeconds > 0) {
        if (mounted) setState(() => _resendTimerSeconds--);
      } else {
        timer.cancel();
      }
    });
  }

  void _startAutoCheckTimer() {
    _autoCheckTimer?.cancel();
    // Détection automatique en direct : vérifie toutes les 3 secondes
    // dès que l'utilisateur clique sur le lien dans sa boîte mail !
    _autoCheckTimer = Timer.periodic(const Duration(seconds: 3), (_) async {
      if (_isSuccess || !mounted) return;
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        try {
          await user.reload();
          final reloadedUser = FirebaseAuth.instance.currentUser;
          if (reloadedUser != null && reloadedUser.emailVerified && mounted) {
            _onVerificationSuccess();
          }
        } catch (_) {}
      }
    });
  }

  Future<void> _resendEmail() async {
    if (_resendTimerSeconds > 0) return;

    final isFr = context.read<LanguageProvider>().isFrench;
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.sendEmailVerification();
      }
      _startCountdownTimer();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.mark_email_read_outlined, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  isFr
                      ? 'Un nouvel e-mail de confirmation a été envoyé à ${widget.email}'
                      : 'A new confirmation email was sent to ${widget.email}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF2563EB),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isFr ? 'Impossible de renvoyer l\'e-mail : $e' : 'Failed to resend email: $e'),
          backgroundColor: const Color(0xFFEF4444),
        ),
      );
    }
  }

  Future<void> _onVerificationSuccess() async {
    _autoCheckTimer?.cancel();
    _countdownTimer?.cancel();
    _pulseController.stop();

    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      try {
        final uid = user.uid;
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'id': uid,
          'name': widget.name.trim(),
          'email': widget.email.trim().toLowerCase(),
          'phone': widget.phone.trim(),
          'role': 'client',
          'emailVerified': true,
        }, SetOptions(merge: true));
        await user.updateDisplayName(widget.name.trim());
      } catch (_) {}
    }

    if (!mounted) return;

    // Mise à jour du profil local
    final userProvider = context.read<UserProvider>();
    userProvider.updateProfile(
      name: widget.name,
      email: widget.email,
      phone: widget.phone.isNotEmpty ? widget.phone : '+229 01 00 00 00',
      location: 'Cotonou, Bénin',
    );

    // Notification de bienvenue
    final isFr = context.read<LanguageProvider>().isFrench;
    final firstName = widget.name.trim().split(' ').first;

    context.read<NotificationProvider>().addNotification(
      title: isFr ? 'Bienvenue, $firstName ! 🎉' : 'Welcome, $firstName! 🎉',
      message: isFr
          ? 'Votre e-mail (${widget.email}) a été vérifié avec succès. Votre compte est activé.'
          : 'Your email (${widget.email}) has been verified successfully. Your account is active.',
      type: NotificationType.system,
    );

    setState(() {
      _isSuccess = true;
    });

    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    await context.read<RentalProvider>().onUserLoggedIn();
    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainShell()),
      (route) => false,
    );
  }

  Future<void> _onChangeEmailOrBack() async {
    final isFr = context.read<LanguageProvider>().isFrench;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(isFr ? 'Modifier l\'adresse e-mail ?' : 'Change email address?'),
        content: Text(
          isFr
              ? 'Voulez-vous retourner à l\'inscription pour corriger votre adresse e-mail ?'
              : 'Do you want to return to registration to correct your email address?',
          style: const TextStyle(fontSize: 14, color: Color(0xFF64748B)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(isFr ? 'Annuler' : 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
            ),
            child: Text(isFr ? 'Modifier' : 'Change'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        await FirebaseAuth.instance.signOut();
      } catch (_) {}
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _autoCheckTimer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final isFr = lang.isFrench;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF0F172A)),
          onPressed: _onChangeEmailOrBack,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),

              // Animated Hero Badge
              ScaleTransition(
                scale: _isSuccess ? const AlwaysStoppedAnimation(1.0) : _pulseAnimation,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _isSuccess
                          ? [const Color(0xFF10B981), const Color(0xFF059669)]
                          : [const Color(0xFF3B82F6), const Color(0xFF1D4ED8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: (_isSuccess ? const Color(0xFF10B981) : const Color(0xFF2563EB))
                            .withValues(alpha: 0.35),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Center(
                    child: _isSuccess
                        ? const Icon(Icons.check_circle_rounded, color: Colors.white, size: 52)
                        : const Icon(Icons.mark_email_unread_outlined, color: Colors.white, size: 48),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // Title
              Text(
                _isSuccess
                    ? (isFr ? 'Compte activé avec succès !' : 'Account Activated Successfully!')
                    : (isFr ? 'Vérifiez votre boîte mail' : 'Check Your Inbox'),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              // Subtitle
              Text(
                _isSuccess
                    ? (isFr
                        ? 'Redirection en cours vers l\'accueil...'
                        : 'Redirecting to home screen...')
                    : (isFr
                        ? 'Un e-mail contenant un lien officiel de confirmation a été envoyé à :'
                        : 'An official confirmation email with an activation link was sent to:'),
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 14),

              // Email Pill badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.email_outlined, size: 18, color: Color(0xFF2563EB)),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        widget.email,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E40AF),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              if (!_isSuccess) ...[
                // Instructions card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildStepItem(
                        number: '1',
                        text: isFr
                            ? 'Ouvrez votre application de messagerie (Gmail, Outlook, etc.)'
                            : 'Open your email inbox (Gmail, Outlook, etc.)',
                      ),
                      const Divider(height: 20, color: Color(0xFFF1F5F9)),
                      _buildStepItem(
                        number: '2',
                        text: isFr
                            ? 'Cliquez sur le lien de confirmation reçu dans l\'e-mail'
                            : 'Click the confirmation link received in the email',
                      ),
                      const Divider(height: 20, color: Color(0xFFF1F5F9)),
                      _buildStepItem(
                        number: '3',
                        text: isFr
                            ? 'Votre compte s\'activera automatiquement ici-même'
                            : 'Your account will activate automatically right here',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // Live detection status card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Flexible(
                        child: Text(
                          isFr
                              ? 'En attente de votre clic sur le lien dans l\'e-mail...'
                              : 'Waiting for your click on the link in email...',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF334155),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Resend Email Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isFr ? "Vous n'avez pas reçu l'e-mail ? " : "Didn't receive the email? ",
                      style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                    ),
                    GestureDetector(
                      onTap: _resendTimerSeconds == 0 ? _resendEmail : null,
                      child: Text(
                        _resendTimerSeconds > 0
                            ? (isFr ? 'Renvoyer (${_resendTimerSeconds}s)' : 'Resend (${_resendTimerSeconds}s)')
                            : (isFr ? 'Renvoyer l\'e-mail' : 'Resend email'),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: _resendTimerSeconds == 0
                              ? const Color(0xFF2563EB)
                              : const Color(0xFF94A3B8),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Edit email / Back button
                TextButton.icon(
                  onPressed: _onChangeEmailOrBack,
                  icon: const Icon(Icons.edit_outlined, size: 16, color: Color(0xFF64748B)),
                  label: Text(
                    isFr ? 'Modifier l\'adresse e-mail' : 'Change email address',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ),
              ] else ...[
                const SizedBox(height: 24),
                const CircularProgressIndicator(
                  color: Color(0xFF10B981),
                  strokeWidth: 3,
                ),
              ],

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepItem({required String number, required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFBFDBFE)),
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2563EB),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF334155),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

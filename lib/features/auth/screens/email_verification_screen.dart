import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/language_provider.dart';
import '../../../core/providers/notification_provider.dart';
import '../../../core/providers/user_provider.dart';
import '../../../main.dart';

class EmailVerificationScreen extends StatefulWidget {
  final String name;
  final String email;
  final String phone;

  const EmailVerificationScreen({
    super.key,
    required this.name,
    required this.email,
    required this.phone,
  });

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final List<TextEditingController> _codeControllers =
      List.generate(4, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());

  bool _isLoading = false;
  bool _isSuccess = false;
  int _resendTimerSeconds = 45;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  void _startResendTimer() {
    _timer?.cancel();
    setState(() => _resendTimerSeconds = 45);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendTimerSeconds > 0) {
        setState(() => _resendTimerSeconds--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var c in _codeControllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _currentCode =>
      _codeControllers.map((c) => c.text.trim()).join();

  void _onVerify({bool isMagicLink = false}) async {
    setState(() => _isLoading = true);

    // Simulation de validation réseau
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;

    // Mise à jour du profil utilisateur avec ses vraies coordonnées !
    final userProvider = context.read<UserProvider>();
    userProvider.updateProfile(
      name: widget.name,
      email: widget.email,
      phone: widget.phone.isNotEmpty ? widget.phone : '+33 6 00 00 00 00',
      location: 'Paris, France',
    );

    // Ajout d'une notification de bienvenue personnalisée
    final isFr = context.read<LanguageProvider>().isFrench;
    final firstName = widget.name.trim().split(' ').first;

    context.read<NotificationProvider>().addNotification(
      title: isFr ? 'Bienvenue, $firstName ! 🎉' : 'Welcome, $firstName! 🎉',
      message: isFr
          ? 'Votre e-mail (${widget.email}) a été vérifié avec succès. Votre profil est prêt.'
          : 'Your email (${widget.email}) has been verified successfully. Your profile is ready.',
      type: NotificationType.system,
    );

    setState(() {
      _isLoading = false;
      _isSuccess = true;
    });

    await Future.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;

    // Navigation directe vers l'application principale
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainShell()),
      (route) => false,
    );
  }

  void _resendCode() {
    if (_resendTimerSeconds > 0) return;
    _startResendTimer();

    final isFr = context.read<LanguageProvider>().isFrench;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.mark_email_read_outlined, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                isFr
                    ? 'Un nouvel e-mail de validation a été envoyé à ${widget.email}'
                    : 'A new verification email was sent to ${widget.email}',
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
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 12),

              // Hero Email Icon Badge
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2563EB).withValues(alpha: 0.35),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Center(
                  child: _isSuccess
                      ? const Icon(Icons.check_circle_rounded, color: Colors.white, size: 48)
                      : const Icon(Icons.mark_email_unread_outlined, color: Colors.white, size: 44),
                ),
              ),

              const SizedBox(height: 28),

              // Title
              Text(
                _isSuccess
                    ? (isFr ? 'Compte vérifié !' : 'Account Verified!')
                    : (isFr ? 'Vérifiez votre e-mail' : 'Verify Your Email'),
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 10),

              // Subtitle
              Text(
                isFr
                    ? 'Nous avons envoyé un lien de confirmation et un code de sécurité à :'
                    : 'We sent a confirmation link and security code to:',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              // Email Pill badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.email, size: 16, color: Color(0xFF2563EB)),
                    const SizedBox(width: 8),
                    Text(
                      widget.email,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E40AF),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 36),

              // Code Input Pin Boxes
              Text(
                isFr ? 'Entrez le code à 4 chiffres' : 'Enter 4-digit code',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF475569),
                ),
              ),
              const SizedBox(height: 14),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  return Container(
                    width: 58,
                    height: 64,
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    child: TextField(
                      controller: _codeControllers[index],
                      focusNode: _focusNodes[index],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                      decoration: InputDecoration(
                        counterText: '',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
                        ),
                      ),
                      onChanged: (val) {
                        if (val.isNotEmpty && index < 3) {
                          _focusNodes[index + 1].requestFocus();
                        } else if (val.isEmpty && index > 0) {
                          _focusNodes[index - 1].requestFocus();
                        }
                        if (_currentCode.length == 4) {
                          _onVerify();
                        }
                      },
                    ),
                  );
                }),
              ),

              const SizedBox(height: 24),

              // Button 1: Valider le code saisi
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : () => _onVerify(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Text(
                          isFr ? 'Valider et continuer' : 'Verify & Continue',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 14),

              // Button 2: Simulation directe de validation via lien e-mail
              // (Répond exactement à l'attente de Jacob : "confirmer dans mon mail")
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: InkWell(
                  onTap: _isLoading ? null : () => _onVerify(isMagicLink: true),
                  borderRadius: BorderRadius.circular(14),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.touch_app_outlined, color: Color(0xFF10B981), size: 20),
                        const SizedBox(width: 8),
                        Text(
                          isFr
                              ? 'Confirmer via le lien reçu dans l\'e-mail'
                              : 'Confirm via link in email',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // Hint card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, size: 18, color: Color(0xFF64748B)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        isFr
                            ? 'Pour la démonstration, tapez n\'importe quel code à 4 chiffres (ex: 1234) ou cliquez sur "Confirmer via le lien".'
                            : 'For demo testing, type any 4-digit code (e.g. 1234) or click "Confirm via link".',
                        style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.3),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Resend Timer
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    isFr ? "Vous n'avez pas reçu l'e-mail ? " : "Didn't receive the email? ",
                    style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                  ),
                  GestureDetector(
                    onTap: _resendTimerSeconds == 0 ? _resendCode : null,
                    child: Text(
                      _resendTimerSeconds > 0
                          ? (isFr ? 'Renvoyer (${_resendTimerSeconds}s)' : 'Resend (${_resendTimerSeconds}s)')
                          : (isFr ? 'Renvoyer' : 'Resend'),
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

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

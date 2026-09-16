import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/language_provider.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/service_client.dart';
import '../../../core/services/service_exception.dart';
import '../../../models/user_model.dart';
import '../../rentals/providers/rental_provider.dart';
import 'register_screen.dart';
import '../../../main.dart';

class LoginScreen extends StatefulWidget {
  final String? prefilledEmail;
  const LoginScreen({super.key, this.prefilledEmail});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.prefilledEmail != null && widget.prefilledEmail!.isNotEmpty) {
      _emailController.text = widget.prefilledEmail!;
    }
    _emailController.addListener(_clearError);
    _passwordController.addListener(_clearError);
  }

  void _clearError() {
    if (_errorMessage != null) {
      setState(() => _errorMessage = null);
    }
  }

  @override
  void dispose() {
    _emailController.removeListener(_clearError);
    _passwordController.removeListener(_clearError);
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final enteredEmail = _emailController.text.trim().toLowerCase();
    final enteredPassword = _passwordController.text;
    final isFr = context.read<LanguageProvider>().isFrench;

    // Connexion réelle Firebase Auth & Firestore
    UserModel? userModel;
    try {
      final client = ServiceClient();
      final authService = AuthService(client);
      userModel = await authService.signIn(
        email: enteredEmail,
        password: enteredPassword,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);

      String errorMsg = isFr
          ? 'Mot de passe incorrect ou compte introuvable.'
          : 'Incorrect password or account not found.';

      final errStr = e.toString().toLowerCase();
      String code = '';
      if (e is ServiceException) {
        code = e.code.toLowerCase();
      } else if (e is FirebaseAuthException) {
        code = e.code.toLowerCase();
      }

      if (code == 'wrong-password' ||
          code == 'invalid-credential' ||
          code.contains('wrong') ||
          code.contains('credential') ||
          code.contains('password') ||
          errStr.contains('wrong') ||
          errStr.contains('credential') ||
          errStr.contains('password')) {
        errorMsg = isFr
            ? 'Mot de passe incorrect. Veuillez vérifier votre mot de passe.'
            : 'Incorrect password. Please check your password.';
      } else if (code == 'user-not-found' || errStr.contains('user-not-found') || errStr.contains('no user')) {
        errorMsg = isFr
            ? 'Aucun compte n\'est associé à cet e-mail.'
            : 'No account found with this email.';
      } else if (code == 'invalid-email' || errStr.contains('invalid-email')) {
        errorMsg = isFr
            ? 'Format d\'adresse e-mail invalide.'
            : 'Invalid email address format.';
      } else if (code == 'user-disabled' || errStr.contains('user-disabled')) {
        errorMsg = isFr
            ? 'Ce compte a été désactivé.'
            : 'This account has been disabled.';
      } else if (code == 'too-many-requests' || errStr.contains('too-many-requests')) {
        errorMsg = isFr
            ? 'Trop de tentatives infructueuses. Veuillez patienter un instant.'
            : 'Too many attempts. Please try again in a few moments.';
      } else if (code == 'network-request-failed' || errStr.contains('network')) {
        errorMsg = isFr
            ? 'Problème de connexion réseau. Vérifiez votre connexion internet.'
            : 'Network error. Please check your internet connection.';
      } else if (e is ServiceException && e.message.isNotEmpty) {
        errorMsg = e.message;
      }

      setState(() => _errorMessage = errorMsg);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(child: Text(errorMsg)),
            ],
          ),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return; // STOP! Ne JAMAIS continuer si le mot de passe est incorrect
    }

    if (!mounted) return;

    // Verrou strict : vérifier si l'adresse e-mail a été confirmée
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      try {
        await currentUser.reload();
      } catch (_) {}
      if (!mounted) return;
      final freshUser = FirebaseAuth.instance.currentUser;
      if (freshUser != null && !freshUser.emailVerified) {
        setState(() => _isLoading = false);
        _showEmailNotVerifiedDialog(freshUser);
        return;
      }
    }

    if (enteredEmail.isNotEmpty) {
      final userProvider = context.read<UserProvider>();
      String loadedName = userModel.name;
      String loadedPhone = userModel.phone;
      String loadedLocation = 'Cotonou, Bénin';
      String? avatarPath;
      int? avatarColorHex;

      try {
        final uid = FirebaseAuth.instance.currentUser?.uid;
        if (uid != null) {
          final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
          final data = doc.data();
          if (data != null) {
            final docName = data['name'] as String?;
            if (docName != null && docName.trim().isNotEmpty) {
              loadedName = docName.trim();
            }
            final docPhone = data['phone'] as String?;
            if (docPhone != null && docPhone.trim().isNotEmpty) {
              loadedPhone = docPhone.trim();
            }
            final docLoc = data['location'] as String?;
            if (docLoc != null && docLoc.trim().isNotEmpty) {
              loadedLocation = docLoc.trim();
            }
            avatarPath = data['avatarPath'] as String?;
            final avatarBase64 = data['avatarBase64'] as String?;
            avatarColorHex = data['avatarColorHex'] as int?;

            final currentUid = uid;
            await userProvider.syncUserAvatar(
              currentUid,
              avatarBase64: avatarBase64,
              avatarPath: avatarPath,
            );
          }
        }
      } catch (e) {
        debugPrint('Firestore profile fetch notice: $e');
      }

      if (loadedName.isEmpty) {
        final rawPrefix = enteredEmail.split('@').first;
        if (rawPrefix.contains('.')) {
          loadedName = rawPrefix
              .split('.')
              .map((p) => p.isNotEmpty ? '${p[0].toUpperCase()}${p.substring(1)}' : '')
              .join(' ');
        } else {
          loadedName = userProvider.name.isNotEmpty ? userProvider.name : rawPrefix;
        }
      }

      userProvider.updateProfile(
        name: loadedName,
        email: enteredEmail,
        phone: loadedPhone.isNotEmpty ? loadedPhone : userProvider.phone,
        location: loadedLocation,
      );

      // Si aucun avatar personnalisé, appliquer la couleur de palette si choisie
      if (!userProvider.hasCustomAvatar && avatarColorHex != null) {
        userProvider.setAvatarColor(Color(avatarColorHex));
      }
    }

    if (!mounted) return;
    // Déclencher le rechargement des réservations depuis Firestore
    await context.read<RentalProvider>().onUserLoggedIn();

    if (!mounted) return;
    setState(() => _isLoading = false);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainShell()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final isFr = lang.isFrench;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 48),

                // Logo & Title
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2563EB).withValues(alpha: 0.15),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.asset(
                            'assets/images/logo.png',
                            fit: BoxFit.contain,
                            errorBuilder: (_, _, _) => Container(
                              color: const Color(0xFF2563EB),
                              child: const Icon(
                                Icons.handshake_outlined,
                                color: Colors.white,
                                size: 34,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'RentIt',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        isFr ? 'Bon retour ! Connectez-vous pour continuer' : 'Welcome back! Sign in to continue',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                if (_errorMessage != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFECACA)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.only(top: 1),
                          child: Icon(Icons.error_outline, color: Color(0xFFDC2626), size: 18),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFB91C1C),
                              height: 1.3,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => setState(() => _errorMessage = null),
                          child: const Icon(Icons.close, color: Color(0xFFDC2626), size: 18),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Email field
                Text(
                  isFr ? 'Adresse e-mail' : 'Email Address',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF374151),
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(fontSize: 15, color: Color(0xFF0F172A)),
                  decoration: InputDecoration(
                    hintText: 'jacob@exemple.com',
                    hintStyle: const TextStyle(color: Color(0xFFCBD5E1)),
                    prefixIcon: const Icon(
                      Icons.mail_outline,
                      color: Color(0xFF94A3B8),
                      size: 20,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: Color(0xFF2563EB),
                        width: 2,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFEF4444)),
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return isFr ? "L'e-mail est requis" : 'Email is required';
                    }
                    if (!val.contains('@')) {
                      return isFr ? 'Entrez un e-mail valide' : 'Enter a valid email';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Password field
                Text(
                  isFr ? 'Mot de passe' : 'Password',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF374151),
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: const TextStyle(fontSize: 15, color: Color(0xFF0F172A)),
                  decoration: InputDecoration(
                    hintText: '••••••••',
                    hintStyle: const TextStyle(color: Color(0xFFCBD5E1)),
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      color: Color(0xFF94A3B8),
                      size: 20,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: const Color(0xFF94A3B8),
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: Color(0xFF2563EB),
                        width: 2,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFEF4444)),
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return isFr ? 'Le mot de passe est requis' : 'Password is required';
                    }
                    if (val.length < 6) {
                      return isFr ? '6 caractères minimum' : 'Minimum 6 characters';
                    }
                    return null;
                  },
                ),

                // Forgot password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                    child: Text(
                      isFr ? 'Mot de passe oublié ?' : 'Forgot Password?',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF2563EB),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Sign In Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFF93C5FD),
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
                            isFr ? 'Se connecter' : 'Sign In',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.2,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 28),

                // Divider
                Row(
                  children: [
                    Expanded(
                      child: Container(height: 1, color: const Color(0xFFE2E8F0)),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      child: Text(
                        isFr ? 'ou' : 'or',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF94A3B8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(height: 1, color: const Color(0xFFE2E8F0)),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // Sign Up redirect
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isFr ? "Vous n'avez pas de compte ? " : "Don't have an account? ",
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const RegisterScreen(),
                            ),
                          );
                        },
                        child: Text(
                          isFr ? "S'inscrire" : 'Sign Up',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF2563EB),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEmailNotVerifiedDialog(User user) {
    final isFr = context.read<LanguageProvider>().isFrench;
    final email = user.email ?? _emailController.text.trim();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        bool isResending = false;
        return StatefulBuilder(
          builder: (dialogCtx, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              backgroundColor: Colors.white,
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.mark_email_unread_outlined, color: Color(0xFFD97706), size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isFr ? 'E-mail non confirmé' : 'Email Not Confirmed',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF0F172A)),
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isFr
                        ? 'Votre compte existe, mais votre adresse e-mail n\'a pas encore été confirmée.'
                        : 'Your account exists, but your email has not been confirmed yet.',
                    style: const TextStyle(fontSize: 14, color: Color(0xFF64748B), height: 1.4),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.email_outlined, size: 16, color: Color(0xFF2563EB)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            email,
                            style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF0F172A), fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isFr
                        ? 'Veuillez ouvrir votre boîte mail et cliquer sur le lien reçu pour activer votre compte avant de vous connecter.'
                        : 'Please check your email and click the confirmation link to activate your account before logging in.',
                    style: const TextStyle(fontSize: 13, color: Color(0xFF475569), height: 1.4),
                  ),
                ],
              ),
              actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              actions: [
                TextButton(
                  onPressed: () async {
                    Navigator.pop(ctx);
                    await FirebaseAuth.instance.signOut();
                  },
                  child: Text(
                    isFr ? 'Fermer' : 'Close',
                    style: const TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                  ),
                ),
                ElevatedButton(
                  onPressed: isResending
                      ? null
                      : () async {
                          setDialogState(() => isResending = true);
                          try {
                            await user.sendEmailVerification();
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  isFr
                                      ? 'E-mail de confirmation renvoyé avec succès !'
                                      : 'Confirmation email resent successfully!',
                                ),
                                backgroundColor: const Color(0xFF2563EB),
                              ),
                            );
                          } catch (e) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(isFr ? 'Erreur : $e' : 'Error: $e'),
                                backgroundColor: const Color(0xFFEF4444),
                              ),
                            );
                          } finally {
                            if (dialogCtx.mounted) {
                              setDialogState(() => isResending = false);
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: isResending
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          isFr ? 'Renvoyer l\'e-mail' : 'Resend email',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'register_page.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../navigation/main_navigation.dart'; // <-- hier deine Hauptseite importieren
import 'package:firebase_messaging/firebase_messaging.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = FirebaseAuth.instance;

  bool _loading = false;
  bool _passwordVisible = false;

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _saveFcmToken(String uid) async {
    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null) {
        await FirebaseFirestore.instance.collection('users').doc(uid).set(
          {'fcmToken': fcmToken},
          SetOptions(
            merge: true,
          ), // merge = true, damit bestehende Felder nicht gelöscht werden
        );
      }
    } catch (e) {
      debugPrint('Fehler beim Speichern des FCM-Tokens: $e');
    }
  }

  // -------------------------------
  // LOGIN MIT EMAIL
  // -------------------------------
  Future<void> _loginWithEmail() async {
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty) {
      _showSnackBar('Bitte E-Mail und Passwort eingeben');
      return;
    }
    try {
      setState(() => _loading = true);
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (userCredential.user != null) {
        // 1️⃣ FCM Token speichern
        await _saveFcmToken(userCredential.user!.uid);

        // 2️⃣ Weiterleitung
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) =>
                const MainNavigationPage(initialIndex: 0), // Feed-Tab
          ),
        );
      }
    } on FirebaseAuthException {
      // Fehler bei Login → Snackbar
      _showSnackBar('E-Mail oder Passwort stimmen nicht überein');
    } finally {
      setState(() => _loading = false);
    }
  }

  // -------------------------------
  // LOGIN MIT GOOGLE
  // -------------------------------
  Future<void> _loginWithGoogle() async {
    try {
      final googleSignIn = GoogleSignIn.instance;
      await googleSignIn.initialize();
      final GoogleSignInAccount account = await googleSignIn.authenticate();
      final auth = account.authentication;

      final credential = GoogleAuthProvider.credential(idToken: auth.idToken);

      final userCredential = await _auth.signInWithCredential(credential);

      final displayName = userCredential.user?.displayName?.split(' ');

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
            'firstName': displayName != null && displayName.isNotEmpty
                ? displayName[0]
                : '',
            'lastName': displayName != null && displayName.length > 1
                ? displayName[1]
                : '',
            'email': userCredential.user?.email ?? '',
          }, SetOptions(merge: true));

      if (userCredential.user != null) {
        await _saveFcmToken(userCredential.user!.uid);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) =>
                const MainNavigationPage(initialIndex: 0), // Feed-Tab
          ),
        );
      }
    } catch (e) {
      _showSnackBar('Login mit Google fehlgeschlagen');
    }
  }

  // -------------------------------
  // LOGIN MIT APPLE
  // -------------------------------
  Future<void> _loginWithApple() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: credential.identityToken,
        accessToken: credential.authorizationCode,
      );

      final userCredential = await _auth.signInWithCredential(oauthCredential);

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
            'firstName': credential.givenName ?? '',
            'lastName': credential.familyName ?? '',
            'email': credential.email ?? '',
          }, SetOptions(merge: true));

      if (userCredential.user != null) {
        await _saveFcmToken(userCredential.user!.uid);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) =>
                const MainNavigationPage(initialIndex: 0), // Feed-Tab
          ),
        );
      }
    } catch (e) {
      _showSnackBar('Login mit Apple fehlgeschlagen');
    }
  }

  // -------------------------------
  // PASSWORT ZURÜCKSETZEN
  // -------------------------------
  Future<void> _resetPassword() async {
    if (_emailController.text.trim().isEmpty) {
      _showSnackBar('Bitte E-Mail eingeben');
      return;
    }
    try {
      await _auth.sendPasswordResetEmail(email: _emailController.text.trim());
      _showSnackBar('Passwort-Zurücksetzungslink gesendet');
    } on FirebaseAuthException catch (e) {
      _showSnackBar(e.message ?? 'Fehler beim Zurücksetzen');
    }
  }

  @override
  Widget build(BuildContext context) {
    final buttonColor = Colors.blue.shade700;

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Login',
                style: GoogleFonts.pacifico(
                  fontSize: 36,
                  color: Colors.blue.shade800,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'E-Mail',
                  labelStyle: TextStyle(color: Colors.blue.shade800),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passwordController,
                obscureText: !_passwordVisible,
                decoration: InputDecoration(
                  labelText: 'Passwort',
                  labelStyle: TextStyle(color: Colors.blue.shade800),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _passwordVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.blue.shade800,
                    ),
                    onPressed: () {
                      setState(() {
                        _passwordVisible = !_passwordVisible;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: _resetPassword,
                  child: Text(
                    'Passwort vergessen?',
                    style: TextStyle(
                      color: Colors.blue.shade800,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _loginWithEmail,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Login mit E-Mail',
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              const Divider(thickness: 1.0, color: Colors.black38),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loginWithGoogle,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Login mit Google',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loginWithApple,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Login mit Apple',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const RegisterPage()),
                  );
                },
                child: Text(
                  'Noch kein Konto? Jetzt registrieren',
                  style: TextStyle(
                    color: Colors.blue.shade800,
                    decoration: TextDecoration.underline,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

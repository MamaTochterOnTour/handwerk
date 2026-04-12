import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_page.dart';
import '../pages/kunde_oder_handwerk_page.dart'; // FeedPage import
import 'package:firebase_messaging/firebase_messaging.dart';
import '../rechtliches/nutzungsbedingungen_page.dart';
import '../rechtliches/datenschutz_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmController = TextEditingController();
  final _auth = FirebaseAuth.instance;

  bool _acceptTerms = false;
  bool _loading = false;

  bool _passwordVisible = false;
  bool _passwordConfirmVisible = false;

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _saveFcmToken(String uid) async {
    try {
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null) {
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'fcmToken': fcmToken,
        }, SetOptions(merge: true));
      }
    } catch (e) {
      debugPrint('Fehler beim Speichern des FCM-Tokens: $e');
    }
  }

  bool _validateFields() {
    if (_firstNameController.text.trim().isEmpty ||
        _lastNameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty ||
        _passwordConfirmController.text.isEmpty) {
      _showSnackBar('Bitte alle Felder ausfüllen');
      return false;
    }
    if (_passwordController.text != _passwordConfirmController.text) {
      _showSnackBar('Passwörter stimmen nicht überein');
      return false;
    }
    if (!_acceptTerms) {
      _showSnackBar('Bitte Datenschutz akzeptieren');
      return false;
    }
    return true;
  }

  Future<void> _registerWithEmail() async {
    if (!_validateFields()) return;

    try {
      setState(() => _loading = true);
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
            'firstName': _firstNameController.text.trim(),
            'lastName': _lastNameController.text.trim(),
            'email': _emailController.text.trim(),
            'createdAt': Timestamp.now(),
            'isPremium': false,
          });

      // FCM Token speichern
      await _saveFcmToken(userCredential.user!.uid);

      // Weiterleitung zur FeedPage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const UserTypeSelectionPage()),
      );
    } on FirebaseAuthException catch (e) {
      _showSnackBar(e.message ?? 'Fehler beim Registrieren');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _registerWithGoogle() async {
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
            'createdAt': Timestamp.now(),
            'isPremium': false,
          }, SetOptions(merge: true));

      // FCM Token speichern
      await _saveFcmToken(userCredential.user!.uid);

      // Weiterleitung zur FeedPage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const UserTypeSelectionPage()),
      );
    } catch (e) {
      _showSnackBar('Fehler: $e');
    }
  }

  Future<void> _registerWithApple() async {
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
            'createdAt': Timestamp.now(),
            'isPremium': false,
          }, SetOptions(merge: true));

      // FCM Token speichern
      await _saveFcmToken(userCredential.user!.uid);

      // Weiterleitung zur FeedPage
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const UserTypeSelectionPage()),
      );
    } catch (e) {
      _showSnackBar('Fehler: $e');
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
              // Überschrift
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  'Registrieren',
                  style: GoogleFonts.pacifico(
                    fontSize: 32,
                    color: Colors.blue.shade800,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              TextField(
                controller: _firstNameController,
                decoration: InputDecoration(
                  labelText: 'Vorname',
                  labelStyle: TextStyle(color: Colors.blue.shade800),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _lastNameController,
                decoration: InputDecoration(
                  labelText: 'Nachname',
                  labelStyle: TextStyle(color: Colors.blue.shade800),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
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
              const SizedBox(height: 12),
              TextField(
                controller: _passwordConfirmController,
                obscureText: !_passwordConfirmVisible,
                decoration: InputDecoration(
                  labelText: 'Passwort wiederholen',
                  labelStyle: TextStyle(color: Colors.blue.shade800),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _passwordConfirmVisible
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Colors.blue.shade800,
                    ),
                    onPressed: () {
                      setState(() {
                        _passwordConfirmVisible = !_passwordConfirmVisible;
                      });
                    },
                  ),
                ),
              ),
              Row(
                children: [
                  Checkbox(
                    value: _acceptTerms,
                    onChanged: (value) => setState(() => _acceptTerms = value!),
                  ),
                  Expanded(
                    child: Wrap(
                      children: [
                        const Text('Ich akzeptiere die '),
                        GestureDetector(
                          onTap: () {
                            // Navigation zur Datenschutzerklärung
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const PrivacyPolicyPage(), // deine Datenschutzseite
                              ),
                            );
                          },
                          child: Text(
                            'Datenschutzbestimmungen',
                            style: const TextStyle(
                              decoration: TextDecoration.underline,
                              color: Colors.blue, // visuell als Link erkennbar
                            ),
                          ),
                        ),
                        const Text(' und '),
                        GestureDetector(
                          onTap: () {
                            // Navigation zu den Nutzungsbedingungen
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const TermsOfServicePage(), // deine Nutzungsbedingungen
                              ),
                            );
                          },
                          child: Text(
                            'Nutzungsbedingungen',
                            style: const TextStyle(
                              decoration: TextDecoration.underline,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loading ? null : _registerWithEmail,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Konto erstellen mit E-Mail',
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
                  onPressed: _registerWithGoogle,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Mit Google registrieren',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _registerWithApple,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonColor,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'Mit Apple registrieren',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                  );
                },
                child: Text(
                  'Du hast schon ein Konto? Hier einloggen',
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

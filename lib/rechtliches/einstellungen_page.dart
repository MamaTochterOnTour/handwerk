import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'datenschutz_page.dart';
import 'nutzungsbedingungen_page.dart';
import 'feedback_page.dart';
import 'impressum_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../pages/handwerk_daten_eintragen_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final blueColor = Colors.blue.shade700;

    return Scaffold(
      backgroundColor: Colors.white,

      // 🔹 AppBar
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Einstellungen',
          style: GoogleFonts.pacifico(fontSize: 24, color: blueColor),
        ),
        iconTheme: IconThemeData(color: blueColor),
      ),

      // 🔹 Inhalt
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.data() == null) {
            return const Center(
              child: Text(
                'Keine Benutzerdaten gefunden',
                style: TextStyle(color: Colors.black),
              ),
            );
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final isHandwerk = data['userType'] == 'Handwerk';

          return Padding(
            padding: const EdgeInsets.all(16),
            child: ListView(
              children: [
                // =====================
                // 🔹 KONTO
                // =====================
                Text(
                  'Kontoeinstellungen',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: blueColor,
                  ),
                ),
                const SizedBox(height: 12),

                if (isHandwerk)
                  ListTile(
                    leading: const Icon(Icons.business, color: Colors.black),
                    title: const Text(
                      'Handwerkerprofil bearbeiten',
                      style: TextStyle(color: Colors.black),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const HandwerkerDataPage(),
                        ),
                      );
                    },
                  ),

                // 🔹 Passwort zurücksetzen
                ListTile(
                  leading: Icon(Icons.lock_reset, color: Colors.black),
                  title: const Text(
                    'Passwort zurücksetzen',
                    style: TextStyle(color: Colors.black),
                  ),
                  onTap: () async {
                    final user = FirebaseAuth.instance.currentUser;

                    if (user != null && user.email != null) {
                      await FirebaseAuth.instance.sendPasswordResetEmail(
                        email: user.email!,
                      );
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'E-Mail zum Zurücksetzen wurde gesendet.',
                          ),
                        ),
                      );
                    }
                  },
                ),

                // 🔹 Abmelden
                ListTile(
                  leading: Icon(Icons.logout, color: Colors.black),
                  title: const Text(
                    'Abmelden',
                    style: TextStyle(color: Colors.black),
                  ),
                  onTap: () async {
                    await FirebaseAuth.instance.signOut();
                    if (!context.mounted) return;
                    Navigator.of(
                      context,
                    ).pushNamedAndRemoveUntil('/', (route) => false);
                  },
                ),

                // 🔹 Konto löschen (rot lassen ist richtig UX 👍)
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text(
                    'Konto löschen',
                    style: TextStyle(color: Colors.black),
                  ),
                  onTap: () async {
                    final user = FirebaseAuth.instance.currentUser;
                    if (user == null) return;

                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Konto wirklich löschen?'),
                        content: const Text(
                          'Möchtest du dein Konto wirklich löschen? Dies kann nicht rückgängig gemacht werden. Alle deine Daten werden entfernt.',
                        ),
                        actions: [
                          TextButton(
                            child: const Text('Nein'),
                            onPressed: () => Navigator.pop(context, false),
                          ),
                          ElevatedButton(
                            child: const Text('Ja, löschen'),
                            onPressed: () => Navigator.pop(context, true),
                          ),
                        ],
                      ),
                    );
                    if (confirm != true) return;
                    if (!context.mounted) return;
                    try {
                      // 🔹 Reauthentication
                      if (user.providerData.any(
                        (p) => p.providerId == 'password',
                      )) {
                        final passwordController = TextEditingController();
                        final reauth = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Passwort bestätigen'),
                            content: TextField(
                              controller: passwordController,
                              obscureText: true,
                              decoration: const InputDecoration(
                                labelText: 'Bitte Passwort eingeben',
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Abbrechen'),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Bestätigen'),
                              ),
                            ],
                          ),
                        );
                        if (reauth != true) return;

                        final credential = EmailAuthProvider.credential(
                          email: user.email!,
                          password: passwordController.text.trim(),
                        );
                        await user.reauthenticateWithCredential(credential);
                      } else if (user.providerData.any(
                        (p) => p.providerId == 'google.com',
                      )) {
                        // Google User Reauthentication
                        final googleSignIn = GoogleSignIn.instance;
                        await googleSignIn.initialize();
                        final GoogleSignInAccount account = await googleSignIn
                            .authenticate();
                        final googleAuth = account.authentication;

                        final credential = GoogleAuthProvider.credential(
                          idToken: googleAuth.idToken,
                        );
                        await user.reauthenticateWithCredential(credential);
                      } else if (user.providerData.any(
                        (p) => p.providerId == 'apple.com',
                      )) {
                        final appleCredential =
                            await SignInWithApple.getAppleIDCredential(
                              scopes: [
                                AppleIDAuthorizationScopes.email,
                                AppleIDAuthorizationScopes.fullName,
                              ],
                            );
                        final credential = OAuthProvider("apple.com")
                            .credential(
                              idToken: appleCredential.identityToken,
                              accessToken: appleCredential.authorizationCode,
                            );
                        await user.reauthenticateWithCredential(credential);
                      }

                      // 🔹 Firestore löschen
                      final uid = user.uid;
                      final firestore = FirebaseFirestore.instance;
                      final collections = [
                        'users',
                        'anzeigen',
                        'handwerker',
                        'chat',
                      ];

                      for (var col in collections) {
                        final docs = await firestore
                            .collection(col)
                            .where('userId', isEqualTo: uid)
                            .get();
                        for (var doc in docs.docs) {
                          await doc.reference.delete();
                        }
                      }

                      // 🔹 Firebase Auth löschen
                      await user.delete();
                      if (!context.mounted) return;

                      // 🔹 Navigation zur Login-Seite
                      Navigator.of(
                        context,
                      ).pushNamedAndRemoveUntil('/', (route) => false);
                    } catch (e) {
                      if (!context.mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Fehler beim Löschen des Kontos: ${e.toString()}',
                          ),
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: 24),

                // =====================
                // 🔹 RECHTLICH & HILFE
                // =====================
                Text(
                  'Rechtliches & Hilfe',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: blueColor,
                  ),
                ),
                const SizedBox(height: 12),

                ListTile(
                  title: const Text(
                    'Datenschutzrichtlinien',
                    style: TextStyle(color: Colors.black),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PrivacyPolicyPage(),
                      ),
                    );
                  },
                ),
                ListTile(
                  title: const Text(
                    'Nutzungsbedingungen',
                    style: TextStyle(color: Colors.black),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TermsOfServicePage(),
                      ),
                    );
                  },
                ),
                ListTile(
                  title: const Text(
                    'Kontakt & Feedback',
                    style: TextStyle(color: Colors.black),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ContactFeedbackPage(),
                      ),
                    );
                  },
                ),
                ListTile(
                  title: const Text(
                    'Impressum',
                    style: TextStyle(color: Colors.black),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ImpressumPage()),
                    );
                  },
                ),

                const SizedBox(height: 40),

                // =====================
                // 🔹 VERSION
                // =====================
                Center(
                  child: Text(
                    'App-Version 1.0.0',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

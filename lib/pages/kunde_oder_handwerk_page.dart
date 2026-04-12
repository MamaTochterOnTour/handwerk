import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../navigation/main_navigation.dart';
import 'paywall_page.dart';

class UserTypeSelectionPage extends StatelessWidget {
  const UserTypeSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final buttonColor = Colors.blue.shade700;

    return Scaffold(
      backgroundColor: Colors.white, // Hintergrund weiß
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // vertikal mittig
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Überschrift
              Text(
                'Nutzerart auswählen',
                style: GoogleFonts.pacifico(fontSize: 32, color: buttonColor),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              // Frage
              Text(
                'Bist du ein Kunde oder aus einem handwerklichen Betrieb?',
                style: GoogleFonts.openSans(
                  fontSize: 20,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              // Button Kunde
              // Button Kunde
              SizedBox(
                width: double.infinity,
                child: GestureDetector(
                  onTap: () async {
                    final user = FirebaseAuth.instance.currentUser;
                    if (user != null) {
                      try {
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(user.uid)
                            .set({
                              'userType': 'Kunde', // Nutzerart speichern
                            }, SetOptions(merge: true));
                        if (!context.mounted) return;
                        // Weiterleitung zur MainNavigationPage mit Feed als initialen Tab
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const MainNavigationPage(initialIndex: 0),
                          ),
                        );
                        if (!context.mounted) return;
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Fehler beim Speichern der Nutzerart: $e',
                            ),
                          ),
                        );
                      }
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: buttonColor, // Hintergrundfarbe der Box
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text(
                        'Ich bin Kunde',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Button Handwerker/Betrieb
              SizedBox(
                width: double.infinity,
                child: GestureDetector(
                  onTap: () async {
                    final user = FirebaseAuth.instance.currentUser;
                    if (user != null) {
                      try {
                        // Nutzerart in Firestore setzen
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(user.uid)
                            .set({
                              'userType': 'Handwerk',
                            }, SetOptions(merge: true));
                        if (!context.mounted) return;
                        // Weiterleitung zur Handwerker-Daten-Seite
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const PaywallPage(),
                          ),
                        );
                        if (!context.mounted) return;
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Fehler beim Speichern: $e')),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Kein Benutzer angemeldet'),
                        ),
                      );
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: buttonColor, // Hintergrundfarbe der Box
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: Text(
                        'Ich bin aus einem handwerklichen Betrieb',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
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

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../navigation/main_navigation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/gestures.dart';

class HandwerkerDataPage extends StatefulWidget {
  const HandwerkerDataPage({super.key});

  @override
  State<HandwerkerDataPage> createState() => _HandwerkerDataPageState();
}

class _HandwerkerDataPageState extends State<HandwerkerDataPage> {
  final _formKey = GlobalKey<FormState>();

  // Pflichtfelder
  final _companyNameController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _shortDescriptionController = TextEditingController();
  final _servicesController = TextEditingController();
  final _nifController = TextEditingController(); // ✅ NIF Pflichtfeld

  // Optionale Felder
  final _nieController = TextEditingController(); // ✅ NIE optional
  final _websiteController = TextEditingController();
  final _phoneController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _emailController = TextEditingController();
  final _detailedDescriptionController = TextEditingController();
  final _priceRangeController = TextEditingController();
  final _foundingYearController = TextEditingController();
  final _addressController = TextEditingController();
  final _instagramController = TextEditingController();
  final _facebookController = TextEditingController();
  final _tiktokController = TextEditingController();
  final _openingHoursController = TextEditingController();
  final _specialServicesController = TextEditingController();

  bool _loading = false;

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _saveData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      await FirebaseFirestore.instance.collection('handwerker').doc(uid).set({
        'userId': uid,
        'userType': 'Handwerk',
        'profileReady': false,

        // Pflichtfelder
        'companyName': _companyNameController.text.trim(),
        'fullName': _fullNameController.text.trim(),
        'nif': _nifController.text.trim(), // ✅ Pflichtfeld NIF
        'shortDescription': _shortDescriptionController.text.trim(),
        'services': _servicesController.text.trim(),
        'phone': _phoneController.text.trim(),

        // Optionale Felder
        'nie': _nieController.text.trim(), // ✅ NIE optional
        'website': _websiteController.text.trim(),
        'whatsapp': _whatsappController.text.trim(),
        'email': _emailController.text.trim(),
        'detailedDescription': _detailedDescriptionController.text.trim(),
        'priceRange': _priceRangeController.text.trim(),
        'foundingYear': _foundingYearController.text.trim(),
        'address': _addressController.text.trim(),
        'instagram': _instagramController.text.trim(),
        'facebook': _facebookController.text.trim(),
        'tiktok': _tiktokController.text.trim(),
        'openingHours': _openingHoursController.text.trim(),
        'specialServices': _specialServicesController.text.trim(),

        // Meta
        'submittedAt': Timestamp.now(),
      });

      _showSnackBar('Daten erfolgreich abgeschickt!');

      // kurzer Delay, damit User die Meldung sieht
      await Future.delayed(const Duration(seconds: 2));

      // Weiterleitung zur Main Navigation (Tab 0 = Feed)
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const MainNavigationPage(initialIndex: 0),
        ),
        (route) => false, // entfernt alle vorherigen Seiten
      );
    } catch (e) {
      _showSnackBar('Fehler beim Speichern der Daten: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return Column(
      children: [
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.black),
          decoration: InputDecoration(
            labelText: label,
            labelStyle: const TextStyle(color: Colors.black),
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.black54),
            border: const OutlineInputBorder(),
          ),
          validator: validator,
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final buttonColor = Colors.blue.shade700;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,

        iconTheme: IconThemeData(
          color: Colors.blue.shade700, // 👈 Back-Pfeil in Blauton
        ),

        title: Text(
          'Daten eingeben',
          style: GoogleFonts.pacifico(
            fontSize: 24,
            color: Colors.blue.shade700,
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: GoogleFonts.openSans(
                    fontSize: 14,
                    color: Colors.black,
                  ),
                  children: [
                    const TextSpan(
                      text:
                          'Hier können Handwerksbetriebe ihre Daten eintragen. Aus Sicherheitsgründen prüfen wir alle Einträge, damit keine Fake-Handwerksbetriebe registriert werden. '
                          'Sobald deine Daten abgeschickt sind, erstellen wir in den nächsten 48 Stunden deine Handwerkseite. ',
                    ),
                    TextSpan(
                      text:
                          'Solltest du Änderungswünsche haben, schreibe uns gerne an ',
                    ),
                    TextSpan(
                      text: 'mamatochterontour@outlook.de',
                      style: const TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () async {
                          final Uri emailLaunchUri = Uri(
                            scheme: 'mailto',
                            path: 'mamatochterontour@outlook.de',
                          );
                          if (await canLaunchUrl(emailLaunchUri)) {
                            await launchUrl(emailLaunchUri);
                          } else {
                            if (!context.mounted) return;
                            // Falls der Mail-Client nicht geöffnet werden kann
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'E-Mail konnte nicht geöffnet werden',
                                ),
                              ),
                            );
                          }
                        },
                    ),
                    const TextSpan(text: '.'),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Pflichtfelder
              _buildTextField(
                controller: _companyNameController,
                label: 'Firmenname *',
                validator: (value) =>
                    value!.isEmpty ? 'Bitte Firmenname eingeben' : null,
              ),

              _buildTextField(
                controller: _fullNameController,
                label: 'Ansprechpartner / Vollständiger Name *',
                validator: (value) =>
                    value!.isEmpty ? 'Bitte Namen eingeben' : null,
              ),

              _buildTextField(
                controller: _nifController,
                label: 'NIF-Nummer *',
                hint: 'Pflichtfeld für offizielle Steuer-ID',
                validator: (value) =>
                    value!.isEmpty ? 'Bitte NIF eingeben' : null,
              ),

              _buildTextField(
                controller: _shortDescriptionController,
                label: 'Kurzer Beschreibungstext *',
                validator: (value) =>
                    value!.isEmpty ? 'Bitte kurze Beschreibung eingeben' : null,
              ),

              _buildTextField(
                controller: _emailController,
                label: 'E-Mail-Adresse *',
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Bitte E-Mail-Adresse eingeben'
                    : null,
              ),

              _buildTextField(
                controller: _addressController,
                label: 'Adresse / Standort *',
                hint: 'Mindestens Stadt angeben',
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Bitte Adresse / Standort eingeben'
                    : null,
              ),

              _buildTextField(
                controller: _servicesController,
                label: 'Dienstleistungen / Kategorien *',
                validator: (value) =>
                    value!.isEmpty ? 'Bitte Dienstleistungen angeben' : null,
              ),

              _buildTextField(
                controller: _nieController,
                label: 'NIE-Nummer',
                hint: 'Für ausländische Nutzer, freiwillig',
              ),

              _buildTextField(controller: _websiteController, label: 'Website'),

              _buildTextField(
                controller: _phoneController,
                label: 'Telefonnummer *',
                validator: (value) =>
                    value!.isEmpty ? 'Bitte Telefonnummer eingeben' : null,
              ),

              _buildTextField(
                controller: _whatsappController,
                label: 'WhatsApp',
              ),

              _buildTextField(
                controller: _detailedDescriptionController,
                label: 'Detaillierte Beschreibung / Über uns',
                maxLines: 3,
              ),

              _buildTextField(
                controller: _priceRangeController,
                label: 'Preisspanne',
              ),

              _buildTextField(
                controller: _foundingYearController,
                label: 'Gründungsjahr / Erfahrung',
              ),

              _buildTextField(
                controller: _instagramController,
                label: 'Instagram',
              ),

              _buildTextField(
                controller: _facebookController,
                label: 'Facebook',
              ),

              _buildTextField(controller: _tiktokController, label: 'TikTok'),

              _buildTextField(
                controller: _openingHoursController,
                label: 'Öffnungszeiten',
              ),

              _buildTextField(
                controller: _specialServicesController,
                label: 'Besondere Services / Aktionen',
              ),

              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loading ? null : _saveData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Speichern',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactFeedbackPage extends StatefulWidget {
  const ContactFeedbackPage({super.key});

  @override
  State<ContactFeedbackPage> createState() => _ContactFeedbackPageState();
}

class _ContactFeedbackPageState extends State<ContactFeedbackPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _improvementController = TextEditingController();
  final _featureController = TextEditingController();
  final _questionController = TextEditingController();

  Future<void> _sendEmail() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final improvement = _improvementController.text.trim();
    final feature = _featureController.text.trim();
    final question = _questionController.text.trim();

    // 🔴 Validierung
    if (name.isEmpty || email.isEmpty) {
      _showError('Bitte Name und E-Mail ausfüllen!');
      return;
    }

    if (improvement.isEmpty && feature.isEmpty && question.isEmpty) {
      _showError('Bitte mindestens ein Feld ausfüllen!');
      return;
    }

    final body =
        '''
Name: $name
E-Mail: $email

Verbesserungsvorschläge:
$improvement

Wünsche für die App:
$feature

Sonstige Fragen:
$question
''';

    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'mamatochterontour@outlook.de', // 👈 HIER DEINE MAIL EINTRAGEN
      query: Uri.encodeFull('subject=Kontakt & Feedback&body=$body'),
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      _showError('E-Mail konnte nicht geöffnet werden.');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

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
          'Kontakt & Feedback',
          style: GoogleFonts.pacifico(fontSize: 24, color: blueColor),
        ),
        iconTheme: IconThemeData(color: blueColor),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // 🔹 Text
            const Text(
              'Wir freuen uns auf dich!\n\nDu hast Fragen oder möchtest uns Feedback geben? Dann bist du hier genau richtig.',
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
            const SizedBox(height: 20),

            // 🔹 Name
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.black),
              decoration: const InputDecoration(
                labelText: 'Name *',
                labelStyle: TextStyle(color: Colors.black),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            // 🔹 Email
            TextField(
              controller: _emailController,
              style: const TextStyle(color: Colors.black),
              decoration: const InputDecoration(
                labelText: 'E-Mail *',
                labelStyle: TextStyle(color: Colors.black),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),

            // 🔹 Verbesserung
            TextField(
              controller: _improvementController,
              style: const TextStyle(color: Colors.black),
              decoration: const InputDecoration(
                labelText: 'Verbesserungsvorschläge',
                labelStyle: TextStyle(color: Colors.black),
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 12),

            // 🔹 Wünsche
            TextField(
              controller: _featureController,
              style: const TextStyle(color: Colors.black),
              decoration: const InputDecoration(
                labelText: 'Wünsche für die App',
                labelStyle: TextStyle(color: Colors.black),
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 12),

            // 🔹 Fragen
            TextField(
              controller: _questionController,
              style: const TextStyle(color: Colors.black),
              decoration: const InputDecoration(
                labelText: 'Sonstige Fragen',
                labelStyle: TextStyle(color: Colors.black),
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20),

            // 🔹 Button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: blueColor,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: _sendEmail,
              child: const Text(
                'Absenden',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

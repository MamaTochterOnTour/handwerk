import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Datenschutzerklärung',
          style: GoogleFonts.pacifico(
            fontSize: 24,
            color: Colors.blue.shade700,
          ),
        ),
        iconTheme: IconThemeData(color: Colors.blue.shade700),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Text(
              'Stand: April 2026',
              style: GoogleFonts.openSans(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            Text(
              '1. Verantwortlicher',
              style: GoogleFonts.openSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Verantwortlich für die Datenverarbeitung in dieser App ist: \n\n'
              'MamaTochterOntour\n'
              'Jennifer Weinreich\n'
              'Stettiner Straße 31, 35410 Hungen\n'
              'mamatochterontour@outlook.de\n',
              style: GoogleFonts.openSans(fontSize: 14, color: Colors.black),
            ),
            const SizedBox(height: 16),

            Text(
              '2. Erhebung und Speicherung personenbezogener Daten',
              style: GoogleFonts.openSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Wir erheben personenbezogene Daten, wenn du ein Konto erstellst, '
              'unsere App nutzt oder mit uns kommunizierst. Dazu gehören insbesondere:\n\n'
              '- Vorname, Nachname\n'
              '- E-Mail-Adresse\n'
              '- Passwort (verschlüsselt bei Firebase Auth)\n'
              '- Nutzer-ID (UID) und Profilinformationen\n'
              '- Push-Benachrichtigungs-Token (FCM-Token)\n'
              '- Login-Daten über Google oder Apple',
              style: GoogleFonts.openSans(fontSize: 14, color: Colors.black),
            ),
            const SizedBox(height: 16),

            Text(
              '3. Nutzung der Daten',
              style: GoogleFonts.openSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Die erhobenen Daten werden verwendet für:\n'
              '- Authentifizierung und Kontoverwaltung\n'
              '- Personalisierte Inhalte und Anzeigen\n'
              '- Push-Benachrichtigungen\n'
              '- Verbesserung der App-Funktionen\n'
              '- Kommunikation mit dem Nutzer',
              style: GoogleFonts.openSans(fontSize: 14, color: Colors.black),
            ),
            const SizedBox(height: 16),

            Text(
              '4. Nutzung von Drittanbieterdiensten',
              style: GoogleFonts.openSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Für die Bereitstellung unserer App nutzen wir folgende Dienste:\n\n'
              '- Firebase (Google LLC, USA): Speicherung von Benutzerkonten, '
              'Cloud Firestore-Datenbank, Push-Benachrichtigungen über FCM. \n'
              '- Google Sign-In: Anmeldung über Google-Konto; es werden Name, E-Mail und UID verarbeitet.\n'
              '- Sign in with Apple (Apple Inc., USA): Anmeldung über Apple-ID; es werden Name, E-Mail und UID verarbeitet.\n\n'
              'Die Datenverarbeitung erfolgt ausschließlich zur Nutzung der App-Funktionalitäten. '
              'Details zur Datenverarbeitung der Anbieter siehe deren Datenschutzrichtlinien:\n'
              '- Firebase: https://firebase.google.com/support/privacy\n'
              '- Google: https://policies.google.com/privacy\n'
              '- Apple: https://www.apple.com/legal/privacy/',
              style: GoogleFonts.openSans(fontSize: 14, color: Colors.black),
            ),
            const SizedBox(height: 16),

            Text(
              '5. Weitergabe von Daten',
              style: GoogleFonts.openSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Eine Weitergabe deiner Daten an Dritte erfolgt nur, soweit es für die App-Funktionen notwendig ist oder gesetzlich vorgeschrieben.',
              style: GoogleFonts.openSans(fontSize: 14, color: Colors.black),
            ),
            const SizedBox(height: 16),

            Text(
              '6. Rechte der Nutzer',
              style: GoogleFonts.openSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Du hast jederzeit das Recht auf:\n'
              '- Auskunft über deine gespeicherten Daten\n'
              '- Berichtigung unrichtiger Daten\n'
              '- Löschung deiner Daten\n'
              '- Einschränkung der Verarbeitung\n'
              '- Widerspruch gegen die Verarbeitung\n'
              '- Datenübertragbarkeit\n\n'
              'Zur Ausübung deiner Rechte kontaktiere uns bitte unter den oben angegebenen Kontaktdaten.',
              style: GoogleFonts.openSans(fontSize: 14, color: Colors.black),
            ),
            const SizedBox(height: 16),

            Text(
              '7. Datensicherheit',
              style: GoogleFonts.openSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Wir setzen technische und organisatorische Sicherheitsmaßnahmen ein, um deine Daten vor unbefugtem Zugriff, Verlust oder Manipulation zu schützen.',
              style: GoogleFonts.openSans(fontSize: 14, color: Colors.black),
            ),
            const SizedBox(height: 16),

            Text(
              '8. Änderungen der Datenschutzerklärung',
              style: GoogleFonts.openSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Wir behalten uns das Recht vor, diese Datenschutzerklärung jederzeit zu ändern. '
              'Die aktuelle Version wird in der App angezeigt.',
              style: GoogleFonts.openSans(fontSize: 14, color: Colors.black),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

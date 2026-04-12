import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Nutzungsbedingungen',
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
              '1. Geltungsbereich',
              style: GoogleFonts.openSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Diese Nutzungsbedingungen regeln die Nutzung dieser App. '
              'Mit der Registrierung und Nutzung der App akzeptierst du diese Bedingungen.',
              style: GoogleFonts.openSans(fontSize: 14, color: Colors.black),
            ),
            const SizedBox(height: 16),

            Text(
              '2. Registrierung und Nutzerkonto',
              style: GoogleFonts.openSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Um bestimmte Funktionen der App zu nutzen, musst du ein Konto erstellen. '
              'Du bist verpflichtet, bei der Registrierung wahrheitsgemäße Angaben zu machen und deine Zugangsdaten geheim zu halten. '
              'Für alle Aktivitäten unter deinem Konto bist du verantwortlich.',
              style: GoogleFonts.openSans(fontSize: 14, color: Colors.black),
            ),
            const SizedBox(height: 16),

            Text(
              '3. Inhalte und Nutzung',
              style: GoogleFonts.openSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Du verpflichtest dich, die App nicht für rechtswidrige Zwecke zu nutzen. '
              'Insbesondere dürfen keine Inhalte verbreitet werden, die gegen geltendes Recht, Rechte Dritter oder die guten Sitten verstoßen. '
              'Der Betreiber kann Inhalte entfernen oder Nutzerkonten sperren, wenn Verstöße festgestellt werden.',
              style: GoogleFonts.openSans(fontSize: 14, color: Colors.black),
            ),
            const SizedBox(height: 16),

            Text(
              '4. Datenschutz und Drittanbieter',
              style: GoogleFonts.openSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Wir verwenden zur Bereitstellung der App Dienste von Drittanbietern, '
              'z.B. Firebase (Google), Google Sign-In und Sign in with Apple. '
              'Deine Daten werden gemäß unserer Datenschutzerklärung verarbeitet.\n'
              'Siehe: Datenschutzerklärung in der App.',
              style: GoogleFonts.openSans(fontSize: 14, color: Colors.black),
            ),
            const SizedBox(height: 16),

            Text(
              '5. Haftung',
              style: GoogleFonts.openSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Die Nutzung der App erfolgt auf eigenes Risiko. Wir übernehmen keine Haftung für Schäden, '
              'die durch die Nutzung der App oder der bereitgestellten Inhalte entstehen, soweit dies gesetzlich zulässig ist.',
              style: GoogleFonts.openSans(fontSize: 14, color: Colors.black),
            ),
            const SizedBox(height: 16),

            Text(
              '6. Änderungen der App und Bedingungen',
              style: GoogleFonts.openSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Wir behalten uns das Recht vor, die App jederzeit zu ändern, Funktionen einzustellen oder die Nutzungsbedingungen anzupassen. '
              'Die aktuelle Version wird in der App angezeigt.',
              style: GoogleFonts.openSans(fontSize: 14, color: Colors.black),
            ),
            const SizedBox(height: 16),

            Text(
              '7. Kündigung',
              style: GoogleFonts.openSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Du kannst dein Nutzerkonto jederzeit löschen. '
              'Wir behalten uns das Recht vor, Konten bei Verstößen gegen diese Bedingungen zu sperren oder zu löschen.',
              style: GoogleFonts.openSans(fontSize: 14, color: Colors.black),
            ),
            const SizedBox(height: 16),

            Text(
              '8. Anwendbares Recht',
              style: GoogleFonts.openSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Es gilt das Recht der Bundesrepublik Deutschland unter Ausschluss des UN-Kaufrechts. '
              'Gerichtsstand ist, soweit gesetzlich zulässig, Köln.',
              style: GoogleFonts.openSans(fontSize: 14, color: Colors.black),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

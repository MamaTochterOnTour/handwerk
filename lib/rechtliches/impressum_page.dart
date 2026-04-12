import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ImpressumPage extends StatelessWidget {
  const ImpressumPage({super.key});

  @override
  Widget build(BuildContext context) {
    final blueColor = Colors.blue.shade700;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Impressum',
          style: GoogleFonts.pacifico(fontSize: 24, color: blueColor),
        ),
        iconTheme: IconThemeData(color: blueColor),
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

            // -------------------
            // Anbieter / Verantwortlicher
            // -------------------
            Text(
              '1. Anbieter / Verantwortlicher',
              style: GoogleFonts.openSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'MamaTochterOntour\n'
              'Jennifer Weinreich\n'
              'Stettiner Straße 31, 35410 Hungen\n'
              'Deutschland\n'
              'E-Mail: mamatochterontour@outlook.de',
              style: GoogleFonts.openSans(fontSize: 14, color: Colors.black),
            ),
            const SizedBox(height: 16),

            Text(
              '2. Vertretungsberechtigte Person',
              style: GoogleFonts.openSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Jennifer Weinreich',
              style: GoogleFonts.openSans(fontSize: 14, color: Colors.black),
            ),
            const SizedBox(height: 16),

            Text(
              '3. Umsatzsteuer-Identifikationsnummer',
              style: GoogleFonts.openSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'USt-IdNr. DE441919331',
              style: GoogleFonts.openSans(fontSize: 14, color: Colors.black),
            ),
            const SizedBox(height: 16),

            Text(
              '4. Inhaltlich Verantwortlicher gemäß § 55 Abs. 2 RStV',
              style: GoogleFonts.openSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Jennifer Weinreich\n'
              'Stettiner Straße 31, 35410 Hungen\n'
              'Deutschland\n'
              'E-Mail: mamatochterontour@outlook.de',
              style: GoogleFonts.openSans(fontSize: 14, color: Colors.black),
            ),
            const SizedBox(height: 16),

            Text(
              '5. Haftungsausschluss',
              style: GoogleFonts.openSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Trotz sorgfältiger inhaltlicher Kontrolle übernehmen wir keine Haftung für die Inhalte externer Links. '
              'Für den Inhalt der verlinkten Seiten sind ausschließlich deren Betreiber verantwortlich.',
              style: GoogleFonts.openSans(fontSize: 14, color: Colors.black),
            ),
            const SizedBox(height: 16),

            Text(
              '6. Urheberrecht',
              style: GoogleFonts.openSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Die durch die App erstellten Inhalte und Werke unterliegen dem deutschen Urheberrecht. '
              'Jegliche Vervielfältigung, Bearbeitung, Verbreitung und jede Art der Verwertung außerhalb der Grenzen des Urheberrechts bedürfen der schriftlichen Zustimmung der jeweiligen Autorin.',
              style: GoogleFonts.openSans(fontSize: 14, color: Colors.black),
            ),
            const SizedBox(height: 16),

            Text(
              '7. Support / Kontakt',
              style: GoogleFonts.openSans(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Für Fragen oder technische Probleme kontaktieren Sie bitte:\n'
              'E-Mail: mamatochterontour@outlook.de',
              style: GoogleFonts.openSans(fontSize: 14, color: Colors.black),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

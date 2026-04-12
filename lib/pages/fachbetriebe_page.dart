import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FachbetriebePage extends StatelessWidget {
  const FachbetriebePage({super.key});

  @override
  Widget build(BuildContext context) {
    final blueColor = Colors.blue.shade700;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white, // AppBar jetzt weiß
        centerTitle: true,
        elevation: 0,
        title: Text(
          'Fachbetriebe',
          style: GoogleFonts.pacifico(
            fontSize: 24,
            color: blueColor, // Titel in Blau
          ),
        ),
        iconTheme: IconThemeData(color: blueColor), // Icons auch blau
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'Hier werden zukünftig alle Fachbetriebe angezeigt.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade800),
          ),
        ),
      ),
    );
  }
}

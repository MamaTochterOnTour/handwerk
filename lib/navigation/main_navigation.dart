import 'package:flutter/material.dart';
import '../pages/anzeigen_page.dart'; // Pfad ggf. anpassen
import '../pages/profile_page.dart'; // 👈 dein echter Screen
import '../pages/angebote_page.dart';
import '../pages/fachbetriebe_page.dart';

class MainNavigationPage extends StatefulWidget {
  final int initialIndex; // <-- hier
  const MainNavigationPage({super.key, this.initialIndex = 0}); // Default = 0

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  late int _currentIndex;

  final List<Widget> _pages = const [
    AnzeigenPage(),
    AngebotePage(), // 👈 NEU
    FachbetriebePage(),
    ProfilPage(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex; // initialer Tab
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        selectedItemColor: const Color(0xFF8C77FF),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Anzeigen',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_offer), // 👈 passt perfekt für Angebote
            label: 'Angebote',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.handyman),
            label: 'Fachbetriebe',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }
}

// Entry Point
void main() {
  runApp(
    const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MainNavigationPage(),
    ),
  );
}

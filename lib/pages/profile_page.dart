import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../rechtliches/einstellungen_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../Fachbetriebe/mamatochterontour_page.dart';
import 'handwerk_daten_eintragen_page.dart';
import 'paywall_page.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _userType;
  XFile? _tempImage;

  // 🔥 NEU HINZUFÜGEN
  late Future _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = Future.wait([_getCurrentUserData(), _getHandwerkerDoc()]);
    _loadUserType(); // 🔥 HINZUFÜGEN
  }

  Future<void> _loadUserType() async {
    final uid = _auth.currentUser!.uid;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;

      if (!mounted) return;

      setState(() {
        _userType = (data['userType'] ?? '').toString().trim();
      });
    }
  }

  Future<void> _pickImagePreview() async {
    final picker = ImagePicker();

    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 80,
    );

    if (pickedFile == null) return;

    setState(() {
      _tempImage = pickedFile;
    });

    _showConfirmDialog();
  }

  void _showConfirmDialog() {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Profilbild verwenden?'),
          content: _tempImage != null
              ? Image.file(File(_tempImage!.path))
              : const SizedBox(),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _tempImage = null;
              },
              child: const Text('Abbrechen'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _uploadImage(_tempImage!);
              },
              child: const Text('Speichern'),
            ),
          ],
        );
      },
    );
  }

  Future<DocumentSnapshot> _getCurrentUserData() async {
    final uid = _auth.currentUser!.uid;

    // Versuche zuerst bei 'handwerker', falls nicht vorhanden -> 'users' (Kunden)
    final handwerkerDoc = await _firestore
        .collection('handwerker')
        .doc(uid)
        .get();
    if (handwerkerDoc.exists) return handwerkerDoc;

    return await _firestore.collection('users').doc(uid).get();
  }

  Future<QuerySnapshot> _getHandwerkerDoc() {
    final uid = _auth.currentUser!.uid;

    return _firestore
        .collection('handwerker')
        .where('userId', isEqualTo: uid)
        .get();
  }

  Future<void> _uploadImage(XFile file) async {
    final uid = _auth.currentUser!.uid;

    try {
      final storageRef = FirebaseStorage.instance.ref().child(
        'Users/$uid/profile.jpg',
      );

      await storageRef.putFile(File(file.path));

      final imageUrl = await storageRef.getDownloadURL();

      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'profileImage': imageUrl,
      }, SetOptions(merge: true));

      setState(() {
        _profileFuture = Future.wait([
          _getCurrentUserData(),
          _getHandwerkerDoc(),
        ]);
        _tempImage = null;
      });
    } catch (e) {
      debugPrint('Upload Fehler: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final blueColor = Colors.blue.shade700;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,

        // 🔥 NEU: Diamant links
        leading: IconButton(
          icon: const Icon(Icons.diamond),
          color: blueColor,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PaywallPage()),
            );
          },
        ),

        title: Text(
          'Profil',
          style: GoogleFonts.pacifico(fontSize: 24, color: blueColor),
        ),

        iconTheme: IconThemeData(color: blueColor),

        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            color: blueColor,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(
              child: Text(
                'Keine Profildaten gefunden',
                style: TextStyle(color: Colors.black),
              ),
            );
          }

          final userDoc = snapshot.data![0] as DocumentSnapshot?;
          final handwerkerSnap = snapshot.data![1] as QuerySnapshot?;

          // 🔥 SAFE CHECK
          if (userDoc == null || !userDoc.exists) {
            return const Center(child: Text('User nicht gefunden'));
          }

          final userDataRaw = userDoc.data();
          if (userDataRaw == null) {
            return const Center(child: Text('Userdaten leer'));
          }

          final userData = userDataRaw as Map<String, dynamic>;
          final userType = (userData['userType'] ?? '').toString().trim();

          final hasHandwerkerDoc = handwerkerSnap?.docs.isNotEmpty ?? false;
          final handwerkerData = hasHandwerkerDoc
              ? handwerkerSnap!.docs.first.data() as Map<String, dynamic>
              : null;

          if (userType.toLowerCase() == 'handwerk') {
            final uid = _auth.currentUser!.uid;

            // Spezialfall MamaTochter
            if (uid == 'ML2WYxV5bRfNzL9J5w1AkxmCzgW2') {
              return const MamaTochterOnTourProfilPage();
            }

            // ❌ KEINE Daten eingereicht
            if (!hasHandwerkerDoc) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const HandwerkerDataPage(),
                        ),
                      );
                    },
                    child: Text(
                      'Du hast deine Handwerkerdaten noch nicht eingereicht.\n\n'
                      'Tipp hier, um deine Daten einzureichen und dein Profil freizuschalten.',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: blueColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              );
            }

            // ✔ Daten vorhanden → bisherige Logik
            final profileReady = handwerkerData?['profileReady'] ?? false;

            if (!profileReady) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Deine Profilseite wird gerade gebaut.\n\nAb Einreichung deiner Daten kann dies bis zu 48 Stunden dauern.',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: blueColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            return Center(
              child: Text(
                'Profilseite ist fertig – hier würde das Handwerkerprofil angezeigt werden.',
                style: TextStyle(fontSize: 18, color: blueColor),
                textAlign: TextAlign.center,
              ),
            );
          } else if (userType.toLowerCase() == 'kunde') {
            // Kundenprofil anzeigen
            final firstName = userData['firstName'] ?? '';
            final lastName = userData['lastName'] ?? '';
            final profileImage = userData['profileImage'] ?? '';

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(16),
                              ),
                            ),
                            builder: (_) {
                              return Padding(
                                padding: const EdgeInsets.only(
                                  bottom: 16,
                                  top: 8,
                                  left: 16,
                                  right: 16,
                                ),
                                child: Wrap(
                                  children: [
                                    ListTile(
                                      leading: const Icon(Icons.photo_library),
                                      title: const Text(
                                        'Bild aus Galerie auswählen',
                                      ),
                                      onTap: () {
                                        Navigator.pop(context);
                                        _pickImagePreview();
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.blue.shade700,
                          child: profileImage.isNotEmpty
                              ? ClipOval(
                                  child: Image.network(
                                    profileImage,
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : const Icon(
                                  Icons.person,
                                  size: 40,
                                  color: Colors.white,
                                ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          '$firstName $lastName',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: blueColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Hier erscheinen später deine Favoriten oder Anzeigen.',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            );
          } else {
            return const Center(child: Text('Benutzertyp nicht erkannt.'));
          }
        },
      ),
    );
  }
}

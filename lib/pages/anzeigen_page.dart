import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'paywall_page.dart';

class AnzeigenPage extends StatefulWidget {
  const AnzeigenPage({super.key});

  @override
  State<AnzeigenPage> createState() => _AnzeigenPageState();
}

class _AnzeigenPageState extends State<AnzeigenPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;
  bool _isKunde = false;
  bool _isLoadingUser = true;
  bool _isHandwerk = false;
  bool _isPremium = false;

  @override
  void initState() {
    super.initState();
    _loadUserType();
  }

  Future<void> _loadUserType() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    if (doc.exists) {
      final data = doc.data() as Map<String, dynamic>;

      setState(() {
        _isHandwerk = data['userType'] == 'Handwerk';
        _isKunde = data['userType'] == 'Kunde';
        _isPremium = data['isPremium'] ?? false;
        _isLoadingUser = false;
      });
    }
  }

  void _openAdDetailsBottomSheet(String userId) async {
    // Nutzer-Daten abrufen
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .get();
    if (!userDoc.exists) return;

    final userData = userDoc.data()!;
    final String fullName =
        '${userData['firstName'] ?? ''} ${userData['lastName'] ?? ''}';
    final String email = userData['email'] ?? 'Keine E-Mail';
    final String? profilePicUrl =
        userData['profileImage']; // <-- hier aus Collection "profileImage"

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profilbild links
              CircleAvatar(
                radius: 32, // nicht zu groß
                backgroundColor: profilePicUrl == null || profilePicUrl.isEmpty
                    ? Colors
                          .blue
                          .shade700 // Blauton als Hintergrund
                    : Colors.transparent,
                backgroundImage:
                    profilePicUrl != null && profilePicUrl.isNotEmpty
                    ? NetworkImage(profilePicUrl)
                    : null,
                child: profilePicUrl == null || profilePicUrl.isEmpty
                    ? const Icon(Icons.person, size: 32, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 16),
              // Name + E-Mail rechts
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fullName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () async {
                        final uri = Uri(scheme: 'mailto', path: email);
                        if (await canLaunchUrl(uri)) {
                          await launchUrl(uri);
                        } else {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Konnte Mail-App nicht öffnen.'),
                            ),
                          );
                        }
                      },
                      child: Text(
                        email,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCategoryBottomSheet(void Function(String) onSelected) {
    final List<String> categories = [
      'Bäckerei / Konditorei',
      'Bodenleger / Parkett',
      'Dachdecker',
      'Elektriker',
      'Florist / Gärtnerei',
      'Friseur / Kosmetik',
      'Fliesenleger',
      'Gebäudereinigung / Bauendreinigung',
      'Glasreinigung',
      'Garten- und Landschaftsbau',
      'Heizungsbauer',
      'Klimatechnik',
      'Installateur / Sanitär',
      'Kfz-Reparatur',
      'Maler / Lackierer',
      'Poolreinigung',
      'Tischler',
      'Trockenbauer / Innenausbau',
      'Andere',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        final height = MediaQuery.of(context).size.height * 0.8;
        return SizedBox(
          height: height,
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                height: 4,
                width: 50,
                decoration: BoxDecoration(
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Kategorie auswählen',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  itemCount: categories.length,
                  separatorBuilder: (_, _) => const Divider(),
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    return ListTile(
                      title: Text(
                        cat,
                        style: const TextStyle(color: Colors.black),
                      ),
                      onTap: () {
                        onSelected(cat);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openEditAdSheet(QueryDocumentSnapshot adData) {
    final titleController = TextEditingController(text: adData['title']);
    final descriptionController = TextEditingController(
      text: adData['description'],
    );
    final locationController = TextEditingController(text: adData['location']);
    final otherCategoryController = TextEditingController();
    String category = adData['category'];
    bool isOtherCategory = category == 'Andere';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AnimatedPadding(
              duration: const Duration(milliseconds: 300),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Anzeige bearbeiten',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      TextField(
                        controller: titleController,
                        decoration: const InputDecoration(labelText: 'Titel *'),
                      ),
                      const SizedBox(height: 8),

                      TextField(
                        controller: descriptionController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Beschreibung *',
                        ),
                      ),
                      const SizedBox(height: 8),

                      TextFormField(
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Kategorie *',
                          hintText: category,
                          suffixIcon: const Icon(Icons.arrow_drop_down),
                        ),
                        onTap: () {
                          _showCategoryBottomSheet((selected) {
                            setModalState(() {
                              category = selected;
                              isOtherCategory = category == 'Andere';
                            });
                          });
                        },
                      ),
                      const SizedBox(height: 8),

                      if (isOtherCategory)
                        TextField(
                          controller: otherCategoryController,
                          decoration: const InputDecoration(
                            labelText: 'Eigene Kategorie *',
                          ),
                        ),

                      const SizedBox(height: 8),

                      TextField(
                        controller: locationController,
                        decoration: const InputDecoration(
                          labelText: 'Ort (optional)',
                        ),
                      ),

                      const SizedBox(height: 16),

                      ElevatedButton(
                        onPressed: () async {
                          String finalCategory = isOtherCategory
                              ? otherCategoryController.text.trim()
                              : category;

                          await FirebaseFirestore.instance
                              .collection('anzeigen')
                              .doc(adData.id)
                              .update({
                                'title': titleController.text.trim(),
                                'description': descriptionController.text
                                    .trim(),
                                'category': finalCategory,
                                'location': locationController.text.trim(),
                              });

                          Navigator.pop(context);

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Anzeige aktualisiert!'),
                            ),
                          );
                        },
                        child: const Text('Speichern'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDeleteAd(String adId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Anzeige löschen'),
        content: const Text(
          'Bist du sicher, dass du diese Anzeige löschen möchtest?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Abbrechen'),
          ),

          TextButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('anzeigen')
                  .doc(adId)
                  .delete();

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Anzeige gelöscht!')),
              );
            },
            child: const Text('Löschen', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _openCreateAdSheet() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final locationController = TextEditingController();
    final otherCategoryController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        String category = 'Kategorie auswählen';
        bool isOtherCategory = false;

        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Anzeige erstellen',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Titel
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'Titel *',
                        hintText: 'z.B. Fensterputzer gesucht',
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Beschreibung
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Beschreibung *',
                        hintText: 'z.B. Villa mit 25 Fenstern…',
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 8),

                    // Kategorie
                    TextFormField(
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: 'Kategorie *',
                        hintText: category,
                        suffixIcon: const Icon(Icons.arrow_drop_down),
                      ),
                      onTap: () {
                        _showCategoryBottomSheet((selected) {
                          setModalState(() {
                            category = selected;
                            isOtherCategory = category == 'Andere';
                          });
                        });
                      },
                    ),
                    const SizedBox(height: 8),

                    // Wenn "Andere" ausgewählt → Hinweis + Textfeld für eigene Kategorie
                    if (isOtherCategory) ...[
                      const Text(
                        'Was genau suchst du? Gib hier deine eigene Kategorie ein:',
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                      const SizedBox(height: 4),
                      TextField(
                        controller: otherCategoryController,
                        decoration: const InputDecoration(
                          labelText: 'Eigene Kategorie *',
                          hintText: 'Kategorie eingeben',
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],

                    // Ort (optional)
                    TextField(
                      controller: locationController,
                      decoration: const InputDecoration(
                        labelText: 'Ort (optional)',
                        hintText: 'z.B. Santa Ponsa',
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Speichern-Button
                    ElevatedButton(
                      onPressed: () async {
                        if (titleController.text.trim().isEmpty ||
                            descriptionController.text.trim().isEmpty ||
                            category == 'Kategorie auswählen' ||
                            (isOtherCategory &&
                                otherCategoryController.text.trim().isEmpty)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Bitte alle Pflichtfelder ausfüllen!',
                              ),
                            ),
                          );
                          return;
                        }

                        final uid = FirebaseAuth.instance.currentUser!.uid;
                        String finalCategory = isOtherCategory
                            ? otherCategoryController.text.trim()
                            : category;

                        await FirebaseFirestore.instance
                            .collection('anzeigen')
                            .add({
                              'title': titleController.text.trim(),
                              'description': descriptionController.text.trim(),
                              'category': finalCategory,
                              'location': locationController.text.trim(),
                              'userId': uid,
                              'createdAt': Timestamp.now(),
                            });
                        if (!context.mounted) return;
                        Navigator.pop(context);
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Anzeige erstellt!')),
                        );
                      },
                      child: const Text('Speichern'),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Stream<QuerySnapshot> _getAdsStream() {
    return FirebaseFirestore.instance
        .collection('anzeigen')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final blueColor = Colors.blue.shade700;
    final textColor = Colors.black;
    final subTextColor = Colors.black87;

    if (_isLoadingUser) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // 🔥 PAYWALL LOGIK
    final bool isBlocked = _isHandwerk && !_isPremium;

    if (isBlocked) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock, size: 70, color: Colors.orange),
                const SizedBox(height: 16),
                const Text(
                  "Um diesen Inhalt anzuzeigen, benötigst du ein aktives Premium-Abo.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PaywallPage()),
                    );
                  },
                  child: const Text("Jetzt upgraden"),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // 👉 NORMALER CONTENT AB HIER
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        title: Text(
          'Anzeigen',
          style: GoogleFonts.pacifico(fontSize: 24, color: blueColor),
        ),
        iconTheme: IconThemeData(color: blueColor),
        actions: [
          if (_isKunde)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _openCreateAdSheet,
              color: blueColor,
            ),
        ],
      ),
      body: Column(
        children: [
          // 🔍 Suche
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: _isSearching
                ? Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          autofocus: true,
                          decoration: InputDecoration(
                            hintText: 'Suche...',
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  _isSearching = false;
                                  _searchController.clear();
                                });
                              },
                            ),
                            border: const OutlineInputBorder(),
                          ),
                          onChanged: (_) {
                            setState(() {});
                          },
                        ),
                      ),
                    ],
                  )
                : GestureDetector(
                    onTap: () {
                      setState(() {
                        _isSearching = true;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      height: 48,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
                      ),
                      alignment: Alignment.centerLeft,
                      child: Row(
                        children: [
                          Icon(
                            Icons.search,
                            size: 20,
                            color: Colors.grey.shade700, // 👈 WICHTIG für iOS
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Suche',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),

          // 📄 Feed
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getAdsStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs.where((doc) {
                  final title = doc['title'].toString().toLowerCase();
                  final description = doc['description']
                      .toString()
                      .toLowerCase();
                  final category = doc['category'].toString().toLowerCase();
                  final search = _searchController.text.toLowerCase();
                  return title.contains(search) ||
                      description.contains(search) ||
                      category.contains(search);
                }).toList();

                if (docs.isEmpty) {
                  return Center(
                    child: Text(
                      'Es sind noch keine Anzeigen vorhanden.\nErstelle die erste!',
                      style: TextStyle(color: blueColor, fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    // Mit setState() wird der Stream neu gebaut → Feed aktualisiert sich
                    setState(() {});
                    // Optional: kleiner Delay, damit der Refresh-Indikator sichtbar bleibt
                    await Future.delayed(const Duration(milliseconds: 500));
                  },
                  child: ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (_, index) {
                      final data = docs[index];
                      final Timestamp createdAt = data['createdAt'];
                      final DateTime createdDate = createdAt.toDate();

                      // Datum formatieren
                      final now = DateTime.now();
                      final difference = now.difference(createdDate);
                      String timeText;
                      if (difference.inMinutes < 60) {
                        timeText =
                            'vor ${difference.inMinutes} Minuten veröffentlicht';
                      } else if (difference.inHours < 24) {
                        timeText =
                            'vor ${difference.inHours} Stunden veröffentlicht';
                      } else if (difference.inDays < 8) {
                        timeText =
                            'vor ${difference.inDays} Tagen veröffentlicht';
                      } else {
                        timeText =
                            'Veröffentlicht am ${createdDate.day}.${createdDate.month}.${createdDate.year}';
                      }

                      // Nutzername abrufen
                      return FutureBuilder<DocumentSnapshot>(
                        future: FirebaseFirestore.instance
                            .collection('users')
                            .doc(data['userId'])
                            .get(),
                        builder: (context, userSnapshot) {
                          if (!userSnapshot.hasData ||
                              !userSnapshot.data!.exists) {
                            return const SizedBox(); // oder leeres Card-Placeholder
                          }

                          final userData =
                              userSnapshot.data!.data() as Map<String, dynamic>;

                          final firstName = userData['firstName']?.toString();
                          final lastName = userData['lastName']?.toString();

                          // ❗ wenn irgendwas fehlt → NICHT anzeigen
                          if (firstName == null ||
                              lastName == null ||
                              firstName.isEmpty ||
                              lastName.isEmpty) {
                            return const SizedBox();
                          }

                          final userName = '$firstName $lastName';

                          return InkWell(
                            onTap: () =>
                                _openAdDetailsBottomSheet(data['userId']),
                            child: Card(
                              color: Colors.white,
                              margin: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            data['title'],
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: blueColor,
                                            ),
                                          ),
                                        ),
                                        if (data['userId'] ==
                                            FirebaseAuth
                                                .instance
                                                .currentUser!
                                                .uid)
                                          PopupMenuButton<String>(
                                            icon: const Icon(
                                              Icons.more_vert,
                                              color: Colors.black,
                                            ),
                                            onSelected: (value) {
                                              if (value == 'bearbeiten') {
                                                _openEditAdSheet(data);
                                              } else if (value == 'löschen') {
                                                _confirmDeleteAd(data.id);
                                              }
                                            },
                                            itemBuilder: (_) => const [
                                              PopupMenuItem(
                                                value: 'bearbeiten',
                                                child: Text('Bearbeiten'),
                                              ),
                                              PopupMenuItem(
                                                value: 'löschen',
                                                child: Text('Löschen'),
                                              ),
                                            ],
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Von: $userName',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                        color: Colors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      data['description'],
                                      style: TextStyle(color: textColor),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Kategorie: ${data['category']}',
                                      style: TextStyle(color: subTextColor),
                                    ),
                                    if (data['location'] != null &&
                                        data['location'].toString().isNotEmpty)
                                      Text('Ort: ${data['location']}'),
                                    const SizedBox(height: 8),
                                    Text(
                                      timeText,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';

import 'handwerk_daten_eintragen_page.dart';

class PaywallPage extends StatefulWidget {
  const PaywallPage({super.key});

  @override
  State<PaywallPage> createState() => _PaywallPageState();
}

class _PaywallPageState extends State<PaywallPage> {
  Offering? _offering;
  bool _loading = true;
  bool _isPurchasing = false;
  bool _isPremium = false;
  String _planType = "free";

  final String entitlementId = "all_access";

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _loadOfferings();
    await _loadUserStatus(); // 🔥 NEU
  }

  Future<void> _loadUserStatus() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .get();

    final data = doc.data();

    setState(() {
      _isPremium = data?['isPremium'] ?? false;
      _planType = data?['plan'] ?? "free";
    });
  }

  Future<void> _loadOfferings() async {
    try {
      final offerings = await Purchases.getOfferings();

      setState(() {
        _offering = offerings.current;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  Future<void> _updateUserPremium({
    required bool isPremium,
    required String plan,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    await FirebaseFirestore.instance.collection("users").doc(uid).set({
      "isPremium": isPremium,
      "plan": plan,
      "updatedAt": FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  String _plan(Package p) {
    if (p.packageType == PackageType.annual) return "yearly";
    if (p.packageType == PackageType.monthly) return "monthly";
    return "unknown";
  }

  Future<void> _buy(Package package) async {
    setState(() => _isPurchasing = true);

    try {
      final result = await Purchases.purchase(PurchaseParams.package(package));

      final active =
          result.customerInfo.entitlements.all[entitlementId]?.isActive ??
          false;

      if (active) {
        await Purchases.syncPurchases();

        await _updateUserPremium(isPremium: true, plan: _plan(package));

        if (!mounted) return;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HandwerkerDataPage()),
        );
      }
    } catch (_) {}

    if (!mounted) return;
    setState(() => _isPurchasing = false);
  }

  Future<void> _restore() async {
    try {
      final info = await Purchases.restorePurchases();

      final active = info.entitlements.all[entitlementId]?.isActive ?? false;

      if (active) {
        await Purchases.syncPurchases();
        await _updateUserPremium(isPremium: true, plan: "restored");
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final packages = _offering?.availablePackages ?? [];
    final monthly = packages
        .where((p) => p.packageType == PackageType.monthly)
        .toList();
    final yearly = packages
        .where((p) => p.packageType == PackageType.annual)
        .toList();

    final primaryBlue = const Color(0xFF1E5EFF);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,

        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: Text(
          "Premium für Handwerker",
          style: GoogleFonts.pacifico(color: Colors.black, fontSize: 24),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Mehr Aufträge. Mehr Sichtbarkeit. Mehr Umsatz.",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 15),

                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _isPremium ? Colors.green[50] : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _isPremium ? Icons.verified : Icons.lock,
                          color: _isPremium ? Colors.green : Colors.grey,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _isPremium
                                ? "Aktiver Plan: ${_planType == "yearly"
                                      ? "Jährlich"
                                      : _planType == "monthly"
                                      ? "Monatlich"
                                      : "Premium"}"
                                : "Aktueller Plan: Kostenlos",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _isPremium ? Colors.green : Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    "Werde sichtbar für Kunden in deiner Region und gewinne neue Aufträge.",
                    style: TextStyle(color: Colors.grey),
                  ),

                  const SizedBox(height: 25),

                  _buildFeature("🧾 Erstelle Angebote direkt in der App"),
                  _buildFeature("🔎 Finde ganz einfach neue Kundenanfragen"),
                  _buildFeature("💬 Kunden können dich direkt kontaktieren"),
                  _buildFeature(
                    "🏗️ Automatisches Handwerker-Profil für deinen Betrieb",
                  ),
                  _buildFeature(
                    "📊 Zeige deine Leistungen & Referenzen in der App",
                  ),
                  _buildFeature(
                    "🚫 Keine Preis-Unterbietung durch bessere Sichtbarkeit",
                  ),

                  _buildFeature(
                    "🚫 Keine Preis-Unterbietung durch bessere Sichtbarkeit",
                  ),

                  const SizedBox(height: 20),

                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.warning, color: Colors.orange),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "Für Handwerksbetriebe ist ein aktives Abo erforderlich, um die App vollständig nutzen zu können.",
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  Row(
                    children: [
                      Expanded(
                        child: _buildPackageCard(
                          title: "Monatlich",
                          price: monthly.isNotEmpty
                              ? monthly.first.storeProduct.priceString
                              : "—",
                          badge: null,
                          color: primaryBlue,
                          onTap: monthly.isEmpty || _isPurchasing
                              ? null
                              : () => _buy(monthly.first),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildPackageCard(
                          title: "Jährlich",
                          price: yearly.isNotEmpty
                              ? yearly.first.storeProduct.priceString
                              : "—",
                          badge: "Bester Preis",
                          color: primaryBlue,
                          onTap: yearly.isEmpty || _isPurchasing
                              ? null
                              : () => _buy(yearly.first),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  Center(
                    child: TextButton(
                      onPressed: _restore,
                      child: const Text("Käufe wiederherstellen"),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                          children: [
                            const TextSpan(
                              text: "Mit dem Abonnieren stimmen Sie unserer ",
                            ),

                            TextSpan(
                              text: "Datenschutzerklärung",
                              style: const TextStyle(
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                                fontWeight: FontWeight.w500,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () async {
                                  final url = Uri.parse(
                                    'https://mamatochterontour.com/pages/datenschutzrichtlinie-von-momentry-und-connect',
                                  );

                                  if (await canLaunchUrl(url)) {
                                    await launchUrl(
                                      url,
                                      mode: LaunchMode.externalApplication,
                                    );
                                  }
                                },
                            ),

                            const TextSpan(text: " und den "),

                            TextSpan(
                              text: "Nutzungsbedingungen",
                              style: const TextStyle(
                                color: Colors.blue,
                                decoration: TextDecoration.underline,
                                fontWeight: FontWeight.w500,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () async {
                                  final url = Uri.parse(
                                    'https://www.apple.com/legal/internet-services/itunes/dev/stdeula/',
                                  );

                                  if (await canLaunchUrl(url)) {
                                    await launchUrl(
                                      url,
                                      mode: LaunchMode.externalApplication,
                                    );
                                  }
                                },
                            ),

                            const TextSpan(text: " zu."),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildFeature(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.black, // 👈 FIX
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPackageCard({
    required String title,
    required String price,
    String? badge,
    required Color color,
    required VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withValues(alpha: 0.3)),
          color: Colors.grey[50],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  badge,
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),

            const SizedBox(height: 10),

            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black, // 👈 FIX
              ),
            ),

            const SizedBox(height: 8),

            Text(
              price,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black, // 👈 FIX (statt color)
              ),
            ),

            const SizedBox(height: 15),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: color.withValues(alpha: 0.15),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(color: color),
                ),
                onPressed: onTap,
                child: Text(
                  "Kaufen",
                  style: TextStyle(color: color, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

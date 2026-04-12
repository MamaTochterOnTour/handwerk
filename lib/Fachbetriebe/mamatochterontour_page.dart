import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MamaTochterOnTourProfilPage extends StatelessWidget {
  const MamaTochterOnTourProfilPage({super.key});

  void _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  void _launchEmail(String email) async {
    final Uri emailUri = Uri(scheme: 'mailto', path: email);
    if (!await launchUrl(emailUri)) {
      throw 'Could not launch email $email';
    }
  }

  void _launchWhatsApp(String number) async {
    final uri = Uri.parse('https://wa.me/$number');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch WhatsApp $number';
    }
  }

  @override
  Widget build(BuildContext context) {
    final blueColor = Colors.blue.shade700;
    const profileImageUrl =
        'https://firebasestorage.googleapis.com/v0/b/handwerk-a55fa.firebasestorage.app/o/MamaTochterOnTour%2FLogo.png?alt=media&token=dbffca69-d041-4c3b-96fa-5d5e320c8275';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profilbild + Name
          Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage(profileImageUrl),
                backgroundColor: Colors.grey[200],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'MamaTochterOnTour',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: blueColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Website
          GestureDetector(
            onTap: () => _launchUrl('https://mamatochterontour.de'),
            child: Text(
              'Website: https://mamatochterontour.de',
              style: const TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          const SizedBox(height: 6),
          // Onlineshop
          GestureDetector(
            onTap: () => _launchUrl('https://mamatochterontour.com'),
            child: Text(
              'Onlineshop: https://mamatochterontour.com',
              style: const TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          const SizedBox(height: 6),
          // Social Media
          Row(
            children: [
              GestureDetector(
                onTap: () => _launchUrl(
                  'https://www.tiktok.com/@mamatochterontour?_r=1&_t=ZG-94zXUUlCzce',
                ),
                child: Text(
                  'TikTok',
                  style: const TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => _launchUrl(
                  'https://www.instagram.com/mamatochterontour?igsh=MXkybTVuNnBuNHowaQ%3D%3D&utm_source=qr',
                ),
                child: Text(
                  'Instagram',
                  style: const TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap: () => _launchUrl(
                  'https://youtube.com/@mamatochterontour?si=hBiPIN3HBLSH4Jk_',
                ),
                child: Text(
                  'YouTube',
                  style: const TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () => _launchUrl(
              'https://open.spotify.com/show/291wzQv8KAKkD8t8c4y4UP?si=2Wl48_TWTe6nakNgnLmLHA',
            ),
            child: Text(
              'Podcast',
              style: const TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Voller Name
          Text(
            'Jenny & Katharina Weinreich',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: blueColor,
            ),
          ),
          const SizedBox(height: 6),
          // Short Description
          const Text(
            'Wir programmieren Apps, erstellen Social-Media-Content und unterstützen Unternehmen bei kreativen Kooperationen.',
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(height: 12),
          // Dienstleistungen
          Text(
            'Dienstleistungen:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: blueColor,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            '• Social Media Management & Content-Erstellung\n'
            '• Kooperationen für Restaurants, Spots, Hotels\n'
            '• Videos & App-Entwicklung nach Kundenwunsch',
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(height: 12),
          // E-Mail
          GestureDetector(
            onTap: () => _launchEmail('mamatochterontour@outlook.de'),
            child: Text(
              'E-Mail: mamatochterontour@outlook.de',
              style: const TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          const SizedBox(height: 6),
          // WhatsApp
          GestureDetector(
            onTap: () => _launchWhatsApp('+491786947734'),
            child: Text(
              'WhatsApp: +49 178 6947734',
              style: const TextStyle(
                color: Colors.green,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          const SizedBox(height: 6),
          // Adresse
          const Text(
            'Adresse: Deutschland / Mallorca',
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(height: 6),
          // Preis
          const Text(
            'Preis: verhandelbar',
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(height: 12),
          // Detaillierte Beschreibung
          Text(
            'Detaillierte Beschreibung:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: blueColor,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Wir sind ein Mutter-Tochter-Duo aus Köln, derzeit auf Mallorca. '
            'Jenny (39) und Katharina (21) lieben Reisen und Social Media. '
            'Unser Content fokussiert sich auf Mallorca, und unser Podcast ebenfalls. '
            '2025 haben wir unsere eigene Reise-App entwickelt. '
            'Wir sind offen für Kooperationen mit Unternehmen in der Reisebranche, '
            'z.B. Hotels, Ausflugsanbieter und Autovermietungen.',
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(height: 12),
          // Öffnungszeiten
          Text(
            'Öffnungszeiten:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: blueColor,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Keine festen Öffnungszeiten',
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}

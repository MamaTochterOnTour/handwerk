import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // FlutterFire CLI generiertes File
import 'login/auth_wrapper.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:flutter/foundation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  Purchases.setLogLevel(LogLevel.debug);

  final String revenueCatApiKey = defaultTargetPlatform == TargetPlatform.iOS
      ? 'appl_yUOIFWamRbcLqPWLsKCPhqfACGr'
      : 'goog_vNnHpfdrpaEPrJpDnjLApFfxGcO';

  try {
    await Purchases.configure(PurchasesConfiguration(revenueCatApiKey));
  } catch (e) {
    debugPrint('⚠️ RevenueCat Fehler: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Handwerker App',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(brightness: Brightness.dark),
      themeMode: ThemeMode.system,
      home: const AuthWrapper(),
    );
  }
}

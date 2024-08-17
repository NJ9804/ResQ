import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:googlemap/firebase_options.dart';
import 'package:googlemap/models/alerts.dart';
import 'package:googlemap/models/user_preference.dart';
import 'package:googlemap/pages/alertlist_page.dart';
import 'package:googlemap/pages/map_page.dart';
import 'package:googlemap/services/location_service.dart';
import 'package:googlemap/themes/theme_provider.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => LocationService()),
        ChangeNotifierProvider(create: (context) => Alerts()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
      ],
    child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const AlertlistPage(),
      theme: Provider.of<ThemeProvider>(context).themeData,
    );
  }
}
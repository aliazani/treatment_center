import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:treatment_center/app.dart';
import 'package:treatment_center/features/questionnaire_form/presentation/pages/navigation_page.dart';
import 'package:treatment_center/firebase_options.dart';
import 'injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations - but don't lock (following Flutter best practices)
  // Users can still rotate if they need to, but we prefer portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    await FirebaseAuth.instance.signInAnonymously();
  } catch (e) {
    //
  }

  // Initialize dependency injection
  await di.init();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system; // Follow system theme by default

  void _changeTheme(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WHO FVD Treatment Center Assessment',
      debugShowCheckedModeBanner: false,

      // Use our enhanced WHO themes
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,

      // Responsive home page
      home: MainNavigationPage(
        onThemeChanged: _changeTheme, // Pass theme callback if needed
      ),

      // Support for different screen sizes and orientations
      builder: (context, child) {
        return MediaQuery(
          // Ensure text scaling doesn't break the layout
          data: MediaQuery.of(context).copyWith(
            textScaler: MediaQuery.of(
              context,
            ).textScaler.clamp(minScaleFactor: 0.8, maxScaleFactor: 1.4),
          ),
          child: child!,
        );
      },

      // Handle navigation and routing in a responsive way
      onGenerateRoute: (settings) {
        // You can add custom route handling here if needed
        return null;
      },
    );
  }
}

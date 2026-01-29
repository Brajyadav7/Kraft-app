import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'services/shake_service.dart';
import 'services/notification_handler.dart'; // Required for background isolation

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Ensure the background handler is available to the compiler
  notificationTapBackground; 
  await ShakeDetectionService().initializeNotifications();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KRAFT',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.red,
          brightness: Brightness.light,
        ),
        appBarTheme: AppBarTheme(
          centerTitle: true,
          backgroundColor: Colors.red.shade700,
          foregroundColor: Colors.white,
          elevation: 8,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade700,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 6,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.red.shade700, width: 2),
          ),
        ),
        textTheme: TextTheme(
          headlineSmall: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.red.shade700,
          ),
          titleMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.red.shade700,
          ),
          bodyMedium: TextStyle(fontSize: 14, color: Colors.grey.shade700),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

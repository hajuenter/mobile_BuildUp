import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'services/api_service.dart';
import 'services/session_manager.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'models/user.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<Widget> _getInitialScreen() async {
    await Future.delayed(const Duration(seconds: 10));

    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult.contains(ConnectivityResult.none)) {
      return const SplashScreen();
    }

    final bool apiAlive = await ApiService().isApiAlive();
    if (!apiAlive) {
      return const SplashScreen();
    }

    // Cek apakah user masih login
    final User? user = await SessionManager.getUser();
    final String? token = await SessionManager.getApiKey();

    if (user != null && token != null) {
      return HomeScreen(user: user); // Masuk ke Home jika masih login
    }

    return const LoginScreen(); // Jika belum login, masuk ke Login
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<Widget>(
        future: _getInitialScreen(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SplashScreen();
          } else if (snapshot.hasData) {
            return snapshot.data!;
          } else {
            return const SplashScreen();
          }
        },
      ),
    );
  }
}

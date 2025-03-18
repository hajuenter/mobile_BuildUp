import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shimmer/shimmer.dart';
import '../services/api_service.dart';
import '../services/session_manager.dart';
import '../models/user.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  bool _showShimmer = true; // Indikator shimmer aktif
  double _opacity = 0.0; // Opacity logo biasa

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..forward();

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    // Shimmer berlangsung selama 5 detik
    Future.delayed(const Duration(seconds: 5), () {
      setState(() {
        _showShimmer = false;
      });

      // Logo fade-in setelah shimmer selesai dalam 1 detik
      Future.delayed(const Duration(milliseconds: 300), () {
        setState(() {
          _opacity = 1.0;
        });
      });
    });

    // Setelah 10 detik, pindah ke halaman berikutnya
    Future.delayed(const Duration(seconds: 10), () {
      _startApp();
    });
  }

  Future<void> _startApp() async {
    const int maxRetries = 3;
    int attempt = 0;

    while (attempt < maxRetries) {
      bool apiConnected = await ApiService().isApiAlive();
      if (apiConnected) {
        final User? user = await SessionManager.getUser();
        final String? token = await SessionManager.getApiKey();
        final int? lastLoginTime = await SessionManager.getLastLoginTime();

        if (user != null && token != null && lastLoginTime != null) {
          final int currentTime = DateTime.now().millisecondsSinceEpoch;
          const int twoHours = 60 * 60 * 1000;

          if ((currentTime - lastLoginTime) < twoHours) {
            _navigateTo(HomeScreen(user: user));
          } else {
            await SessionManager.clearSession();
            _navigateTo(const LoginScreen());
          }
        } else {
          _navigateTo(const LoginScreen());
        }
        return;
      } else {
        attempt++;
        await Future.delayed(const Duration(seconds: 3));
      }
    }
  }

  void _navigateTo(Widget page) {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Shimmer effect berjalan selama 5 detik
                if (_showShimmer)
                  Shimmer.fromColors(
                    baseColor: Colors.grey.withAlpha(30),
                    highlightColor: Colors.white.withAlpha(150),
                    period: const Duration(seconds: 2),
                    child: SvgPicture.asset(
                      'assets/logonew.svg',
                      width: MediaQuery.of(context).size.width * 0.4,
                      height: MediaQuery.of(context).size.height * 0.3,
                      fit: BoxFit.contain,
                    ),
                  ),

                // Logo biasa dengan efek fade-in
                AnimatedOpacity(
                  opacity: _opacity,
                  duration: const Duration(seconds: 1),
                  child: SvgPicture.asset(
                    'assets/logonew.svg',
                    width: MediaQuery.of(context).size.width * 0.4,
                    height: MediaQuery.of(context).size.height * 0.3,
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: FadeTransition(
              opacity: _animation,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.copyright, size: 16, color: Colors.black54),
                  SizedBox(width: 5),
                  Text(
                    "2025 B2. All Rights Reserved",
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

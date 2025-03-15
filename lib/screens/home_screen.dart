import 'package:flutter/material.dart';
import '../models/user.dart';
import 'login_screen.dart';
import '../services/session_manager.dart';
import '../widgets/custom_card.dart';
import '../widgets/custom_navigation_bar.dart';
import '../widgets/carousel_slider.dart';
import '../widgets/custom_wide_card.dart';

class HomeScreen extends StatefulWidget {
  final User user;

  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? apiKey;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadApiKey();
  }

  Future<void> _loadApiKey() async {
    final String? key = await SessionManager.getApiKey();

    if (key == null) {
      _logout();
      return;
    }

    setState(() {
      apiKey = key;
    });

    _checkSession();
  }

  Future<void> _checkSession() async {
    final int? lastLoginTime = await SessionManager.getLastLoginTime();

    if (lastLoginTime != null) {
      final int currentTime = DateTime.now().millisecondsSinceEpoch;
      const int twoHours = 2 * 60 * 60 * 1000;

      if ((currentTime - lastLoginTime) > twoHours) {
        _logout();
      }
    }
  }

  Future<void> _logout() async {
    await SessionManager.clearSession();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: _logout,
            tooltip: "Logout",
          ),
        ],
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: const CarouselSliderWidget(),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Selamat datang, ${widget.user.name}!",
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.normal),
              ),
              const SizedBox(height: 8), // Jarak antara teks
              //debug api key
              Text(
                "API Key: ${apiKey ?? 'Tidak ditemukan'}",
                style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.red),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: [
                    CustomCard(
                      title: 'Proses Verifikasi',
                      count: 108,
                      color: Colors.yellow,
                      icon: Icons.home,
                    ),
                    CustomCard(
                      title: 'Terverifikasi',
                      count: 27,
                      color: Colors.blue,
                      icon: Icons.check_circle,
                    ),
                    CustomCard(
                      title: 'Masih Layak Huni',
                      count: 59,
                      color: Colors.red,
                      icon: Icons.home_work,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: CustomWideCard(
                  title: 'Pengajuan',
                  count: 1990,
                  color: Colors.green,
                  icon: Icons.home,
                ),
              ),
              const SizedBox(height: 35),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.blue,
        shape: const CircleBorder(),
        elevation: 4.0,
        child: const Icon(Icons.add, size: 28, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: CustomNavigationBar(
        selectedIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }
}

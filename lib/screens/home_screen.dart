import 'package:flutter/material.dart';
import '../models/user.dart';
import 'login_screen.dart';
import '../services/session_manager.dart';
import '../widgets/custom_card.dart';
import '../widgets/custom_navigation_bar.dart';
import '../widgets/carousel_slider.dart';
import '../widgets/custom_wide_card.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../widgets/dashboard_chart.dart';
import 'profile_screen.dart';
import '../screens/data_and_verifikasi_screen.dart';

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
    // Buat daftar halaman yang bisa ditampilkan di IndexedStack
    final List<Widget> screens = [
      _buildHomeContent(),
      ProfileScreen(user: widget.user),
    ];

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: _selectedIndex == 1
          ? null
          : PreferredSize(
              preferredSize: const Size.fromHeight(145),
              child: _buildAppBar(),
            ),
      body: IndexedStack(
        index: _selectedIndex,
        children: screens,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const DataAndVerifikasiScreen()),
          );
        },
        backgroundColor: const Color(0xFF0D6EFD),
        shape: const CircleBorder(),
        elevation: 4.0,
        child: const Icon(Icons.add, size: 28, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: CustomNavigationBar(
        selectedIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        user: widget.user,
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0D6EFD),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(25),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Row(
                  children: [
                    const Text(
                      'Welcome to ',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    SizedBox(
                      width: 90,
                      child: AnimatedTextKit(
                        repeatForever: true,
                        animatedTexts: [
                          TypewriterAnimatedText(
                            'BuildUp',
                            textStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            speed: const Duration(milliseconds: 250),
                            cursor: '',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.people, color: Colors.white),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DataAndVerifikasiScreen(),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.assignment_turned_in,
                      color: Colors.white),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DataAndVerifikasiScreen(),
                        settings:
                            RouteSettings(arguments: 1), 
                      ),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              height: 45,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(20),
                    blurRadius: 6,
                    spreadRadius: 2,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: Colors.grey.shade600),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      style: const TextStyle(fontSize: 16),
                      decoration: const InputDecoration(
                        hintText: "Cari data penerima...",
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeContent() {
    return SingleChildScrollView(
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
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
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
                  icon: Icons.home,
                ),
                CustomCard(
                  title: 'Masih Layak Huni',
                  count: 59,
                  color: Colors.red,
                  icon: Icons.home,
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
              icon: Icons.volunteer_activism,
            ),
          ),
          DashboardChart(),
          const SizedBox(height: 35),
        ],
      ),
    );
  }
}

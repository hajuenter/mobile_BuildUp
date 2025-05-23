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
import 'package:shimmer/shimmer.dart';
import '../services/api_service.dart';
import '../models/statistik_data_model.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class HomeScreen extends StatefulWidget {
  final User user;

  const HomeScreen({super.key, required this.user});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? apiKey;
  int _selectedIndex = 0;
  bool _isLoading = true; // State untuk loading

  StatistikDataModel? statistikData;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID');
    _loadApiKey();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.delayed(const Duration(seconds: 3));
    try {
      final response = await _apiService.getHomeStatistik();
      if (response.status) {
        setState(() {
          statistikData = response.data;
          _isLoading = false;
        });
      } else {
        // Tangani kasus respons gagal
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal memuat data: ${response.message}')),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Terjadi kesalahan: $e')),
        );
      }
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      _isLoading = true;
    });
    await _loadData();
    return Future.value();
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
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    SizedBox(
                      width: 110,
                      child: AnimatedTextKit(
                        repeatForever: true,
                        animatedTexts: [
                          TypewriterAnimatedText(
                            'NganjukMase',
                            textStyle: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
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
                        settings: RouteSettings(arguments: 1),
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
                  Icon(Icons.calendar_today_rounded,
                      color: Colors.grey.shade600, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      DateFormat('EEEE, dd MMMM yyyy', 'id_ID')
                          .format(DateTime.now()),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
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

  Widget _buildImageSliderSkeleton() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: double.infinity,
        height: 180, // Sesuaikan dengan tinggi CarouselSlider Anda
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // Skeleton untuk CustomCard
  Widget _buildCardSkeleton() {
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth - 44) / 3;

    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: cardWidth,
        height: 155,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // Skeleton untuk CustomWideCard
  Widget _buildWideCardSkeleton() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: double.infinity,
        height: 110,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // Skeleton untuk Chart
  Widget _buildChartSkeleton() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: double.infinity,
        height: 250,
        margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildHomeContent() {
    return RefreshIndicator(
      onRefresh: _refreshData,
      color: Color(0xFF0D6EFD),
      child: SingleChildScrollView(
        physics:
            const AlwaysScrollableScrollPhysics(), // Penting untuk RefreshIndicator
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _isLoading
                    ? _buildImageSliderSkeleton()
                    : const CarouselSliderWidget(),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "Selamat datang, ${widget.user.name}!",
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
            ),
            const SizedBox(height: 16),

            // Cards dengan data aktual dari API
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _isLoading
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildCardSkeleton(),
                        _buildCardSkeleton(),
                        _buildCardSkeleton(),
                      ],
                    )
                  : Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      alignment: WrapAlignment.center,
                      children: [
                        CustomCard(
                          title: 'Proses Verifikasi',
                          count: statistikData?.prosesVerifikasi ?? 0,
                          color: Colors.yellow,
                          icon: Icons.hourglass_top,
                        ),
                        CustomCard(
                          title: 'Terverifikasi',
                          count: statistikData?.terverifikasi ?? 0,
                          color: Colors.blue,
                          icon: Icons.verified,
                        ),
                        CustomCard(
                          title: 'Masih Layak Huni',
                          count: statistikData?.masihLayakHuni ?? 0,
                          color: Colors.red,
                          icon: Icons.home_work,
                        ),
                      ],
                    ),
            ),

            const SizedBox(height: 16),

            // Wide Card dengan data aktual
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _isLoading
                  ? _buildWideCardSkeleton()
                  : CustomWideCard(
                      title: 'Pengajuan',
                      count: statistikData?.pengajuan ?? 0,
                      color: Colors.green,
                      icon: Icons.volunteer_activism,
                    ),
            ),

            // Chart dengan skeleton loading
            _isLoading
                ? _buildChartSkeleton()
                : DashboardChart(statistikData: statistikData),

            const SizedBox(height: 35),
          ],
        ),
      ),
    );
  }
}

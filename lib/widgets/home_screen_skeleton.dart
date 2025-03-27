import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class HomeScreenSkeleton extends StatelessWidget {
  const HomeScreenSkeleton({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildAppBarSkeleton(),
            const SizedBox(height: 20),
            _buildCarouselSkeleton(),
            const SizedBox(height: 20),
            _buildWelcomeTextSkeleton(),
            const SizedBox(height: 16),
            _buildCardsSkeleton(context),
            const SizedBox(height: 16),
            _buildWideCardSkeleton(),
            const SizedBox(height: 16),
            _buildChartSkeleton(),
            const SizedBox(height: 35),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBarSkeleton() {
    return Container(
      height: 145,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF0D6EFD),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildShimmerBox(width: 120, height: 24),
                const Spacer(),
                _buildShimmerCircle(32),
                const SizedBox(width: 8),
                _buildShimmerCircle(32),
              ],
            ),
            const SizedBox(height: 10),
            _buildShimmerBox(
              width: double.infinity,
              height: 45,
              borderRadius: BorderRadius.circular(30),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCarouselSkeleton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: _buildShimmerBox(
        width: double.infinity,
        height: 200,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _buildWelcomeTextSkeleton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: _buildShimmerBox(width: 200, height: 24),
    );
  }

  Widget _buildCardsSkeleton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        alignment: WrapAlignment.center,
        children: List.generate(
          3,
          (_) => _buildCardSkeleton(context),
        ),
      ),
    );
  }

  Widget _buildWideCardSkeleton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: _buildShimmerBox(
        width: double.infinity,
        height: 100,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _buildChartSkeleton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: _buildShimmerBox(
        width: double.infinity,
        height: 250,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _buildCardSkeleton(BuildContext context) {
    return _buildShimmerBox(
      width: (MediaQuery.of(context).size.width - 64) / 2.2,
      height: 100,
      borderRadius: BorderRadius.circular(12),
    );
  }

  Widget _buildShimmerBox({
    required double width,
    required double height,
    BorderRadius? borderRadius,
  }) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius ?? BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildShimmerCircle(double size) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: CircleAvatar(
        radius: size / 2,
        backgroundColor: Colors.white,
      ),
    );
  }
}

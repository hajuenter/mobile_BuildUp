import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DashboardChart extends StatelessWidget {
  const DashboardChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha((255 * 0.1).toInt()),
                  // Menghindari deprecated
                  blurRadius: 5,
                  spreadRadius: 1,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              height: 250,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 5000, // Menyesuaikan batas tertinggi
                  barGroups: [
                    _buildBarGroup(
                        0, 108, Colors.yellow, Icons.hourglass_bottom),
                    _buildBarGroup(1, 27, Colors.blue, Icons.verified),
                    _buildBarGroup(2, 59, Colors.red, Icons.home),
                    _buildBarGroup(3, 1990, Colors.green, Icons.assignment),
                  ],
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.blue, width: 1),
                  ),
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize:
                            50, // Tambah lebar agar angka tidak kepotong
                        interval: 500,
                        getTitlesWidget: (double value, TitleMeta meta) {
                          return Text(
                            NumberFormat("#,###")
                                .format(value.toInt()), // Format angka ribuan
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                            textAlign: TextAlign.right,
                          );
                        },
                      ),
                    ),
                    bottomTitles: const AxisTitles(
                      sideTitles: SideTitles(
                          showTitles:
                              false), // Hilangkan teks agar diganti ikon
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity, // Memastikan scroll bekerja dengan baik
            height: 25, // Sesuaikan tinggi legend
            child: ListView(
              scrollDirection: Axis.horizontal, // Bisa digeser ke samping
              children: [
                _buildLegend(
                    Icons.hourglass_bottom, "Proses Verifikasi", Colors.yellow),
                _buildLegend(Icons.verified, "Terverifikasi", Colors.blue),
                _buildLegend(Icons.home, "Masih Layak Huni", Colors.red),
                _buildLegend(Icons.assignment, "Pengajuan", Colors.green),
              ],
            ),
          ),
        ],
      ),
    );
  }

  BarChartGroupData _buildBarGroup(int x, int y, Color color, IconData icon) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y.toDouble(),
          color: color,
          width: 20,
          borderRadius: BorderRadius.circular(5),
        ),
      ],
    );
  }

  Widget _buildLegend(IconData icon, String text, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 4),
          Text(text, style: const TextStyle(fontSize: 13)),
        ],
      ),
    );
  }
}

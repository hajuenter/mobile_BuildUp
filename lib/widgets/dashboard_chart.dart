import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/statistik_data_model.dart';

class DashboardChart extends StatelessWidget {
  final StatistikDataModel? statistikData;

  const DashboardChart({super.key, required this.statistikData});

  @override
  Widget build(BuildContext context) {
    // Gunakan data dari model statistik, atau nilai default jika null
    final prosesVerifikasi = statistikData?.prosesVerifikasi ?? 0;
    final terverifikasi = statistikData?.terverifikasi ?? 0;
    final masihLayakHuni = statistikData?.masihLayakHuni ?? 0;
    final pengajuan = statistikData?.pengajuan ?? 0;

    // Tetap menggunakan nilai maxY yang sama seperti di chart asli
    const double chartMaxY = 5000;

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
                  maxY: chartMaxY, // Nilai tetap seperti chart asli
                  barGroups: [
                    _buildBarGroup(0, prosesVerifikasi.toDouble(),
                        Colors.yellow, Icons.hourglass_bottom),
                    _buildBarGroup(1, terverifikasi.toDouble(), Colors.blue,
                        Icons.verified),
                    _buildBarGroup(
                        2, masihLayakHuni.toDouble(), Colors.red, Icons.home),
                    _buildBarGroup(3, pengajuan.toDouble(), Colors.green,
                        Icons.assignment),
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
                        reservedSize: 50,
                        interval: 500, // Interval tetap seperti chart asli
                        getTitlesWidget: (double value, TitleMeta meta) {
                          return Text(
                            NumberFormat("#,###").format(value.toInt()),
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
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            height: 25,
            child: ListView(
              scrollDirection: Axis.horizontal,
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

  BarChartGroupData _buildBarGroup(
      int x, double y, Color color, IconData icon) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
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

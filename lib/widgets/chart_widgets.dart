import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../theme/design_tokens.dart';

/// Bar chart for profit by month
class ProfitBarChart extends StatelessWidget {
  final List<String> labels;
  final List<double> data;
  final double height;

  const ProfitBarChart({Key? key, required this.labels, required this.data, this.height = 130}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return SizedBox(height: height, child: const Center(child: Text('No data', style: TextStyle(color: Tok.text3))));
    final maxY = data.fold<double>(0, (m, v) => v.abs() > m ? v.abs() : m) * 1.3;
    return SizedBox(
      height: height,
      child: BarChart(
        BarChartData(
          maxY: maxY,
          minY: data.any((d) => d < 0) ? -maxY : 0,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (_) => const Color(0xF50B1520),
              tooltipBorder: const BorderSide(color: Tok.border2),
              tooltipRoundedRadius: 8,
              getTooltipItem: (group, gi, rod, ri) {
                final v = rod.toY;
                return BarTooltipItem(
                  '${labels[group.x]}\n₹${_fmtNum(v)}',
                  TextStyle(color: v < 0 ? Tok.red2 : Tok.gold2, fontSize: 11, fontWeight: FontWeight.w600),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 36,
                getTitlesWidget: (v, _) => Text(
                  v >= 1000 || v <= -1000 ? '${(v / 1000).round()}k' : v.round().toString(),
                  style: const TextStyle(fontSize: 9, color: Tok.text3),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (v, _) {
                  final i = v.toInt();
                  if (i < 0 || i >= labels.length) return const SizedBox();
                  return Text(labels[i], style: const TextStyle(fontSize: 9, color: Tok.text3));
                },
              ),
            ),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => FlLine(color: const Color(0x66263D58), strokeWidth: 0.5),
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(data.length, (i) {
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: data[i],
                  width: 16,
                  borderRadius: BorderRadius.circular(5),
                  color: data[i] < 0 ? Tok.red : Tok.gold,
                  gradient: LinearGradient(
                    colors: data[i] < 0 ? [Tok.red, Tok.red2] : [Tok.gold, Tok.gold2],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ],
            );
          }),
        ),
        duration: const Duration(milliseconds: 600),
      ),
    );
  }
}

/// Line chart for trends
class TrendLineChart extends StatelessWidget {
  final List<String> labels;
  final List<List<double>> datasets;
  final List<Color> colors;
  final List<String>? legendLabels;
  final double height;

  const TrendLineChart({
    Key? key,
    required this.labels,
    required this.datasets,
    required this.colors,
    this.legendLabels,
    this.height = 140,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (datasets.isEmpty || datasets[0].isEmpty) {
      return SizedBox(height: height, child: const Center(child: Text('No data', style: TextStyle(color: Tok.text3))));
    }
    double maxY = 0;
    for (final ds in datasets) {
      for (final v in ds) {
        if (v > maxY) maxY = v;
      }
    }
    maxY *= 1.2;

    return Column(
      children: [
        if (legendLabels != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(legendLabels!.length, (i) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 10, height: 3, color: colors[i]),
                    const SizedBox(width: 4),
                    Text(legendLabels![i], style: const TextStyle(fontSize: 9, color: Tok.text3)),
                  ],
                ),
              )),
            ),
          ),
        SizedBox(
          height: height,
          child: LineChart(
            LineChartData(
              maxY: maxY,
              minY: 0,
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) => const Color(0xF50B1520),
                  tooltipBorder: const BorderSide(color: Tok.border2),
                  tooltipRoundedRadius: 8,
                ),
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 36,
                    getTitlesWidget: (v, _) => Text(
                      v >= 1000 ? '${(v / 1000).round()}k' : v.round().toString(),
                      style: const TextStyle(fontSize: 9, color: Tok.text3),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: labels.length > 6 ? 2 : 1,
                    getTitlesWidget: (v, _) {
                      final i = v.toInt();
                      if (i < 0 || i >= labels.length) return const SizedBox();
                      return Text(labels[i], style: const TextStyle(fontSize: 9, color: Tok.text3));
                    },
                  ),
                ),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (_) => FlLine(color: const Color(0x66263D58), strokeWidth: 0.5),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: List.generate(datasets.length, (di) {
                return LineChartBarData(
                  spots: List.generate(datasets[di].length, (i) => FlSpot(i.toDouble(), datasets[di][i])),
                  isCurved: true,
                  curveSmoothness: 0.4,
                  color: colors[di],
                  barWidth: 2,
                  dotData: FlDotData(show: true, getDotPainter: (_, __, ___, ____) =>
                    FlDotCirclePainter(radius: 2, color: colors[di], strokeColor: Colors.transparent)),
                  belowBarData: di == 0 ? BarAreaData(show: true, color: colors[di].withOpacity(0.08)) : null,
                );
              }),
            ),
            duration: const Duration(milliseconds: 600),
          ),
        ),
      ],
    );
  }
}

String _fmtNum(double v) {
  final abs = v.abs();
  if (abs >= 100000) return '${(v / 100000).toStringAsFixed(1)}L';
  if (abs >= 1000) return '${(v / 1000).toStringAsFixed(1)}K';
  return v.round().toString();
}

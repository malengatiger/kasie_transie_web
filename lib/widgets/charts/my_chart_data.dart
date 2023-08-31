import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../utils/functions.dart';

class MyChartData {
  static LineChartData getData(
      {required List<Color> colors, required List<FlSpot> spots}) {
    pp('\n🔴 MyChartData: will return LineChartData ...'
        ' spots: ${spots.length} colors: ${colors.length}');
    var total = 0.0;
    var maxY = 0.0;
    for (var value in spots) {
      total += value.y;
      if (value.y > maxY) {
        maxY = value.y;
      }
    }
    final avg = maxY / spots.length;
    pp('🔴 MyChartData: returning LineChartData ... maxY: $maxY avg: $avg total: $total');
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 4,
        verticalInterval: 4,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: colors.first,
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: colors.last,
            strokeWidth: 1,
          );
        },
      ),
      // titlesData: FlTitlesData(
      //   show: true,
      //   rightTitles: const AxisTitles(
      //     sideTitles: SideTitles(showTitles: true),
      //   ),
      //   topTitles:  AxisTitles(
      //     sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta){
      //       return SideTitleWidget(child: Text('Title'), axisSide: meta.axisSide);
      //     }),
      //   ),
      //   bottomTitles: AxisTitles(
      //     sideTitles: SideTitles(
      //       showTitles: true,
      //       reservedSize: 30,
      //       interval: 1,
      //       getTitlesWidget: (value, meta) {
      //         return bottomTitleWidgets(value, meta, spots);
      //       },
      //     ),
      //   ),
      //   leftTitles: AxisTitles(
      //     sideTitles: SideTitles(
      //       showTitles: true,
      //       interval: 1,
      //       getTitlesWidget: (double value, TitleMeta meta) {
      //         return leftTitleWidgets(value, meta, avg);
      //       },
      //       reservedSize: 42,
      //     ),
      //   ),
      // ),
      // borderData: FlBorderData(
      //   show: true,
      //   border: Border.all(color: const Color(0xff37434d)),
      // ),
      minX: 0,
      maxX: 24,
      minY: 0,
      maxY: maxY,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          gradient: LinearGradient(
            colors: gradientColors,
          ),
          barWidth: 2,
          isStrokeCapRound: true,
          dotData: const FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: gradientColors
                  .map((color) => color.withOpacity(0.3))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }

  static Widget bottomTitleWidgets(
      double value, TitleMeta meta, List<FlSpot> spots) {
    pp('🔵 ... bottomTitleWidgets: value: $value meta: max: ${meta.max} '
        'min: ${meta.min} spots: ${spots.length} axis: ${meta.axisSide.name}  ${meta.axisSide.index}');
    const style = TextStyle(
      fontWeight: FontWeight.normal,
      fontSize: 12,
    );
    if (value > 23) {
      return gapH16;
    }
    late Widget text;
    text = Text('${spots.elementAt(value.toInt()).x}', style: style,);

    // return SideTitleWidget(
    //   axisSide: meta.axisSide,
    //   child: text,
    // );
    return gapH32;
  }

  static Widget leftTitleWidgets(double value, TitleMeta meta, double average) {
    pp('🔴 ... leftTitleWidgets: value: $value meta: max: ${meta.max} '
        'min: ${meta.min} average: $average');
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 15,
    );
    late String text;
    var v = (value * average).round().toStringAsFixed(0);
    switch (value) {
      default:
        return gapW32;
    }
  }

  static List<Color> gradientColors = [
    Colors.purpleAccent,
    Colors.amber,
  ];
}

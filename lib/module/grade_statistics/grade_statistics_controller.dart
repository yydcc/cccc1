import 'package:cccc1/common/utils/http.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:cccc1/model/grade_statistics_model.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
class GradeStatisticsController extends GetxController {





  final RxList<GradeStatistics> _allStatistics = <GradeStatistics>[].obs;
  List<GradeStatistics> get statistics => _filteredStatistics;
  final http = HttpUtil();
  final RxBool isLoading = true.obs;
  final RxInt filterType = 0.obs; // 0: 全部, 1: 作业, 2: 测验
  final int classId;
  final int studentId;

  GradeStatisticsController({
    required this.classId,
    required this.studentId
  });
  // 获取筛选后的数据
  List<GradeStatistics> get _filteredStatistics {
    if (filterType.value == 0) return _allStatistics;
    if (filterType.value == 1) return _allStatistics.where((stat) => !stat.isInClass).toList();
    return _allStatistics.where((stat) => stat.isInClass).toList();
  }

  @override
  void onInit() {
    super.onInit();
    fetchData();
    // 监听筛选类型变化
    ever(filterType, (_) => update());
  }

  Future<void> fetchData() async {
    try {
      isLoading.value = true;
      final response = await http.get("/statistics/grades",
        queryParameters: {
          "classId": classId,
          "studentId": studentId,
        }
      );

      if (response.data != null) {
        final list = (response.data as List)
            .map((item) => GradeStatistics.fromJson(item))
            .toList();
        list.sort((a, b) => a.createTime.compareTo(b.createTime));
        _allStatistics.value = list;
        update(); // 确保视图更新
      }
    } catch (e) {
      debugPrint('获取数据失败: $e');
    } finally {
      isLoading.value = false;
    }
  }

  double get averageScore {
    final currentStats = statistics;
    if (currentStats.isEmpty) return 0.0;
    return currentStats.map((e) => e.score).reduce((a, b) => a + b) / currentStats.length;
  }

  double get maxScore {
    final currentStats = statistics;
    if (currentStats.isEmpty) return 0.0;
    return currentStats.map((e) => e.score).reduce((a, b) => a > b ? a : b);
  }

  double get minScore {
    final currentStats = statistics;
    if (currentStats.isEmpty) return 0.0;
    return currentStats.map((e) => e.score).reduce((a, b) => a < b ? a : b);
  }

  LineChartData getLineChartData() {
    if (statistics.isEmpty) {
      return LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineBarsData: [],
      );
    }

    final spots = statistics.map((stat) {
      final index = statistics.indexOf(stat).toDouble();
      return FlSpot(index, stat.score);
    }).toList();

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: 20,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colors.grey.withOpacity(0.2),
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: (value, meta) {
              if (value.toInt() >= 0 && value.toInt() < statistics.length) {
                return Padding(
                  padding: EdgeInsets.only(top: 8.h),
                  child: Text(
                    statistics[value.toInt()].title.length > 6
                        ? statistics[value.toInt()].title.substring(0, 6) + '...'
                        : statistics[value.toInt()].title,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 10.sp,
                    ),
                  ),
                );
              }
              return const Text('');
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 20,
            reservedSize: 40,
            getTitlesWidget: (value, meta) {
              return Text(
                value.toInt().toString(),
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 10.sp,
                ),
              );
            },
          ),
        ),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: false),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          curveSmoothness: 0.35,
          gradient: const LinearGradient(
            colors: [Colors.blue, Colors.blueAccent],
          ),
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 4,
                color: Colors.white,
                strokeWidth: 2,
                strokeColor: Colors.blue,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                Colors.blue.withOpacity(0.2),
                Colors.blue.withOpacity(0.0),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          tooltipBgColor: Colors.blueAccent,
          getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
            return touchedBarSpots.map((barSpot) {
              return LineTooltipItem(
                '${statistics[barSpot.x.toInt()].title}\n',
                TextStyle(
                  color: Colors.white,
                  fontSize: 12.sp,
                ),
                children: [
                  TextSpan(
                    text: '分数: ${barSpot.y.toStringAsFixed(1)}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              );
            }).toList();
          },
        ),
      ),
    );
  }

  BarChartData getDistributionChartData(GradeStatistics stat) {
    final List<BarChartGroupData> barGroups = [];
    final intervals = ['0-60', '60-70', '70-80', '80-90', '90-100'];
    
    // 如果分布数据为空，创建一个全零的分布
    final distribution = stat.distribution.isEmpty 
        ? List<int>.filled(5, 0) 
        : stat.distribution;
    
    for (int i = 0; i < distribution.length; i++) {
      final double x = i.toDouble();
      final double y = distribution[i].toDouble();
      
      // 判断当前成绩所在区间
      bool isCurrentScoreInterval = false;
      if (i == 0 && stat.score < 60) isCurrentScoreInterval = true;
      else if (i == 1 && stat.score >= 60 && stat.score < 70) isCurrentScoreInterval = true;
      else if (i == 2 && stat.score >= 70 && stat.score < 80) isCurrentScoreInterval = true;
      else if (i == 3 && stat.score >= 80 && stat.score < 90) isCurrentScoreInterval = true;
      else if (i == 4 && stat.score >= 90) isCurrentScoreInterval = true;

      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: y,
              color: isCurrentScoreInterval ? Colors.red : Colors.blue,
              width: 20,
            ),
          ],
        ),
      );
    }

    return BarChartData(
      gridData: FlGridData(show: false),
      titlesData: FlTitlesData(
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              return Text(
                intervals[value.toInt()],
                style: const TextStyle(fontSize: 10),
              );
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
          ),
        ),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(show: false),
      barGroups: barGroups,
    );
  }

  String? getScoreTrend() {
    final currentStats = statistics;
    if (currentStats.length < 2) return null;
    
    final lastScore = currentStats.first.score;
    final previousScore = currentStats[1].score;
    final difference = lastScore - previousScore;
    
    if (difference > 0) {
      return '+${difference.toStringAsFixed(1)}';
    } else if (difference < 0) {
      return difference.toStringAsFixed(1);
    }
    return null;
  }
} 
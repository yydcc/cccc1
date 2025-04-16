import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:cccc1/model/grade_statistics_model.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
class GradeStatisticsController extends GetxController {

  final RxList<GradeStatistics> _allStatistics = <GradeStatistics>[].obs;
  List<GradeStatistics> get statistics => _filteredStatistics;
  
  final RxBool isLoading = true.obs;
  final RxInt filterType = 0.obs; // 0: 全部, 1: 作业, 2: 测验

  // 获取筛选后的数据
  List<GradeStatistics> get _filteredStatistics {
    if (filterType.value == 0) return _allStatistics;
    if (filterType.value == 1) return _allStatistics.where((stat) => !stat.isQuiz).toList();
    return _allStatistics.where((stat) => stat.isQuiz).toList();
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
      // 模拟网络延迟
      await Future.delayed(const Duration(seconds: 1));
      
      // 模拟数据
      final mockData = [
        GradeStatistics(
          assignmentId: 1,
          title: '第一次作业',
          score: 85.5,
          averageScore: 78.3,
          maxScore: 95.0,
          minScore: 60.0,
          isQuiz: false,
          createTime: '2024-03-01',
          distribution: [3, 8, 15, 12, 5], // 各分数段人数分布
        ),
        GradeStatistics(
          assignmentId: 2,
          title: '第一次测验',
          score: 92.0,
          averageScore: 82.5,
          maxScore: 98.0,
          minScore: 65.0,
          isQuiz: true,
          createTime: '2024-03-05',
          distribution: [2, 5, 12, 18, 8],
        ),
        GradeStatistics(
          assignmentId: 3,
          title: '第二次作业',
          score: 88.5,
          averageScore: 80.0,
          maxScore: 96.0,
          minScore: 62.0,
          isQuiz: false,
          createTime: '2024-03-10',
          distribution: [2, 6, 14, 15, 6],
        ),
        GradeStatistics(
          assignmentId: 4,
          title: '第二次测验',
          score: 90.0,
          averageScore: 83.5,
          maxScore: 97.0,
          minScore: 68.0,
          isQuiz: true,
          createTime: '2024-03-15',
          distribution: [1, 4, 13, 16, 9],
        ),
        GradeStatistics(
          assignmentId: 5,
          title: '第三次作业',
          score: 94.5,
          averageScore: 85.0,
          maxScore: 98.0,
          minScore: 70.0,
          isQuiz: false,
          createTime: '2024-03-20',
          distribution: [0, 3, 10, 18, 12],
        ),
        GradeStatistics(
          assignmentId: 6,
          title: '期中测验',
          score: 87.5,
          averageScore: 81.0,
          maxScore: 96.0,
          minScore: 63.0,
          isQuiz: true,
          createTime: '2024-03-25',
          distribution: [2, 7, 15, 14, 7],
        ),
      ];

      // 按时间倒序排列
      mockData.sort((a, b) => b.createTime.compareTo(a.createTime));
      
      // 更新数据
      _allStatistics.value = mockData;
    } catch (e) {
      Get.snackbar('错误', '获取数据失败');
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
    
    for (int i = 0; i < stat.distribution.length; i++) {
      final double x = i.toDouble();
      final double y = stat.distribution[i].toDouble();
      
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
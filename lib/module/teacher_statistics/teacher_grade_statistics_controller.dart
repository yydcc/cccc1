import 'package:cccc1/common/utils/http.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:cccc1/model/grade_statistics_model.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TeacherGradeStatisticsController extends GetxController {
  final RxList<GradeStatistics> _allStatistics = <GradeStatistics>[].obs;
  List<GradeStatistics> get statistics => _filteredStatistics;
  final http = HttpUtil();
  final RxBool isLoading = true.obs;
  final RxInt filterType = 0.obs; // 0: 全部, 1: 作业, 2: 测验
  final int classId;

  TeacherGradeStatisticsController({
    required this.classId,
  });

  List<GradeStatistics> get _filteredStatistics {
    if (filterType.value == 0) return _allStatistics;
    if (filterType.value == 1) return _allStatistics.where((stat) => !stat.isInClass).toList();
    return _allStatistics.where((stat) => stat.isInClass).toList();
  }

  @override
  void onInit() {
    super.onInit();
    fetchData();
    ever(filterType, (_) => update());
  }

  Future<void> fetchData() async {
    try {
      isLoading.value = true;
      final response = await http.get("/statistics/class-grades",
        queryParameters: {
          "classId": classId,
        }
      );

      if (response.data != null) {
        final list = (response.data as List)
            .map((item) => GradeStatistics.fromJson(item))
            .toList();
        list.sort((a, b) => a.createTime.compareTo(b.createTime));
        _allStatistics.value = list;
        update();
      }
    } catch (e) {
      debugPrint('获取数据失败: $e');
    } finally {
      isLoading.value = false;
    }
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
          spots: statistics.map((stat) {
            final index = statistics.indexOf(stat).toDouble();
            return FlSpot(index, stat.averageScore);
          }).toList(),
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
        LineChartBarData(
          spots: statistics.map((stat) {
            final index = statistics.indexOf(stat).toDouble();
            return FlSpot(index, stat.maxScore);
          }).toList(),
          isCurved: true,
          curveSmoothness: 0.35,
          gradient: const LinearGradient(
            colors: [Colors.green, Colors.greenAccent],
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
                strokeColor: Colors.green,
              );
            },
          ),
        ),
        LineChartBarData(
          spots: statistics.map((stat) {
            final index = statistics.indexOf(stat).toDouble();
            return FlSpot(index, stat.minScore);
          }).toList(),
          isCurved: true,
          curveSmoothness: 0.35,
          gradient: const LinearGradient(
            colors: [Colors.red, Colors.redAccent],
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
                strokeColor: Colors.red,
              );
            },
          ),
        ),
      ],
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          tooltipBgColor: Colors.blueAccent,
          getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
            return touchedBarSpots.map((barSpot) {
              final stat = statistics[barSpot.x.toInt()];
              String label = '';
              if (barSpot.barIndex == 0) label = '平均分';
              else if (barSpot.barIndex == 1) label = '最高分';
              else label = '最低分';
              
              return LineTooltipItem(
                '${stat.title}\n',
                TextStyle(
                  color: Colors.white,
                  fontSize: 12.sp,
                ),
                children: [
                  TextSpan(
                    text: '$label: ${barSpot.y.toStringAsFixed(1)}',
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

  PieChartData getDistributionChartData(GradeStatistics stat) {
    final intervals = ['0-60', '60-70', '70-80', '80-90', '90-100'];
    final colors = [
      Colors.red,
      Colors.orange,
      Colors.yellow,
      Colors.lightGreen,
      Colors.green,
    ];

    // 如果分布数据为空，创建一个全零的分布
    final distribution = stat.distribution.isEmpty 
        ? List<int>.filled(5, 0) 
        : stat.distribution;

    return PieChartData(
      sections: List.generate(distribution.length, (index) {
        return PieChartSectionData(
          value: distribution[index].toDouble(),
          title: '${intervals[index]}\n${distribution[index]}人',
          color: colors[index],
          radius: 100,
          titleStyle: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        );
      }),
      sectionsSpace: 2,
      centerSpaceRadius: 40,
    );
  }
} 
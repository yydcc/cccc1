import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:cccc1/model/grade_statistics_model.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'teacher_grade_statistics_controller.dart';
class TeacherGradeStatisticsView extends GetView<TeacherGradeStatisticsController> {
  const TeacherGradeStatisticsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          '班级成绩统计',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfoDialog(),
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF5F6FA),
      body: SafeArea(
        child: Column(
          children: [
            _buildFilterSection(),
            Expanded(
              child: Obx(
                () => controller.isLoading.value
                    ? const Center(child: CircularProgressIndicator())
                    : RefreshIndicator(
                        onRefresh: () => controller.fetchData(),
                        child: ListView(
                          padding: EdgeInsets.all(16.w),
                          children: [
                            _buildScoreTrendChart(),
                            SizedBox(height: 16.h),
                            _buildLegend(),
                            SizedBox(height: 16.h),
                            _buildAssignmentList(),
                          ],
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '筛选类型',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: Obx(() => SegmentedButton<int>(
                  segments: [
                    ButtonSegment(
                      value: 0,
                      label: Text('全部', style: TextStyle(fontSize: 13.sp)),
                      icon: Icon(Icons.all_inclusive, size: 18.sp),
                    ),
                    ButtonSegment(
                      value: 1,
                      label: Text('作业', style: TextStyle(fontSize: 13.sp)),
                      icon: Icon(Icons.assignment, size: 18.sp),
                    ),
                    ButtonSegment(
                      value: 2,
                      label: Text('测验', style: TextStyle(fontSize: 13.sp)),
                      icon: Icon(Icons.quiz, size: 18.sp),
                    ),
                  ],
                  selected: {controller.filterType.value},
                  onSelectionChanged: (Set<int> value) {
                    controller.filterType.value = value.first;
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith<Color>(
                      (states) {
                        if (states.contains(MaterialState.selected)) {
                          return Colors.blue;
                        }
                        return Colors.white;
                      },
                    ),
                  ),
                )),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScoreTrendChart() {
    return Container(
      height: 280.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(8.w),
            child: Text(
              '成绩趋势',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.statistics.isEmpty) {
                return const Center(child: Text('暂无数据'));
              }
              return SingleChildScrollView(
                padding: EdgeInsets.all(10.w),
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: controller.statistics.length * 100.w,
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: 16.w,
                      bottom: 16.h,
                    ),
                    child: LineChart(
                      controller.getLineChartData(),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildLegend() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildLegendItem('平均分', Colors.blue),
          _buildLegendItem('最高分', Colors.green),
          _buildLegendItem('最低分', Colors.red),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12.w,
          height: 12.w,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildAssignmentList() {
    return Column(
      children: controller.statistics.map((stat) {
        return Container(
          margin: EdgeInsets.only(bottom: 12.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: InkWell(
            onTap: () => _showDistributionDialog(stat),
            borderRadius: BorderRadius.circular(12.r),
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: stat.isInClass ? Colors.blue[100] : Colors.green[100],
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          stat.isInClass ? '测验' : '作业',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: stat.isInClass ? Colors.blue : Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          stat.title,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildScoreIndicator(
                        label: '平均分',
                        score: stat.averageScore,
                        color: Colors.blue,
                      ),
                      _buildScoreIndicator(
                        label: '最高分',
                        score: stat.maxScore,
                        color: Colors.green,
                      ),
                      _buildScoreIndicator(
                        label: '最低分',
                        score: stat.minScore,
                        color: Colors.red,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildScoreIndicator({
    required String label,
    required double score,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.grey[600],
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          score.toStringAsFixed(1),
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  void _showDistributionDialog(GradeStatistics stat) {
    final bool allZero = stat.distribution.isEmpty || stat.distribution.every((value) => value == 0);
    
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Container(
          padding: EdgeInsets.all(20.w),
          width: 0.85.sw,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: stat.isInClass ? Colors.blue[100] : Colors.green[100],
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      stat.isInClass ? '测验' : '作业',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: stat.isInClass ? Colors.blue : Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      stat.title,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Get.back(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              if (allZero)
                Container(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  child: Text(
                    '暂无学生提交',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              Container(
                height: 280.h,
                padding: EdgeInsets.only(
                  left: 16.w,
                  right: 16.w,
                  top: 24.h,
                  bottom: 16.h,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: PieChart(
                  controller.getDistributionChartData(stat),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showInfoDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '成绩统计说明',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16.h),
              _buildInfoItem(
                icon: Icons.analytics_outlined,
                title: '成绩趋势',
                description: '展示班级历次作业和测验的平均分、最高分、最低分变化趋势',
              ),
              SizedBox(height: 12.h),
              _buildInfoItem(
                icon: Icons.pie_chart,
                title: '分数分布',
                description: '显示每次作业或测验的班级分数分布情况',
              ),
              SizedBox(height: 20.h),
              ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: Text(
                  '我知道了',
                  style: TextStyle(fontSize: 14.sp),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, color: Colors.blue, size: 20.sp),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
} 
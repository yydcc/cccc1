import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import 'package:cccc1/model/grade_statistics_model.dart';
import 'grade_statistics_controller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GradeStatisticsView extends GetView<GradeStatisticsController> {
  const GradeStatisticsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          '成绩统计',
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
                            _buildSummaryCards(),
                            SizedBox(height: 8.h),
                            _buildLatestAssignmentList(),
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
                      label: Text('问答', style: TextStyle(fontSize: 13.sp)),
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

  Widget _buildContent() {
    return RefreshIndicator(
      onRefresh: () => controller.fetchData(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: [
            _buildScoreTrendChart(),
            _buildSummaryCards(),
            SizedBox(height: 8.h),
            _buildLatestAssignmentList(),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Container(


      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: _buildSummaryCard(
              title: '平均分',
              value: controller.averageScore.toStringAsFixed(1),
              icon: Icons.analytics_outlined,
              color: Colors.blue,
              trend: controller.getScoreTrend(),
            ),
          ),
          SizedBox(width: 4.w), // 减小间距以适应三个卡片
          Expanded(
            flex: 1,
            child: _buildSummaryCard(
              title: '最高分',
              value: controller.maxScore.toStringAsFixed(1),
              icon: Icons.emoji_events_outlined,
              color: Colors.orange,
              showTrend: false,
            ),
          ),
          SizedBox(width: 4.w), // 减小间距以适应三个卡片
          Expanded(
            flex: 1,
            child: _buildSummaryCard(
              title: '最低分',
              value: controller.minScore.toStringAsFixed(1),
              icon: Icons.low_priority,
              color: Colors.red,
              showTrend: false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    String? trend,
    bool showTrend = true,
  }) {
    return Container(
      padding: EdgeInsets.all(12.w),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(icon, color: color, size: 16.sp),
              ),
              SizedBox(width: 6.w),
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (showTrend && trend != null) ...[
                SizedBox(width: 4.w),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 2.w,
                    vertical: 2.h,
                  ),
                  decoration: BoxDecoration(
                    color: trend.startsWith('+')
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        trend.startsWith('+')
                            ? Icons.arrow_upward
                            : Icons.arrow_downward,
                        size: 10.sp,
                        color: trend.startsWith('+')
                            ? Colors.green
                            : Colors.red,
                      ),

                      Text(
                        trend,
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: trend.startsWith('+')
                              ? Colors.green
                              : Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScoreTrendChart() {
    return Container(
      height: 280.h,
      margin: EdgeInsets.symmetric(vertical: 16.w),
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
            padding: EdgeInsets.all(16.w),
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

  Widget _buildLatestAssignmentList() {
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
                          stat.isInClass ? '问答' : '作业',
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
                    children: [
                      _buildScoreIndicator(
                        label: '个人得分',
                        score: stat.score,
                        color: Colors.blue,
                      ),
                      SizedBox(width: 24.w),
                      _buildScoreIndicator(
                        label: '平均分',
                        score: stat.averageScore,
                        color: Colors.grey[600]!,
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
                      stat.isInClass ? '问答' : '作业',
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
                height: 240.h,
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: BarChart(
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
                description: '展示你的历次作业和问答成绩变化趋势',
              ),
              SizedBox(height: 12.h),
              _buildInfoItem(
                icon: Icons.bar_chart,
                title: '分数分布',
                description: '显示每次作业或问答的班级分数分布情况',
              ),
              SizedBox(height: 12.h),
              _buildInfoItem(
                icon: Icons.compare_arrows,
                title: '成绩对比',
                description: '可以查看个人得分与班级平均分的对比',
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

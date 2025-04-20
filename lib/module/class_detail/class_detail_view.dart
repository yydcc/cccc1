import 'package:cccc1/common/utils/storage.dart';
import 'package:cccc1/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../common/theme/color.dart';
import '../../model/classinfo_model.dart';
import 'package:cccc1/module/class_detail/class_detail_controller.dart';

class ClassDetailView extends GetView<ClassDetailController> {


  const ClassDetailView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: GlobalThemData.backgroundColor,
      body: Obx(() => controller.isLoading.value
          ? _buildLoadingView()
          : controller.classInfo.value == null
          ? _buildErrorView()
          : _buildContent(context, primaryColor),
      ),
    );
  }

  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 40.w,
            height: 40.w,
            child: CircularProgressIndicator(
              strokeWidth: 3.w,
              valueColor: AlwaysStoppedAnimation<Color>(Theme.of(Get.context!).primaryColor),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            '加载中...',
            style: TextStyle(
              fontSize: 16.sp,
              color: GlobalThemData.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 60.sp,
            color: Colors.red,
          ),
          SizedBox(height: 16.h),
          Text(
            '无法加载班级信息',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: GlobalThemData.textPrimaryColor,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '请检查网络连接后重试',
            style: TextStyle(
              fontSize: 14.sp,
              color: GlobalThemData.textSecondaryColor,
            ),
          ),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: controller.loadClassDetail,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(Get.context!).primaryColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.r),
              ),
            ),
            child: Text('重试'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, Color primaryColor) {
    final classInfo = controller.classInfo.value!;

    return CustomScrollView(
      slivers: [
        _buildAppBar(classInfo, primaryColor),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildClassInfoCard(classInfo, primaryColor),
                SizedBox(height: 16.h),
                _buildStatsCard(primaryColor),
                SizedBox(height: 16.h),
                _buildFunctionCards(primaryColor),
                SizedBox(height: 16.h),

              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar(ClassInfo classInfo, Color primaryColor) {
    return SliverAppBar(
      expandedHeight: 180.h,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          classInfo.className ?? '未命名班级',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primaryColor, primaryColor.withOpacity(0.7)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                right: -30.w,
                bottom: -30.h,
                child: Container(
                  width: 150.w,
                  height: 150.w,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                left: -20.w,
                top: -20.h,
                child: Container(
                  width: 100.w,
                  height: 100.w,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.refresh),
          onPressed: controller.loadClassDetail,
          tooltip: '刷新',
        ),
      ],
    );
  }

  Widget _buildClassInfoCard(ClassInfo classInfo, Color primaryColor) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 24.sp,
                color: primaryColor,
              ),
              SizedBox(width: 8.w),
              Text(
                '班级信息',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: GlobalThemData.textPrimaryColor,
                ),
              ),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.code,
                      size: 14.sp,
                      color: primaryColor,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      '课程码: ${classInfo.courseCode ?? '无'}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          _buildInfoRow(
            icon: Icons.class_,
            title: '班级名称',
            content: classInfo.className ?? '未命名班级',
            iconColor: primaryColor,
          ),
          SizedBox(height: 12.h),
          _buildInfoRow(
            icon: Icons.person,
            title: '教师昵称',
            content: classInfo.teacherNickname ?? '未知',
            iconColor: primaryColor,
          ),
          SizedBox(height: 12.h),
          _buildInfoRow(
            icon: Icons.calendar_today,
            title: '创建时间',
            content: classInfo.createAt?.substring(0, 10) ?? '未知',
            iconColor: primaryColor,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(Color primaryColor) {
    final classInfo = controller.classInfo.value;
    if (classInfo == null) return SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.bar_chart,
                size: 24.sp,
                color: primaryColor,
              ),
              SizedBox(width: 8.w),
              Text(
                '班级统计',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: GlobalThemData.textPrimaryColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: Icons.people,
                  title: '学生',
                  value: classInfo.studentCount?.toString() ?? '0',
                  color: Colors.blue,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.assignment,
                  title: '作业',
                  value: classInfo.assignmentCount?.toString() ?? '0',
                  color: Colors.green,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  icon:Icons.quiz,
                  title: '测验',
                  value: classInfo.quizCount?.toString() ?? '0',
                  color: Colors.orange,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          width: 50.w,
          height: 50.w,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              icon,
              color: color,
              size: 24.sp,
            ),
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: GlobalThemData.textPrimaryColor,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          title,
          style: TextStyle(
            fontSize: 12.sp,
            color: GlobalThemData.textSecondaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildFunctionCards(Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '班级功能',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: GlobalThemData.textPrimaryColor,
          ),
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(
              child: _buildFunctionCard(
                icon: Icons.people,
                title: '班级成员',
                subtitle: '查看同学',
                color: Colors.blue,
                onTap: controller.goToClassMembers,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: _buildFunctionCard(
                icon: Icons.quiz,
                title: '课堂测验',
                subtitle: '即时测验',
                color: Colors.orange,
                onTap: ()=>controller.goToQuiz(),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(
              child: _buildFunctionCard(
                icon: Icons.assignment,
                title: '作业详情',
                subtitle: "查看作业",
                color: Colors.green,
                onTap: controller.goToHomework,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: _buildFunctionCard(
                icon: Icons.analytics,
                title: '成绩统计',
                subtitle: '学习分析',
                color: Colors.purple,
                onTap: () async {
                  final prefs = await StorageService.instance;
                  Get.toNamed(AppRoutes.GRADE_STATISTICS,arguments: {
                    "classId": controller.classInfo.value?.classId,
                    "studentId": prefs.getUserId()
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFunctionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 24.sp,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: GlobalThemData.textPrimaryColor,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12.sp,
                color: GlobalThemData.textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String content,
    Color? iconColor,
    Color? contentColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18.sp,
          color: iconColor ?? GlobalThemData.textSecondaryColor,
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: GlobalThemData.textSecondaryColor,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                content,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: contentColor ?? GlobalThemData.textPrimaryColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
} 
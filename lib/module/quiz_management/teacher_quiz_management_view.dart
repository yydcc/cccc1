import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../common/theme/color.dart';
import '../../model/assignment_model.dart';
import '../../routes/app_pages.dart';
import 'teacher_quiz_management_controller.dart';

class TeacherQuizManagementView extends GetView<TeacherQuizManagementController> {
  const TeacherQuizManagementView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GlobalThemData.backgroundColor,
      appBar: AppBar(
        title: Text('课堂测验管理'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: controller.refreshQuizList,
            tooltip: '刷新',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed(
          AppRoutes.CREATE_QUIZ,
          arguments: {'classId': controller.classId},
        )?.then((value) {
          if (value == true) {
            controller.refreshQuizList();
          }
        }),
        icon: Icon(Icons.add),
        label: Text('创建测验'),
        tooltip: '创建新测验',
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildLoadingView();
        } else if (controller.quizzes.isEmpty) {
          return _buildEmptyView();
        } else {
          return _buildQuizList();
        }
      }),
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
  
  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120.w,
            height: 120.w,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.quiz_outlined,
              size: 60.sp,
              color: Colors.grey.shade400,
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            '暂无课堂测验',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: GlobalThemData.textPrimaryColor,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '点击下方按钮创建新的课堂测验',
            style: TextStyle(
              fontSize: 14.sp,
              color: GlobalThemData.textSecondaryColor,
            ),
          ),
          SizedBox(height: 32.h),
          ElevatedButton.icon(
            onPressed: () => Get.toNamed(
              AppRoutes.CREATE_QUIZ,
              arguments: {'classId': controller.classId},
            )?.then((value) {
              if (value == true) {
                controller.refreshQuizList();
              }
            }),
            icon: Icon(Icons.add),
            label: Text('创建测验'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildQuizList() {
    return RefreshIndicator(
      onRefresh: controller.refreshQuizList,
      child: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: controller.quizzes.length,
        itemBuilder: (context, index) {
          final quiz = controller.quizzes[index];
          return _buildQuizCard(quiz);
        },
      ),
    );
  }
  
  Widget _buildQuizCard(Assignment quiz) {
    // 获取状态对应的颜色
    Color statusColor;
    IconData statusIcon;
    
    switch (quiz.statusText) {
      case '未开始':
        statusColor = Colors.blue;
        statusIcon = Icons.schedule;
        break;
      case '进行中':
        statusColor = Colors.green;
        statusIcon = Icons.play_circle_outline;
        break;
      case '已截止':
        statusColor = Colors.orange;
        statusIcon = Icons.assignment_turned_in;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help_outline;
    }
    
    return GestureDetector(
      onTap: () => controller.goToQuizDetail(quiz),
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: statusColor.withOpacity(0.1),
              blurRadius: 12,
              offset: Offset(0, 5),
            ),
          ],
          border: Border.all(
            color: statusColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(16.w),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 左侧状态图标
                  Container(
                    width: 50.w,
                    height: 50.w,
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      statusIcon,
                      color: statusColor,
                      size: 28.sp,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  // 右侧内容
                  Expanded(
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
                                color: statusColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4.r),
                              ),
                              child: Text(
                                quiz.statusText,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: statusColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Spacer(),
                            Icon(
                              Icons.quiz,
                              size: 16.sp,
                              color: statusColor,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              '课堂测验',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: statusColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          quiz.title ?? '未命名测验',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: GlobalThemData.textPrimaryColor,
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 16.sp,
                              color: quiz.isDeadlineNear ? Colors.orange : GlobalThemData.textSecondaryColor,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              '截止时间: ${quiz.formattedDeadline}',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: quiz.isDeadlineNear ? Colors.orange : GlobalThemData.textSecondaryColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // 底部操作区域
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 12.h),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.05),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(16.r),
                ),
              ),
              child: Center(
                child: Text(
                  '点击查看详情',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: statusColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 
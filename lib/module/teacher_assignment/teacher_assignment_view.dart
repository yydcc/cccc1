import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_refresh/easy_refresh.dart';
import '../../common/theme/color.dart';
import '../../routes/app_pages.dart';
import 'teacher_assignment_controller.dart';
import '../../model/assignment_model.dart';


class TeacherAssignmentView extends GetView<TeacherAssignmentController> {
  const TeacherAssignmentView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GlobalThemData.backgroundColor,
      appBar: AppBar(
        title: const Text('作业管理'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: controller.refreshAssignments,
            tooltip: '刷新',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.toNamed(
          AppRoutes.CREATE_ASSIGNMENT,
          arguments: {'classId': controller.classId},
        )?.then((value) {
          if (value == true) {
            controller.refreshAssignments();
          }
        }),
        icon: Icon(Icons.add),
        label: Text('创建作业'),
        tooltip: '布置新作业',
      ),
      body: Column(
        children: [
          _buildFilterTabs(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value && controller.assignments.isEmpty) {
                return _buildLoadingView();
              } else if (controller.filteredAssignments.isEmpty) {
                return _buildEmptyView();
              } else {
                return _buildAssignmentList();
              }
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      height: 50.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildFilterTab('全部', 'all'),
          SizedBox(width: 16.w),
          _buildFilterTab('未开始', 'not_started'),
          SizedBox(width: 16.w),
          _buildFilterTab('进行中', 'in_progress'),
          SizedBox(width: 16.w),
          _buildFilterTab('已过期', 'expired'),
        ],
      ),
    );
  }

  Widget _buildFilterTab(String title, String status) {
    return Obx(() => GestureDetector(
      onTap: () => controller.setFilter(status),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: controller.filterStatus.value == status
              ? Theme.of(Get.context!).primaryColor
              : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: controller.filterStatus.value == status
                ? Colors.white
                : Colors.grey.shade700,
          ),
        ),
      ),
    ));
  }

  Widget _buildAssignmentList() {
    // 使用EasyRefresh包装ListView，避免直接使用controller.refreshController
    return EasyRefresh(
      controller: controller.refreshController,
      onRefresh: controller.onRefresh,
      onLoad: controller.onLoadMore,
      child: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: controller.filteredAssignments.length,
        itemBuilder: (context, index) {
          final assignment = controller.filteredAssignments[index];
          return _buildAssignmentItem(assignment);
        },
      ),
    );
  }

  Widget _buildAssignmentItem(Assignment assignment) {
    // 获取状态对应的颜色
    Color statusColor;
    IconData statusIcon;

    switch (assignment.statusText) {
      case '未开始':
        statusColor = Colors.blue;
        statusIcon = Icons.schedule;
        break;
      case '进行中':
        statusColor = Colors.green;
        statusIcon = Icons.play_circle_outline;
        break;
      case '已过期':
        statusColor = Colors.red;
        statusIcon = Icons.assignment_turned_in;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help_outline;
    }

    return GestureDetector(
      onTap: () => controller.goToAssignmentManagement(assignment.assignmentId),
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
                                assignment.statusText,
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
                              '作业',
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
                          assignment.title ?? '未命名作业',
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
                              color: assignment.isDeadlineNear ? Colors.red : GlobalThemData.textSecondaryColor,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              '截止时间: ${assignment.formattedDeadline}',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: assignment.isDeadlineNear ? Colors.red : GlobalThemData.textSecondaryColor,
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
          Icon(
            Icons.assignment_outlined,
            size: 60.sp,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: 16.h),
          Text(
            '暂无作业',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: GlobalThemData.textSecondaryColor,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '点击右下角按钮发布新作业',
            style: TextStyle(
              fontSize: 14.sp,
              color: GlobalThemData.textTertiaryColor,
            ),
          ),

        ],
      ),
    );
  }
} 
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../common/theme/color.dart';
import 'teacher_assignment_controller.dart';

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
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
            tooltip: '筛选',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.goToCreateAssignment,
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
        tooltip: '发布作业',
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.assignments.isEmpty) {
          return _buildLoadingView();
        } else {
          return EasyRefresh(
            controller: controller.refreshController,
            header: const ClassicHeader(
              processedDuration: Duration(milliseconds: 0),
            ),
            footer: const ClassicFooter(
              processedDuration: Duration(milliseconds: 0),
            ),
            onRefresh: controller.onRefresh,
            onLoad: controller.onLoadMore,
            child: controller.filteredAssignments.isEmpty
                ? _buildEmptyView()
                : _buildAssignmentList(),
          );
        }
      }),
    );
  }

  void _showFilterDialog() {
    showDialog(
      context: Get.context!,
      builder: (context) => AlertDialog(
        title: Text('筛选作业'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.filter_list),
              title: Text('全部作业'),
              selected: controller.filterStatus.value == 'all',
              selectedColor: Theme.of(context).primaryColor,
              onTap: () {
                controller.setFilter('all');
                Get.back();
              },
            ),
            ListTile(
              leading: Icon(Icons.assignment_outlined),
              title: Text('未开始'),
              selected: controller.filterStatus.value == 'not_started',
              selectedColor: Theme.of(context).primaryColor,
              onTap: () {
                controller.setFilter('not_started');
                Get.back();
              },
            ),
            ListTile(
              leading: Icon(Icons.edit_note),
              title: Text('进行中'),
              selected: controller.filterStatus.value == 'in_progress',
              selectedColor: Theme.of(context).primaryColor,
              onTap: () {
                controller.setFilter('in_progress');
                Get.back();
              },
            ),
            ListTile(
              leading: Icon(Icons.assignment_late),
              title: Text('已过期'),
              selected: controller.filterStatus.value == 'expired',
              selectedColor: Theme.of(context).primaryColor,
              onTap: () {
                controller.setFilter('expired');
                Get.back();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('取消'),
          ),
        ],
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
            size: 80.sp,
            color: GlobalThemData.textSecondaryColor.withOpacity(0.5),
          ),
          SizedBox(height: 16.h),
          Text(
            '暂无作业',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: GlobalThemData.textPrimaryColor,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            controller.filterStatus.value == 'all'
                ? '点击右下角按钮发布新作业'
                : '当前筛选条件下没有作业',
            style: TextStyle(
              fontSize: 14.sp,
              color: GlobalThemData.textSecondaryColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAssignmentList() {
    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: controller.filteredAssignments.length,
      itemBuilder: (context, index) {
        final assignment = controller.filteredAssignments[index];
        return Container(
          margin: EdgeInsets.only(bottom: 16.h),
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
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => controller.goToAssignmentManagement(assignment.assignmentId),
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
                            color: assignment.statusColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            assignment.statusText,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: assignment.statusColor,
                            ),
                          ),
                        ),
                        Spacer(),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 14.sp,
                              color: GlobalThemData.textSecondaryColor,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              '截止时间: ${assignment.formattedDeadline}',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: GlobalThemData.textSecondaryColor,
                              ),
                            ),
                          ],
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8.h),
                    if (assignment.description != null && assignment.description!.isNotEmpty)
                      Text(
                        assignment.description!,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: GlobalThemData.textSecondaryColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
} 
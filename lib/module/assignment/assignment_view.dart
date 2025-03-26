import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../common/theme/color.dart';
import 'assignment_controller.dart';
import 'package:easy_refresh/easy_refresh.dart';
import '../../model/assignment_model.dart';

class AssignmentView extends GetView<AssignmentController> {
  const AssignmentView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(Get.context!).primaryColor;
    
    return Scaffold(
      backgroundColor: GlobalThemData.backgroundColor,
      appBar: AppBar(
        title: Text('班级作业'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: primaryColor,
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
    return EasyRefresh(
      controller: controller.refreshController,
      header: const ClassicHeader(
        processedDuration: Duration(milliseconds: 0),
        dragText: '下拉刷新',
        armedText: '释放刷新',
        processingText: '刷新中...',
        processedText: '刷新成功',
        failedText: '刷新失败',
        readyText: '准备刷新',
      ),
      footer: const ClassicFooter(
        processedDuration: Duration(milliseconds: 0),
        dragText: '上拉加载',
        armedText: '释放加载',
        processingText: '加载中...',
        processedText: '加载成功',
        failedText: '加载失败',
        readyText: '准备加载',
        noMoreText: '没有更多数据',
      ),
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
    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: InkWell(
        onTap: () => controller.goToAssignmentDetail(assignment.assignmentId),
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      assignment.title ?? '无标题',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: GlobalThemData.textPrimaryColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 2.h,
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
                ],
              ),
              SizedBox(height: 8.h),
              Text(
                assignment.description ?? '无描述',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: GlobalThemData.textSecondaryColor,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 12.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '截止日期: ${assignment.formattedDeadline}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: assignment.isDeadlineNear && assignment.status == 'in_progress'
                          ? Colors.orange
                          : GlobalThemData.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
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
            '老师还没有布置作业',
            style: TextStyle(
              fontSize: 14.sp,
              color: GlobalThemData.textTertiaryColor,
            ),
          ),
          SizedBox(height: 24.h),
          Obx(() => ElevatedButton(
            onPressed: controller.isManualRefreshing.value 
                ? null 
                : controller.manualRefresh,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(Get.context!).primaryColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              disabledBackgroundColor: Theme.of(Get.context!).primaryColor.withOpacity(0.6),
            ),
            child: controller.isManualRefreshing.value
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 16.w,
                        height: 16.w,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.w,
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        '刷新中...',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  )
                : Text(
                    '刷新',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          )),
        ],
      ),
    );
  }
} 
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../common/theme/color.dart';
import 'assignment_controller.dart';
import 'package:easy_refresh/easy_refresh.dart';
import '../../model/assignment_model.dart';

class AssignmentView extends GetView<AssignmentController> {
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
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {
              // 添加筛选功能
              _showFilterDialog(context);
            },
          ),
        ],
      ),
      body: EasyRefresh(
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
        child: Obx(() => controller.isLoading.value && controller.assignments.isEmpty
          ? _buildLoadingView()
          : controller.assignments.isEmpty
              ? _buildEmptyView()
              : _buildAssignmentList(),
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
          Container(
            width: 120.w,
            height: 120.w,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.assignment_outlined,
              size: 60.sp,
              color: Theme.of(Get.context!).primaryColor.withOpacity(0.5),
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            '暂无作业',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w500,
              color: GlobalThemData.textPrimaryColor,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '老师还没有布置作业哦',
            style: TextStyle(
              fontSize: 14.sp,
              color: GlobalThemData.textSecondaryColor,
            ),
          ),
          SizedBox(height: 32.h),
          ElevatedButton(
            onPressed: controller.onRefresh,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(Get.context!).primaryColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.r),
              ),
            ),
            child: Text('刷新'),
          ),
        ],
      ),
    );
  }

  Widget _buildAssignmentList() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      itemCount: controller.assignments.length,
      itemBuilder: (context, index) {
        final assignment = controller.assignments[index];
        return _buildAssignmentCard(assignment);
      },
    );
  }

  Widget _buildAssignmentCard(Assignment assignment) {
    // 计算截止日期是否临近（3天内）
    bool isDeadlineNear = false;
    if (assignment.deadline != null && assignment.deadline!.isNotEmpty) {
      final deadlineDate = DateTime.parse(assignment.deadline!);
      final now = DateTime.now();
      final difference = deadlineDate.difference(now).inDays;
      isDeadlineNear = difference >= 0 && difference <= 3;
    }

    // 添加渐变背景色
    final gradientColors = _getStatusGradient(assignment.status);

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
          onTap: () {
            print('作业标题: ${assignment.title}');
            print('作业ID原始值: ${assignment.assignmentId}');
            print('作业完整数据: $assignment');
            
            final id = assignment.assignmentId;
            if (id == null || id == 0) {
              Get.snackbar('提示', '无法获取作业ID，请联系管理员');
              return;
            }
            
            print('点击作业卡片，ID: $id');
            controller.goToAssignmentDetail(id);
          },
          borderRadius: BorderRadius.circular(12.r),
          child: Column(
            children: [
              // 添加顶部状态条
              Container(
                height: 6.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradientColors,
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12.r),
                    topRight: Radius.circular(12.r),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40.w,
                          height: 40.w,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: gradientColors,
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: gradientColors[0].withOpacity(0.3),
                                blurRadius: 8,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Icon(
                            _getAssignmentIcon(assignment.status),
                            color: Colors.white,
                            size: 20.sp,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
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
                              SizedBox(height: 4.h),
                              Row(
                                children: [
                                  Icon(
                                    Icons.access_time,
                                    size: 14.sp,
                                    color: isDeadlineNear && assignment.status != 'submitted' && assignment.status != 'graded'
                                        ? Colors.red
                                        : GlobalThemData.textSecondaryColor,
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    '截止: ${assignment.formattedDeadline}',
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: isDeadlineNear && assignment.status != 'submitted' && assignment.status != 'graded'
                                          ? Colors.red
                                          : GlobalThemData.textSecondaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // 使用渐变背景的状态标签
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                gradientColors[0].withOpacity(0.7),
                                gradientColors[1].withOpacity(0.7),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Text(
                            assignment.statusText,
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (assignment.description != null && assignment.description!.isNotEmpty) ...[
                      SizedBox(height: 12.h),
                      Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: GlobalThemData.backgroundColor,
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            color: gradientColors[0].withOpacity(0.1),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          assignment.description!,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: GlobalThemData.textSecondaryColor,
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                    if (assignment.status == 'graded') ...[
                      SizedBox(height: 12.h),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 6.h,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.orange, Colors.amber],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.orange.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.star,
                                  color: Colors.white,
                                  size: 16.sp,
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  '得分: ${assignment.score}',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 修改_getStatusGradient方法，使用主题色
  List<Color> _getStatusGradient(String status) {
    final primaryColor = Theme.of(Get.context!).primaryColor;
    
    switch (status) {
      case 'not_started':
        return [Colors.grey.shade400, Colors.grey.shade600];
      case 'in_progress':
        return [primaryColor.withOpacity(0.7), primaryColor]; // 使用主题色
      case 'submitted':
        return [Colors.green.shade300, Colors.green.shade600];
      case 'graded':
        return [Colors.purple.shade300, Colors.purple.shade600];
      default:
        return [Colors.grey.shade400, Colors.grey.shade600];
    }
  }

  IconData _getAssignmentIcon(String status) {
    switch (status) {
      case 'not_started':
        return Icons.assignment_outlined;
      case 'in_progress':
        return Icons.edit_note;
      case 'submitted':
        return Icons.assignment_turned_in_outlined;
      case 'graded':
        return Icons.grading;
      default:
        return Icons.assignment_outlined;
    }
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('筛选作业'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.filter_list),
              title: Text('全部作业'),
              onTap: () {
                // 筛选全部作业
                Get.back();
              },
            ),
            ListTile(
              leading: Icon(Icons.pending_actions),
              title: Text('未完成'),
              onTap: () {
                // 筛选未完成作业
                Get.back();
              },
            ),
            ListTile(
              leading: Icon(Icons.done_all),
              title: Text('已完成'),
              onTap: () {
                // 筛选已完成作业
                Get.back();
              },
            ),
            ListTile(
              leading: Icon(Icons.grading),
              title: Text('已批改'),
              onTap: () {
                // 筛选已批改作业
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
} 
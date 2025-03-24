import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../common/theme/color.dart';
import 'teacher_assignment_detail_controller.dart';

class TeacherAssignmentDetailView extends GetView<TeacherAssignmentDetailController> {
  const TeacherAssignmentDetailView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GlobalThemData.backgroundColor,
      appBar: AppBar(
        title: const Text('作业管理'),
        centerTitle: true,
        elevation: 0,

      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildLoadingView();
        } else if (controller.assignment.value == null) {
          return _buildErrorView();
        } else {
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAssignmentDetail(),
                SizedBox(height: 16.h),
                _buildSubmissionsSection(),
              ],
            ),
          );
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
            '无法加载作业信息',
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
            onPressed: controller.loadAssignmentDetail,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(Get.context!).primaryColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.r),
              ),
            ),
            child: const Text('重试'),
          ),
        ],
      ),
    );
  }

  Widget _buildAssignmentDetail() {
    final assignment = controller.assignment.value!;
    
    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
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
              const Spacer(),
              Text(
                '开始时间: ${assignment.formattedCreateTime}',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: GlobalThemData.textSecondaryColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            assignment.title ?? '未命名作业',
            style: TextStyle(
              fontSize: 18.sp,
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
                color: GlobalThemData.textSecondaryColor,
              ),
              SizedBox(width: 4.w),
              Text(
                '截止时间: ${assignment.formattedDeadline}',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: GlobalThemData.textSecondaryColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          if (assignment.description != null && assignment.description!.isNotEmpty) ...[
            Text(
              '作业描述',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: GlobalThemData.textPrimaryColor,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              assignment.description!,
              style: TextStyle(
                fontSize: 14.sp,
                color: GlobalThemData.textPrimaryColor,
              ),
            ),
            SizedBox(height: 16.h),
          ],
          if (assignment.contentUrl != null && assignment.contentUrl!.isNotEmpty) ...[
            Text(
              '作业附件',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: GlobalThemData.textPrimaryColor,
              ),
            ),
            SizedBox(height: 8.h),
            InkWell(
              onTap: controller.downloadAttachment,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 8.h,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: Colors.blue.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.attach_file,
                      size: 20.sp,
                      color: Colors.blue,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        assignment.attachmentFileName ?? '附件',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.blue,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Icon(
                      Icons.download,
                      size: 20.sp,
                      color: Colors.blue,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSubmissionsSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '学生提交情况',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: GlobalThemData.textPrimaryColor,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 4.h,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(Get.context!).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15.r),
                ),
                child: Obx(() => Text(
                  '已提交: ${controller.submissions.length}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Theme.of(Get.context!).primaryColor,
                  ),
                )),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Obx(() {
            if (controller.isSubmissionsLoading.value) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 32.h),
                  child: CircularProgressIndicator(
                    strokeWidth: 3.w,
                    valueColor: AlwaysStoppedAnimation<Color>(Theme.of(Get.context!).primaryColor),
                  ),
                ),
              );
            } else if (controller.submissions.isEmpty) {
              return _buildEmptySubmissions();
            } else {
              return _buildSubmissionsList();
            }
          }),
        ],
      ),
    );
  }

  Widget _buildEmptySubmissions() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 32.h),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 60.sp,
            color: GlobalThemData.textSecondaryColor.withOpacity(0.5),
          ),
          SizedBox(height: 16.h),
          Text(
            '暂无学生提交',
            style: TextStyle(
              fontSize: 16.sp,
              color: GlobalThemData.textSecondaryColor,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '学生提交作业后将显示在这里',
            style: TextStyle(
              fontSize: 14.sp,
              color: GlobalThemData.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmissionsList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: controller.submissions.length,
      itemBuilder: (context, index) {
        final submission = controller.submissions[index];
        return Container(
          margin: EdgeInsets.only(bottom: 12.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => controller.goToGradeSubmission(submission),
              borderRadius: BorderRadius.circular(8.r),
              child: Padding(
                padding: EdgeInsets.all(12.w),
                child: Row(
                  children: [
                    Container(
                      width: 40.w,
                      height: 40.w,
                      decoration: BoxDecoration(
                        color: submission.isGraded
                            ? Colors.green.withOpacity(0.1)
                            : Colors.orange.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          submission.isGraded
                              ? Icons.check_circle
                              : Icons.pending,
                          color: submission.isGraded
                              ? Colors.green
                              : Colors.orange,
                          size: 24.sp,
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '学生: ${submission.username}',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: GlobalThemData.textPrimaryColor,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            '提交时间: ${submission.formattedSubmitTime}',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: GlobalThemData.textSecondaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: submission.isGraded
                                ? Colors.green.withOpacity(0.1)
                                : Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text(
                            submission.isGraded ? '已批改' : '待批改',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: submission.isGraded
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                          ),
                        ),
                        SizedBox(height: 4.h),
                        if (submission.isGraded)
                          Text(
                            '得分: ${submission.score}',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: GlobalThemData.textPrimaryColor,
                            ),
                          ),
                      ],
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
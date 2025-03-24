import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../common/theme/color.dart';
import 'grade_submission_controller.dart';

class GradeSubmissionView extends GetView<GradeSubmissionController> {
  const GradeSubmissionView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GlobalThemData.backgroundColor,
      appBar: AppBar(
        title: const Text('批改作业'),
        centerTitle: true,
        elevation: 0,
        actions: [
          if (controller.submission.value?.hasFile == true)
            IconButton(
              icon: const Icon(Icons.download),
              onPressed: controller.downloadSubmissionFile,
              tooltip: '下载附件',
            ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildLoadingView();
        } else if (controller.submission.value == null) {
          return _buildErrorView();
        } else {
          return SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSubmissionInfo(),
                SizedBox(height: 16.h),
                _buildSubmissionContent(),
                SizedBox(height: 24.h),
                _buildGradingForm(),
                SizedBox(height: 24.h),
                _buildSubmitButton(),
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
            '无法加载提交信息',
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
            onPressed: controller.loadSubmissionDetail,
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

  Widget _buildSubmissionInfo() {
    final submission = controller.submission.value!;
    
    return Container(
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
                  color: submission.isGraded
                      ? Colors.green.withOpacity(0.1)
                      : Colors.orange.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  submission.isGraded ? '已批改' : '待批改',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: submission.isGraded ? Colors.green : Colors.orange,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '提交时间: ${submission.formattedSubmitTime}',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: GlobalThemData.textSecondaryColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            '学生: ${submission.username ?? '未知学生'}',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: GlobalThemData.textPrimaryColor,
            ),
          ),
          SizedBox(height: 8.h),
          if (submission.hasFile) ...[
            Row(
              children: [
                Icon(
                  Icons.attach_file,
                  size: 16.sp,
                  color: GlobalThemData.textSecondaryColor,
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: Text(
                    '附件: ${submission.fileName ?? '未知文件'}',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: GlobalThemData.textSecondaryColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                TextButton(
                  onPressed: controller.downloadSubmissionFile,
                  child: Text(
                    '下载',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Theme.of(Get.context!).primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSubmissionContent() {
    final submission = controller.submission.value!;
    
    if (submission.content == null || submission.content!.isEmpty) {
      return Container();
    }
    
    return Container(
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
          Text(
            '提交内容',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: GlobalThemData.textPrimaryColor,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            submission.content!,
            style: TextStyle(
              fontSize: 14.sp,
              color: GlobalThemData.textPrimaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGradingForm() {
    return Container(
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
          Text(
            '批改评分',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: GlobalThemData.textPrimaryColor,
            ),
          ),
          SizedBox(height: 16.h),
          TextField(
            controller: controller.scoreController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: '分数 (0-100)',
              hintText: '请输入分数',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              prefixIcon: const Icon(Icons.score),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            '批改反馈',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: GlobalThemData.textPrimaryColor,
            ),
          ),
          SizedBox(height: 8.h),
          TextField(
            controller: controller.feedbackController,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: '请输入批改反馈',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: Obx(() => ElevatedButton(
        onPressed: controller.isSubmitting.value
            ? null
            : controller.submitGrade,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(Get.context!).primaryColor,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          disabledBackgroundColor: Colors.grey.shade300,
        ),
        child: controller.isSubmitting.value
            ? SizedBox(
                width: 20.w,
                height: 20.w,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                controller.submission.value!.isGraded ? '更新批改' : '提交批改',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
      )),
    );
  }
} 
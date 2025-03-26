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
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildLoadingView();
        } else if (controller.submission.value == null) {
          return _buildErrorView();
        } else {
          return _buildGradeForm();
        }
      }),
      bottomNavigationBar: Obx(() {
        if (controller.isLoading.value) {
          return const SizedBox.shrink();
        }
        return Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Row(
            children: [
              // AI自动批改按钮
              Expanded(
                flex: 1,
                child: ElevatedButton.icon(
                  onPressed: controller.isAutoGrading.value ? null : controller.autoGradeSubmission,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    disabledBackgroundColor: Colors.deepPurple.withOpacity(0.6),
                  ),
                  icon: controller.isAutoGrading.value
                      ? SizedBox(
                          width: 16.w,
                          height: 16.w,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Icon(Icons.auto_awesome, size: 18.sp),
                  label: Text(
                    'AI批改',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              // 提交批改按钮
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: controller.isSubmitting.value ? null : controller.submitGrade,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: controller.isSubmitting.value
                      ? SizedBox(
                          width: 20.w,
                          height: 20.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.w,
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          controller.submission.value!.isGraded ? '更新批改' : '提交批改',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        );
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

  Widget _buildGradeForm() {
    final submission = controller.submission.value!;
    
    return Stack(
      children: [
        SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 学生信息卡片
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.person,
                            size: 20.sp,
                            color: Theme.of(Get.context!).primaryColor,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            '学生信息',
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '学生姓名',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: GlobalThemData.textSecondaryColor,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  submission.username ?? '未知',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                    color: GlobalThemData.textPrimaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '提交时间',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: GlobalThemData.textSecondaryColor,
                                  ),
                                ),
                                SizedBox(height: 4.h),
                                Text(
                                  submission.formattedSubmitTime,
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                    color: GlobalThemData.textPrimaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 16.h),
              
              // 提交内容卡片
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.description,
                            size: 20.sp,
                            color: Theme.of(Get.context!).primaryColor,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            '提交内容',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: GlobalThemData.textPrimaryColor,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      if (submission.content != null && submission.content!.isNotEmpty) ...[
                        Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: SelectableText(
                            submission.content!,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: GlobalThemData.textPrimaryColor,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ] else ...[
                        Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Text(
                            '无文本内容',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: GlobalThemData.textSecondaryColor,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                      if (submission.hasFile) ...[
                        SizedBox(height: 16.h),
                        Text(
                          '附件',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: GlobalThemData.textPrimaryColor,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        InkWell(
                          onTap: controller.downloadSubmissionFile,
                          borderRadius: BorderRadius.circular(8.r),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 12.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8.r),
                              border: Border.all(color: Colors.blue.withOpacity(0.3)),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.attach_file,
                                  size: 20.sp,
                                  color: Colors.blue,
                                ),
                                SizedBox(width: 12.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        submission.fileName ?? '附件',
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.bold,
                                          color: GlobalThemData.textPrimaryColor,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
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
                ),
              ),
              
              SizedBox(height: 16.h),
              
              // 批改表单卡片
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.grading,
                            size: 20.sp,
                            color: Theme.of(Get.context!).primaryColor,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            '批改评分',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: GlobalThemData.textPrimaryColor,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        '分数',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: GlobalThemData.textPrimaryColor,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      TextField(
                        controller: controller.scoreController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: '输入0-100之间的分数',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 12.h,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        '评语',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: GlobalThemData.textPrimaryColor,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      TextField(
                        controller: controller.feedbackController,
                        maxLines: 5,
                        decoration: InputDecoration(
                          hintText: '输入评语',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 12.h,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // 底部空间，避免内容被底部导航栏遮挡
              SizedBox(height: 80.h),
            ],
          ),
        ),
        
        // AI自动批改状态覆盖层
        Obx(() {
          if (controller.isAutoGrading.value && controller.autoGradingStatus.value.isNotEmpty) {
            return Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.7),
                child: Center(
                  child: Container(
                    padding: EdgeInsets.all(24.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 50.w,
                          height: 50.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 3.w,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                          ),
                        ),
                        SizedBox(height: 24.h),
                        Text(
                          'AI自动批改',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: GlobalThemData.textPrimaryColor,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          controller.autoGradingStatus.value,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: GlobalThemData.textSecondaryColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }
} 
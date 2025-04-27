import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../common/theme/color.dart';
import '../../model/assignment_model.dart';
import '../../model/submission_model.dart';
import 'teacher_quiz_detail_controller.dart';

class TeacherQuizDetailView extends GetView<TeacherQuizDetailController> {
  const TeacherQuizDetailView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // 根据问答状态获取主题色
      Color primaryColor = Colors.purple;
      
      if (!controller.isLoading.value && controller.quiz.value != null) {
        final statusText = controller.quiz.value!.statusText;
        switch (statusText) {
          case '未开始':
            primaryColor = Colors.blue;
            break;
          case '进行中':
            primaryColor = Colors.green;
            break;
          case '已截止':
          case '已过期':
            primaryColor = Colors.red;
            break;
          case '已提交':
            primaryColor = Colors.orange;
            break;
          case '已批改':
            primaryColor = Colors.purple;
            break;
          default:
            primaryColor = Colors.grey;
        }
      }
      
      return Scaffold(
        backgroundColor: GlobalThemData.backgroundColor,
        appBar: AppBar(
          title: Text('问答详情'),
          centerTitle: true,
          backgroundColor: primaryColor,
          elevation: 0,
          actions: [
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: controller.refreshData,
              tooltip: '刷新',
            ),
          ],
        ),
        body: controller.isLoading.value
          ? Center(child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
            ))
          : _buildContent(primaryColor),
      );
    });
  }

  Widget _buildContent(Color primaryColor) {
    if (controller.quiz.value == null) {
      return Center(
        child: Text(
          '无法加载问答详情',
          style: TextStyle(
            fontSize: 16.sp,
            color: GlobalThemData.textSecondaryColor,
          ),
        ),
      );
    }

    final quiz = controller.quiz.value!;
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildQuizHeader(quiz, primaryColor),
          SizedBox(height: 16.h),
          _buildQuizEditor(quiz, primaryColor),
          SizedBox(height: 16.h),
          _buildSubmissionsList(primaryColor),
        ],
      ),
    );
  }
  
  Widget _buildQuizHeader(Assignment quiz, Color primaryColor) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor, primaryColor.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(
                        Icons.quiz,
                        color: Colors.white,
                        size: 24.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            quiz.title ?? '未命名问答',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              quiz.statusText,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
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
                            '班级',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            controller.className.value,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            '已提交',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            '${controller.submittedCount.value}/${controller.totalStudents.value}',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '已批改',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            '${controller.gradedCount.value}/${controller.submittedCount.value}',
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
            ),
          ),
          if (!quiz.isExpired)
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(12.r),
                ),
              ),
              child: ElevatedButton.icon(
                onPressed: controller.endQuiz,
                icon: Icon(Icons.stop_circle_outlined),
                label: Text('结束问答'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: primaryColor,
                  elevation: 0,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildQuizEditor(Assignment quiz, Color primaryColor) {
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
                Icons.edit_note,
                size: 24.sp,
                color: primaryColor,
              ),
              SizedBox(width: 8.w),
              Text(
                '问答编辑',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: GlobalThemData.textPrimaryColor,
                ),
              ),
              Spacer(),
              Obx(() => controller.isUpdatingQuiz.value
                ? SizedBox(
                    width: 20.w,
                    height: 20.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.w,
                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                    ),
                  )
                : TextButton.icon(
                    onPressed: controller.updateQuizInfo,
                    icon: Icon(Icons.save, size: 18.sp),
                    label: Text('保存修改'),
                    style: TextButton.styleFrom(
                      foregroundColor: primaryColor,
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                    ),
                  ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          
          // 标题
          Text(
            '问答标题',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: GlobalThemData.textPrimaryColor,
            ),
          ),
          SizedBox(height: 8.h),
          TextField(
            controller: controller.titleController.value,
            decoration: InputDecoration(
              hintText: '请输入问答标题',
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(color: primaryColor),
              ),
              contentPadding: EdgeInsets.all(12.w),
            ),
          ),
          SizedBox(height: 16.h),
          
          // 描述
          Text(
            '问答描述',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: GlobalThemData.textPrimaryColor,
            ),
          ),
          SizedBox(height: 8.h),
          TextField(
            controller: controller.descriptionController.value,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: '请输入问答描述（可选）',
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(color: primaryColor),
              ),
              contentPadding: EdgeInsets.all(12.w),
            ),
          ),
          SizedBox(height: 16.h),
          
          // 时间选择
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '开始时间',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: GlobalThemData.textPrimaryColor,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Obx(() => GestureDetector(
                      onTap: controller.selectStartTime,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                controller.startTimeText.value.isEmpty 
                                    ? '选择开始时间' 
                                    : controller.startTimeText.value,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: controller.startTimeText.value.isEmpty 
                                      ? Colors.grey 
                                      : GlobalThemData.textPrimaryColor,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.calendar_today,
                              size: 18.sp,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    )),
                  ],
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '截止时间',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: GlobalThemData.textPrimaryColor,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Obx(() => GestureDetector(
                      onTap: controller.selectEndTime,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                controller.endTimeText.value.isEmpty 
                                    ? '选择截止时间' 
                                    : controller.endTimeText.value,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: controller.endTimeText.value.isEmpty 
                                      ? Colors.grey 
                                      : GlobalThemData.textPrimaryColor,
                                ),
                              ),
                            ),
                            Icon(
                              Icons.calendar_today,
                              size: 18.sp,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ),
                    )),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildSubmissionsList(Color primaryColor) {
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
                Icons.assignment_turned_in,
                size: 24.sp,
                color: primaryColor,
              ),
              SizedBox(width: 8.w),
              Text(
                '学生提交',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: GlobalThemData.textPrimaryColor,
                ),
              ),
              Spacer(),
              Obx(() => controller.isAutoGrading.value
                ? SizedBox(
                    width: 20.w,
                    height: 20.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.w,
                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                    ),
                  )
                : TextButton.icon(
                    onPressed: controller.autoGradeAll,
                    icon: Icon(Icons.auto_awesome, size: 18.sp),
                    label: Text('一键批改'),
                    style: TextButton.styleFrom(
                      foregroundColor: primaryColor,
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                    ),
                  ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Obx(() {
            if (controller.isLoadingSubmissions.value) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.h),
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                  ),
                ),
              );
            } else if (controller.submissions.isEmpty) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.h),
                  child: Column(
                    children: [
                      Icon(
                        Icons.assignment_outlined,
                        size: 48.sp,
                        color: Colors.grey.shade400,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        '暂无学生提交',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: GlobalThemData.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            } else {
              return Column(
                children: [
                  // 表头
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Text(
                            '学生',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            '提交时间',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            '状态',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Text(
                            '分数',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(width: 60.w),
                      ],
                    ),
                  ),
                  SizedBox(height: 8.h),
                  // 提交列表
                  ...controller.submissions.map((submission) => _buildSubmissionItem(submission, primaryColor)).toList(),
                ],
              );
            }
          }),
        ],
      ),
    );
  }
  
  Widget _buildSubmissionItem(Submission submission, Color primaryColor) {
    // 获取状态文本和颜色
    String statusText;
    Color statusColor;
    
    if (submission.isGraded) {
      statusText = '已批改';
      statusColor = Colors.green;
    } else {
      statusText = '待批改';
      statusColor = Colors.orange;
    }
    
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16.r,
                  backgroundColor: primaryColor.withOpacity(0.2),
                  child: Text(
                    submission.username?.isNotEmpty == true 
                        ? submission.username!.substring(0, 1).toUpperCase() 
                        : '?',
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    submission.username ?? '未知学生',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: GlobalThemData.textPrimaryColor,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              submission.formattedSubmitTime,
              style: TextStyle(
                fontSize: 14.sp,
                color: GlobalThemData.textSecondaryColor,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Text(
                statusText,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: statusColor,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              submission.isGraded ? '${submission.score}' : '-',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: submission.isGraded ? FontWeight.bold : FontWeight.normal,
                color: submission.isGraded ? Colors.green : GlobalThemData.textSecondaryColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(width: 8.w),
          SizedBox(
            width: 52.w,
            child: TextButton(
              onPressed: () => controller.viewSubmission(submission),
              child: Text(
                submission.isGraded ? '查看' : '批改',
                style: TextStyle(
                  fontSize: 12.sp,
                ),
              ),
              style: TextButton.styleFrom(
                foregroundColor: primaryColor,
                backgroundColor: primaryColor.withOpacity(0.1),
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizInfo(Assignment quiz) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8.h),
            
            // 添加批改模式信息
            if (quiz.feedbackMode != null)
              Column(
                children: [
                  Divider(height: 24.h),
                  Row(
                    children: [
                      Icon(
                        Icons.grading,
                        size: 18.sp,
                        color: GlobalThemData.textSecondaryColor,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        '批改模式: ',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: GlobalThemData.textSecondaryColor,
                        ),
                      ),
                      Text(
                        quiz.feedbackModeText,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: GlobalThemData.textPrimaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  
                  // 如果是自动批改，显示批改时间
                  if (quiz.feedbackMode != 0)
                    Padding(
                      padding: EdgeInsets.only(top: 8.h),
                      child: Row(
                        children: [
                          Icon(
                            Icons.timer,
                            size: 18.sp,
                            color: GlobalThemData.textSecondaryColor,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            '批改时间: ',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: GlobalThemData.textSecondaryColor,
                            ),
                          ),
                          Text(
                            quiz.feedbackTimeText,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: quiz.feedbackMode == 2 ? Colors.blue : Colors.orange,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                  // 如果是自动批改，添加AI批改说明
                  if (quiz.feedbackMode != 0)
                    Padding(
                      padding: EdgeInsets.only(top: 12.h),
                      child: Container(
                        padding: EdgeInsets.all(12.w),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.smart_toy_outlined,
                              size: 16.sp,
                              color: Colors.blue,
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Text(
                                '本问答将由AI自动批改，您可以在批改前手动批改或修改批改设置。',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
} 
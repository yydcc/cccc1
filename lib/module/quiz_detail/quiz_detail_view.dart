import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../common/theme/color.dart';
import '../../model/assignment_model.dart';
import '../../model/submission_model.dart';
import 'quiz_detail_controller.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class QuizDetailView extends GetView<QuizDetailController> {
  const QuizDetailView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // 根据测验状态获取主题色
      Color primaryColor = Colors.purple;
      List<Color> gradientColors = [Color(0xFF9E9E9E), Color(0xFF616161)];
      
      if (!controller.isLoading.value && controller.quiz.value != null) {
        // 使用控制器的方法获取正确的状态文本
        final statusText = controller.getStatusText(
          controller.quiz.value!, 
          controller.submission.value
        );
        gradientColors = _getStatusGradient(statusText);
        primaryColor = gradientColors[0];
      }
      
      return Scaffold(
        backgroundColor: GlobalThemData.backgroundColor,
        appBar: AppBar(
          title: Text('课堂测验'),
          centerTitle: true,
          elevation: 0,
          backgroundColor: primaryColor,
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
          '无法加载测验详情',
          style: TextStyle(
            fontSize: 16.sp,
            color: GlobalThemData.textSecondaryColor,
          ),
        ),
      );
    }

    final quiz = controller.quiz.value!;
    final submission = controller.submission.value;
    // 使用控制器的方法获取正确的状态文本
    final String statusText = controller.getStatusText(quiz, submission);
    
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildQuizHeader(quiz, submission, statusText),
          SizedBox(height: 16.h),
          _buildQuizInfo(quiz, primaryColor),
          SizedBox(height: 16.h),
          if (submission != null && submission.isGraded)
            _buildFeedbackCard(submission, primaryColor),
          if (submission == null || !submission.isGraded)
            _buildAnswerSection(primaryColor, statusText),
        ],
      ),
    );
  }

  Widget _buildQuizHeader(Assignment quiz, Submission? submission, String statusText) {
    // 获取状态对应的图标
    IconData statusIcon;
    switch (statusText) {
      case '未开始':
        statusIcon = Icons.quiz_outlined;
        break;
      case '进行中':
        statusIcon = Icons.edit_note;
        break;
      case '已提交':
        statusIcon = Icons.check_circle_outline;
        break;
      case '已批改':
        statusIcon = Icons.grading;
        break;
      case '已过期':
        statusIcon = Icons.timer_off;
        break;
      default:
        statusIcon = Icons.quiz_outlined;
    }
    
    // 根据状态获取对应的渐变色
    List<Color> statusGradient = _getStatusGradient(statusText);
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: statusGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: statusGradient[0].withOpacity(0.3),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              statusIcon,
              color: Colors.white,
              size: 28.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  quiz.title ?? '课堂测验',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        offset: Offset(0, 1),
                        blurRadius: 3.0,
                        color: Colors.black.withOpacity(0.3),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 4.h),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizInfo(Assignment quiz, Color primaryColor) {
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
                '测验信息',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: GlobalThemData.textPrimaryColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          _buildInfoRow(
            icon: Icons.calendar_today,
            title: '开始时间',
            content: quiz.formattedCreateTime,
            iconColor: primaryColor,
          ),
          SizedBox(height: 12.h),
          _buildInfoRow(
            icon: Icons.access_time,
            title: '截止时间',
            content: quiz.formattedDeadline,
            iconColor: quiz.isDeadlineNear ? Colors.red : primaryColor,
          ),
          SizedBox(height: 16.h),
          Text(
            '测验说明',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: GlobalThemData.textPrimaryColor,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            quiz.description?.isNotEmpty == true 
                ? quiz.description! 
                : '请根据教师课堂提问，在下方添加回答。可以根据需要添加或删除回答框。',
            style: TextStyle(
              fontSize: 14.sp,
              color: GlobalThemData.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerSection(Color primaryColor, String statusText) {
    // 只有在进行中状态才允许编辑
    bool canEdit = statusText == '进行中';
    
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
                Icons.question_answer,
                size: 24.sp,
                color: primaryColor,
              ),
              SizedBox(width: 8.w),
              Text(
                '回答区域',
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '添加或删除回答框',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: GlobalThemData.textSecondaryColor,
                ),
              ),
              ElevatedButton.icon(
                onPressed: canEdit ? () => controller.addAnswerField() : null,
                icon: Icon(Icons.add, size: 18.sp),
                label: Text('添加回答'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Obx(() => Column(
            children: List.generate(
              controller.answerFields.length,
              (index) => _buildAnswerField(index, primaryColor, canEdit),
            ),
          )),
          SizedBox(height: 24.h),
          // 添加保存和提交按钮
          Row(
            children: [
              // 保存按钮
              Expanded(
                child: Obx(() => ElevatedButton(
                  onPressed: canEdit && !controller.isSaving.value
                      ? () => controller.saveQuiz()
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    disabledBackgroundColor: Colors.grey,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: Text(
                    controller.isSaving.value 
                        ? '保存中...' 
                        : '保存',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )),
              ),
              SizedBox(width: 12.w),
              // 提交按钮
              Expanded(
                child: Obx(() => ElevatedButton(
                  onPressed: canEdit && !controller.isSubmitting.value
                      ? () => controller.submitQuiz()
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    disabledBackgroundColor: Colors.grey,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: Text(
                    controller.isSubmitting.value 
                        ? '提交中...' 
                        : '提交测验',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerField(int index, Color primaryColor, bool canEdit) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        border: Border.all(color: primaryColor.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.vertical(top: Radius.circular(7.r)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '问题 ${index + 1}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: primaryColor,
                  ),
                ),
                if (canEdit)
                  Row(
                    children: [
                      Obx(() {
                        final hasAttachment = (controller.answerAttachments[index] ?? []).isNotEmpty;
                        return Row(
                          children: [
                            if (!hasAttachment) ...[
                              IconButton(
                                onPressed: () => controller.pickImage(index, ImageSource.camera),
                                icon: Icon(Icons.camera_alt, color: primaryColor, size: 20.sp),
                                padding: EdgeInsets.zero,
                                constraints: BoxConstraints(),
                                tooltip: '拍照',
                              ),
                              SizedBox(width: 8.w),
                              IconButton(
                                onPressed: () => controller.pickImage(index, ImageSource.gallery),
                                icon: Icon(Icons.photo_library, color: primaryColor, size: 20.sp),
                                padding: EdgeInsets.zero,
                                constraints: BoxConstraints(),
                                tooltip: '从相册选择',
                              ),
                              SizedBox(width: 8.w),
                              IconButton(
                                onPressed: () => controller.pickFile(index),
                                icon: Icon(Icons.attach_file, color: primaryColor, size: 20.sp),
                                padding: EdgeInsets.zero,
                                constraints: BoxConstraints(),
                                tooltip: '附加文件',
                              ),
                            ],
                            SizedBox(width: 8.w),
                            IconButton(
                              onPressed: () => controller.removeAnswerField(index),
                              icon: Icon(Icons.delete, color: Colors.red, size: 20.sp),
                              padding: EdgeInsets.zero,
                              constraints: BoxConstraints(),
                              tooltip: '删除此回答',
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
              ],
            ),
          ),
          TextField(
            controller: controller.answerControllers[index],
            maxLines: 4,
            enabled: canEdit,
            decoration: InputDecoration(
              hintText: '请输入回答...',
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(12.w),
            ),
            style: TextStyle(
              fontSize: 14.sp,
              color: GlobalThemData.textPrimaryColor,
            ),
          ),
          Obx(() {
            final attachments = controller.answerAttachments[index] ?? [];
            if (attachments.isEmpty) return SizedBox();
            
            return Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(7.r)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '附件:',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: GlobalThemData.textSecondaryColor,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: attachments.map((attachment) {
                      final bool isImage = attachment.path!.toLowerCase().endsWith('.jpg') ||
                                          attachment.path!.toLowerCase().endsWith('.jpeg') ||
                                          attachment.path!.toLowerCase().endsWith('.png');
                      
                      return Stack(
                        children: [
                          Container(
                            width: 80.w,
                            height: 80.w,
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: isImage
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(4.r),
                                    child: Image.file(
                                      File(attachment.path!),
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          _getFileIcon(attachment.path!),
                                          size: 32.sp,
                                          color: primaryColor,
                                        ),
                                        SizedBox(height: 4.h),
                                        Text(
                                          attachment.name,
                                          style: TextStyle(
                                            fontSize: 10.sp,
                                            color: GlobalThemData.textSecondaryColor,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                          ),
                          if (canEdit)
                            Positioned(
                              top: 0,
                              right: 0,
                              child: GestureDetector(
                                onTap: () => controller.removeAttachment(index, attachment),
                                child: Container(
                                  padding: EdgeInsets.all(4.w),
                                  decoration: BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.close,
                                    size: 12.sp,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    }).toList(),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  IconData _getFileIcon(String path) {
    final extension = path.split('.').last.toLowerCase();
    
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'ppt':
      case 'pptx':
        return Icons.slideshow;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image;
      case 'zip':
      case 'rar':
        return Icons.folder_zip;
      default:
        return Icons.insert_drive_file;
    }
  }

  Widget _buildFeedbackCard(Submission submission, Color primaryColor) {
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
                Icons.grading,
                size: 24.sp,
                color: primaryColor,
              ),
              SizedBox(width: 8.w),
              Text(
                '测验结果',
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
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  submission.score.toString(),
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '得分',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: GlobalThemData.textSecondaryColor,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${submission.score} 分',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: GlobalThemData.textPrimaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (submission.feedback != null && submission.feedback!.isNotEmpty) ...[
            SizedBox(height: 16.h),
            Text(
              '教师评语',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: GlobalThemData.textPrimaryColor,
              ),
            ),
            SizedBox(height: 8.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: primaryColor.withOpacity(0.1)),
              ),
              child: Text(
                submission.feedback!,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: GlobalThemData.textPrimaryColor,
                ),
              ),
            ),
          ],
          SizedBox(height: 16.h),
          Text(
            '提交内容',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: GlobalThemData.textPrimaryColor,
            ),
          ),
          SizedBox(height: 8.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: Colors.grey.withOpacity(0.1)),
            ),
            child: Text(
              submission.content ?? '无内容',
              style: TextStyle(
                fontSize: 14.sp,
                color: GlobalThemData.textPrimaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 添加状态渐变色方法
  List<Color> _getStatusGradient(String status) {
    switch (status) {
      case '未开始':
        return [Color(0xFF5C6BC0), Color(0xFF3949AB)]; // 蓝色渐变
      case '进行中':
        return [Color(0xFF66BB6A), Color(0xFF388E3C)]; // 绿色渐变
      case '已截止':
      case '已过期':
        return [Color(0xFFEF5350), Color(0xFFD32F2F)]; // 红色渐变
      case '已提交':
        return [Color(0xFFFF9800), Color(0xFFE65100)]; // 橙色渐变
      case '已批改':
        return [Color(0xFF9575CD), Color(0xFF5E35B1)]; // 紫色渐变
      default:
        return [Color(0xFF9E9E9E), Color(0xFF616161)]; // 灰色渐变
    }
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String content,
    required Color iconColor,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20.sp,
          color: iconColor,
        ),
        SizedBox(width: 8.w),
        Text(
          '$title: ',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: GlobalThemData.textPrimaryColor,
          ),
        ),
        Expanded(
          child: Text(
            content,
            style: TextStyle(
              fontSize: 14.sp,
              color: GlobalThemData.textSecondaryColor,
            ),
          ),
        ),
      ],
    );
  }
} 
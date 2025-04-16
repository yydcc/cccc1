import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../common/theme/color.dart';
import '../../model/assignment_model.dart';
import '../../model/submission_model.dart';
import 'assignment_detail_controller.dart';

class AssignmentDetailView extends GetView<AssignmentDetailController> {
  const AssignmentDetailView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      Color primaryColor = Colors.purple;

      if (!controller.isLoading.value && controller.assignment.value != null) {
        primaryColor = controller.assignment.value!.getStatusColor(controller.submission.value);
      }
      return Scaffold(
        backgroundColor: GlobalThemData.backgroundColor,
        appBar: AppBar(
            title: Text('作业详情'),
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
    },
    );
  }

  Widget _buildContent(Color primaryColor) {
    final assignment = controller.assignment.value!;
    final submission = controller.submission.value;

    if (controller.assignment.value == null) {
      return Center(
        child: Text(
          '无法加载作业详情',
          style: TextStyle(
            fontSize: 16.sp,
            color: GlobalThemData.textSecondaryColor,
          ),
        ),
      );
    }



    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderSection(assignment, submission, primaryColor),
          SizedBox(height: 16.h),
          _buildInfoCard(assignment, submission, primaryColor),
          SizedBox(height: 16.h),
          if (submission != null && submission.isGraded)
            _buildFeedbackCard(submission, primaryColor),
          SizedBox(height: 16.h),
          if (submission != null)
            _buildSubmissionCard(submission, primaryColor),
          SizedBox(height: 16.h),
          if (controller.canSubmit.value)
            _buildSubmitSection(primaryColor, isUpdate: controller.isSubmitted),
          if (!controller.canSubmit.value && !controller.isSubmitted)
            _buildExpiredNotice(),
        ],
      ),
    );
  }

  Widget _buildHeaderSection(Assignment assignment, Submission? submission, Color primaryColor) {
    // 获取状态文本和对应图标
    final String statusText = assignment.getStatusText(submission);
    
    // 根据状态文本获取对应的图标
    IconData statusIcon;
    switch (statusText) {
      case '未开始':
        statusIcon = Icons.assignment_outlined;
        break;
      case '进行中':
        statusIcon = Icons.edit_note;
        break;
      case '已提交':
      case '待批改':
        statusIcon = Icons.assignment_turned_in_outlined;
        break;
      case '已批改':
        statusIcon = Icons.grading;
        break;
      case '已过期':
        statusIcon = Icons.assignment_late;
        break;
      default:
        statusIcon = Icons.assignment_outlined;
    }
    

    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.3),
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
                  assignment.title ?? '',
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

  Widget _buildInfoCard(Assignment assignment, Submission? submission, Color primaryColor) {

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
                '作业信息',
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
            content: assignment.formattedCreateTime,
            iconColor: primaryColor,
          ),
          SizedBox(height: 12.h),
          _buildInfoRow(
            icon: Icons.access_time,
            title: '截止时间',
            content: assignment.formattedDeadline,
            iconColor: assignment.isDeadlineNear && submission == null
                ? Colors.red
                : primaryColor,
          ),
          
          if (assignment.description != null && assignment.description!.isNotEmpty) ...[
            SizedBox(height: 16.h),
          Text(
              '作业描述:',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: GlobalThemData.textPrimaryColor,
              ),
            ),
            SizedBox(height: 8.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: GlobalThemData.backgroundColor,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: primaryColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                assignment.description ?? '暂无描述',
            style: TextStyle(
                  fontSize: 14.sp,
              color: GlobalThemData.textPrimaryColor,
              height: 1.5,
            ),
          ),
            ),
          ],
          
          if (assignment.contentUrl != null && assignment.contentUrl!.isNotEmpty) ...[
            SizedBox(height: 16.h),
            Text(
              '作业附件:',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: GlobalThemData.textPrimaryColor,
              ),
            ),
            SizedBox(height: 8.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: GlobalThemData.backgroundColor,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: primaryColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _getFileIcon(assignment.contentUrl ?? ''),
                    size: 24.sp,
                    color: primaryColor,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      assignment.attachmentFileName ?? '',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: GlobalThemData.textSecondaryColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Container(
                    height: 36.h,
                    child: ElevatedButton(
                      onPressed: controller.downloadAttachment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.download, size: 16.sp, color: Colors.white),
                          SizedBox(width: 4.w),
                          Text('下载'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          // 添加批改模式信息
          if (assignment.feedbackMode != null)
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
                      assignment.feedbackModeText,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: GlobalThemData.textPrimaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),

                // 如果是自动批改，显示批改时间
                if (assignment.feedbackMode != 0)
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
                          assignment.feedbackTimeText,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: assignment.feedbackMode == 2 ? Colors.blue : Colors.orange,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String content,
    Color? iconColor,
    Color? contentColor,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18.sp,
          color: iconColor ?? GlobalThemData.textSecondaryColor,
        ),
        SizedBox(width: 8.w),
        Text(
          '$title:',
          style: TextStyle(
            fontSize: 14.sp,
            color: GlobalThemData.textSecondaryColor,
          ),
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Text(
          content,
          style: TextStyle(
            fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            color: contentColor ?? GlobalThemData.textPrimaryColor,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitSection( Color primaryColor, {bool isUpdate = false}) {
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
                Icons.edit,
                size: 20.sp,
                color: primaryColor,
              ),
              SizedBox(width: 8.w),
          Text(
                isUpdate ? '更新提交' : '提交作业',
            style: TextStyle(
                  fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: GlobalThemData.textPrimaryColor,
            ),
          ),
            ],
          ),
          SizedBox(height: 16.h),
          
          Container(
            margin: EdgeInsets.only(bottom: 16.h),
            decoration: BoxDecoration(
              color: GlobalThemData.backgroundColor,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Obx(() => Row(
            children: [
              Expanded(
                  child: InkWell(
                    onTap: () => controller.setSubmissionType('content'),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      decoration: BoxDecoration(
                        color: controller.submissionType.value == 'content'
                            ? primaryColor
                            : GlobalThemData.backgroundColor,
                        borderRadius: BorderRadius.horizontal(left: Radius.circular(8.r)),
                      ),
                      child: Center(
                        child: Text(
                          '文本提交',
                  style: TextStyle(
                    fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: controller.submissionType.value == 'content'
                                ? Colors.white
                                : GlobalThemData.textSecondaryColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () => controller.setSubmissionType('file'),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      decoration: BoxDecoration(
                        color: controller.submissionType.value == 'file'
                            ? primaryColor
                            : GlobalThemData.backgroundColor,
                        borderRadius: BorderRadius.horizontal(right: Radius.circular(8.r)),
                      ),
                      child: Center(
                        child: Text(
                          '文件提交',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: controller.submissionType.value == 'file'
                                ? Colors.white
                                : GlobalThemData.textSecondaryColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )),
          ),
          
          Obx(() => controller.submissionType.value == 'content'
              ? _buildContentSubmissionForm(primaryColor)
              : _buildFileSubmissionForm(primaryColor)
          ),
          
          SizedBox(height: 24.h),
          SizedBox(
            width: double.infinity,
            height: 48.h,
            child: Obx(() => ElevatedButton(
              onPressed: controller.assignment.value != null && controller.assignment.value!.isSubmittable 
                  ? () => controller.showSubmitDialog()
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                disabledBackgroundColor: Colors.grey,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: Text(
                controller.assignment.value != null && controller.assignment.value!.isSubmittable 
                    ? '提交作业' 
                    : (controller.assignment.value?.statusText == '未开始' ? '作业未开始' : '已过截止日期'),
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildContentSubmissionForm(Color primaryColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '作业内容',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: GlobalThemData.textPrimaryColor,
          ),
        ),
        SizedBox(height: 8.h),
        TextField(
          onChanged: (value) => controller.contentText.value = value,
          maxLines: 8,
          decoration: InputDecoration(
            hintText: '请输入作业内容...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          style: TextStyle(
            fontSize: 14.sp,
            color: GlobalThemData.textPrimaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildFileSubmissionForm(Color primaryColor) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: GlobalThemData.backgroundColor,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: primaryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Obx(() => Text(
              controller.selectedFileName.value.isEmpty
                ? '未选择文件'
                : controller.selectedFileName.value,
              style: TextStyle(
                fontSize: 14.sp,
                color: GlobalThemData.textSecondaryColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )),
          ),
          SizedBox(width: 8.w),
          Container(
            height: 36.h,
            child: ElevatedButton(
              onPressed: controller.pickFile,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.r),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.attach_file, size: 16.sp, color: Colors.white),
                  SizedBox(width: 4.w),
                  Text('选择文件'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpiredNotice() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      margin: EdgeInsets.only(top: 16.h),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Colors.red.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: Colors.red,
            size: 24.sp,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              '该作业处于${controller.assignment.value!.getStatusText(controller.submission.value)}状态，无法提交',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmissionCard(Submission submission, Color primaryColor) {
    final primaryColor = Theme.of(Get.context!).primaryColor;
    
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
                color: GlobalThemData.textPrimaryColor,
              ),
              SizedBox(width: 8.w),
              Text(
                '提交记录',
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
            title: '提交时间',
            content: submission.formattedSubmitTime,
            iconColor: primaryColor,
          ),
          if (submission.hasFile) ...[
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: GlobalThemData.backgroundColor,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: primaryColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _getFileIcon(submission.filePath!),
                    size: 24.sp,
                    color: primaryColor,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      submission.fileName ?? '',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: GlobalThemData.textSecondaryColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Container(
                    height: 36.h,
                    child: ElevatedButton(
                      onPressed: controller.downloadSubmissionFile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.download, size: 16.sp,color: Colors.white),
                          SizedBox(width: 4.w),
                          Text('下载'),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (submission.content != null && submission.content!.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Text(
              '提交内容:',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: GlobalThemData.textPrimaryColor,
              ),
            ),
            SizedBox(height: 8.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: GlobalThemData.backgroundColor,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: primaryColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Text(
                submission.content!,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: GlobalThemData.textSecondaryColor,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFeedbackCard(Submission submission,  Color primaryColor) {

    
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
                Icons.comment,
                size: 24.sp,
                color: Colors.orange,
              ),
              SizedBox(width: 8.w),
              Text(
                '教师评语',
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
            icon: Icons.score,
            title: '得分',
            content: '${submission.score}',
            contentColor: Colors.orange,
            iconColor: Colors.orange,
          ),
          SizedBox(height: 12.h),
          Text(
            '评语:',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: GlobalThemData.textPrimaryColor,
            ),
          ),
          SizedBox(height: 8.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: GlobalThemData.backgroundColor,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: Colors.orange.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              submission.feedback ?? '暂无评语',
              style: TextStyle(
                fontSize: 14.sp,
                color: GlobalThemData.textSecondaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }






  IconData _getFileIcon(String url) {
    if (url.isEmpty) return Icons.insert_drive_file;
    
    if (url.endsWith('.pdf')) {
      return Icons.picture_as_pdf;
    } else if (url.endsWith('.doc') || url.endsWith('.docx')) {
      return Icons.description;
    } else if (url.endsWith('.xls') || url.endsWith('.xlsx')) {
      return Icons.table_chart;
    } else if (url.endsWith('.ppt') || url.endsWith('.pptx')) {
      return Icons.slideshow;
    } else if (url.endsWith('.jpg') || url.endsWith('.jpeg') || url.endsWith('.png')) {
      return Icons.image;
    } else if (url.endsWith('.zip') || url.endsWith('.rar')) {
      return Icons.folder_zip;
    } else {
      return Icons.insert_drive_file;
    }
  }




}

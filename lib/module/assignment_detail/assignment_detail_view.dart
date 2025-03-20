import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../common/theme/color.dart';
import '../../model/assignment_model.dart';
import 'assignment_detail_controller.dart';

class AssignmentDetailView extends GetView<AssignmentDetailController> {
  const AssignmentDetailView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(Get.context!).primaryColor;
    
    return Scaffold(
      backgroundColor: GlobalThemData.backgroundColor,
      appBar: AppBar(
        title: Text('作业详情'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: primaryColor,
      ),
      body: Obx(() => controller.isLoading.value
        ? Center(child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
          ))
        : _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
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

    final assignment = controller.assignment.value!;
    final gradientColors = _getStatusGradient(assignment.status);
    final primaryColor = Theme.of(Get.context!).primaryColor;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderSection(assignment, gradientColors),
          SizedBox(height: 16.h),
          _buildInfoCard(assignment, gradientColors),
          SizedBox(height: 16.h),
          _buildDescriptionCard(assignment, gradientColors),
          SizedBox(height: 16.h),
          if (assignment.contentUrl != null && assignment.contentUrl!.isNotEmpty)
            _buildDownloadDocumentCard(assignment, gradientColors),
          SizedBox(height: 16.h),
          if (assignment.status == 'in_progress')
            _buildSubmitSection(gradientColors),
          if (assignment.status == 'expired' && !assignment.isSubmitted)
            _buildExpiredNotice(),
        ],
      ),
    );
  }

  Widget _buildHeaderSection(Assignment assignment, List<Color> gradientColors) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            gradientColors[0].withOpacity(0.1),
            gradientColors[1].withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: gradientColors[0].withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradientColors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(8.r),
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
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  assignment.title ?? '未命名作业',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: GlobalThemData.textPrimaryColor,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 6.h,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradientColors,
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
        ],
      ),
    );
  }

  Widget _buildInfoCard(Assignment assignment, List<Color> gradientColors) {
    final primaryColor = Theme.of(Get.context!).primaryColor;
    
    return Container(
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
        children: [
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
            iconColor: assignment.isDeadlineNear && assignment.status != 'submitted' && assignment.status != 'graded'
                ? Colors.red
                : primaryColor,
          ),
          if (assignment.status == 'graded') ...[
            SizedBox(height: 12.h),
            _buildInfoRow(
              icon: Icons.score,
              title: '得分',
              content: '${assignment.score}',
              contentColor: Colors.orange,
              iconColor: Colors.orange,
            ),
          ],
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

  Widget _buildDescriptionCard(Assignment assignment, List<Color> gradientColors) {
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
                Icons.description,
                size: 20.sp,
                color: gradientColors[0],
              ),
              SizedBox(width: 8.w),
              Text(
                '作业说明',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: GlobalThemData.textPrimaryColor,
                ),
              ),
            ],
          ),
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
              assignment.description ?? '无作业说明',
              style: TextStyle(
                fontSize: 14.sp,
                color: GlobalThemData.textPrimaryColor,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadDocumentCard(Assignment assignment, List<Color> gradientColors) {
    final primaryColor = Theme.of(Get.context!).primaryColor;
    final String? contentUrl = assignment.contentUrl;
    
    if (contentUrl == null || contentUrl.isEmpty) {
      return SizedBox.shrink();
    }
    
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
                Icons.file_download,
                size: 24.sp,
                color: primaryColor,
              ),
              SizedBox(width: 8.w),
              Text(
                '作业附件',
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
                  _getFileIcon(contentUrl),
                  size: 24.sp,
                  color: primaryColor,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    _getFileName(contentUrl),
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
                        Icon(Icons.download, size: 16.sp,color: Colors.white,),
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
      ),
    );
  }

  Widget _buildSubmitSection(List<Color> gradientColors) {
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
                Icons.edit,
                size: 20.sp,
                color: primaryColor,
              ),
              SizedBox(width: 8.w),
              Text(
                '提交作业',
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
              onPressed: controller.isSubmitting.value
                ? null
                : controller.submitAssignment,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                disabledBackgroundColor: primaryColor.withOpacity(0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: controller.isSubmitting.value
                ? SizedBox(
                    width: 24.w,
                    height: 24.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text('提交作业'),
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildContentSubmissionForm(Color primaryColor) {
    return TextField(
      maxLines: 5,
      decoration: InputDecoration(
        hintText: '请输入作业内容...',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(
            color: primaryColor.withOpacity(0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(
            color: primaryColor,
            width: 2,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(
            color: primaryColor.withOpacity(0.3),
          ),
        ),
      ),
      onChanged: (value) => controller.content.value = value,
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
              '该作业已过截止日期，无法提交',
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

  // 辅助方法
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
      case 'expired':
        return Icons.assignment_late;
      default:
        return Icons.assignment_outlined;
    }
  }

  List<Color> _getStatusGradient(String status) {
    final primaryColor = Theme.of(Get.context!).primaryColor;
    
    switch (status) {
      case 'not_started':
        return [Colors.grey.shade400, Colors.grey.shade600];
      case 'in_progress':
        return [primaryColor.withOpacity(0.7), primaryColor];
      case 'submitted':
        return [Colors.green.shade300, Colors.green.shade600];
      case 'graded':
        return [Colors.purple.shade300, Colors.purple.shade600];
      case 'expired':
        return [Colors.red.shade300, Colors.red.shade600];
      default:
        return [Colors.grey.shade400, Colors.grey.shade600];
    }
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

  String _getFileName(String url) {
    if (url.isEmpty) return '无附件';
    
    final uri = Uri.parse(url);
    final pathSegments = uri.pathSegments;
    if (pathSegments.isNotEmpty) {
      return pathSegments.last;
    }
    return '附件';
  }
} 
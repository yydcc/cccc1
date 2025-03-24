import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../common/theme/color.dart';
import 'create_assignment_controller.dart';
import 'dart:io';

class CreateAssignmentView extends GetView<CreateAssignmentController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GlobalThemData.backgroundColor,
      appBar: AppBar(
        title: Text('发布作业'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTitleField(),
            SizedBox(height: 16.h),
            _buildDescriptionField(),
            SizedBox(height: 16.h),
            _buildDeadlineSelector(),
            SizedBox(height: 16.h),
            _buildAttachmentSelector(),
            SizedBox(height: 24.h),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTitleField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '作业标题',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: GlobalThemData.textPrimaryColor,
          ),
        ),
        SizedBox(height: 8.h),
        TextField(
          controller: controller.titleController,
          decoration: InputDecoration(
            hintText: '请输入作业标题',
            filled: true,
            fillColor: Colors.white,
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
              borderSide: BorderSide(color: Theme.of(Get.context!).primaryColor),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '作业描述',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: GlobalThemData.textPrimaryColor,
          ),
        ),
        SizedBox(height: 8.h),
        TextField(
          controller: controller.descriptionController,
          maxLines: 5,
          decoration: InputDecoration(
            hintText: '请输入作业描述（选填）',
            filled: true,
            fillColor: Colors.white,
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
              borderSide: BorderSide(color: Theme.of(Get.context!).primaryColor),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildDeadlineSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '截止日期',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: GlobalThemData.textPrimaryColor,
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: controller.selectDeadlineDate,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Obx(() => Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 20.sp,
                        color: GlobalThemData.textSecondaryColor,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        controller.deadlineDate.value.isEmpty
                            ? '选择日期'
                            : controller.deadlineDate.value,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: controller.deadlineDate.value.isEmpty
                              ? GlobalThemData.textSecondaryColor
                              : GlobalThemData.textPrimaryColor,
                        ),
                      ),
                    ],
                  )),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: GestureDetector(
                onTap: controller.selectDeadlineTime,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Obx(() => Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 20.sp,
                        color: GlobalThemData.textSecondaryColor,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        controller.deadlineTime.value.isEmpty
                            ? '选择时间'
                            : controller.deadlineTime.value,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: controller.deadlineTime.value.isEmpty
                              ? GlobalThemData.textSecondaryColor
                              : GlobalThemData.textPrimaryColor,
                        ),
                      ),
                    ],
                  )),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildAttachmentSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '附件（选填）',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: GlobalThemData.textPrimaryColor,
          ),
        ),
        SizedBox(height: 8.h),
        Obx(() => controller.selectedFile.value.isEmpty
          ? _buildFileSelector()
          : _buildSelectedFile()
        ),
      ],
    );
  }
  
  Widget _buildFileSelector() {
    return GestureDetector(
      onTap: controller.selectFile,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 24.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: Colors.grey.shade300,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.cloud_upload,
              size: 40.sp,
              color: Theme.of(Get.context!).primaryColor.withOpacity(0.7),
            ),
            SizedBox(height: 8.h),
            Text(
              '点击上传附件',
              style: TextStyle(
                fontSize: 14.sp,
                color: GlobalThemData.textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSelectedFile() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Obx(() {
        final fileName = controller.selectedFile.value.split('/').last;
        return Row(
          children: [
            Icon(
              Icons.insert_drive_file,
              size: 24.sp,
              color: Theme.of(Get.context!).primaryColor,
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                fileName,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: GlobalThemData.textPrimaryColor,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.close,
                size: 20.sp,
                color: Colors.grey,
              ),
              onPressed: () => controller.selectedFile.value = '',
            ),
          ],
        );
      }),
    );
  }
  
  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: Obx(() => ElevatedButton(
        onPressed: controller.isSubmitting.value
            ? null
            : controller.createAssignment,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(Get.context!).primaryColor,
          padding: EdgeInsets.symmetric(vertical: 12.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          disabledBackgroundColor: Theme.of(Get.context!).primaryColor.withOpacity(0.6),
        ),
        child: controller.isSubmitting.value
            ? SizedBox(
                width: 24.w,
                height: 24.w,
                child: CircularProgressIndicator(
                  strokeWidth: 2.w,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                '发布作业',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
      )),
    );
  }
} 
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
            Text(
              '开始时间',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: GlobalThemData.textPrimaryColor,
              ),
            ),
            SizedBox(height: 8.h),
            TextFormField(
              controller: controller.startTimeController,
              decoration: InputDecoration(
                hintText: '选择作业开始时间',
                prefixIcon: const Icon(Icons.calendar_today),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 12.h,
                ),
              ),
              readOnly: true,
              onTap: controller.selectStartTime,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return '请选择开始时间';
                }
                return null;
              },
            ),
            SizedBox(height: 16.h),
            Text(
              '截止时间',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: GlobalThemData.textPrimaryColor,
              ),
            ),
            SizedBox(height: 8.h),
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
            hintText: '请输入作业描述',
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
    return TextFormField(
      controller: controller.deadlineController,
      decoration: InputDecoration(
        hintText: '选择作业截止时间',
        prefixIcon: const Icon(Icons.event),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 12.h,
        ),
      ),
      readOnly: true,
      onTap: controller.selectDeadline,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '请选择截止时间';
        }
        return null;
      },
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
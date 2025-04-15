import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../common/theme/color.dart';
import 'create_quiz_controller.dart';

class CreateQuizView extends GetView<CreateQuizController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GlobalThemData.backgroundColor,
      appBar: AppBar(
        title: Text('发布课堂测验'),
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
                hintText: '选择测验开始时间',
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
            SizedBox(height: 24.h),
            _buildInfoCard(),
            SizedBox(height: 16.h),
            _buildFeedbackSettings(),
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
          '测验标题',
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
            hintText: '请输入测验标题',
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
        hintText: '选择测验截止时间',
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
  
  Widget _buildInfoCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Colors.blue,
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                '课堂测验说明',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            '1. 课堂测验是一种特殊的作业类型，适用于课堂即时提问。',
            style: TextStyle(
              fontSize: 12.sp,
              color: GlobalThemData.textPrimaryColor,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            '2. 测验创建后，学生可以在测验界面看到并提交答案。',
            style: TextStyle(
              fontSize: 12.sp,
              color: GlobalThemData.textPrimaryColor,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            '3. 测验结束后，您可以添加描述和附件，并进行批改。',
            style: TextStyle(
              fontSize: 12.sp,
              color: GlobalThemData.textPrimaryColor,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildFeedbackSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '批改设置',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: GlobalThemData.textPrimaryColor,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '批改模式',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: GlobalThemData.textPrimaryColor,
                ),
              ),
              SizedBox(height: 8.h),
              Obx(() => Column(
                children: [
                  RadioListTile<int>(
                    title: Text('手动批改', style: TextStyle(fontSize: 14.sp)),
                    value: 0,
                    groupValue: controller.feedbackMode.value,
                    onChanged: (value) => controller.feedbackMode.value = value!,
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  ),
                  RadioListTile<int>(
                    title: Text('截止后自动批改（时间阈值）', style: TextStyle(fontSize: 14.sp)),
                    value: 1,
                    groupValue: controller.feedbackMode.value,
                    onChanged: (value) => controller.feedbackMode.value = value!,
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  ),
                  if (controller.feedbackMode.value == 1)
                    Padding(
                      padding: EdgeInsets.only(left: 32.w, right: 16.w, bottom: 8.h),
                      child: TextField(
                        controller: controller.thresholdMinutesController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: '截止后多少分钟自动批改',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 8.h,
                          ),
                        ),
                      ),
                    ),
                  RadioListTile<int>(
                    title: Text('指定时间自动批改', style: TextStyle(fontSize: 14.sp)),
                    value: 2,
                    groupValue: controller.feedbackMode.value,
                    onChanged: (value) => controller.feedbackMode.value = value!,
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  ),
                  if (controller.feedbackMode.value == 2)
                    Padding(
                      padding: EdgeInsets.only(left: 32.w, right: 16.w, bottom: 8.h),
                      child: GestureDetector(
                        onTap: controller.selectReleaseTime,
                        child: AbsorbPointer(
                          child: TextField(
                            controller: controller.releaseTimeController,
                            decoration: InputDecoration(
                              hintText: '选择批改结果发布时间',
                              prefixIcon: const Icon(Icons.event),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 8.h,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              )),
              SizedBox(height: 8.h),
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16.sp,
                      color: Colors.blue,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        '自动批改将使用AI对学生提交进行评分，并自动发布结果。',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: Obx(() => ElevatedButton(
        onPressed: controller.isSubmitting.value
            ? null
            : controller.createQuiz,
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
                '发布测验',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
      )),
    );
  }
} 
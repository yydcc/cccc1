import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../common/theme/color.dart';
import '../../routes/app_pages.dart';
import 'schedule_controller.dart';
import '../../flutter_illuminate/ui.dart'; // Importing the BottomSheetDatePicker

class ScheduleView extends GetView<ScheduleController> {
  const ScheduleView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.grey[100]!, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '备忘录',
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w700,
                    color: GlobalThemData.textPrimaryColor,
                  ),
                ),
                SizedBox(height: 24.h),
                Obx(() => TextField(
                  controller: controller.taskController,
                  decoration: InputDecoration(
                    hintText: '请输入要做的事情',
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: Icon(Icons.note, color: Theme.of(context).primaryColor),
                    suffixIcon: controller.taskController.text.isNotEmpty
                        ? IconButton(
                      icon: Icon(Icons.clear, color: GlobalThemData.textSecondaryColor),
                      onPressed: () => controller.taskController.clear(),
                    )
                        : null,
                    errorText: controller.taskError.value.isEmpty ? null : controller.taskError.value,
                  ),
                )),
                SizedBox(height: 16.h),
                Obx(() => GestureDetector(
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                      builder: (context, child) {
                        return Theme(
                          data: Theme.of(context).copyWith(
                            colorScheme: ColorScheme.light(
                              primary: Theme.of(context).primaryColor,
                              onPrimary: Colors.white,
                              surface: Colors.grey[100]!,
                            ),
                            dialogBackgroundColor: Colors.white,
                          ),
                          child: child!,
                        );
                      },
                    );
                    if (pickedDate != null) {
                      controller.dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
                    }
                  },
                  child: AbsorbPointer(
                    child: TextField(
                      controller: controller.dateController,
                      decoration: InputDecoration(
                        hintText: '请选择日期（YYYY-MM-DD）',
                        filled: true,
                        fillColor: Colors.grey[200],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide.none,
                        ),
                        prefixIcon: Icon(Icons.calendar_today, color: Theme.of(context).primaryColor),
                        errorText: controller.dateError.value.isEmpty ? null : controller.dateError.value,
                      ),
                    ),
                  ),
                )),
                SizedBox(height: 24.h),
                Obx(() => AnimatedScale(
                  scale: controller.isTaskValid.value ? 1.0 : 0.95,
                  duration: const Duration(milliseconds: 200),
                  child: Tooltip(
                    message: controller.isTaskValid.value ? '添加备忘录' : '请填写备忘事项和日期',
                    child: SizedBox(
                      width: double.infinity,
                      height: 50.h,
                      child: ElevatedButton(
                        onPressed: controller.isTaskValid.value ? controller.addMemo : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          disabledBackgroundColor: Theme.of(context).primaryColor.withOpacity(0.5),
                          elevation: 5,
                          shadowColor: Theme.of(context).primaryColor.withOpacity(0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Text(
                          '添加备忘录',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                )),
                SizedBox(height: 24.h),
                Expanded(
                  child: Obx(() => ListView.builder(
                    itemCount: controller.schedules.length,
                    itemBuilder: (context, index) {
                      final schedule = controller.schedules[index];
                      return AnimatedOpacity(
                        opacity: schedule.isCompleted ? 0.6 : 1.0,
                        duration: const Duration(milliseconds: 300),
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.h),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.2),
                                  spreadRadius: 1,
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ListTile(
                              leading: Checkbox(
                                value: schedule.isCompleted,
                                onChanged: (value) => controller.toggleCompletion(index),
                                activeColor: Theme.of(context).primaryColor,
                              ),
                              title: Text(
                                schedule.task,
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  decoration: schedule.isCompleted
                                      ? TextDecoration.lineThrough
                                      : TextDecoration.none,
                                  color: schedule.isCompleted
                                      ? GlobalThemData.textSecondaryColor
                                      : GlobalThemData.textPrimaryColor,
                                ),
                              ),
                              subtitle: Text(
                                schedule.date,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: GlobalThemData.textSecondaryColor,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  )),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
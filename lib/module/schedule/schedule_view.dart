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
      backgroundColor: GlobalThemData.backgroundColor,
      appBar: AppBar(
        title: const Text('备忘录'),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        titleTextStyle: TextStyle(
          fontSize: 20.sp,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
        actions: [
          Obx(() => AnimatedScale(
            scale: controller.schedules.isNotEmpty ? 1.0 : 0.95,
            duration: const Duration(milliseconds: 200),
            child: Tooltip(
              message: controller.schedules.isNotEmpty ? '生成计划' : '请先添加备忘录事项',
              child: TextButton.icon(
                onPressed: controller.schedules.isNotEmpty && !controller.isGeneratingPlan.value
                    ? controller.generatePlan
                    : null,
                icon: controller.isGeneratingPlan.value
                    ? SizedBox(
                        width: 16.w,
                        height: 16.w,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Icon(
                        Icons.auto_awesome,
                        color: controller.schedules.isNotEmpty ? Colors.white : Colors.white.withOpacity(0.5),
                        size: 20.sp,
                      ),
                label: Text(
                  '生成计划',
                  style: TextStyle(
                    color: controller.schedules.isNotEmpty ? Colors.white : Colors.white.withOpacity(0.5),
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ),
          )),
          SizedBox(width: 8.w),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(16.r),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 8.h),
                    width: 40.w,
                    height: 4.h,
        decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                Obx(() => TextField(
                  controller: controller.taskController,
                  decoration: InputDecoration(
                    hintText: '请输入要做的事情',
                    filled: true,
                            fillColor: Colors.grey[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide.none,
                    ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: BorderSide(
                                color: Theme.of(context).primaryColor.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: BorderSide(
                                color: Theme.of(context).primaryColor,
                                width: 1.5,
                              ),
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
                        SizedBox(height: 12.h),
                        Row(
                          children: [
                            Expanded(
                              child: Obx(() => GestureDetector(
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
                                            surface: Colors.white,
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
                                      hintText: '选择日期',
                        filled: true,
                                      fillColor: Colors.grey[50],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide.none,
                        ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12.r),
                                        borderSide: BorderSide(
                                          color: Theme.of(context).primaryColor.withOpacity(0.2),
                                          width: 1,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12.r),
                                        borderSide: BorderSide(
                                          color: Theme.of(context).primaryColor,
                                          width: 1.5,
                                        ),
                                      ),
                        prefixIcon: Icon(Icons.calendar_today, color: Theme.of(context).primaryColor),
                        errorText: controller.dateError.value.isEmpty ? null : controller.dateError.value,
                      ),
                    ),
                  ),
                )),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Obx(() => GestureDetector(
                                onTap: () async {
                                  TimeOfDay? pickedTime = await showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay.now(),
                                    builder: (context, child) {
                                      return Theme(
                                        data: Theme.of(context).copyWith(
                                          colorScheme: ColorScheme.light(
                                            primary: Theme.of(context).primaryColor,
                                            onPrimary: Colors.white,
                                            surface: Colors.white,
                                          ),
                                          dialogBackgroundColor: Colors.white,
                                        ),
                                        child: child!,
                                      );
                                    },
                                  );
                                  if (pickedTime != null) {
                                    controller.timeController.text = '${pickedTime.hour.toString().padLeft(2, '0')}:${pickedTime.minute.toString().padLeft(2, '0')}';
                                  }
                                },
                                child: AbsorbPointer(
                                  child: TextField(
                                    controller: controller.timeController,
                                    decoration: InputDecoration(
                                      hintText: '选择时间',
                                      filled: true,
                                      fillColor: Colors.grey[50],
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12.r),
                                        borderSide: BorderSide.none,
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12.r),
                                        borderSide: BorderSide(
                                          color: Theme.of(context).primaryColor.withOpacity(0.2),
                                          width: 1,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12.r),
                                        borderSide: BorderSide(
                                          color: Theme.of(context).primaryColor,
                                          width: 1.5,
                                        ),
                                      ),
                                      prefixIcon: Icon(Icons.access_time, color: Theme.of(context).primaryColor),
                                      errorText: controller.timeError.value.isEmpty ? null : controller.timeError.value,
                                    ),
                                  ),
                                ),
                              )),
                            ),
                          ],
                        ),
                        SizedBox(height: 16.h),
                        SizedBox(
                      width: double.infinity,
                      height: 50.h,
                          child: Obx(() => ElevatedButton(
                            onPressed: controller.isTaskValid.value ? () {
                              controller.addMemo();
                              Navigator.pop(context);
                            } : null,
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
                          )),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        backgroundColor: Theme.of(context).primaryColor,
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          minimum: EdgeInsets.only(bottom: 16.h),
          child: CustomScrollView(
            slivers: [
              Obx(() {
                if (controller.schedules.isEmpty) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 120.w,
                            height: 120.w,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.note_add_outlined,
                              size: 60.sp,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                SizedBox(height: 24.h),
                          Text(
                            '暂无备忘录',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w600,
                              color: GlobalThemData.textPrimaryColor,
                            ),
                          ),
                          SizedBox(height: 12.h),
                          Text(
                            '点击右下角按钮添加备忘录\n添加后可以生成AI建议计划',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: GlobalThemData.textSecondaryColor,
                              height: 1.5,
                            ),
                          ),
                          SizedBox(height: 32.h),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.auto_awesome,
                                  size: 16.sp,
                                  color: Theme.of(context).primaryColor,
                                ),
                                SizedBox(width: 8.w),
                                Text(
                                  '添加备忘录后可以生成AI计划',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final schedule = controller.schedules[index];
                      return AnimatedOpacity(
                        opacity: schedule.isCompleted ? 0.6 : 1.0,
                        duration: const Duration(milliseconds: 300),
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(16.w, index == 0 ? 16.h : 0, 16.w, 12.h),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.1),
                                  spreadRadius: 1,
                                  blurRadius: 5,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ListTile(
                              onLongPress: () => _showDeleteDialog(context, index, schedule.task),
                              leading: Container(
                                width: 40.w,
                                height: 40.w,
                                decoration: BoxDecoration(
                                  color: schedule.isCompleted
                                      ? Theme.of(context).primaryColor.withOpacity(0.1)
                                      : Colors.grey[100],
                                  borderRadius: BorderRadius.circular(20.r),
                                ),
                                child: Checkbox(
                                value: schedule.isCompleted,
                                onChanged: (value) => controller.toggleCompletion(index),
                                activeColor: Theme.of(context).primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.r),
                                  ),
                                ),
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
                                '${schedule.date} ${schedule.time}',
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
                    childCount: controller.schedules.length,
                  ),
                );
              }),
              // AI 建议计划
              Obx(() {
                if (controller.aiPlan.value.isEmpty) {
                  return const SliverToBoxAdapter(child: SizedBox.shrink());
                }
                return SliverToBoxAdapter(
                  child: Container(
                    margin: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ExpansionTile(
                      title: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8.w),
                            decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Icon(
                              Icons.lightbulb_outline,
                              color: Colors.amber,
                              size: 20.sp,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Text(
                            'AI 建议计划',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: GlobalThemData.textPrimaryColor,
                            ),
                ),
              ],
            ),
                      children: [
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 16.w),
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(
                              color: Colors.grey[200]!,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            controller.aiPlan.value,
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: GlobalThemData.textSecondaryColor,
                              height: 1.5,
                            ),
                          ),
                        ),
                        SizedBox(height: 16.h),
                      ],
                    ),
                  ),
                );
              }),
              // 底部间距
              const SliverToBoxAdapter(
                child: SizedBox(height: 80),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, int index, String task) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '删除备忘事项',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: GlobalThemData.textPrimaryColor,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                '确定要删除"$task"吗？',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: GlobalThemData.textSecondaryColor,
                ),
              ),
              SizedBox(height: 20.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text(
                      '取消',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: GlobalThemData.textPrimaryColor,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  ElevatedButton(
                    onPressed: () {
                      controller.deleteMemo(index);
                      Get.back();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Text(
                      '删除',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
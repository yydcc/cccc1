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
      ),
      body: Container(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '备忘录',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: GlobalThemData.textPrimaryColor,
              ),
            ),
            SizedBox(height: 10.h),
            TextField(
              controller: controller.taskController,
              decoration: InputDecoration(
                hintText: '请输入要做的事情',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10.h),
            GestureDetector(
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (pickedDate != null) {
                  controller.dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
                }
              },
              child: AbsorbPointer(
                child: TextField(
                  controller: controller.dateController,
                  decoration: InputDecoration(
                    hintText: '请输入日期（YYYY-MM-DD）',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10.h),
            ElevatedButton(
              onPressed: controller.addMemo,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              ),
              child: Text(
                '添加备忘录',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 10.h),
            Expanded(
              child: Obx(() => ListView.builder(
                itemCount: controller.schedules.length,
                itemBuilder: (context, index) {
                  final schedule = controller.schedules[index];
                  return ListTile(
                    title: Text(schedule.task),
                    subtitle: Text(schedule.date),
                  );
                },
              )),
            ),
          ],
        ),
      ),
    );
  }
}
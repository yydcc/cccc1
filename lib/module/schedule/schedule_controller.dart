import 'package:get/get.dart';
import 'package:flutter/material.dart';

class ScheduleController extends GetxController {
  final TextEditingController taskController = TextEditingController();
  final TextEditingController dateController = TextEditingController();
  final RxList<Schedule> schedules = <Schedule>[].obs;
  
  @override
  void onClose() {
    taskController.dispose();
    dateController.dispose();
    super.onClose();
  }
  
  void addMemo() {
    if (taskController.text.isNotEmpty && dateController.text.isNotEmpty) {
      schedules.add(Schedule(
        task: taskController.text,
        date: dateController.text,
      ));
      taskController.clear();
      dateController.clear();
    } else {
      Get.snackbar('提示', '请输入任务和日期');
    }
  }
}

class Schedule {
  final String task;
  final String date;

  Schedule({required this.task, required this.date});
}
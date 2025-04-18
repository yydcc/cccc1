import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Schedule {
  String task;
  String date;
  bool isCompleted;

  Schedule({required this.task, required this.date, this.isCompleted = false});
}

class ScheduleController extends GetxController {
  final taskController = TextEditingController();
  final dateController = TextEditingController();
  final schedules = <Schedule>[].obs;
  final isTaskValid = false.obs;
  final taskError = ''.obs;
  final dateError = ''.obs;

  @override
  void onInit() {
    super.onInit();
    taskController.addListener(() {
      taskError.value = '';
      validateInputs();
    });
    dateController.addListener(() {
      dateError.value = '';
      validateInputs();
    });
  }

  @override
  void onClose() {
    taskController.dispose();
    dateController.dispose();
    super.onClose();
  }

  void validateInputs() {
    isTaskValid.value = taskController.text.isNotEmpty && dateController.text.isNotEmpty;
  }

  void addMemo() {
    if (taskController.text.isEmpty) {
      taskError.value = '请输入备忘事项';
      return;
    }
    if (dateController.text.isEmpty) {
      dateError.value = '请选择日期';
      return;
    }

    schedules.add(Schedule(
      task: taskController.text,
      date: dateController.text,
    ));
    Get.snackbar(
      '成功',
      '备忘录已添加',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
    taskController.clear();
    dateController.clear();
    taskError.value = '';
    dateError.value = '';
    isTaskValid.value = false;
  }
  void deleteMemo(int index) {
    schedules.removeAt(index);
  }


  void toggleCompletion(int index) {
    schedules[index].isCompleted = !schedules[index].isCompleted;
    schedules.refresh();
  }
}
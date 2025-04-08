import 'package:get/get.dart';
import 'package:flutter/material.dart';

class Memo {
  final String task;
  final String date;

  Memo({required this.task, required this.date});
}

class MemoController extends GetxController {
  final taskController = TextEditingController();
  final dateController = TextEditingController();
  final memos = <Memo>[].obs;

  void addMemo() {
    final task = taskController.text;
    final date = dateController.text;

    if (task.isNotEmpty && date.isNotEmpty) {
      memos.add(Memo(task: task, date: date));
      taskController.clear();
      dateController.clear();
      scheduleReminder(task, date);
    }
  }

  void scheduleReminder(String task, String date) {
    // Implement the logic to schedule reminders
    // This could be using a timer, local notifications, or any other method
  }
}
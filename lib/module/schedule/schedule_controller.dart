import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../common/theme/color.dart';
import '../../common/utils/http.dart';
import 'package:dio/dio.dart';
import '../../common/api/api.dart';

class Schedule {
  String task;
  String date;
  String time;
  bool isCompleted;

  Schedule({
    required this.task,
    required this.date,
    required this.time,
    this.isCompleted = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'task': task,
      'date': date,
      'time': time,
      'isCompleted': isCompleted
    };
  }

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      task: json['task'],
      date: json['date'],
      time: json['time'] ?? '00:00',
      isCompleted: json['isCompleted'] ?? false,
    );
  }
}

class ScheduleController extends GetxController {
  final taskController = TextEditingController();
  final dateController = TextEditingController();
  final timeController = TextEditingController();
  final schedules = <Schedule>[].obs;
  final isTaskValid = false.obs;
  final taskError = ''.obs;
  final dateError = ''.obs;
  final timeError = ''.obs;
  final _prefs = SharedPreferences.getInstance();
  final RxBool isGeneratingPlan = false.obs;
  final RxString aiPlan = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSchedules();
    _loadPlan();
    taskController.addListener(() {
      taskError.value = '';
      validateInputs();
    });
    dateController.addListener(() {
      dateError.value = '';
      validateInputs();
    });
    timeController.addListener(() {
      timeError.value = '';
      validateInputs();
    });
  }

  Future<void> _loadSchedules() async {
    try {
      final prefs = await _prefs;
      final schedulesJson = prefs.getStringList('schedules') ?? [];
      schedules.value = schedulesJson
          .map((json) => Schedule.fromJson(jsonDecode(json)))
          .toList();
    } catch (e) {
      print('加载备忘录失败: $e');
    }
  }

  Future<void> _loadPlan() async {
    try {
      final prefs = await _prefs;
      aiPlan.value = prefs.getString('ai_plan') ?? '';
    } catch (e) {
      print('加载计划失败: $e');
    }
  }

  Future<void> _saveSchedules() async {
    try {
      final prefs = await _prefs;
      final schedulesJson = schedules
          .map((schedule) => jsonEncode(schedule.toJson()))
          .toList();
      await prefs.setStringList('schedules', schedulesJson);
    } catch (e) {
      print('保存备忘录失败: $e');
    }
  }

  Future<void> _savePlan(String plan) async {
    try {
      final prefs = await _prefs;
      await prefs.setString('ai_plan', plan);
      aiPlan.value = plan;
    } catch (e) {
      print('保存计划失败: $e');
    }
  }

  @override
  void onClose() {
    taskController.dispose();
    dateController.dispose();
    timeController.dispose();
    super.onClose();
  }

  void validateInputs() {
    isTaskValid.value = taskController.text.isNotEmpty && 
                       dateController.text.isNotEmpty && 
                       timeController.text.isNotEmpty;
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
    if (timeController.text.isEmpty) {
      timeError.value = '请选择时间';
      return;
    }

    schedules.add(Schedule(
      task: taskController.text,
      date: dateController.text,
      time: timeController.text,
    ));
    _saveSchedules();
    Get.snackbar(
      '成功',
      '备忘录已添加',

    );
    taskController.clear();
    dateController.clear();
    timeController.clear();
    taskError.value = '';
    dateError.value = '';
    timeError.value = '';
    isTaskValid.value = false;
  }

  void deleteMemo(int index) {
    schedules.removeAt(index);
    _saveSchedules();
  }

  void toggleCompletion(int index) {
    schedules[index].isCompleted = !schedules[index].isCompleted;
    schedules.refresh();
    _saveSchedules();
  }

  Future<void> generatePlan() async {
    if (schedules.isEmpty) {
      Get.snackbar('提示', '请先添加备忘录事项');
      return;
    }

    isGeneratingPlan.value = true;
    try {
      final response = await API.schedules.generatePlan(
        schedules.map((s) => s.toJson()).toList(),
      );
      
      if (response.code == 200) {
        final plan = response.data['plan'] as String;
        await _savePlan(plan);
        Get.snackbar(
          '成功',
          '计划已生成',
          snackPosition: SnackPosition.TOP,

          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      } else {
        Get.snackbar(
          '错误',
          response.msg ?? '生成计划失败，请稍后重试',
        );
      }
    } catch (e) {
      Get.snackbar(
        '错误',
        '生成计划失败，请检查网络连接',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isGeneratingPlan.value = false;
    }
  }
}
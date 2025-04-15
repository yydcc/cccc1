import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import '../../common/utils/http.dart';
import '../../common/api/api.dart';
import '../../common/utils/storage.dart';
import 'package:dio/dio.dart' as dio;
import 'dart:convert';

class CreateAssignmentController extends GetxController {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final RxString selectedFile = ''.obs;
  final RxBool isSubmitting = false.obs;
  final RxString deadlineDate = ''.obs;
  final RxString deadlineTime = ''.obs;
  final startTimeController = TextEditingController();
  final Rx<DateTime?> selectedStartTime = Rx<DateTime?>(DateTime.now());
  final deadlineController = TextEditingController();
  final Rx<DateTime?> selectedDeadline = Rx<DateTime?>(null);
  final RxInt feedbackMode = 0.obs; // 0: 手动批改, 1: 时间阈值, 2: 固定时间点
  final TextEditingController thresholdMinutesController = TextEditingController();
  final TextEditingController releaseTimeController = TextEditingController();
  final Rx<DateTime?> selectedReleaseTime = Rx<DateTime?>(null);
  
  final String classId;
  
  CreateAssignmentController({required this.classId});
  
  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
    thresholdMinutesController.dispose();
    releaseTimeController.dispose();
    super.onClose();
  }
  
  Future<void> selectFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      
      if (result != null) {
        File file = File(result.files.single.path!);
        selectedFile.value = file.path;
      }
    } catch (e) {
      print('选择文件失败: $e');
      Get.snackbar('错误', '选择文件失败');
    }
  }
  
  void selectDeadline() async {
    final DateTime now = DateTime.now();
    final DateTime initialDate = selectedDeadline.value ?? 
        (selectedStartTime.value?.add(const Duration(days: 7)) ?? now.add(const Duration(days: 7)));
    
    final DateTime? picked = await showDatePicker(
      context: Get.context!,
      initialDate: initialDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    
    if (picked != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: Get.context!,
        initialTime: TimeOfDay.now(),
      );
      
      if (pickedTime != null) {
        final DateTime combinedDateTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        
        if (selectedStartTime.value != null && 
            combinedDateTime.isBefore(selectedStartTime.value!)) {
          Get.snackbar('错误', '截止时间不能早于开始时间');
          return;
        }
        
        selectedDeadline.value = combinedDateTime;
        deadlineController.text = _formatDateTime(combinedDateTime);
        
        deadlineDate.value = '${picked.year}-${_twoDigits(picked.month)}-${_twoDigits(picked.day)}';
        deadlineTime.value = '${_twoDigits(pickedTime.hour)}:${_twoDigits(pickedTime.minute)}';
      }
    }
  }
  
  void selectStartTime() async {
    final DateTime now = DateTime.now();
    
    final DateTime? picked = await showDatePicker(
      context: Get.context!,
      initialDate: selectedStartTime.value ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    
    if (picked != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: Get.context!,
        initialTime: TimeOfDay.now(),
      );
      
      if (pickedTime != null) {
        final DateTime combinedDateTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        
        selectedStartTime.value = combinedDateTime;
        startTimeController.text = _formatDateTime(combinedDateTime);
      }
    }
  }
  
  void selectReleaseTime() async {
    final DateTime now = DateTime.now();
    
    final DateTime? picked = await showDatePicker(
      context: Get.context!,
      initialDate: selectedReleaseTime.value ?? now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );
    
    if (picked != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: Get.context!,
        initialTime: TimeOfDay.now(),
      );
      
      if (pickedTime != null) {
        final DateTime combinedDateTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        
        selectedReleaseTime.value = combinedDateTime;
        releaseTimeController.text = _formatDateTime(combinedDateTime);
      }
    }
  }
  
  Future<void> createAssignment() async {
    if (titleController.text.isEmpty) {
      Get.snackbar('提示', '请输入作业标题');
      return;
    }
    
    if (selectedDeadline.value == null) {
      Get.snackbar('提示', '请选择截止时间');
      return;
    }
    
    if (selectedStartTime.value == null) {
      Get.snackbar('提示', '请选择开始时间');
      return;
    }
    
    if (selectedStartTime.value!.isAfter(selectedDeadline.value!)) {
      Get.snackbar('错误', '截止时间不能早于开始时间');
      return;
    }
    
    // 验证批改设置
    if (feedbackMode.value == 1 && thresholdMinutesController.text.isEmpty) {
      Get.snackbar('提示', '请输入时间阈值');
      return;
    }
    
    if (feedbackMode.value == 2 && selectedReleaseTime.value == null) {
      Get.snackbar('提示', '请选择发布时间');
      return;
    }
    
    try {
      isSubmitting.value = true;
      
      final storage = await StorageService.instance;
      final teacherId = storage.getUserId();
      
      // 创建Assignment对象
      final Map<String, dynamic> assignmentData = {
        'title': titleController.text,
        'description': descriptionController.text,
        'classId': int.parse(classId),
        'teacherId': teacherId,
        'deadline': _formatDateTimeForApi(selectedDeadline.value!),
        'createTime': _formatDateTimeForApi(selectedStartTime.value!),
        'feedbackMode': feedbackMode.value,
      };
      
      // 添加时间阈值或发布时间
      if (feedbackMode.value == 1 && thresholdMinutesController.text.isNotEmpty) {
        assignmentData['thresholdMinutes'] = int.parse(thresholdMinutesController.text);
      } else if (feedbackMode.value == 2 && selectedReleaseTime.value != null) {
        assignmentData['releaseTime'] = _formatDateTimeForApi(selectedReleaseTime.value!);
      }
      
      // 准备文件（如果有）
      File? fileToUpload = null;
      if (selectedFile.value.isNotEmpty) {
        fileToUpload = File(selectedFile.value);
      }
      
      final response = await API.assignments.createAssignment(assignmentData, fileToUpload);
      
      if (response.code == 200) {
        Get.back(result: true);
        Get.snackbar('成功', '作业发布成功');
      } else {
        Get.snackbar('发布失败', response.msg);
      }
    } catch (e) {
      print('发布作业失败: $e');
      Get.snackbar('错误', '发布作业失败，请稍后重试');
    } finally {
      isSubmitting.value = false;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}-${_twoDigits(dateTime.month)}-${_twoDigits(dateTime.day)} ${_twoDigits(dateTime.hour)}:${_twoDigits(dateTime.minute)}';
  }

  String _formatDateTimeForApi(DateTime dateTime) {
    return '${dateTime.year}-${_twoDigits(dateTime.month)}-${_twoDigits(dateTime.day)} ${_twoDigits(dateTime.hour)}:${_twoDigits(dateTime.minute)}:00';
  }

  String _twoDigits(int n) {
    if (n >= 10) return '$n';
    return '0$n';
  }
} 
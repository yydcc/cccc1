import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import '../../common/utils/http.dart';
import '../../common/utils/storage.dart';

class CreateAssignmentController extends GetxController {
  final HttpUtil httpUtil = HttpUtil();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final RxString selectedFile = ''.obs;
  final RxBool isSubmitting = false.obs;
  final RxString deadlineDate = ''.obs;
  final RxString deadlineTime = ''.obs;
  
  final String classId;
  
  CreateAssignmentController({required this.classId});
  
  @override
  void onClose() {
    titleController.dispose();
    descriptionController.dispose();
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
  
  Future<void> selectDeadlineDate() async {
    final DateTime? picked = await showDatePicker(
      context: Get.context!,
      initialDate: DateTime.now().add(Duration(days: 7)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    
    if (picked != null) {
      deadlineDate.value = '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    }
  }
  
  Future<void> selectDeadlineTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: Get.context!,
      initialTime: TimeOfDay.now(),
    );
    
    if (picked != null) {
      deadlineTime.value = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    }
  }
  
  Future<void> createAssignment() async {
    if (titleController.text.isEmpty) {
      Get.snackbar('错误', '请输入作业标题');
      return;
    }
    
    if (deadlineDate.value.isEmpty || deadlineTime.value.isEmpty) {
      Get.snackbar('错误', '请设置截止日期和时间');
      return;
    }
    
    try {
      isSubmitting.value = true;
      
      final storage = await StorageService.instance;
      final teacherId = storage.getUserId();
      
      // 构建表单数据
      final formData = {
        'title': titleController.text,
        'description': descriptionController.text,
        'classId': classId,
        'teacherId': teacherId,
        'deadline': '${deadlineDate.value}T${deadlineTime.value}:00',
      };
      
      // 如果有附件，添加到表单
      if (selectedFile.value.isNotEmpty) {
        // 这里需要根据后端API的要求处理文件上传
        // 可能需要使用MultipartRequest或其他方式
      }
      
      final response = await httpUtil.post(
        '/assignment/create',
        data: formData,
      );
      
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
} 
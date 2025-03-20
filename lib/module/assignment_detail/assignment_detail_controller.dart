import 'package:cccc1/common/utils/storage.dart';
import 'package:get/get.dart';
import '../../model/assignment_model.dart';
import '../../common/utils/http.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AssignmentDetailController extends GetxController {

  final HttpUtil httpUtil = HttpUtil();
  final assignment = Rx<Assignment?>(null);
  final RxBool isLoading = true.obs;
  final RxBool isSubmitting = false.obs;
  final RxString selectedFileName = ''.obs;
  final RxString content = ''.obs;
  File? selectedFile;
  final int assignmentId;
  
  final RxString submissionType = 'content'.obs; // 'content' 或 'file'
  
  AssignmentDetailController({required this.assignmentId});

  @override
  void onInit() {
    super.onInit();
    loadAssignmentDetail();
  }

  void setSubmissionType(String type) {
    submissionType.value = type;
  }

  Future<void> loadAssignmentDetail() async {
    try {
      isLoading.value = true;
      final response = await httpUtil.get('/assignment/detail/$assignmentId');
      
      if (response.code == 200 && response.data != null) {
        assignment.value = Assignment.fromJson(response.data);
        print('获取到的附件URL: ${assignment.value?.contentUrl}');
      }
    } catch (e) {
      print('加载作业详情失败: $e');
      Get.snackbar('错误', '获取作业详情失败');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        if (file.path != null) {
          selectedFile = File(file.path!);
          selectedFileName.value = file.name;
          submissionType.value = 'file';
        }
      }
    } catch (e) {
      print('选择文件失败: $e');
      Get.snackbar('错误', '选择文件失败');
    }
  }

  Future<void> submitAssignment() async {
    if (submissionType.value == 'content' && content.value.trim().isEmpty) {
      Get.snackbar('提示', '请输入作业内容');
      return;
    } else if (submissionType.value == 'file' && selectedFile == null) {
      Get.snackbar('提示', '请选择要提交的文件');
      return;
    }

    try {
      isSubmitting.value = true;
      
      if (submissionType.value == 'file') {
        await submitFileAssignment();
      } else {
        await submitContentAssignment();
      }
    } catch (e) {
      print('提交作业失败: $e');
      Get.snackbar('错误', '提交作业失败，请稍后重试');
    } finally {
      isSubmitting.value = false;
    }
  }
  
  Future<void> submitFileAssignment() async {
    if (selectedFile == null) {
      Get.snackbar('提示', '请选择要提交的文件');
      return;
    }

    final formData = FormData({
      'assignmentId': assignment.value?.assignmentId,
      'studentId': (await StorageService.instance).getUserId() ?? 0,
    });
    
    formData.files.add(MapEntry(
      'file',
      MultipartFile(
        selectedFile!.path,
        filename: selectedFileName.value,
      ),
    ));
    
    final response = await httpUtil.post(
      '/assignment/submit/file',
      data: formData,
    );
    
    if (response.code == 200) {
      Get.back(result: true);
      Get.snackbar('成功', '作业文件提交成功');
    } else {
      Get.snackbar('失败', response.msg);
    }
  }
  
  Future<void> submitContentAssignment() async {
    if (content.value.trim().isEmpty) {
      Get.snackbar('提示', '请输入作业内容');
      return;
    }
    
    final data = {
      'assignmentId': assignment.value?.assignmentId,
      'studentId': (await StorageService.instance).getUserId() ?? 0,
      'content': content.value,
    };
    
    final response = await httpUtil.post(
      '/assignment/submit/content',
      data: data,
    );
    
    if (response.code == 200) {
      Get.back(result: true);
      Get.snackbar('成功', '作业内容提交成功');
    } else {
      Get.snackbar('失败', response.msg);
    }
  }

  Future<void> downloadAttachment() async {
    final String? contentUrl = assignment.value?.contentUrl;
    
    if (contentUrl == null || contentUrl.isEmpty) {
      Get.snackbar('提示', '没有可下载的附件');
      return;
    }
    
    try {
      print('尝试下载附件: $contentUrl');
      final Uri? url = Uri.tryParse(contentUrl);
      if (url != null && await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        Get.snackbar('错误', '无法打开附件链接');
      }
    } catch (e) {
      print('下载附件失败: $e');
      Get.snackbar('错误', '下载附件失败: $e');
    }
  }
} 
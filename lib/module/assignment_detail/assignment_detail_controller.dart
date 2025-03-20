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
  
  AssignmentDetailController({required this.assignmentId});

  @override
  void onInit() {
    super.onInit();
    loadAssignmentDetail();
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
        }
      }
    } catch (e) {
      print('选择文件失败: $e');
      Get.snackbar('错误', '选择文件失败');
    }
  }

  Future<void> submitAssignment() async {
    if (content.value.isEmpty && selectedFile == null) {
      Get.snackbar('提示', '请输入作业内容或上传文件');
      return;
    }

    try {
      isSubmitting.value = true;
      
      final formData = FormData({
        'assignmentId': assignment.value?.assignmentId,
        'content': content.value,
      });

      if (selectedFile != null) {
        formData.files.add(MapEntry(
          'file',
          MultipartFile(
            selectedFile!.path,
            filename: selectedFileName.value,
          ),
        ));
      }

      final response = await httpUtil.post(
        '/student/assignment/submit',
        data: formData,
      );

      if (response.code == 200) {
        Get.back(result: true);
        Get.snackbar('成功', '作业提交成功');
      } else {
        Get.snackbar('失败', response.msg);
      }
    } catch (e) {
      print('提交作业失败: $e');
      Get.snackbar('错误', '提交作业失败，请稍后重试');
    } finally {
      isSubmitting.value = false;
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
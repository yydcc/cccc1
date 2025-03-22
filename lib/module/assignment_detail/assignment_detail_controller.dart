import 'package:cccc1/common/utils/storage.dart';
import 'package:get/get.dart';
import '../../model/assignment_model.dart';
import '../../model/submission_model.dart';
import '../../common/utils/http.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dio/dio.dart' as dio;

class AssignmentDetailController extends GetxController {

  final HttpUtil httpUtil = HttpUtil();
  final assignment = Rx<Assignment?>(null);
  final submission = Rx<Submission?>(null);
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
      
      // 加载作业详情
      await _fetchAssignmentDetail();
      
      // 加载提交信息
      await _fetchSubmissionDetail();
      
    } catch (e) {
      print('加载作业详情失败: $e');
      Get.snackbar('错误', '获取作业详情失败');
    } finally {
      isLoading.value = false;
    }
  }
  
  // 获取作业详情
  Future<void> _fetchAssignmentDetail() async {
    final response = await httpUtil.get('/assignment/detail/$assignmentId');
    
    if (response.code == 200 && response.data != null) {
      assignment.value = Assignment.fromJson(response.data);
      print('获取到的附件URL: ${assignment.value?.contentUrl}');
    } else {
      throw Exception('获取作业详情失败: ${response.msg}');
    }
  }
  
  // 获取提交信息
  Future<void> _fetchSubmissionDetail() async {
    final prefs = await StorageService.instance;
    final studentId = prefs.getUserId() ?? 0;
    
    try {
      final submissionResponse = await httpUtil.get(
        "/submission/detail",
        queryParameters: {
          'studentId': studentId,
          'assignmentId': assignmentId,
        }
      );
      
      if (submissionResponse.code == 200 && submissionResponse.data != null) {
        submission.value = Submission.fromJson(submissionResponse.data);
        print('获取到的提交信息: ${submission.value?.submissionId}');
      }
    } catch (e) {
      print('获取提交信息失败: $e');
      // 这里不抛出异常，因为没有提交记录是正常情况
    }
  }

  // 判断作业是否已提交
  bool get isSubmitted {
    return submission.value != null && submission.value!.isSubmitted;
  }

  // 判断作业是否已批改
  bool get isGraded {
    return submission.value?.isGraded ?? false;
  }

  // 获取作业状态
  String getAssignmentStatus() {
    if (submission.value != null) {
      if (submission.value!.isGraded) {
        return 'graded';
      } else if (submission.value!.isSubmitted) {
        return 'submitted';
      }
    }
    
    return assignment.value?.status ?? 'in_progress';
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
      
      // 检查作业是否已过期
      final assignment = this.assignment.value;
      if (assignment != null && assignment.status == 'expired') {
        Get.snackbar('提示', '作业已过期，无法提交');
        return;
      }
      
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

    try {
      final formData = dio.FormData.fromMap({
        'assignmentId': assignment.value?.assignmentId,
        'studentId': (await StorageService.instance).getUserId() ?? 0,
      });
      
      formData.files.add(
        MapEntry(
          'file',
          await dio.MultipartFile.fromFile(
            selectedFile!.path,
            filename: selectedFileName.value,
          ),
        ),
      );
      
      final response = await httpUtil.post(
        '/assignment/submit/file',
        data: formData,
      );
      
      if (response.code == 200) {
        // 更新提交状态
        await loadAssignmentDetail();
        Get.back(result: true);
        Get.snackbar('成功', '作业文件提交成功');
      } else {
        Get.snackbar('失败', response.msg);
      }
    } catch (e) {
      print('提交文件失败: $e');
      Get.snackbar('错误', '提交文件失败: ${e.toString()}');
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
      // 更新提交状态
      await loadAssignmentDetail();
      Get.back(result: true);
      Get.snackbar('成功', '作业内容提交成功');
    } else {
      Get.snackbar('失败', response.msg);
    }
  }

  // 下载作业附件
  Future<void> downloadAttachment() async {
    final String? contentUrl = assignment.value?.contentUrl;
    
    if (contentUrl == null || contentUrl!.isEmpty) {
      Get.snackbar('提示', '没有可下载的附件');
      return;
    }
    
    try {
      // 使用完整路径：服务器基地址 + contentUrl
      final String fullUrl = HttpUtil.SERVER_API_URL + contentUrl;
      print('尝试下载附件: $fullUrl');
      
      final Uri? url = Uri.tryParse(fullUrl);
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

  // 下载提交文件
  Future<void> downloadSubmissionFile() async {
    final String? filePath = submission.value?.filePath;
    
    if (filePath == null || filePath.isEmpty) {
      Get.snackbar('提示', '没有可下载的提交文件');
      return;
    }
    
    try {
      // 使用完整路径：服务器基地址 + filePath
      final String fullUrl = HttpUtil.SERVER_API_URL + filePath;
      print('尝试下载提交文件: $fullUrl');
      
      final Uri? url = Uri.tryParse(fullUrl);
      if (url != null && await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        Get.snackbar('错误', '无法打开文件链接');
      }
    } catch (e) {
      print('下载提交文件失败: $e');
      Get.snackbar('错误', '下载提交文件失败: $e');
    }
  }
} 
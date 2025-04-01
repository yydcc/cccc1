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
import '../../common/api/api.dart';

class AssignmentDetailController extends GetxController {

  final HttpUtil httpUtil = HttpUtil();
  final assignment = Rx<Assignment?>(null);
  final submission = Rx<Submission?>(null);
  final RxBool isLoading = true.obs;
  final RxBool isSubmitting = false.obs;
  final RxString selectedFile = ''.obs;
  final RxString contentText = ''.obs;
  File? selectedFileObj;
  final int assignmentId;
  final RxString submissionType = 'content'.obs; // 'content' 或 'file'
  final RxString selectedFileName = ''.obs;
  final RxBool canSubmit = false.obs;
  
  AssignmentDetailController({required this.assignmentId});

  @override
  void onInit() {
    super.onInit();
    loadAssignmentDetail();
    

  }

  @override
  void onClose() {
    super.onClose();
  }

  void setSubmissionType(String type) {
    submissionType.value = type;
  }

  Future<void> loadAssignmentDetail() async {
    try {
      isLoading.value = true;
      
      final response = await API.assignments.getAssignmentDetail(assignmentId);
      
      if (response.code == 200 && response.data != null) {
        assignment.value = Assignment.fromJson(response.data);
        
        // 加载提交信息
        await loadSubmission();
        
        // 根据作业状态决定是否显示提交按钮
        canSubmit.value = _canSubmitAssignment();
        
        // 打印调试信息
        print('作业状态: ${assignment.value?.getStatusText(submission.value)}');
        print('提交信息: ${submission.value?.isSubmitted}');
      } else {
        Get.snackbar('错误', '获取作业详情失败: ${response.msg}');
      }
    } catch (e) {
      print('加载作业详情失败: $e');
      Get.snackbar('错误', '获取作业详情失败，请检查网络连接');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadSubmission() async {
    try {
      final storage = await StorageService.instance;
      final studentId = storage.getUserId() ?? 0;
      
      final response = await API.submissions.getStudentSubmission(
        assignmentId, 
        studentId
      );
      
      if (response.code == 200 && response.data != null) {
        submission.value = Submission.fromJson(response.data);
      }
    } catch (e) {
      print('加载提交记录失败: $e');
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
    
    return assignment.value?.statusText ?? 'in_progress';
  }

  Future<void> selectFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      
      if (result != null) {
        File file = File(result.files.single.path!);
        selectedFile.value = file.path;
        selectedFileObj = file;
        submissionType.value = 'file';
      }
    } catch (e) {
      print('选择文件失败: $e');
      Get.snackbar('错误', '选择文件失败');
    }
  }

  Future<void> pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      
      if (result != null) {
        File file = File(result.files.single.path!);
        selectedFile.value = file.path;
        selectedFileName.value = file.path.split('/').last;
      }
    } catch (e) {
      print('选择文件失败: $e');
      Get.snackbar('错误', '选择文件失败');
    }
  }

  Future<void> submitAssignment() async {
    // 检查是否可以提交
    if (!canSubmit.value) {
      if (assignment.value?.isExpired ?? false) {
        Get.snackbar('提示', '作业已过期，无法提交');
      } else if (!(assignment.value?.isStarted ?? true)) {
        Get.snackbar('提示', '作业尚未开始，无法提交');
      }
      return;
    }
    
    // 检查是否有文本或文件
    final String content = contentText.value.trim();
    final bool hasFile = selectedFile.value.isNotEmpty;
    
    // 如果既没有文本也没有文件，显示错误提示
    if (content.isEmpty && !hasFile) {
      Get.snackbar('提示', '请输入文本内容或上传文件');
      return;
    }
    
    try {
      isSubmitting.value = true;
      
      // 获取学生ID
      final storage = await StorageService.instance;
      final studentId = storage.getUserId() ?? 0;
      
      dynamic response;
      
      if (hasFile) {
        // 提交文件
        final formData = dio.FormData();
        final file = File(selectedFile.value);
        final fileName = file.path.split('/').last;
        
        formData.files.add(MapEntry(
          'file',
          await dio.MultipartFile.fromFile(
            file.path,
            filename: fileName,
          ),
        ));
        
        formData.fields.add(MapEntry('studentId', studentId.toString()));
        
        response = await API.assignments.submitFile(
          assignmentId, 
          studentId,
          formData,
        );
      } else {
        // 提交文本内容
        response = await API.assignments.submitContent(
          assignmentId,
          studentId,
          content,
        );
      }
      
      if (response.code == 200) {
        Get.snackbar('成功', '作业提交成功');
        
        // 重新加载提交信息
        await loadSubmission();
        
        // 清空输入
        contentText.value = '';
        selectedFile.value = '';
      } else {
        Get.snackbar('错误', '提交失败: ${response.msg}');
      }
    } catch (e) {
      print('提交作业失败: $e');
      Get.snackbar('错误', '提交失败，请稍后重试');
    } finally {
      isSubmitting.value = false;
    }
  }
  

  // 下载作业附件
  Future<void> downloadAttachment() async {
    if (assignment.value == null || 
        assignment.value!.contentUrl == null || 
        assignment.value!.contentUrl!.isEmpty) {
      Get.snackbar('提示', '没有可下载的附件');
      return;
    }
    
    try {
      final String fullUrl = HttpUtil.SERVER_API_URL + assignment.value!.contentUrl!;
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

  bool _canSubmitAssignment() {
    if (assignment.value == null) return false;
    
    // 如果作业未开始或已过期，不能提交
    if (!assignment.value!.isStarted || assignment.value!.isExpired) {
      return false;
    }
    
    return true;
  }
} 
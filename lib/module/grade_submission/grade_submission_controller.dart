import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../common/utils/http.dart';
import '../../common/api/api.dart';
import '../../model/submission_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart' as dio;

class GradeSubmissionController extends GetxController {
  final submission = Rx<Submission?>(null);
  final RxBool isLoading = true.obs;
  final RxBool isSubmitting = false.obs;
  final RxBool isAutoGrading = false.obs;
  final RxString autoGradingStatus = ''.obs; // 添加自动批改状态信息
  
  final scoreController = TextEditingController();
  final feedbackController = TextEditingController();
  
  final int submissionId;
  
  GradeSubmissionController({required this.submissionId});
  
  @override
  void onInit() {
    super.onInit();
    loadSubmissionDetail();
  }
  
  @override
  void onClose() {
    scoreController.dispose();
    feedbackController.dispose();
    super.onClose();
  }
  
  Future<void> loadSubmissionDetail() async {
    try {
      isLoading.value = true;
      
      final response = await API.submissions.getSubmissionDetail(submissionId);
      
      if (response.code == 200 && response.data != null) {
        submission.value = Submission.fromJson(response.data);
        
        // 预填充评分和反馈
        if (submission.value != null) {
          scoreController.text = submission.value!.score.toString();
          feedbackController.text = submission.value!.feedback ?? '';
        }
      } else {
        Get.snackbar('错误', '获取提交详情失败: ${response.msg}');
      }
    } catch (e) {
      print('加载提交详情失败: $e');
      Get.snackbar('错误', '获取提交详情失败，请检查网络连接');
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> submitGrade() async {
    if (isSubmitting.value) return;
    
    try {
      isSubmitting.value = true;
      
      if (scoreController.text.isEmpty) {
        Get.snackbar('提示', '请输入分数');
        return;
      }
      
      final double score = double.tryParse(scoreController.text) ?? 0;
      
      if (score < 0 || score > 100) {
        Get.snackbar('提示', '分数应在0-100之间');
        return;
      }
      
      final data = {
        'submissionId': submissionId,
        'score': score,
        'feedback': feedbackController.text,
      };
      
      final response = await API.submissions.gradeSubmission(submissionId, data);
      
      if (response.code == 200) {
        Get.back(result: true);
        Get.snackbar('成功', '评分已提交');
      } else {
        Get.snackbar('错误', '评分提交失败: ${response.msg}');
      }
    } catch (e) {
      print('提交评分失败: $e');
      Get.snackbar('错误', '评分提交失败，请稍后重试');
    } finally {
      isSubmitting.value = false;
    }
  }
  
  Future<void> autoGrade() async {
    if (isAutoGrading.value) return;
    
    try {
      isAutoGrading.value = true;
      
      final response = await API.submissions.autoGradeSubmission(submissionId);
      
      if (response.code == 200 && response.data != null) {
        submission.value = Submission.fromJson(response.data);
        
        // 更新UI
        scoreController.text = submission.value!.score.toString();
        feedbackController.text = submission.value!.feedback ?? '';
        
        Get.snackbar('成功', '自动批改完成');
      } else {
        Get.snackbar('错误', '自动批改失败: ${response.msg}');
      }
    } catch (e) {
      print('自动批改失败: $e');
      Get.snackbar('错误', '自动批改失败，请稍后重试');
    } finally {
      isAutoGrading.value = false;
    }
  }
  
  Future<void> downloadSubmission() async {
    if (submission.value == null || 
        submission.value!.filePath == null || 
        submission.value!.filePath!.isEmpty) {
      Get.snackbar('提示', '没有可下载的文件');
      return;
    }
    
    try {
      final String fullUrl = HttpUtil.SERVER_API_URL + submission.value!.filePath!;
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
  
  // 添加下载提交文件的方法
  Future<void> downloadSubmissionFile() async {
    if (submission.value == null || 
        submission.value!.filePath == null || 
        submission.value!.filePath!.isEmpty) {
      Get.snackbar('提示', '没有可下载的文件');
      return;
    }
    
    try {
      final String fullUrl = HttpUtil.SERVER_API_URL + submission.value!.filePath!;
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
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../common/utils/http.dart';
import '../../model/submission_model.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:dio/dio.dart' as dio;

class GradeSubmissionController extends GetxController {
  final HttpUtil httpUtil = HttpUtil();
  final Rx<Submission?> submission = Rx<Submission?>(null);
  final RxBool isLoading = true.obs;
  final RxBool isSubmitting = false.obs;
  
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
      
      final response = await httpUtil.get(
        '/submission/$submissionId',
      );
      
      if (response.code == 200 && response.data != null) {
        submission.value = Submission.fromJson(response.data);
        
        // 如果已经批改过，填充表单
        if (submission.value!.isGraded) {
          scoreController.text = submission.value!.score.toString();
          feedbackController.text = submission.value!.feedback ?? '';
        }
      } else {
        Get.snackbar('错误', '加载提交详情失败: ${response.msg}');
      }
    } catch (e) {
      print('加载提交详情出错: $e');
      Get.snackbar('错误', '加载提交详情失败，请稍后重试');
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> submitGrade() async {
    // 验证分数
    if (scoreController.text.isEmpty) {
      Get.snackbar('错误', '请输入分数');
      return;
    }
    
    final double? score = double.tryParse(scoreController.text);
    if (score == null || score < 0 || score > 100) {
      Get.snackbar('错误', '分数必须在0-100之间');
      return;
    }
    
    try {
      isSubmitting.value = true;
      
      final response = await httpUtil.post(
        '/submission/grade',
        data: {
          'submissionId': submissionId,
          'score': score,
          'feedback': feedbackController.text,
        },
      );
      
      if (response.code == 200) {
        Get.back(result: true);
        Get.snackbar('成功', '批改已提交');
      } else {
        Get.snackbar('错误', '提交批改失败: ${response.msg}');
      }
    } catch (e) {
      print('提交批改出错: $e');
      Get.snackbar('错误', '提交批改失败，请稍后重试');
    } finally {
      isSubmitting.value = false;
    }
  }
  
  Future<void> downloadSubmissionFile() async {
    if (submission.value == null || !submission.value!.hasFile) {
      Get.snackbar('提示', '没有可下载的文件');
      return;
    }
    
    try {
      final String fileUrl = submission.value!.filePath!;
      
      if (await canLaunch(fileUrl)) {
        await launch(fileUrl);
      } else {
        // 如果无法直接打开URL，尝试下载文件
        final dio.Dio dioInstance = dio.Dio();
        final Directory tempDir = await getTemporaryDirectory();
        final String fileName = submission.value!.fileName ?? 'submission_file';
        final String savePath = '${tempDir.path}/$fileName';
        
        Get.snackbar('提示', '正在下载文件...');
        
        await dioInstance.download(
          fileUrl,
          savePath,
          onReceiveProgress: (received, total) {
            if (total != -1) {
              final progress = (received / total * 100).toStringAsFixed(0);
              print('下载进度: $progress%');
            }
          },
        );
        
        Get.snackbar('成功', '文件已下载到: $savePath');
        
        // 尝试打开文件
        final File file = File(savePath);
        if (await file.exists()) {
          // 根据平台打开文件
          if (Platform.isAndroid || Platform.isIOS) {
            await launch('file://$savePath');
          } else {
            Get.snackbar('提示', '文件已下载，但无法自动打开');
          }
        }
      }
    } catch (e) {
      print('下载文件出错: $e');
      Get.snackbar('错误', '下载文件失败，请稍后重试');
    }
  }
} 
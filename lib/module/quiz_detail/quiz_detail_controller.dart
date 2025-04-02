import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../../common/utils/http.dart';
import '../../common/api/api.dart';
import '../../model/assignment_model.dart';
import '../../model/submission_model.dart';
import '../../common/utils/storage.dart';
import 'package:dio/dio.dart' as dio;

class QuizDetailController extends GetxController {
  final HttpUtil httpUtil = HttpUtil();
  final quiz = Rx<Assignment?>(null);
  final submission = Rx<Submission?>(null);
  final RxBool isLoading = true.obs;
  final RxBool isSubmitting = false.obs;
  
  // 用于动态添加回答框
  final RxList<TextEditingController> answerControllers = <TextEditingController>[].obs;
  final RxList<String> answerFields = <String>[].obs;
  
  // 用于存储附件
  final RxMap<int, List<PlatformFile>> answerAttachments = <int, List<PlatformFile>>{}.obs;
  
  final ImagePicker _imagePicker = ImagePicker();
  
  final int quizId;
  
  QuizDetailController({required this.quizId});
  
  @override
  void onInit() {
    super.onInit();
    loadQuizDetail();
    // 默认添加一个回答框
    addAnswerField();
  }
  
  @override
  void onClose() {
    // 释放所有文本控制器
    for (var controller in answerControllers) {
      controller.dispose();
    }
    super.onClose();
  }
  
  void addAnswerField() {
    final controller = TextEditingController();
    answerControllers.add(controller);
    answerFields.add('');
    answerAttachments[answerControllers.length - 1] = [];
  }
  
  void removeAnswerField(int index) {
    if (answerFields.length <= 1) {
      Get.snackbar('提示', '至少需要保留一个回答框');
      return;
    }
    
    answerControllers[index].dispose();
    answerControllers.removeAt(index);
    answerFields.removeAt(index);
    
    // 重新整理附件映射
    final Map<int, List<PlatformFile>> newAttachments = {};
    for (int i = 0; i < answerControllers.length; i++) {
      if (i < index) {
        newAttachments[i] = answerAttachments[i] ?? [];
      } else {
        newAttachments[i] = answerAttachments[i + 1] ?? [];
      }
    }
    answerAttachments.clear();
    answerAttachments.addAll(newAttachments);
  }
  
  Future<void> pickImage(int index, ImageSource source) async {
    try {
      // 检查是否已有附件
      if ((answerAttachments[index] ?? []).isNotEmpty) {
        Get.snackbar('提示', '每个回答只能添加一个附件，请先删除现有附件');
        return;
      }
      
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        imageQuality: 80,
      );
      
      if (image != null) {
        final file = PlatformFile(
          name: image.name,
          size: await File(image.path).length(),
          path: image.path,
        );
        
        final attachments = <PlatformFile>[];
        attachments.add(file);
        answerAttachments[index] = attachments;
      }
    } catch (e) {
      print('选择图片失败: $e');
      Get.snackbar('错误', '选择图片失败，请重试');
    }
  }
  
  Future<void> pickFile(int index) async {
    try {
      // 检查是否已有附件
      if ((answerAttachments[index] ?? []).isNotEmpty) {
        Get.snackbar('提示', '每个回答只能添加一个附件，请先删除现有附件');
        return;
      }
      
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        
        final attachments = <PlatformFile>[];
        attachments.add(file);
        answerAttachments[index] = attachments;
      }
    } catch (e) {
      print('选择文件失败: $e');
      Get.snackbar('错误', '选择文件失败，请重试');
    }
  }
  
  void removeAttachment(int index, PlatformFile file) {
    final attachments = answerAttachments[index] ?? [];
    attachments.removeWhere((attachment) => attachment.path == file.path);
    answerAttachments[index] = attachments;
  }
  
  Future<void> loadQuizDetail() async {
    try {
      isLoading.value = true;
      
      final response = await API.assignments.getAssignmentDetail(quizId);
      
      if (response.code == 200 && response.data != null) {
        quiz.value = Assignment.fromJson(response.data);
        await loadSubmission();
      } else {
        Get.snackbar('错误', '获取测验详情失败: ${response.msg}');
      }
    } catch (e) {
      print('加载测验详情失败: $e');
      Get.snackbar('错误', '获取测验详情失败，请检查网络连接');
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> loadSubmission() async {
    try {
      if (quiz.value == null) return;
      
      final storage = await StorageService.instance;
      final userId = storage.getUserId();
      
      final response = await API.submissions.getStudentSubmission(
        quiz.value!.assignmentId!,
        userId!,
      );
      
      if (response.code == 200 && response.data != null) {
        submission.value = Submission.fromJson(response.data);
        
        // 如果已有提交内容，解析并填充到回答框
        if (submission.value?.content != null && submission.value!.content!.isNotEmpty) {
          try {
            final answers = submission.value!.content!.split('|||');
            
            // 清空现有回答框
            for (var controller in answerControllers) {
              controller.dispose();
            }
            answerControllers.clear();
            answerFields.clear();
            
            // 添加已有回答
            for (var answer in answers) {
              final controller = TextEditingController(text: answer);
              answerControllers.add(controller);
              answerFields.add(answer);
            }
            
            // 如果没有回答，添加一个空回答框
            if (answerControllers.isEmpty) {
              addAnswerField();
            }
          } catch (e) {
            print('解析回答失败: $e');
            addAnswerField();
          }
        }
      }
    } catch (e) {
      print('加载提交记录失败: $e');
    }
  }
  
  Future<void> submitQuiz() async {
    if (isSubmitting.value) return;
    
    if (quiz.value == null) {
      Get.snackbar('错误', '测验信息不完整');
      return;
    }
    
    if (!quiz.value!.isSubmittable) {
      Get.snackbar('提示', '当前不能提交测验');
      return;
    }
    
    // 收集所有回答
    final List<String> answers = [];
    for (var controller in answerControllers) {
      if (controller.text.trim().isNotEmpty) {
        answers.add(controller.text.trim());
      }
    }
    
    if (answers.isEmpty && answerAttachments.values.every((list) => list.isEmpty)) {
      Get.snackbar('提示', '请至少填写一个回答或上传一个附件');
      return;
    }
    
    try {
      isSubmitting.value = true;
      
      final storage = await StorageService.instance;
      final userId = storage.getUserId();
      
      // 使用 \n 分隔多个回答
      final content = answers.join('\n');
      
      // 检查是否有附件
      bool hasAttachments = false;
      for (var attachmentList in answerAttachments.values) {
        if (attachmentList.isNotEmpty) {
          hasAttachments = true;
          break;
        }
      }
      
      if (hasAttachments) {
        // 创建FormData对象
        final formData = dio.FormData.fromMap({
          'assignmentId': quiz.value!.assignmentId.toString(),
          'studentId': userId.toString(),
          'content': content,
        });
        
        // 添加所有附件
        int fileIndex = 0;
        for (var entry in answerAttachments.entries) {
          final questionIndex = entry.key;
          final attachments = entry.value;
          
          for (var file in attachments) {
            if (file.path != null) {
              final fileName = '${questionIndex}_${fileIndex}_${file.name}';
              formData.files.add(MapEntry(
                'files',
                dio.MultipartFile.fromFileSync(
                  file.path!,
                  filename: fileName,
                ),
              ));
              fileIndex++;
            }
          }
        }
        
        // 提交带附件的测验
        final response = await API.submissions.submitAssignment(formData);
        
        if (response.code == 200) {
          Get.back(result: true);
          Get.snackbar('成功', '测验已提交');
        } else {
          Get.snackbar('提交失败', response.msg);
        }
      } else {
        // 提交纯文本测验
        final response = await API.assignments.submitContent(
          quiz.value?.assignmentId ?? 0, 
          userId!, 
          content
        );
        
        if (response.code == 200) {
          Get.back(result: true);
          Get.snackbar('成功', '测验已提交');
        } else {
          Get.snackbar('提交失败', response.msg);
        }
      }
    } catch (e) {
      print('提交测验失败: $e');
      Get.snackbar('错误', '提交测验失败，请稍后重试');
    } finally {
      isSubmitting.value = false;
    }
  }
} 
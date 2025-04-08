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
import 'dart:async';

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
  
  // 添加新属性
  final RxBool isSaving = false.obs;
  final RxBool isSubmitted = false.obs;
  
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
  
  // 加载测验详情时，获取最新答案
  Future<void> loadQuizDetail() async {
    try {
      isLoading.value = true;
      
      final response = await API.assignments.getAssignmentDetail(quizId);
      
      if (response.code == 200 && response.data != null) {
        quiz.value = Assignment.fromJson(response.data);
        await loadLatestAnswer();
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
  
  // 加载最新答案（包括未提交的保存内容）
  Future<void> loadLatestAnswer() async {
    try {
      if (quiz.value == null) return;
      
      final storage = await StorageService.instance;
      final userId = storage.getUserId();
      
      // 先尝试获取最终答案
      final finalResponse = await API.quiz.getFinalAnswer(
        quiz.value!.assignmentId!,
        userId!,
      );
      
      // 只有当成功获取到最终答案且答案标记为已提交时，才设置isSubmitted为true
      if (finalResponse.code == 200 && finalResponse.data != null) {
        final finalSubmission = Submission.fromJson(finalResponse.data);
        // 检查submission是否为最终提交
        if (finalSubmission.status == 'submitted' || finalSubmission.isFinalSubmission == true) {
          submission.value = finalSubmission;
          isSubmitted.value = true;
          fillAnswerFields(submission.value!);
          return;
        }
      }
      
      // 如果没有最终答案或答案未标记为已提交，获取最新答案
      final latestResponse = await API.quiz.getLatestAnswer(
        quiz.value!.assignmentId!,
        userId!,
      );
      
      if (latestResponse.code == 200 && latestResponse.data != null) {
        submission.value = Submission.fromJson(latestResponse.data);
        // 确保isSubmitted为false，允许编辑
        isSubmitted.value = false;
        fillAnswerFields(submission.value!);
      } else {
        // 没有任何答案，添加默认回答框
        clearAnswerFields();
        addAnswerField();
      }
    } catch (e) {
      print('加载答案失败: $e');
      // 出错时添加默认回答框
      clearAnswerFields();
      addAnswerField();
    }
  }
  
  // 填充回答框
  void fillAnswerFields(Submission submission) {
    try {
      // 清空现有回答框
      clearAnswerFields();
      
      if (submission.content != null && submission.content!.isNotEmpty) {
        final answers = submission.content!.split('\n');
        
        // 添加已有回答
        for (var answer in answers) {
          final controller = TextEditingController(text: answer);
          answerControllers.add(controller);
          answerFields.add(answer);
        }
      }
      
      // 如果没有回答，添加一个空回答框
      if (answerControllers.isEmpty) {
        addAnswerField();
      }
    } catch (e) {
      print('填充回答框失败: $e');
      clearAnswerFields();
      addAnswerField();
    }
  }
  
  // 清空回答框
  void clearAnswerFields() {
    for (var controller in answerControllers) {
      controller.dispose();
    }
    answerControllers.clear();
    answerFields.clear();
    answerAttachments.clear();
  }
  
  // 保存测验答案（不提交为最终版本）
  Future<void> saveQuiz({bool showSnackbar = true}) async {
    if (isSaving.value || isSubmitting.value) return;
    if (isSubmitted.value) {
      if (showSnackbar) Get.snackbar('提示', '已提交的测验无法再次保存');
      return;
    }
    
    if (quiz.value == null) {
      if (showSnackbar) Get.snackbar('错误', '测验信息不完整');
      return;
    }
    
    // 收集所有回答
    final List<String> answers = [];
    for (var controller in answerControllers) {
      answers.add(controller.text.trim());
    }
    
    try {
      isSaving.value = true;
      
      final storage = await StorageService.instance;
      final userId = storage.getUserId();
      
      // 使用 \n 分隔多个回答
      final content = answers.join('\n');
      
      // 检查是否有附件
      File? fileToUpload;
      for (var attachmentList in answerAttachments.values) {
        if (attachmentList.isNotEmpty) {
          // 只上传第一个附件
          final file = attachmentList.first;
          if (file.path != null) {
            fileToUpload = File(file.path!);
            break;
          }
        }
      }
      
      final response = await API.quiz.saveAnswer(
        quiz.value!.assignmentId!,
        userId!,
        content,
        fileToUpload,
        isFinalSubmission: false, // 修改为 false，表示只是保存
      );
      
      if (response.code == 200) {
        if (showSnackbar) Get.snackbar('成功', '测验已保存');
        // 更新submission
        if (response.data != null) {
          submission.value = Submission.fromJson(response.data);
        }
      } else {
        if (showSnackbar) Get.snackbar('保存失败', response.msg);
      }
    } catch (e) {
      print('保存测验失败: $e');
      if (showSnackbar) Get.snackbar('错误', '保存测验失败，请稍后重试');
    } finally {
      isSaving.value = false;
    }
  }
  
  // 提交测验答案（标记为最终版本）
  Future<void> submitQuiz() async {
    if (isSubmitting.value || isSaving.value) return;
    
    if (isSubmitted.value) {
      Get.snackbar('提示', '测验已提交，无法再次提交');
      return;
    }
    
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
      File? fileToUpload;
      for (var attachmentList in answerAttachments.values) {
        if (attachmentList.isNotEmpty) {
          // 只上传第一个附件
          final file = attachmentList.first;
          if (file.path != null) {
            fileToUpload = File(file.path!);
            break;
          }
        }
      }
      
      final response = await API.quiz.saveAnswer(
        quiz.value!.assignmentId!,
        userId!,
        content,
        fileToUpload,
        isFinalSubmission: true, // 指定为最终提交
      );
      
      if (response.code == 200) {
        isSubmitted.value = true;
        Get.back(result: true);
        Get.snackbar('成功', '测验已提交');
      } else {
        Get.snackbar('提交失败', response.msg);
      }
    } catch (e) {
      print('提交测验失败: $e');
      Get.snackbar('错误', '提交测验失败，请稍后重试');
    } finally {
      isSubmitting.value = false;
    }
  }

  // 在 QuizDetailController 类中添加一个方法来获取正确的状态文本
  String getStatusText(Assignment quiz, Submission? submission) {
    if (quiz.isExpired) {
      return '已截止';
    }
    
    if (submission != null) {
      // 检查是否为最终提交
      if (submission.isFinalSubmission == true || submission.status == 'submitted') {
        return '已提交';
      } else {
        // 只是保存但未最终提交
        return '进行中';
      }
    }
    
    if (quiz.isStarted) {
      return '进行中';
    }
    
    return '未开始';
  }
} 
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import '../../common/api/api.dart';
import '../../model/assignment_model.dart';
import '../../model/submission_model.dart';
import '../../common/utils/storage.dart';
import '../../routes/app_pages.dart';

class TeacherQuizDetailController extends GetxController {
  final int quizId = Get.arguments['quizId'];
  final RxBool isLoading = true.obs;
  final RxBool isLoadingSubmissions = false.obs;
  final RxBool isUpdatingQuiz = false.obs;
  final RxBool isAutoGrading = false.obs;
  final quiz = Rx<Assignment?>(null);
  final RxList<Submission> submissions = <Submission>[].obs;
  
  // 编辑表单控制器
  final Rx<TextEditingController> titleController = TextEditingController().obs;
  final Rx<TextEditingController> descriptionController = TextEditingController().obs;
  final Rx<TextEditingController> startTimeController = TextEditingController().obs;
  final Rx<TextEditingController> endTimeController = TextEditingController().obs;
  final RxString attachmentPath = ''.obs;
  final RxString attachmentName = ''.obs;
  
  // 班级信息
  final RxString className = ''.obs;
  final RxInt totalStudents = 0.obs;
  final RxInt submittedCount = 0.obs;
  final RxInt gradedCount = 0.obs;
  
  // 添加这些可观察变量
  final RxString startTimeText = ''.obs;
  final RxString endTimeText = ''.obs;
  
  @override
  void onInit() {
    super.onInit();
    loadQuizDetail();
  }
  
  @override
  void onClose() {
    titleController.value.dispose();
    descriptionController.value.dispose();
    startTimeController.value.dispose();
    endTimeController.value.dispose();
    super.onClose();
  }
  
  Future<void> loadQuizDetail() async {
    try {
      isLoading.value = true;
      
      final response = await API.assignments.getAssignmentDetail(quizId);
      
      if (response.code == 200 && response.data != null) {
        quiz.value = Assignment.fromJson(response.data);
        
        // 设置表单初始值
        titleController.value.text = quiz.value?.title ?? '';
        descriptionController.value.text = quiz.value?.description ?? '';
        
        if (quiz.value?.createTime != null) {
          startTimeController.value.text = quiz.value!.formattedCreateTime;
          startTimeText.value = quiz.value!.formattedCreateTime;
        }
        
        if (quiz.value?.deadline != null) {
          endTimeController.value.text = quiz.value!.formattedDeadline;
          endTimeText.value = quiz.value!.formattedDeadline;
        }
        
        if (quiz.value?.contentUrl != null && quiz.value!.contentUrl!.isNotEmpty) {
          attachmentPath.value = quiz.value!.contentUrl!;
          attachmentName.value = quiz.value!.attachmentFileName ?? '';
        }
        
        // 获取班级信息
        await loadClassInfo();
        
        // 加载提交列表
        await loadSubmissions();
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
  
  Future<void> loadClassInfo() async {
    try {
      if (quiz.value?.classId == null) return;
      
      final response = await API.classes.getClassDetail(quiz.value!.classId!);
      
      if (response.code == 200 && response.data != null) {
        className.value = response.data['className'] ?? '';
        totalStudents.value = response.data['studentCount'] ?? 0;
      }
    } catch (e) {
      print('加载班级信息失败: $e');
    }
  }
  
  Future<void> loadSubmissions() async {
    try {
      isLoadingSubmissions.value = true;
      
      final response = await API.submissions.getAssignmentSubmissions(quizId);
      
      if (response.code == 200 && response.data != null) {
        final List<dynamic> submissionsData = response.data;
        
        // 只过滤出最终提交的答案
        submissions.value = submissionsData
            .map((item) => Submission.fromJson(item))
            .where((submission) => submission.isFinalSubmission == true)
            .toList();
        
        // 统计已提交和已批改的数量
        submittedCount.value = submissions.length;
        gradedCount.value = submissions.where((s) => s.isGraded).length;
      }
    } catch (e) {
      print('加载提交列表失败: $e');
    } finally {
      isLoadingSubmissions.value = false;
    }
  }
  
  Future<void> pickAttachment() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      
      if (result != null) {
        File file = File(result.files.single.path!);
        attachmentPath.value = file.path;
        attachmentName.value = result.files.single.name;
      }
    } catch (e) {
      print('选择附件失败: $e');
      Get.snackbar('错误', '选择附件失败');
    }
  }
  
  // 选择开始时间
  Future<void> selectStartTime() async {
    final DateTime now = DateTime.now();
    DateTime initialDate;
    
    try {
      // 尝试解析当前输入框中的时间
      if (startTimeController.value.text.isNotEmpty) {
        initialDate = startTimeController.value.text.contains('T')
            ? DateTime.parse(startTimeController.value.text)
            : DateTime.parse(startTimeController.value.text.replaceAll(' ', 'T'));
      } else {
        initialDate = quiz.value?.createTime != null
            ? DateTime.parse(quiz.value!.createTime!.replaceAll(' ', 'T'))
            : now;
      }
    } catch (e) {
      print('解析开始时间出错: $e');
      initialDate = now;
    }
    
    final DateTime? picked = await showDatePicker(
      context: Get.context!,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    
    if (picked != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: Get.context!,
        initialTime: TimeOfDay.fromDateTime(initialDate),
      );
      
      if (pickedTime != null) {
        final DateTime dateTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        
        // 更新控制器文本
        startTimeController.value.text = '${dateTime.year}-${_twoDigits(dateTime.month)}-${_twoDigits(dateTime.day)} ${_twoDigits(dateTime.hour)}:${_twoDigits(dateTime.minute)}';
        startTimeText.value = startTimeController.value.text;
        
        // 强制UI刷新
        update();
      }
    }
  }
  
  // 选择截止时间
  Future<void> selectEndTime() async {
    final DateTime now = DateTime.now();
    DateTime initialDate;
    
    try {
      // 尝试解析当前输入框中的时间
      if (endTimeController.value.text.isNotEmpty) {
        initialDate = endTimeController.value.text.contains('T')
            ? DateTime.parse(endTimeController.value.text)
            : DateTime.parse(endTimeController.value.text.replaceAll(' ', 'T'));
      } else {
        initialDate = quiz.value?.deadline != null
            ? DateTime.parse(quiz.value!.deadline!.replaceAll(' ', 'T'))
            : now.add(const Duration(days: 1));
      }
    } catch (e) {
      print('解析截止时间出错: $e');
      initialDate = now.add(const Duration(days: 1));
    }
    
    final DateTime? picked = await showDatePicker(
      context: Get.context!,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    
    if (picked != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: Get.context!,
        initialTime: TimeOfDay.fromDateTime(initialDate),
      );
      
      if (pickedTime != null) {
        final DateTime dateTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        
        // 更新控制器文本
        endTimeController.value.text = '${dateTime.year}-${_twoDigits(dateTime.month)}-${_twoDigits(dateTime.day)} ${_twoDigits(dateTime.hour)}:${_twoDigits(dateTime.minute)}';
        endTimeText.value = endTimeController.value.text;
        
        // 强制UI刷新
        update();
      }
    }
  }
  
  Future<void> updateQuizInfo() async {
    if (titleController.value.text.isEmpty) {
      Get.snackbar('提示', '测验标题不能为空');
      return;
    }
    
    try {
      isUpdatingQuiz.value = true;
      
      // 准备更新数据
      Map<String, dynamic> updateData = {
        'title': titleController.value.text,
        'description': descriptionController.value.text,
      };
      
      // 处理开始时间
      if (startTimeController.value.text.isNotEmpty) {
        // 确保日期格式为 yyyy-MM-dd HH:mm:ss
        final startTime = _formatDateTimeForApi(startTimeController.value.text);
        updateData['createTime'] = startTime;
      }
      
      // 处理截止时间
      if (endTimeController.value.text.isNotEmpty) {
        // 确保日期格式为 yyyy-MM-dd HH:mm:ss
        final endTime = _formatDateTimeForApi(endTimeController.value.text);
        updateData['deadline'] = endTime;
      }
      
      final response = await API.assignments.updateAssignment(
        quiz.value!.assignmentId!, 
        updateData,
      );
      
      if (response.code == 200) {
        Get.snackbar('成功', '测验信息已更新');
        
        // 更新本地数据
        if (quiz.value != null) {
          quiz.value!.title = titleController.value.text;
          quiz.value!.description = descriptionController.value.text;
          quiz.refresh();
        }
      } else {
        Get.snackbar('更新失败', response.msg);
      }
    } catch (e) {
      print('更新测验信息失败: $e');
      Get.snackbar('错误', '更新测验信息失败，请稍后重试');
    } finally {
      isUpdatingQuiz.value = false;
    }
  }
  
  // 添加这个辅助方法来格式化日期
  String _formatDateTimeForApi(String dateTimeStr) {
    try {
      // 处理可能的格式差异
      DateTime dateTime;
      if (dateTimeStr.contains('T')) {
        dateTime = DateTime.parse(dateTimeStr);
      } else {
        // 假设格式为 "yyyy-MM-dd HH:mm"
        dateTime = DateTime.parse(dateTimeStr.replaceAll(' ', 'T'));
      }
      
      // 返回格式为 "yyyy-MM-dd HH:mm:ss" 的字符串
      return '${dateTime.year}-${_twoDigits(dateTime.month)}-${_twoDigits(dateTime.day)} ${_twoDigits(dateTime.hour)}:${_twoDigits(dateTime.minute)}:00';
    } catch (e) {
      print('日期格式化错误: $e');
      return dateTimeStr; // 出错时返回原始字符串
    }
  }
  
  // 辅助方法：确保数字为两位
  String _twoDigits(int n) {
    if (n >= 10) return '$n';
    return '0$n';
  }
  
  Future<void> endQuiz() async {
    if (quiz.value == null || quiz.value!.isExpired) {
      Get.snackbar('提示', '该测验已经结束');
      return;
    }
    
    try {
      final result = await Get.dialog(
        AlertDialog(
          title: Text('结束测验'),
          content: Text('确定要结束该测验吗？所有未提交的答案将被自动提交为最终版本。'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: Text('取消'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: Text('确定'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
            ),
          ],
        ),
      );
      
      if (result == true) {
        // 更新截止时间为当前时间，使用正确的格式
        final now = DateTime.now();
        final formattedNow = '${now.year}-${_twoDigits(now.month)}-${_twoDigits(now.day)} ${_twoDigits(now.hour)}:${_twoDigits(now.minute)}:00';
        
        final response = await API.quiz.endTest(quizId, {'deadline': formattedNow});
        
        if (response.code == 200) {
          Get.snackbar('成功', '测验已结束');
          refreshData();
        } else {
          Get.snackbar('操作失败', response.msg);
        }
      }
    } catch (e) {
      print('结束测验失败: $e');
      Get.snackbar('错误', '结束测验失败，请稍后重试');
    }
  }
  
  Future<void> autoGradeAll() async {
    if (isAutoGrading.value) return;
    
    try {
      isAutoGrading.value = true;
      
      final result = await Get.dialog(
        AlertDialog(
          title: Text('AI自动批改'),
          content: Text('确定要使用AI对所有提交进行自动批改吗？'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: Text('取消'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: Text('确定'),
            ),
          ],
        ),
      );
      
      if (result == true) {
        // final response = await API.quiz.autoGradeAll(quizId);
        
        // if (response.code == 200) {
        //   Get.snackbar('成功', 'AI批改已启动，请稍后刷新查看结果');
        //
        //   // 延迟3秒后刷新数据
        //   await Future.delayed(Duration(seconds: 3));
        //   refreshData();
        // } else {
        //   Get.snackbar('操作失败', response.msg);
        // }
      }
    } catch (e) {
      print('AI批改失败: $e');
      Get.snackbar('错误', 'AI批改失败，请稍后重试');
    } finally {
      isAutoGrading.value = false;
    }
  }
  
  void refreshData() {
    loadQuizDetail();
  }
  
  void viewSubmission(Submission submission) {
    Get.toNamed(
      AppRoutes.GRADE_SUBMISSION,
      arguments: {
        'submissionId': submission.submissionId,
        'isQuiz': true,
      },
    )?.then((value) {
      if (value == true) {
        loadSubmissions();
      }
    });
  }
} 
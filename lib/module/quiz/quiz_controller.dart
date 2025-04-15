import 'package:get/get.dart';
import '../../../common/utils/http.dart';
import '../../../common/api/api.dart';
import '../../../model/assignment_model.dart';
import '../../../routes/app_pages.dart';
import 'package:flutter/material.dart';
class QuizController extends GetxController {
  final HttpUtil httpUtil = HttpUtil();
  final RxBool isLoading = true.obs;
  final RxList<Assignment> quizzes = <Assignment>[].obs;
  final RxMap<int, Map<String, int>> quizSubmissionStats = <int, Map<String, int>>{}.obs;
  final int classId;
  final RxString filterStatus = 'all'.obs;
  QuizController() : classId = Get.arguments['classId'] as int;

  @override
  void onInit() {
    super.onInit();
    loadQuizList();
  }


  List<Assignment> get filteredQuizzes {
    if (filterStatus.value == 'all') {
      return quizzes;
    }

    return quizzes.where((assignment) {
      switch (filterStatus.value) {
        case 'not_started':
          return assignment.status == 'not_started';
        case 'in_progress':
          return assignment.status == 'in_progress';
        case 'expired':
          return assignment.status == 'expired';
        default:
          return true;
      }
    }).toList();
  }

  void setFilter(String status) {
    filterStatus.value = status;
  }



  Future<void> loadQuizList() async {
    try {
      isLoading.value = true;

      final response = await API.assignments.getClassAssignments(classId);

      if (response.code == 200 && response.data != null) {
        final List<dynamic> assignmentsData = response.data;

        // 过滤出inClass为true的作业作为测验
        quizzes.value = assignmentsData
            .map((item) => Assignment.fromJson(item))
            .where((assignment) => assignment.isInClass == true)
            .toList();


      }
    } catch (e) {
      print('Load quiz list error: $e');
      Get.snackbar('错误', '获取测试列表失败');
    } finally {
      isLoading.value = false;
    }
  }

  void goToQuizDetail(Assignment quiz) {
    Get.toNamed(
        AppRoutes.QUIZ_DETAIL,
        arguments: {'quizId': quiz.assignmentId}
    )?.then((value) {
      if (value == true) {
        refreshQuizList();
      }
    });
  }


  // 刷新测验列表
  Future<void> refreshQuizList() async {
    await loadQuizList();
  }

  // 结束测验
  Future<void> endQuiz(Assignment quiz) async {
    if (quiz.isExpired) {
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

      // if (result == true) {
      //   // final response = await API.quiz.endTest(quiz.assignmentId!);
      //
      //   if (response.code == 200) {
      //     Get.snackbar('成功', '测验已结束');
      //     refreshQuizList();
      //   } else {
      //     Get.snackbar('操作失败', response.msg);
      //   }
      // }
    } catch (e) {
      print('End quiz error: $e');
      Get.snackbar('错误', '结束测验失败，请稍后重试');
    }
  }
} 
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../common/utils/http.dart';
import '../../common/api/api.dart';
import '../../model/assignment_model.dart';
import 'package:easy_refresh/easy_refresh.dart';

import '../../routes/app_pages.dart';

class QuizController extends GetxController {
  final HttpUtil httpUtil = HttpUtil();
  final RxList<Assignment> quizzes = <Assignment>[].obs;
  final RxList<Assignment> filteredQuizzes = <Assignment>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isManualRefreshing = false.obs;
  final refreshController = EasyRefreshController(
    controlFinishRefresh: true,
    controlFinishLoad: true,
  );

  final RxString filterStatus = 'all'.obs;

  int currentPage = 1;
  final int pageSize = 10;
  bool hasMore = true;
  final int classId;

  QuizController({required this.classId});

  @override
  void onInit() async {
    super.onInit();
    await loadQuizzes();
    applyFilter();
    print("以下是获取的作业");
    print(quizzes);
  }

  void setFilter(String status) {
    filterStatus.value = status;
    applyFilter();
  }

  void applyFilter() {
    if (filterStatus.value == 'all') {
      filteredQuizzes.value = quizzes;
    } else {
      filteredQuizzes.value = quizzes.where(
              (quiz) => quiz.status == filterStatus.value
      ).toList();
    }
  }

  Future<void> manualRefresh() async {
    try {
      isManualRefreshing.value = true;
      await onRefresh();
    } finally {
      isManualRefreshing.value = false;
    }
  }

  Future<void> onRefresh() async {
    try {
      currentPage = 1;
      hasMore = true;
      await loadQuizzes();
      applyFilter();
      refreshController.finishRefresh(IndicatorResult.success);
      refreshController.resetFooter();
    } catch (e) {
      print('刷新失败: $e');
      refreshController.finishRefresh(IndicatorResult.fail);
    }
  }

  Future<void> onLoadMore() async {
    if (!hasMore) {
      refreshController.finishLoad(IndicatorResult.noMore);
      return;
    }

    try {
      currentPage++;
      await loadQuizzes(isLoadMore: true);
      applyFilter();
      refreshController.finishLoad(
          hasMore ? IndicatorResult.success : IndicatorResult.noMore
      );
    } catch (e) {
      print('加载更多失败: $e');
      currentPage--;
      refreshController.finishLoad(IndicatorResult.fail);
    }
  }

  Future<void> loadQuizzes({bool isLoadMore = false}) async {
    try {
      isLoading.value = true;

      if (classId == 0) {
        Get.snackbar('错误', '班级ID不能为空');
        return;
      }

      final response = await API.assignments.getClassAssignments(classId);

      if (response.code == 200 && response.data != null) {
        final List<dynamic> quizzesData = response.data;

        // 过滤掉isInClass为true的作业（课堂测验）
        quizzes.value = quizzesData
            .map((item) => Assignment.fromJson(item))
            .where((quiz) => quiz.isInClass == true)
            .toList();
      }
    } catch (e) {
      print('Load quizzes error: $e');
      Get.snackbar('错误', '获取测验列表失败');
    } finally {
      isLoading.value = false;
    }
  }

  void goToQuizDetail(int? quizId) {
    Get.toNamed(
        AppRoutes.QUIZ_DETAIL,
        arguments: {'quizId': quizId}
    );
  }

  void refreshQuizzes() {
    loadQuizzes();
  }

  @override
  void onClose() {
    refreshController.dispose();
    super.onClose();
  }
} 
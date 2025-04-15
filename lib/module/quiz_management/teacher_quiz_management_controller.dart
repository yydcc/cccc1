import 'package:get/get.dart';

import '../../common/api/api.dart';
import '../../model/assignment_model.dart';
import 'package:easy_refresh/easy_refresh.dart';
import '../../routes/app_pages.dart';

class TeacherQuizManagementController extends GetxController {
  final RxList<Assignment> quizzes = <Assignment>[].obs;
  final RxBool isLoading = true.obs;
  final int classId;
  final RxString filterStatus = 'all'.obs;

  EasyRefreshController refreshController = EasyRefreshController(
    controlFinishRefresh: true,
    controlFinishLoad: true,
  );

  int currentPage = 1;
  final int pageSize = 10;
  bool hasMore = true;

  TeacherQuizManagementController({required this.classId});

  @override
  void onInit() {
    super.onInit();
    loadQuizzes();
  }

  @override
  void onClose() {
    refreshController.dispose();
    super.onClose();
  }

  Future<void> loadQuizzes() async {
    try {
      isLoading.value = true;

      if (classId == 0) {
        Get.snackbar('错误', '班级ID不能为空');
        return;
      }

      final response = await API.assignments.getClassAssignments(classId);

      if (response.code == 200 && response.data != null) {
        final List<dynamic> quizsData = response.data;

        // 过滤掉isInClass为true的作业（课堂测验）
        quizzes.value = quizsData
            .map((item) => Assignment.fromJson(item))
            .where((quiz) => quiz.isInClass == true)
            .toList();
      }
    } catch (e) {
      print('加载测验列表失败: $e');
      Get.snackbar('错误', '获取测验列表失败，请检查网络连接');
    } finally {
      isLoading.value = false;
    }
  }

  void goToQuizDetail(int? quizId) {
    Get.toNamed(
        AppRoutes.TEACHER_QUIZ_DETAIL,
        arguments: {'quizId': quizId}
    )?.then((value) {
      if (value == true) {
        loadQuizzes();
      }
    });
  }


  Future<void> refreshQuizzes() async{
    await loadQuizzes();
  }

  void goToCreateQuiz() {
    Get.toNamed(
        AppRoutes.CREATE_QUIZ,
        arguments: {'classId': classId}
    )?.then((value) {
      if (value == true) {
        loadQuizzes();
      }
    });
  }

  List<Assignment> get filteredQuizzes {
    if (filterStatus.value == 'all') {
      return quizzes;
    }

    return quizzes.where((quiz) {
      switch (filterStatus.value) {
        case 'not_started':
          return quiz.status == 'not_started';
        case 'in_progress':
          return quiz.status == 'in_progress';
        case 'expired':
          return quiz.status == 'expired';
        default:
          return true;
      }
    }).toList();
  }

  void setFilter(String status) {
    filterStatus.value = status;
  }

  Future<void> onRefresh() async {
    try {
      currentPage = 1;
      hasMore = true;
      await loadQuizzes();
      if (refreshController.controlFinishRefresh) {
        refreshController.finishRefresh();
        refreshController.resetFooter();
      }
    } catch (e) {
      print('刷新失败: $e');
      if (refreshController.controlFinishRefresh) {
        refreshController.finishRefresh(IndicatorResult.fail);
      }
    }
  }

  Future<void> onLoadMore() async {
    try {
      if (hasMore) {
        currentPage++;
        await loadQuizzes();
        if (refreshController.controlFinishLoad) {
          refreshController.finishLoad(hasMore ? IndicatorResult.success : IndicatorResult.noMore);
        }
      } else {
        if (refreshController.controlFinishLoad) {
          refreshController.finishLoad(IndicatorResult.noMore);
        }
      }
    } catch (e) {
      print('加载更多失败: $e');
      if (refreshController.controlFinishLoad) {
        refreshController.finishLoad(IndicatorResult.fail);
      }
    }
  }


} 
import 'package:get/get.dart';
import '../../common/utils/http.dart';
import '../../common/api/api.dart';
import '../../model/assignment_model.dart';
import '../../routes/app_pages.dart';

class QuizController extends GetxController {
  final HttpUtil httpUtil = HttpUtil();
  final RxBool isLoading = true.obs;
  final RxList<Assignment> quizzes = <Assignment>[].obs;
  final int? classId;

  QuizController() : classId = Get.arguments['classId'] as int?;

  @override
  void onInit() {
    super.onInit();
    loadQuizList();
  }

  Future<void> loadQuizList() async {
    try {
      isLoading.value = true;
      
      if (classId == null) {
        Get.snackbar('错误', '班级ID不能为空');
        return;
      }
      
      final response = await API.assignments.getClassAssignments(classId!);
      
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
} 
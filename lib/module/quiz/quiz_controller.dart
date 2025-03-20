import 'package:get/get.dart';
import '../../common/utils/http.dart';

class QuizController extends GetxController {
  final HttpUtil httpUtil = HttpUtil();
  final RxBool isLoading = true.obs;
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
      final response = await httpUtil.get(
        '/student/quiz/list',
        queryParameters: {'classId': classId},
      );
      
      if (response.code == 200) {
        // TODO: 处理测试列表数据
      }
    } catch (e) {
      print('Load quiz list error: $e');
      Get.snackbar('错误', '获取测试列表失败');
    } finally {
      isLoading.value = false;
    }
  }
} 
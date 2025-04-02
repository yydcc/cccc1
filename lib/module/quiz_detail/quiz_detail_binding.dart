import 'package:get/get.dart';
import 'quiz_detail_controller.dart';

class QuizDetailBinding implements Bindings {
  @override
  void dependencies() {
    final Map<String, dynamic> args = Get.arguments ?? {};
    final int quizId = args['quizId'] ?? 0;
    
    Get.lazyPut<QuizDetailController>(
      () => QuizDetailController(quizId: quizId)
    );
  }
} 
import 'package:get/get.dart';
import 'quiz_controller.dart';

class QuizBinding implements Bindings {
  @override
  void dependencies() {

    final Map<String, dynamic> args = Get.arguments ?? {};
    final int classId = args['classId']?? 0;
    Get.lazyPut<QuizController>(() => QuizController(classId: classId));
  }
} 
import 'package:get/get.dart';
import 'create_quiz_controller.dart';

class CreateQuizBinding implements Bindings {
  @override
  void dependencies() {
    final Map<String, dynamic> args = Get.arguments ?? {};
    final String classId = args['classId']?.toString() ?? '';
    
    Get.lazyPut<CreateQuizController>(
      () => CreateQuizController(classId: classId)
    );
  }
} 
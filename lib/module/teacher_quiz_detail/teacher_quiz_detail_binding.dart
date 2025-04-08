import 'package:get/get.dart';
import 'teacher_quiz_detail_controller.dart';

class TeacherQuizDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TeacherQuizDetailController>(
      () => TeacherQuizDetailController(),
    );
  }
} 
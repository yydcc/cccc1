import 'package:get/get.dart';
import 'teacher_quiz_management_controller.dart';

class TeacherQuizManagementBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TeacherQuizManagementController>(
      () => TeacherQuizManagementController(),
    );
  }
} 
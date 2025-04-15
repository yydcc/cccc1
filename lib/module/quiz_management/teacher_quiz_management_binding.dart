import 'package:get/get.dart';
import 'teacher_quiz_management_controller.dart';

class TeacherQuizManagementBinding extends Bindings {
  @override
  void dependencies() {
    final Map<String, dynamic> args = Get.arguments ?? {};
    final int classId = args['classId']?? 0;
    Get.lazyPut<TeacherQuizManagementController>(
      () => TeacherQuizManagementController(classId: classId),
    );
  }
} 
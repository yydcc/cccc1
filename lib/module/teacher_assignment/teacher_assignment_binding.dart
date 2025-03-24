import 'package:get/get.dart';
import 'teacher_assignment_controller.dart';

class TeacherAssignmentBinding implements Bindings {
  @override
  void dependencies() {
    final Map<String, dynamic> args = Get.arguments ?? {};
    final String classId = args['classId']?.toString() ?? '';
    
    Get.lazyPut<TeacherAssignmentController>(
      () => TeacherAssignmentController(classId: classId)
    );
  }
} 
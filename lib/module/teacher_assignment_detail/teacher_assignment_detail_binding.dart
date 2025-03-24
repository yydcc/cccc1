import 'package:get/get.dart';
import 'teacher_assignment_detail_controller.dart';

class TeacherAssignmentDetailBinding implements Bindings {
  @override
  void dependencies() {
    final Map<String, dynamic> args = Get.arguments ?? {};
    final int assignmentId = args['assignmentId'] ?? 0;
    
    Get.lazyPut<TeacherAssignmentDetailController>(
      () => TeacherAssignmentDetailController(assignmentId: assignmentId)
    );
  }
} 
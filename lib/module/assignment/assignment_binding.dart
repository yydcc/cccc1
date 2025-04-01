import 'package:get/get.dart';
import 'assignment_controller.dart';

class AssignmentBinding implements Bindings {
  @override
  void dependencies() {
    final Map<String, dynamic> args = Get.arguments ?? {};
    final int classId = args['classId']?? 0;
    
    Get.lazyPut<AssignmentController>(
      () => AssignmentController(classId: classId)
    );
  }
} 
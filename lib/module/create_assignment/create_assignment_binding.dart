import 'package:get/get.dart';
import 'create_assignment_controller.dart';

class CreateAssignmentBinding implements Bindings {
  @override
  void dependencies() {
    final Map<String, dynamic> args = Get.arguments ?? {};
    final String classId = args['classId']?.toString() ?? '';
    
    Get.lazyPut<CreateAssignmentController>(
      () => CreateAssignmentController(classId: classId)
    );
  }
} 
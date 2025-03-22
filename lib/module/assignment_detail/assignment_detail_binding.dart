import 'package:get/get.dart';
import 'assignment_detail_controller.dart';

class AssignmentDetailBinding implements Bindings {
  @override
  void dependencies() {
    final Map<String, dynamic> args = Get.arguments ?? {};
    final int assignmentId = args['assignmentId'] ?? 0;
    
    print('接收到的作业ID: $assignmentId'); // 添加日志
    
    Get.lazyPut<AssignmentDetailController>(
      () => AssignmentDetailController(assignmentId: assignmentId)
    );
  }
} 
import 'package:get/get.dart';
import 'grade_submission_controller.dart';

class GradeSubmissionBinding implements Bindings {
  @override
  void dependencies() {
    final Map<String, dynamic> args = Get.arguments ?? {};
    final int submissionId = args['submissionId'] ?? 0;
    
    Get.lazyPut<GradeSubmissionController>(
      () => GradeSubmissionController(submissionId: submissionId)
    );
  }
} 
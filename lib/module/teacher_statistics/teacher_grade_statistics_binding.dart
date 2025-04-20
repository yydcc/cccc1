import 'package:get/get.dart';
import 'package:cccc1/module/teacher_statistics/teacher_grade_statistics_controller.dart';

class TeacherGradeStatisticsBinding implements Bindings {
  @override
  void dependencies() {
    final Map<String, dynamic> args = Get.arguments ?? {};
    final int classId = args['classId'] ?? 0;
    Get.lazyPut<TeacherGradeStatisticsController>(
      () => TeacherGradeStatisticsController(classId: classId),
    );
  }
} 
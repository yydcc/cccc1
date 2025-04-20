import 'package:cccc1/model/grade_statistics_model.dart';
import 'package:cccc1/module/grade_statistics/grade_statistics_controller.dart';
import 'package:get/get.dart';

class GradeStatisticsBinding implements Bindings{
  @override
  void dependencies() {

      final Map<String, dynamic> args = Get.arguments ?? {};
      final int studentId = args['studentId']??0;
      final int classId = args['classId']??0;
      Get.lazyPut<GradeStatisticsController>(() => GradeStatisticsController(
        studentId:studentId,
        classId: classId
      ));
  }
}
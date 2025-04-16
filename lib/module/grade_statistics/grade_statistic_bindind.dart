import 'package:cccc1/model/grade_statistics_model.dart';
import 'package:cccc1/module/grade_statistics/grade_statistics_controller.dart';
import 'package:get/get.dart';

class GradeStatisticsBinding implements Bindings{
  @override
  void dependencies() {
    Get.lazyPut<GradeStatisticsController>(() => GradeStatisticsController());
  }

}
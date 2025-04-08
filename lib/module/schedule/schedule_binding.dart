import 'package:get/get.dart';
import 'memo_controller.dart';

class ScheduleBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MemoController>(() => MemoController());
  }
} 
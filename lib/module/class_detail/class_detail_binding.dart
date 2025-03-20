import 'package:get/get.dart';
import 'class_detail_controller.dart';

class ClassDetailBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ClassDetailController>(() => ClassDetailController());
  }
} 
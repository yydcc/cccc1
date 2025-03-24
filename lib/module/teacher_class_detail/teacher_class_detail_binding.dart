import 'package:get/get.dart';
import 'teacher_class_detail_controller.dart';

class TeacherClassDetailBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TeacherClassDetailController>(
      () => TeacherClassDetailController()
    );
  }
} 
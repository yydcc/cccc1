import 'package:get/get.dart';
import 'teacher_classinfo_controller.dart';

class TeacherClassinfoBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TeacherClassInfoController>(() => TeacherClassInfoController());
  }
} 
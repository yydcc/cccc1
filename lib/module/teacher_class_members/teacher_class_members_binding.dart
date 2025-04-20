import 'package:get/get.dart';
import 'teacher_class_members_controller.dart';

class TeacherClassMembersBinding extends Bindings {
  @override
  void dependencies() {
    final classId = Get.arguments['classId'];
    Get.lazyPut<TeacherClassMembersController>(
      () => TeacherClassMembersController(classId: classId),
    );
  }
} 
import 'package:get/get.dart';
import 'class_members_controller.dart';

class ClassMembersBinding extends Bindings {
  @override
  void dependencies() {
    final classId = Get.arguments['classId'];
    Get.lazyPut<ClassMembersController>(
      () => ClassMembersController(classId: classId),
    );
  }
} 
import 'package:get/get.dart';
import 'class_members_controller.dart';

class ClassMembersBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ClassMembersController>(() => ClassMembersController());
  }
} 
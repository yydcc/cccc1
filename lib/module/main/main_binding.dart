import 'package:cccc1/module/classinfo/classinfo_controller.dart';
import 'package:get/get.dart';
import 'main_controller.dart';
import '../home/home_controller.dart';
import '../schedule/memo_controller.dart';
import '../message/message_controller.dart';
import '../profile/profile_controller.dart';
import '../teacher_classinfo/teacher_classinfo_controller.dart';

class MainBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainController>(() => MainController());
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<MemoController>(() => MemoController());
    Get.lazyPut<ClassinfoController>(() => ClassinfoController());
    Get.lazyPut<TeacherClassInfoController>(() => TeacherClassInfoController());
    Get.lazyPut<ProfileController>(() => ProfileController());
  }
} 
import 'package:get/get.dart';
import 'main_controller.dart';
import '../home/home_controller.dart';
import '../schedule/schedule_controller.dart';
import '../message/message_controller.dart';
import '../profile/profile_controller.dart';

class MainBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MainController>(() => MainController());
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<ScheduleController>(() => ScheduleController());
    Get.lazyPut<MessageController>(() => MessageController());
    Get.lazyPut<ProfileController>(() => ProfileController());
  }
} 
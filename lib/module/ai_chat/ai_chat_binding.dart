import 'package:get/get.dart';
import 'ai_chat_controller.dart';

class AIChatBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AIChatController>(() => AIChatController());
  }
} 
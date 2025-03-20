import 'package:get/get.dart';
import 'discussion_controller.dart';

class DiscussionBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DiscussionController>(() => DiscussionController());
  }
} 
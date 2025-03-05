import 'package:get/get.dart';
import 'classinfo_controller.dart';
class ClassinfoBinding implements Bindings{
  @override
  void dependencies() {
    Get.lazyPut<ClassinfoController>(() => ClassinfoController());
  }
}
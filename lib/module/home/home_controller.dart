import 'package:get/get.dart';
import 'package:cccc1/common/utils/http.dart';

class HomeController extends GetxController {
  final RxString info = "初始状态".obs;
  final HttpUtil httpUtil = HttpUtil();

  Future<void> test() async {
    try {
      final response = await httpUtil.get("/student/hello");
      if (response.code == 200) {
        info.value = response.data.toString(); // 将返回的 data 字段赋值给 info
        print("Token test success: ${response.data}");
      }
    } catch (e) {
      print("Token test error: $e");
      Get.snackbar("错误", "请求失败，可能是token已过期");
    }
  }
} 
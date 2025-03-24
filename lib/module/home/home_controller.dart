import 'package:get/get.dart';
import 'package:cccc1/common/utils/http.dart';


import '../../common/utils/storage.dart';
import '../../routes/app_pages.dart';

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

  void goToClassDetail(String classId) async {
    final prefs = await StorageService.instance;
    final role = prefs.getRole();
    
    if (role == 'teacher') {
      // 如果是教师，跳转到教师班级详情页面
      Get.toNamed(
        AppRoutes.TEACHER_CLASS_DETAIL,
        arguments: {'classId': classId}
      );
    } else {
      // 如果是学生，跳转到学生班级详情页面
      Get.toNamed(
        AppRoutes.CLASS_DETAIL,
        arguments: {'classId': classId}
      );
    }
  }
} 
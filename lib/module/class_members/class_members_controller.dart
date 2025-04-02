import 'package:get/get.dart';
import '../../common/utils/http.dart';

class ClassMembersController extends GetxController {
  final HttpUtil httpUtil = HttpUtil();
  final RxBool isLoading = true.obs;
  final int? classId;

  ClassMembersController() : classId = Get.arguments['classId'] as int?;

  @override
  void onInit() {
    super.onInit();
    loadMembers();
  }

  Future<void> loadMembers() async {
    try {

    } catch (e) {
      print('Load members error: $e');
      Get.snackbar('错误', '获取班级成员失败');
    } finally {
      isLoading.value = false;
    }
  }
} 
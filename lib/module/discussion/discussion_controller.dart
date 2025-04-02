import 'package:get/get.dart';
import '../../common/utils/http.dart';

class DiscussionController extends GetxController {
  final HttpUtil httpUtil = HttpUtil();
  final RxBool isLoading = true.obs;
  final int? classId;

  DiscussionController() : classId = Get.arguments['classId'] as int?;

  @override
  void onInit() {
    super.onInit();
    loadDiscussions();
  }

  Future<void> loadDiscussions() async {
    try {

    } catch (e) {
      print('Load discussions error: $e');
      Get.snackbar('错误', '获取讨论列表失败');
    } finally {
      isLoading.value = false;
    }
  }
} 
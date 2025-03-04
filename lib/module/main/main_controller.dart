import 'package:get/get.dart';

class MainController extends GetxController {
  // 当前选中的页面索引
  final RxInt currentPage = 0.obs;

  // 切换页面
  void changePage(int index) {
    currentPage.value = index;
  }
} 
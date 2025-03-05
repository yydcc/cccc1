import 'package:get/get.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'classinfo_model.dart';

class ClassinfoController extends GetxController {
  var classList = <ClassInfo>[].obs;
  late EasyRefreshController refreshController;
  var page = 1;
  var hasMore = true.obs;

  @override
  void onInit() {
    super.onInit();
    refreshController = EasyRefreshController(
      controlFinishRefresh: true,
      controlFinishLoad: true,
    );
    fetchClassList();
  }

  @override
  void onClose() {
    refreshController.dispose();
    super.onClose();
  }

  Future<void> fetchClassList() async {
    try {
      var fetchedClasses = [
        ClassInfo(id: 1, name: 'Class 1', teacherNickname: 'Teacher A', studentCount: 30, courseCode: 'ABC123'),
        ClassInfo(id: 2, name: 'Class 2', teacherNickname: 'Teacher B', studentCount: 25, courseCode: 'DEF456'),
      ];
      classList.assignAll(fetchedClasses);
      page = 1;
    } catch (e) {
      print('Fetch failed: $e');
    }
  }

  Future<void> onRefresh() async {
    try {
      await fetchClassList();
      refreshController.finishRefresh(IndicatorResult.success);
      refreshController.resetFooter();
      hasMore.value = true;
    } catch (e) {
      refreshController.finishRefresh(IndicatorResult.fail);
      print('Refresh failed: $e');
    }
  }

  Future<void> onLoadMore() async {
    if (!hasMore.value) {
      refreshController.finishLoad(IndicatorResult.noMore);
      return;
    }

    try {
      // 模拟加载更多数据
      await Future.delayed(Duration(seconds: 1));
      var moreClasses = [
        ClassInfo(id: 3, name: 'Class ${page + 2}', teacherNickname: 'Teacher C', studentCount: 20, courseCode: 'GHI789'),
      ];
      
      if (moreClasses.isEmpty) {
        hasMore.value = false;
        refreshController.finishLoad(IndicatorResult.noMore);
      } else {
        classList.addAll(moreClasses);
        page++;
        refreshController.finishLoad(IndicatorResult.success);
      }
    } catch (e) {
      refreshController.finishLoad(IndicatorResult.fail);
      print('Load more failed: $e');
    }
  }

  Future<void> goToClassDetail(int classId) async {
    Get.toNamed('/class_detail', arguments: {'classId': classId});
  }
}
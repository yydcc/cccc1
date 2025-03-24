import 'package:get/get.dart';
import '../../common/utils/http.dart';
import '../../model/assignment_model.dart';
import 'package:easy_refresh/easy_refresh.dart';

import '../../routes/app_pages.dart';

class AssignmentController extends GetxController {
  final HttpUtil httpUtil = HttpUtil();
  final RxList<Assignment> assignments = <Assignment>[].obs;
  final RxList<Assignment> filteredAssignments = <Assignment>[].obs;
  final RxBool isLoading = true.obs;
  final refreshController = EasyRefreshController(
    controlFinishRefresh: true,
    controlFinishLoad: true,
  );
  
  final RxString filterStatus = 'all'.obs;
  
  int currentPage = 1;
  final int pageSize = 10;
  bool hasMore = true;
  final String classId;

  AssignmentController({required this.classId});

  @override
  void onInit() async {
    super.onInit();
    await loadAssignments();
    applyFilter();
    print("以下是获取的作业");
    print(assignments);
  }

  void setFilter(String status) {
    filterStatus.value = status;
    applyFilter();
  }
  
  void applyFilter() {
    if (filterStatus.value == 'all') {
      filteredAssignments.value = assignments;
    } else {
      filteredAssignments.value = assignments.where(
        (assignment) => assignment.status == filterStatus.value
      ).toList();
    }
  }

  Future<void> onRefresh() async {
    try {
      currentPage = 1;
      hasMore = true;
      await loadAssignments();
      applyFilter();
      refreshController.finishRefresh(IndicatorResult.success);
      refreshController.resetFooter();
    } catch (e) {
      refreshController.finishRefresh(IndicatorResult.fail);
    }
  }

  Future<void> onLoadMore() async {
    if (!hasMore) {
      refreshController.finishLoad(IndicatorResult.noMore);
      return;
    }
    
    try {
      currentPage++;
      await loadAssignments(isLoadMore: true);
      applyFilter();
      refreshController.finishLoad(
        hasMore ? IndicatorResult.success : IndicatorResult.noMore
      );
    } catch (e) {
      currentPage--;
      refreshController.finishLoad(IndicatorResult.fail);
    }
  }

  Future<void> loadAssignments({bool isLoadMore = false}) async {
    try {
      isLoading.value = true;
      final response = await httpUtil.get(
        '/assignment/list',
        queryParameters: {
          'classId': classId,
          'page': currentPage,
          'size': pageSize
        }
      );
      
      if (response.code == 200) {
        final data = response.data;
        final List<dynamic> records = data['records'] ?? [];
        
        if (isLoadMore) {
          assignments.addAll(records.map((item) => Assignment.fromJson(item)).toList());
        } else {
          assignments.value = records.map((item) => Assignment.fromJson(item)).toList();
        }
        
        hasMore = currentPage < (data['pages'] ?? 1);
      }
    } catch (e) {
      print('加载作业列表失败: $e');
      Get.snackbar('错误', '获取作业列表失败');
    } finally {
      isLoading.value = false;
    }
  }

  void goToAssignmentDetail(int? assignmentId) {
    if (assignmentId == null || assignmentId == 0) {
      Get.snackbar('错误', '无效的作业ID');
      return;
    }
    
    print('跳转到作业详情页，作业ID: $assignmentId');
    Get.toNamed(
      AppRoutes.ASSIGNMENT_DETAIL,
      arguments: {'assignmentId': assignmentId}
    );
  }

  @override
  void onClose() {
    refreshController.dispose();
    super.onClose();
  }
} 
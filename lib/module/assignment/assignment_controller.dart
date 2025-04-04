import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../common/utils/http.dart';
import '../../common/api/api.dart';
import '../../model/assignment_model.dart';
import 'package:easy_refresh/easy_refresh.dart';

import '../../routes/app_pages.dart';

class AssignmentController extends GetxController {
  final HttpUtil httpUtil = HttpUtil();
  final RxList<Assignment> assignments = <Assignment>[].obs;
  final RxList<Assignment> filteredAssignments = <Assignment>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isManualRefreshing = false.obs;
  final refreshController = EasyRefreshController(
    controlFinishRefresh: true,
    controlFinishLoad: true,
  );
  
  final RxString filterStatus = 'all'.obs;
  
  int currentPage = 1;
  final int pageSize = 10;
  bool hasMore = true;
  final int classId;

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

  Future<void> manualRefresh() async {
    try {
      isManualRefreshing.value = true;
      await onRefresh();
    } finally {
      isManualRefreshing.value = false;
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
      print('刷新失败: $e');
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
      print('加载更多失败: $e');
      currentPage--;
      refreshController.finishLoad(IndicatorResult.fail);
    }
  }

  Future<void> loadAssignments({bool isLoadMore = false}) async {
    try {
      isLoading.value = true;
      
      final response = await API.assignments.getAssignments(classId);
      
      if (response.code == 200 && response.data != null) {
        final data = response.data;
        final List<dynamic> assignmentsData = data is Map ? data['records'] : data;
        
        assignments.value = assignmentsData
            .map((item) => Assignment.fromJson(item))
            .toList();
      } else {
        Get.snackbar('提示', '暂无作业');
      }
    } catch (e) {
      print('加载作业列表失败: $e');
      Get.snackbar('错误', '获取作业列表失败，请检查网络连接');
    } finally {
      isLoading.value = false;
    }
  }

  void goToAssignmentDetail(Assignment assignment) {
    Get.toNamed(
      AppRoutes.ASSIGNMENT_DETAIL,
      arguments: {'assignmentId': assignment.assignmentId}
    );
  }

  void refreshAssignments() {
    loadAssignments();
  }

  @override
  void onClose() {
    refreshController.dispose();
    super.onClose();
  }
} 
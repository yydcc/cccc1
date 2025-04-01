import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../common/utils/http.dart';
import '../../common/api/api.dart';
import '../../model/assignment_model.dart';
import 'package:easy_refresh/easy_refresh.dart';
import '../../routes/app_pages.dart';

class TeacherAssignmentController extends GetxController {
  final RxList<Assignment> assignments = <Assignment>[].obs;
  final RxBool isLoading = true.obs;
  final int classId;
  final RxString filterStatus = 'all'.obs;
  
  EasyRefreshController refreshController = EasyRefreshController(
    controlFinishRefresh: true,
    controlFinishLoad: true,
  );
  
  int currentPage = 1;
  final int pageSize = 10;
  bool hasMore = true;
  
  TeacherAssignmentController({required this.classId});
  
  @override
  void onInit() {
    super.onInit();
    loadAssignments();
  }
  
  @override
  void onClose() {
    refreshController.dispose();
    super.onClose();
  }
  
  Future<void> loadAssignments() async {
    try {
      isLoading.value = true;
      
      final response = await API.assignments.getClassAssignments(classId);
      
      if (response.code == 200 && response.data != null) {
        final List<dynamic> assignmentsData = response.data;
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
      AppRoutes.TEACHER_ASSIGNMENT_DETAIL,
      arguments: {'assignmentId': assignment.assignmentId}
    )?.then((value) {
      if (value == true) {
        loadAssignments();
      }
    });
  }
  
  void createAssignment() {
    Get.toNamed(
      AppRoutes.CREATE_ASSIGNMENT,
      arguments: {'classId': classId}
    )?.then((value) {
      if (value == true) {
        loadAssignments();
      }
    });
  }
  
  void refreshAssignments() {
    loadAssignments();
  }
  
  void goToCreateAssignment() {
    Get.toNamed(
      AppRoutes.CREATE_ASSIGNMENT,
      arguments: {'classId': classId}
    )?.then((value) {
      if (value == true) {
        loadAssignments();
      }
    });
  }
  
  List<Assignment> get filteredAssignments {
    if (filterStatus.value == 'all') {
      return assignments;
    }
    
    return assignments.where((assignment) {
      switch (filterStatus.value) {
        case 'not_started':
          return assignment.status == 'not_started';
        case 'in_progress':
          return assignment.status == 'in_progress';
        case 'expired':
          return assignment.status == 'expired';
        default:
          return true;
      }
    }).toList();
  }
  
  void setFilter(String status) {
    filterStatus.value = status;
  }
  
  Future<void> onRefresh() async {
    try {
      currentPage = 1;
      hasMore = true;
      await loadAssignments();
      if (refreshController.controlFinishRefresh) {
        refreshController.finishRefresh();
        refreshController.resetFooter();
      }
    } catch (e) {
      print('刷新失败: $e');
      if (refreshController.controlFinishRefresh) {
        refreshController.finishRefresh(IndicatorResult.fail);
      }
    }
  }
  
  Future<void> onLoadMore() async {
    try {
      if (hasMore) {
        currentPage++;
        await loadAssignments();
        if (refreshController.controlFinishLoad) {
          refreshController.finishLoad(hasMore ? IndicatorResult.success : IndicatorResult.noMore);
        }
      } else {
        if (refreshController.controlFinishLoad) {
          refreshController.finishLoad(IndicatorResult.noMore);
        }
      }
    } catch (e) {
      print('加载更多失败: $e');
      if (refreshController.controlFinishLoad) {
        refreshController.finishLoad(IndicatorResult.fail);
      }
    }
  }
  
  void goToAssignmentManagement(int? assignmentId) {
    if (assignmentId == null) return;
    
    Get.toNamed(
      AppRoutes.TEACHER_ASSIGNMENT_DETAIL,
      arguments: {'assignmentId': assignmentId}
    )?.then((value) {
      if (value == true) {
        loadAssignments();
      }
    });
  }
} 
import 'package:get/get.dart';
import '../../common/utils/http.dart';
import '../../model/assignment_model.dart';
import 'package:easy_refresh/easy_refresh.dart';
import '../../routes/app_pages.dart';

class TeacherAssignmentController extends GetxController {
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

  TeacherAssignmentController({required this.classId});

  @override
  void onInit() async {
    super.onInit();
    await loadAssignments();
    applyFilter();
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
      
      final response = await httpUtil.get(
        '/assignment/list',
        queryParameters: {
          'classId': classId,
          'page': currentPage,
          'size': pageSize
        }
      ).catchError((error) {
        print('网络请求错误: $error');
        throw error;
      });
      
      if (response.code == 200) {
        final data = response.data;
        
        if (data == null) {
          print('返回数据为空');
          if (!isLoadMore) {
            assignments.clear();
          }
          hasMore = false;
          return;
        }
        
        final List<dynamic> records = data['records'] ?? [];
        final int totalPages = data['pages'] ?? 1;
        
        final List<Assignment> newAssignments = [];
        for (var item in records) {
          try {
            newAssignments.add(Assignment.fromJson(item));
          } catch (e) {
            print('解析作业数据错误: $e');
            // 继续处理下一条数据
          }
        }
        
        if (isLoadMore) {
          assignments.addAll(newAssignments);
        } else {
          assignments.value = newAssignments;
        }
        
        hasMore = currentPage < totalPages;
      } else {
        print('API返回错误: ${response.msg}');
        if (!isLoadMore) {
          // 如果不是加载更多，则清空列表
          assignments.clear();
        }
        hasMore = false;
      }
    } catch (e) {
      print('加载作业列表失败: $e');
      if (!isLoadMore) {
        // 如果不是加载更多，则清空列表
        assignments.clear();
      }
      hasMore = false;
      // 不在这里显示snackbar，避免多次弹出
    } finally {
      isLoading.value = false;
    }
  }

  void goToCreateAssignment() {
    Get.toNamed(
      AppRoutes.CREATE_ASSIGNMENT,
      arguments: {'classId': classId}
    )?.then((value) {
      if (value == true) {
        onRefresh(); // 使用onRefresh而不是直接调用loadAssignments
      }
    });
  }

  void goToAssignmentManagement(int? assignmentId) {
    if (assignmentId == null || assignmentId == 0) {
      Get.snackbar('错误', '无效的作业ID');
      return;
    }
    
    Get.toNamed(
      AppRoutes.TEACHER_ASSIGNMENT_DETAIL,
      arguments: {'assignmentId': assignmentId}
    )?.then((value) {
      if (value == true) {
        onRefresh(); // 使用onRefresh而不是直接调用loadAssignments
      }
    });
  }

  void goToPendingGrading() {
    Get.toNamed(
      AppRoutes.PENDING_GRADING,
      arguments: {'classId': classId}
    )?.then((value) {
      if (value == true) {
        onRefresh(); // 使用onRefresh而不是直接调用loadAssignments
      }
    });
  }

  @override
  void onClose() {
    refreshController.dispose();
    super.onClose();
  }
} 
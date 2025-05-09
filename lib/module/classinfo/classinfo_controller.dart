import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../common/utils/storage.dart';
import '../../model/classinfo_model.dart';
import 'package:cccc1/common/utils/http.dart';
import 'package:cccc1/common/widget/code_input_field.dart';
import 'dart:async';
import '../../routes/app_pages.dart';
import 'package:cccc1/common/api/api.dart';
class ClassinfoController extends GetxController {
  var joinClassCode = ''.obs;
  var isJoining = false.obs; // 标记是否正在加入班级
  final List<TextEditingController> controllers = List.generate(
      6, (_) => TextEditingController());
  final List<FocusNode> focusNodes = List.generate(6, (_) => FocusNode());

  Future<void> showJoinClassDialog() async {
    // 清空输入框
    for (var controller in controllers) {
      controller.clear();
    }
    isJoining.value = false; // 重置按钮状态

    await Get.dialog(
      Obx(() =>
          Dialog(
            child: Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '请输入6位加课码',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Container(
                    width: 300.w,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(6, (index) {
                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4.w),
                            child: CodeInputField(
                              controller: controllers[index],
                              focusNode: focusNodes[index],
                              index: index,
                              totalFields: 6,
                              controllers: controllers,
                              focusNodes: focusNodes,
                              autoFocus: index == 0,
                              onComplete: (value) {
                                String code = controllers
                                    .map((c) => c.text)
                                    .join();
                                if (code.length == 6) {
                                  joinClass(); // 发送请求
                                }
                              },
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          for (var controller in controllers) {
                            controller.clear();
                          }
                          Get.back();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme
                              .of(Get.context!)
                              .primaryColor,
                          padding: EdgeInsets.symmetric(
                              horizontal: 30.w, vertical: 10.h),
                        ),
                        child: Text('取消', style: TextStyle(fontSize: 14.sp)),
                      ),
                      SizedBox(width: 20.w),
                      ElevatedButton(
                        onPressed: isJoining.value ? null : joinClass,
                        // 请求进行中时禁用按钮
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme
                              .of(Get.context!)
                              .primaryColor,
                          padding: EdgeInsets.symmetric(
                              horizontal: 30.w, vertical: 10.h),
                        ),
                        child: isJoining.value
                            ? SizedBox(
                          width: 20.w,
                          height: 20.w,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                            : Text('确定', style: TextStyle(fontSize: 14.sp)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )),
      barrierDismissible: false,
    );
  }

  Future<void> joinClass() async {
    String code = controllers.map((controller) => controller.text).join();
    if (code.length != 6) {
      Get.snackbar('提示', '请输入完整的6位加课码');
      return;
    }

    isJoining.value = true; // 显示加载状态
    joinClassCode.value = code;

    try {
      final storage = await StorageService.instance;
      final userRole = storage.getRole() ?? 'student';
      final response = await API.students.joinClass(
          storage.getUserId() ?? 0, code);
      if (response.code == 200) {
        Get.back(); // 关闭对话框
        Get.snackbar('成功', '成功加入班级');
      } else {
        Get.snackbar('错误', response.msg ?? '加入失败，请检查加课码');
      }
    } catch (e) {
      Get.snackbar('错误', '请求失败，请检查网络');
    } finally {
      isJoining.value = false; // 结束加载状态
    }
  }

  final HttpUtil httpUtil = HttpUtil();
  final RxList<ClassInfo> classList = <ClassInfo>[].obs;
  final refreshController = EasyRefreshController(
    controlFinishRefresh: true,
    controlFinishLoad: true,
  );

  int currentPage = 1;
  final int pageSize = 10;
  bool hasMore = true;

  @override
  void onInit() {
    super.onInit();
    loadClasses();
  }

  @override
  void onClose() {
    refreshController.dispose();
    for (var controller in controllers) {
      controller.dispose();
    }
    for (var focusNode in focusNodes) {
      focusNode.dispose();
    }
    super.onClose();
  }

  Future<void> onRefresh() async {
    try {
      currentPage = 1;
      hasMore = true;
      await loadClasses().timeout(
        Duration(seconds: 3),
        onTimeout: () {
          throw TimeoutException('请求超时');
        },
      );
      refreshController.finishRefresh(IndicatorResult.success);
      refreshController.resetFooter();
    } catch (e) {
      refreshController.finishRefresh(IndicatorResult.fail);
      Get.snackbar('提示', '刷新失败，请检查网络');
    }
  }

  Future<void> onLoadMore() async {
    if (!hasMore) {
      refreshController.finishLoad(IndicatorResult.noMore);
      return;
    }

    try {
      currentPage++;
      await loadClasses(isLoadMore: true).timeout(
        Duration(seconds: 3),
        onTimeout: () {
          throw TimeoutException('请求超时');
        },
      );
      refreshController.finishLoad(
          hasMore ? IndicatorResult.success : IndicatorResult.noMore
      );
    } catch (e) {
      currentPage--; // 加载失败，恢复页码
      refreshController.finishLoad(IndicatorResult.fail);
      Get.snackbar('提示', '加载失败，请检查网络');
    }
  }

  Future<void> loadClasses({bool isLoadMore = false}) async {
    final storage = await StorageService.instance;
    final username = storage.getUsername() ?? '';
    try {
      final response = await API.students.getStudentClasses(
          storage.getUserId() ?? 0);
      if (response.code == 200) {
        final data = response.data;
        final List<ClassInfo> newClasses = (data['records'] as List? ?? [])
            .map((item) =>
            ClassInfo(
              teacherId: item['teacherId'] ?? 0,
              classId: item['classId'] ?? 0,
              className: item['className'] ?? '',
              teacherNickname: item['teacherNickname'] ?? '',
              joinedAt: item['joinedAt'] ?? '',
              courseCode: item['courseCode'] ?? '',
              createAt: item['createdAt'] ?? '',
              studentCount: item['studentCount'] ?? 0,
            ))
            .toList();

        if (isLoadMore) {
          classList.addAll(newClasses);
        } else {
          classList.value = newClasses;
        }

        // 根据后端返回的总页数判断是否还有更多数据
        final int totalPages = data['pages'] ?? 1;
        hasMore = currentPage < totalPages;
      }
    } catch (e) {
      print('Load classes error: $e');
      Get.snackbar('错误', '获取班级列表失败');
      rethrow; // 重新抛出异常以便上层处理
    }
  }

  void handleClassTap(ClassInfo classInfo) {
    Get.toNamed(
      AppRoutes.CLASS_DETAIL,
      arguments: {'classInfo': classInfo},
    );
  }

  void goToQuizzes(ClassInfo classInfo) {
    Get.toNamed(
      AppRoutes.CLASS_QUIZ,
      arguments: {'classId': classInfo.classId}
    );
  }

  void goToAssignments() {
    if (classList.isEmpty) return;
    Get.toNamed(
      AppRoutes.ASSIGNMENT,
      arguments: {'classId': classList[0].classId}
    );
  }

  void goToClassMembers(ClassInfo classInfo) {
    Get.toNamed(
      AppRoutes.CLASS_MEMBERS,
      arguments: {'classId': classInfo.classId}
    );
  }

  void goToAIChat(ClassInfo classInfo) {
    Get.toNamed(
      AppRoutes.AI_CHAT,
      arguments: {'classId': classInfo.classId}
    );
  }
}
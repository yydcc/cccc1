import 'package:cccc1/common/utils/storage.dart';
import 'package:cccc1/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../common/utils/http.dart';
import '../../common/theme/color.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'dart:async';

import '../../model/classinfo_model.dart';
import 'package:cccc1/common/api/api.dart';
class TeacherClassInfoController extends GetxController {
  final HttpUtil httpUtil = HttpUtil();
  final RxList<ClassInfo> classList = <ClassInfo>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  final TextEditingController classNameController = TextEditingController();
  final TextEditingController teacherNicknameController = TextEditingController();
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
    fetchClassList();
  }

  Future<void> fetchClassList({bool isLoadMore = false}) async {
    try {
      if (!isLoadMore) {
        isLoading.value = true;
      }
      hasError.value = false;
      
      final storage = await StorageService.instance;
      final username = storage.getUsername();
      final userId = storage.getUserId()??0;
      if (username == null || username.isEmpty) {
        hasError.value = true;
        errorMessage.value = '用户名不存在，请重新登录';
        return;
      }
      final response = await API.teachers.getTeacherClasses(userId);
      if (response.code == 200 && response.data != null) {
        try {
          final data = response.data;
          final List<dynamic> records = data['records'] as List? ?? [];
          
          final List<ClassInfo> newClasses = [];
          
          for (var item in records) {
            try {
              final classInfo = ClassInfo(
                teacherId: item['teacherId'] ?? 0,
                classId: item['classId'] ?? 0,
                className: item['className'] ?? '',
                teacherNickname: item['teacherNickname'] ?? '',
                joinedAt: item['joinedAt'] ?? '',
                courseCode: item['courseCode'] ?? '',
                createAt: item['createAt'] ?? '',
                studentCount: item['studentCount'] ?? 0,
                assignmentCount: item['assignmentCount'] ?? 0,
              );
              newClasses.add(classInfo);
            } catch (e) {
              print('解析班级数据失败: $e');
              // 继续处理下一个班级
            }
          }
          
          if (isLoadMore) {
            classList.addAll(newClasses);
          } else {
            classList.value = newClasses;
          }
          
          final int totalPages = data['pages'] ?? 1;
          hasMore = currentPage < totalPages;
          
          hasError.value = false;
        } catch (e) {
          print('解析班级列表数据失败: $e');
          hasError.value = true;
          errorMessage.value = '解析班级数据失败';
        }
      } else {
        hasError.value = true;
        errorMessage.value = response.msg ?? '获取班级列表失败';
      }
    } catch (e) {
      print('加载班级列表失败: $e');
      hasError.value = true;
      errorMessage.value = '网络错误，请检查网络连接';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> onRefresh() async {
    try {
      currentPage = 1;
      hasMore = true;
      await fetchClassList();
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
      await fetchClassList(isLoadMore: true);
      refreshController.finishLoad(
        hasMore ? IndicatorResult.success : IndicatorResult.noMore
      );
    } catch (e) {
      currentPage--; // 加载失败，恢复页码
      refreshController.finishLoad(IndicatorResult.fail);
      Get.snackbar('提示', '加载失败，请检查网络');
    }
  }

  void showCreateClassDialog() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.r),
        ),
        child: Container(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '创建新班级',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: GlobalThemData.textPrimaryColor,
                ),
              ),
              SizedBox(height: 20.h),
              TextField(
                controller: classNameController,
                decoration: InputDecoration(
                  labelText: '班级名称',
                  labelStyle: TextStyle(color: GlobalThemData.textSecondaryColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: BorderSide(color: Theme.of(Get.context!).primaryColor),
                  ),
                ),
              ),
              SizedBox(height: 15.h),
              TextField(
                controller: teacherNicknameController,
                decoration: InputDecoration(
                  labelText: '教师昵称',
                  labelStyle: TextStyle(color: GlobalThemData.textSecondaryColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: BorderSide(color: Theme.of(Get.context!).primaryColor),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      classNameController.clear();
                      teacherNicknameController.clear();
                      Get.back();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(Get.context!).primaryColor,
                    ),
                    child: Text('取消'),
                  ),
                  ElevatedButton(
                    onPressed: () => handleCreateClass(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(Get.context!).primaryColor,
                    ),
                    child: Text('创建'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> handleCreateClass() async {
    if (classNameController.text.isEmpty || teacherNicknameController.text.isEmpty) {
      Get.snackbar('错误', '请填写完整信息');
      return;
    }

    try {
      final storage = await StorageService.instance;
      final userId = await storage.getUserId()??0;
      final data = {
      "teacherName":storage.getUsername(),
      'className': classNameController.text,
      'teacherNickname': teacherNicknameController.text,
      };
      final response = await API.teachers.createClass(userId, data);
      if (response.code == 200) {
        Get.back();
        classNameController.clear();
        teacherNicknameController.clear();
        Get.snackbar('成功', '班级创建成功');
        fetchClassList();  // 重新加载班级列表
      } else {
        Get.snackbar('创建失败', response.msg);
      }
    } catch (e) {
      print('Create class error: $e');
      Get.snackbar('错误', '创建班级失败，请稍后重试');
    }
  }

  void goToClassDetail(ClassInfo classInfo) {
    if (classInfo.classId == null) {
      Get.snackbar('错误', '班级ID不存在');
      return;
    }
    
    Get.toNamed(
      AppRoutes.TEACHER_CLASS_DETAIL,
      arguments: {'classInfo': classInfo}
    );
  }

  void goToCreateClass() {
    Get.toNamed(AppRoutes.CREATE_CLASS)?.then((value) {
      if (value == true) {
        fetchClassList();
      }
    });
  }

  void goToJoinClass() {
    Get.toNamed(AppRoutes.JOIN_CLASS)?.then((value) {
      if (value == true) {
        fetchClassList();
      }
    });
  }

  @override
  void onClose() {
    classNameController.dispose();
    teacherNicknameController.dispose();
    refreshController.dispose();
    super.onClose();
  }
} 
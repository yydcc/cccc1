import 'package:cccc1/common/utils/storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../common/utils/http.dart';
import '../../common/theme/color.dart';
import 'package:easy_refresh/easy_refresh.dart';

import 'classinfo_model.dart';



class TeacherClassinfoController extends GetxController {
  final HttpUtil httpUtil = HttpUtil();
  final RxList<ClassInfo> classList = <ClassInfo>[].obs;
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
    loadClasses();
  }

  Future<void> onRefresh() async {
    currentPage = 1;
    hasMore = true;
    await loadClasses();
    refreshController.finishRefresh();
    refreshController.resetFooter();
  }

  Future<void> onLoadMore() async {
    if (!hasMore) {
      refreshController.finishLoad(IndicatorResult.noMore);
      return;
    }
    
    currentPage++;
    await loadClasses(isLoadMore: true);
    refreshController.finishLoad(
      hasMore ? IndicatorResult.success : IndicatorResult.noMore
    );
  }

  Future<void> loadClasses({bool isLoadMore = false}) async {
    final storage = await StorageService.instance;
    final username = storage.getUsername()??'';
    try {
      final response = await httpUtil.post(
        '/teacher/get_class',
        data: {
          'username':username,
          'page': currentPage,
          'size': pageSize,
        },
      );
      
      if (response.code == 200) {
        final List<ClassInfo> newClasses = (response.data['classInfoList'] as List? ?? [])
            .map((item) => ClassInfo(
          teacherId: item['teacherId'],
          classId: item['classId'] ,
          className: item['className'] ?? '',
          teacherNickname: item['teacherNickname'] ?? '',
          joinedAt: item['joinedAt'] ?? '',
          courseCode: item['courseCode'] ?? '',
          createAt: item['createAt'],
          studentCount: item['studentCount'],
        ))
            .toList();

        if (isLoadMore) {
          classList.addAll(newClasses);
        } else {
          classList.value = newClasses;
        }
        
        hasMore = newClasses.length >= pageSize;
      }
    } catch (e) {
      print('Load classes error: $e');
      Get.snackbar('错误', '获取班级列表失败');
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
      final response = await httpUtil.post(
        '/teacher/create_class',
        data: {
          'className': classNameController.text,
          'teacherNickname': teacherNicknameController.text,
        },
      );

      if (response.code == 200) {
        Get.back();
        classNameController.clear();
        teacherNicknameController.clear();
        Get.snackbar('成功', '班级创建成功');
        loadClasses();  // 重新加载班级列表
      } else {
        Get.snackbar('创建失败', response.msg);
      }
    } catch (e) {
      print('Create class error: $e');
      Get.snackbar('错误', '创建班级失败，请稍后重试');
    }
  }

  void handleClassTap(ClassInfo classInfo) {
    // 处理班级点击事件，可以跳转到班级详情页面
    // Get.toNamed('/class-detail', arguments: classInfo);
  }

  @override
  void onClose() {
    classNameController.dispose();
    teacherNicknameController.dispose();
    refreshController.dispose();
    super.onClose();
  }
} 
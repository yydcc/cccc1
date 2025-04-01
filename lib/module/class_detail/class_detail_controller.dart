import 'package:get/get.dart';
import '../../common/utils/http.dart';
import '../../routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cccc1/model/classinfo_model.dart';
import 'package:cccc1/common/api/api.dart';
class ClassDetailController extends GetxController {
  final HttpUtil httpUtil = HttpUtil();
  final classInfo = Rx<ClassInfo?>(null);
  final RxBool isLoading = true.obs;
  final RxList<dynamic> activities = <dynamic>[].obs;
  String? contentUrl;

  @override
  void onInit() {
    super.onInit();
    final Map<String, dynamic> args = Get.arguments;
    final ClassInfo info = args['classInfo'];
    classInfo.value = info;
    loadClassDetail();
  }

  Future<void> loadClassDetail() async {
    if (classInfo.value == null) return;
    
    try {
      isLoading.value = true;
      final response = await API.classes.getClassDetail(classInfo.value!.classId);
      
      if (response.code == 200 && response.data != null) {
        final data = response.data;
        classInfo.value = ClassInfo.fromJson(data);
        activities.value = classInfo.value?.activities ?? [];
        
        contentUrl = data['content_url'];
      }
    } catch (e) {
      print('Load class detail error: $e');
      Get.snackbar('错误', '获取班级详情失败');
    } finally {
      isLoading.value = false;
    }
  }

  // 作业功能
  void goToHomework() {
    Get.toNamed(
      AppRoutes.ASSIGNMENT,
      arguments: {'classId': classInfo.value?.classId},
    );
  }

  // 测试功能
  void goToQuiz() {
    Get.toNamed(
      AppRoutes.CLASS_QUIZ,
      arguments: {'classId': classInfo.value?.classId},
    );
  }

  // 讨论功能
  void goToDiscussion() {
    Get.toNamed(
      AppRoutes.CLASS_DISCUSSION,
      arguments: {'classId': classInfo.value?.classId},
    );
  }

  // 更多功能
  void showMoreOptions() {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.people),
              title: Text('班级成员'),
              onTap: () {
                Get.back();
                goToClassMembers();
              },
            ),
            ListTile(
              leading: Icon(Icons.announcement),
              title: Text('班级公告'),
              onTap: () {
                Get.back();
                goToAnnouncements();
              },
            ),
          ],
        ),
      ),
    );
  }

  // 班级成员
  void goToClassMembers() {
    Get.toNamed(
      AppRoutes.CLASS_MEMBERS,
      arguments: {'classId': classInfo.value?.classId},
    );
  }

  // 班级公告
  void goToAnnouncements() {
    Get.toNamed(
      AppRoutes.CLASS_ANNOUNCEMENTS,
      arguments: {'classId': classInfo.value?.classId},
    );
  }

  Future<void> downloadClassMaterial() async {
    if (contentUrl == null || contentUrl!.isEmpty) {
      Get.snackbar('提示', '没有可下载的资料');
      return;
    }
    
    Get.snackbar('提示', '开始下载班级资料');
  }
} 
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




  // 班级成员
  void goToClassMembers() {
    if (classInfo.value == null) return;
    
    Get.toNamed(
      AppRoutes.CLASS_MEMBERS,
      arguments: {'classId': classInfo.value!.classId}
    );
  }

  // 班级公告


  Future<void> downloadClassMaterial() async {
    if (contentUrl == null || contentUrl!.isEmpty) {
      Get.snackbar('提示', '没有可下载的资料');
      return;
    }
    
    Get.snackbar('提示', '开始下载班级资料');
  }

  void goToAIChat() {
    if (classInfo.value == null) return;
    
    Get.toNamed(
      AppRoutes.AI_CHAT,
      arguments: {'classId': classInfo.value!.classId}
    );
  }
} 
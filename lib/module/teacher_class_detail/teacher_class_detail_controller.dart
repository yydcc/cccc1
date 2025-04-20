import 'package:get/get.dart';
import '../../common/utils/http.dart';
import '../../model/classinfo_model.dart';
import '../../routes/app_pages.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:cccc1/common/api/api.dart';
class TeacherClassDetailController extends GetxController {
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
    try {
      isLoading.value = true;
      
      if (classInfo.value == null) {
        Get.snackbar('错误', '班级信息不存在');
        return;
      }
      
      final int classId = classInfo.value!.classId;
      
      // 获取班级详情
      final response = await API.classes.getClassDetail(classId);
      
      if (response.code == 200 && response.data != null) {
        try {
          // 使用try-catch包裹可能出错的代码
          classInfo.value = ClassInfo.fromJson(response.data);
          

          
          // 安全地获取contentUrl
          contentUrl = response.data['content_url'] as String?;
        } catch (e) {
          print('解析班级详情数据失败: $e');
          Get.snackbar('警告', '解析班级数据时出现问题，部分信息可能不完整');
        }
      } else {
        Get.snackbar('错误', '获取班级信息失败: ${response.msg}');
      }
    } catch (e) {
      print('加载班级详情失败: $e');
      Get.snackbar('错误', '获取班级信息失败，请检查网络连接');
    } finally {
      isLoading.value = false;
    }
  }
  
  void goToAssignmentList() {
    if (classInfo.value == null) {
      Get.snackbar('错误', '班级信息不存在');
      return;
    }
    
    Get.toNamed(
      AppRoutes.TEACHER_ASSIGNMENT,
      arguments: {'classId': classInfo.value!.classId}
    );
  }
  
  void goToCreateAssignment() {
    if (classInfo.value == null) return;
    
    // 跳转到创建作业页面
    Get.toNamed(
      AppRoutes.CREATE_ASSIGNMENT,
      arguments: {'classId': classInfo.value!.classId.toString()}
    )?.then((value) {
      if (value == true) {
        // 如果创建成功，刷新数据
        loadClassDetail();
      }
    });
  }
  
  void goToClassMembers() {
    if (classInfo.value == null) return;

    Get.toNamed(
      AppRoutes.TEACHER_CLASS_MEMBERS,
      arguments: {
        'classId': classInfo.value?.classId,
      },
    );
  }
  
  void goToAnnouncements() {
    if (classInfo.value == null) return;
    
    Get.toNamed(
      AppRoutes.CLASS_ANNOUNCEMENTS,
      arguments: {'classId': classInfo.value!.classId}
    );
  }
  
  void goToPendingGrading() {
    if (classInfo.value == null) return;
    
    // 跳转到待批改作业列表
    Get.toNamed(
      AppRoutes.PENDING_GRADING,
      arguments: {'classId': classInfo.value!.classId}
    );
  }
  
  Future<void> downloadClassMaterial() async {
    if (contentUrl == null || contentUrl!.isEmpty) {
      Get.snackbar('提示', '没有可下载的资料');
      return;
    }
    
    try {
      final String fullUrl = HttpUtil.SERVER_API_URL + contentUrl!;
      print('尝试下载班级资料: $fullUrl');
      
      final Uri? url = Uri.tryParse(fullUrl);
      if (url != null && await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        Get.snackbar('错误', '无法打开资料链接');
      }
    } catch (e) {
      print('下载班级资料失败: $e');
      Get.snackbar('错误', '下载班级资料失败: $e');
    }
  }


  
  void goToQuizManagement() {
    Get.toNamed(
      AppRoutes.TEACHER_QUIZ_MANAGEMENT,
      arguments: {'classId': classInfo.value?.classId}
    )?.then((value) {
      if (value == true) {
        // 刷新数据
        loadClassDetail();
      }
    });
  }
  
  void goToAssignments() {
    Get.toNamed(
      AppRoutes.TEACHER_ASSIGNMENT,
      arguments: {'classId': classInfo.value?.classId}
    )?.then((value) {
      if (value == true) {
        // 刷新数据
        loadClassDetail();
      }
    });
  }
} 
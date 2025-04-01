import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common/utils/http.dart';
import '../../common/utils/storage.dart';
import 'dart:async';
import 'package:cccc1/common/api/api.dart';
class SignUpController extends GetxController {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final HttpUtil httpUtil = HttpUtil();
  
  // 使用 Rx 管理角色选择状态
  final RxString selectedRole = 'student'.obs;
  final RxBool isLoading = false.obs;  // 添加加载状态

  void setRole(String role) {
    selectedRole.value = role;
  }

  Future<void> handleSignUp() async {
    if (isLoading.value) return;  // 如果正在加载，直接返回
    
    if (passwordController.text.isEmpty || usernameController.text.isEmpty) {
      Get.snackbar('提示', '请填写完整信息');
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      Get.snackbar('错误', '两次输入的密码不一致');
      return;
    }

    try {
      isLoading.value = true;  // 开始加载
      dynamic response;
      final  data = {
        'username': usernameController.text,
        'password': passwordController.text,
      };
      if(selectedRole.value == 'student'){
        response = await API.students.register(data) .timeout(  // 添加超时处理
          const Duration(seconds: 3),
          onTimeout: () {
            throw TimeoutException('请求超时');
          },
        );

      }
      else {
        response = await API.teachers.register(data) .timeout(  // 添加超时处理
          const Duration(seconds: 3),
          onTimeout: () {
            throw TimeoutException('请求超时');
          },
        );
      }

      if (response.code == 200) {
        final storage = await StorageService.instance;
        await storage.setRole(selectedRole.value);
        Get.back();  // 返回登录页
        Get.snackbar('注册成功', response.msg);
      } else {
        Get.snackbar("注册失败", response.msg);
      }
    } catch (e) {
      if (e is TimeoutException) {
        Get.snackbar('错误', '注册超时，请检查网络后重试');
      } else {
        Get.snackbar('错误', '注册失败，请稍后重试');
      }
    } finally {
      isLoading.value = false;  // 结束加载
    }
  }

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
} 
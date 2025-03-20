import 'package:cccc1/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../common/utils/http.dart';
import '../../common/utils/storage.dart';
import '../profile/profile_controller.dart';
import 'dart:async';
class SignInController extends GetxController {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final HttpUtil httpUtil = HttpUtil();
  
  // 添加角色选择状态
  final RxString selectedRole = 'student'.obs;
  final RxBool isLoading = false.obs;  // 添加加载状态

  void setRole(String role) {
    selectedRole.value = role;
  }

  Future<void> handleSignIn() async {
    if (isLoading.value) return;  // 如果正在加载，直接返回
    
    if (usernameController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar('提示', '请填写完整信息');
      return;
    }

    try {
      isLoading.value = true;  // 开始加载
      final response = await httpUtil.post(
        '/${selectedRole.value}/login',
        data: {
          'username': usernameController.text,
          'password': passwordController.text,
        },
      ).timeout(  // 添加超时处理
        const Duration(seconds: 3),
        onTimeout: () {
          throw TimeoutException('请求超时');
        },
      );
      
      if (response.code == 200) {
        final storage = await StorageService.instance;
        await storage.setToken(response.data['token']);
        await storage.setRole(selectedRole.value);
        await storage.setUsername(usernameController.text);
        
        Get.snackbar("登录成功", response.msg);
        
        await Get.offAllNamed(
          AppRoutes.HOME,
          arguments: {
            'transition': Transition.fadeIn,
            'duration': const Duration(milliseconds: 500),
          },
        );
      } else {
        Get.snackbar("登录失败", response.msg);
      }
    } catch (e) {
      if (e is TimeoutException) {
        Get.snackbar('错误', '登录超时，请检查网络后重试');
      } else {
        Get.snackbar('错误', '登录失败，请检查网络连接');
      }
    } finally {
      isLoading.value = false;  // 结束加载
    }
  }

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }
} 
import 'package:cccc1/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../common/utils/http.dart';
import '../../common/utils/storage.dart';

class SignInController extends GetxController {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final HttpUtil httpUtil = HttpUtil();
  
  // 添加角色选择状态
  final RxString selectedRole = 'student'.obs;

  void setRole(String role) {
    selectedRole.value = role;
  }

  Future<void> handleSignIn() async {
    if (usernameController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar('提示', '请填写完整信息');
      return;
    }

    try {
      print('Attempting login with role: ${selectedRole.value}');
      final response = await httpUtil.post(
        '/${selectedRole.value}/login',
        data: {
          'username': usernameController.text,
          'password': passwordController.text,
        },
      );
      
      print('Login response: $response');
      print(response.data);
      if (response.code ==  200) {
        final storage = await StorageService.instance;
        await storage.setToken(response.data['token']);
        await storage.setRole(selectedRole.value);
        await storage.setUsername(usernameController.text);
        print(storage);
        print('Token saved: ${response.data['token']}');
        Get.snackbar("登录成功", response.msg);
        Get.offAllNamed(AppRoutes.HOME);
      }
      else{
        Get.snackbar("登录失败", response.msg);
      }
    } catch (e) {
      print('Login error: $e');
      Get.snackbar('错误', '登录失败，请检查网络连接');
    }
  }

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }
} 
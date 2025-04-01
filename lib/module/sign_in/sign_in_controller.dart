import 'package:cccc1/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../common/utils/http.dart';
import '../../common/utils/storage.dart';
import '../../common/api/api.dart';
import '../profile/profile_controller.dart';
import 'dart:async';

class SignInController extends GetxController {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final RxString selectedRole = 'student'.obs;
  final RxBool isLoading = false.obs;

  void setRole(String role) {
    selectedRole.value = role;
  }

  Future<void> handleSignIn() async {
    if (isLoading.value) return;
    
    if (usernameController.text.isEmpty || passwordController.text.isEmpty) {
      Get.snackbar('提示', '请填写完整信息');
      return;
    }

    try {
      isLoading.value = true;
      
      dynamic response;
      if (selectedRole.value == 'student') {
        response = await API.students.login(
          usernameController.text,
          passwordController.text,
        );
      } else {
        response = await API.teachers.login(
          usernameController.text,
          passwordController.text,
        );
      }
      
      if (response.code == 200) {
        final storage = await StorageService.instance;
        await storage.setToken(response.data['token']);
        await storage.setRole(selectedRole.value);
        await storage.setUsername(usernameController.text);
        await storage.setUserId(response.data['userId']);
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
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }
} 
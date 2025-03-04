import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common/utils/http.dart';
import '../../common/utils/storage.dart';

class SignUpController extends GetxController {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final HttpUtil httpUtil = HttpUtil();
  
  // 使用 Rx 管理角色选择状态
  final RxString selectedRole = 'student'.obs;

  void setRole(String role) {
    selectedRole.value = role;
  }

  Future<void> handleSignUp() async {
    if (passwordController.text.isEmpty || usernameController.text.isEmpty) {
      Get.snackbar('提示', '请填写完整信息');
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      Get.snackbar('错误', '两次输入的密码不一致');
      return;
    }

    try {
      final response = await httpUtil.post(
        '/$selectedRole/register',
        data: {
          'username': usernameController.text,
          'password': passwordController.text,
        },
      );
      
      if (response.code == 200) {
        print("here");
        print(response.data);
        final storage = await StorageService.instance;
        await storage.setRole(selectedRole.value);
        Get.snackbar('注册成功',response.msg );
      }
      else{
        Get.snackbar("注册失败", response.msg);
      }
    } catch (e) {
      Get.snackbar('错误', '注册失败，请稍后重试');
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
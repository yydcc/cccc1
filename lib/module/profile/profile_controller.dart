import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../common/utils/http.dart';
import '../../common/utils/storage.dart';
import '../../routes/app_pages.dart';
import '../../common/theme/color.dart';

class ProfileController extends GetxController {
  final HttpUtil httpUtil = HttpUtil();
  final RxString username = 'yizhe'.obs;
  final RxString role = 'student'.obs;
  final RxString avatarUrl = ''.obs;
  
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    loadUserInfo();
  }

  @override
  void onClose() {
    usernameController.dispose();
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  Future<void> loadUserInfo() async {
    try {
      final storage = await StorageService.instance;
      final userRole = storage.getRole() ?? 'student';
      role.value = userRole == 'student' ? '学生' : '教师';
      
      username.value = storage.getUsername() ?? '';
      
      final response = await httpUtil.get('/$userRole/info?username=$username');
      if (response.code == 200) {
        avatarUrl.value = response.data['avatar'] ?? '';
        if (response.data['username'] != null && response.data['username'] != username.value) {
          username.value = response.data['username'];
          await storage.setUsername(username.value);
        }
      }
    } catch (e) {
      print('Load user info error: $e');
      Get.snackbar(
        '错误',
        '获取用户信息失败',
      );
    }
  }

  Future<void> handleUpdateUsername() async {
    final result = await Get.dialog(
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
                '修改用户名',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: GlobalThemData.textPrimaryColor,
                ),
              ),
              SizedBox(height: 20.h),
              TextField(
                controller: usernameController,
                decoration: InputDecoration(
                  labelText: '新用户名',
                  labelStyle: TextStyle(color: GlobalThemData.textSecondaryColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    borderSide: BorderSide(color: GlobalThemData.primaryColor),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text(
                      '取消',
                      style: TextStyle(
                        color: GlobalThemData.textSecondaryColor,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  ElevatedButton(
                    onPressed: () => Get.back(result: usernameController.text),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: GlobalThemData.primaryColor,
                    ),
                    child: Text('确定', style: TextStyle(fontSize: 14.sp)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (result != null && result.toString().isNotEmpty) {
      try {
        final storage = await StorageService.instance;
        final userRole = storage.getRole() ?? 'student';
        
        final response = await httpUtil.post(
          '/$userRole/update/username',
          data: {'username': result},
        );

        if (response.code == 200) {
          username.value = result;
          await storage.setUsername(username.value);
          Get.snackbar(
            '成功',
            '用户名修改成功',
          );
        }
      } catch (e) {
        print('Update username error: $e');
        Get.snackbar(
          '错误',
          '修改用户名失败',
        );
      }
    }
  }

  Future<void> handleChangePassword() async {
    final result = await Get.dialog(
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
                '修改密码',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: GlobalThemData.textPrimaryColor,
                ),
              ),
              SizedBox(height: 20.h),
              TextField(
                controller: oldPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: '原密码',
                  labelStyle: TextStyle(color: GlobalThemData.textSecondaryColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),
              SizedBox(height: 15.h),
              TextField(
                controller: newPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: '新密码',
                  labelStyle: TextStyle(color: GlobalThemData.textSecondaryColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),
              SizedBox(height: 15.h),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: '确认新密码',
                  labelStyle: TextStyle(color: GlobalThemData.textSecondaryColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      oldPasswordController.clear();
                      newPasswordController.clear();
                      confirmPasswordController.clear();
                      Get.back(result: false);
                    },
                    child: Text(
                      '取消',
                      style: TextStyle(
                        color: GlobalThemData.textSecondaryColor,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  ElevatedButton(
                    onPressed: () {
                      if (newPasswordController.text != confirmPasswordController.text) {
                        Get.snackbar('错误', '两次输入的新密码不一致');
                        return;
                      }
                      Get.back(result: true);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: GlobalThemData.primaryColor,
                    ),
                    child: Text('确定', style: TextStyle(fontSize: 14.sp)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (result == true) {
      try {
        final storage = await StorageService.instance;
        final userRole = storage.getRole() ?? 'student';
        
        final response = await httpUtil.put(
          '/$userRole/update/password',
          data: {
            'username': username.value,
            'password': oldPasswordController.text,
            'newPassword': newPasswordController.text,
          },
        );
        usernameController.clear();
        oldPasswordController.clear();
        newPasswordController.clear();
        if (response.code == 200) {
          Get.snackbar('成功', '密码修改成功');
          await storage.removeToken();
          Get.offAllNamed(AppRoutes.SIGN_IN);
        }
        else{
          Get.snackbar("修改失败", response.meg);
        }
      } catch (e) {
        print('Change password error: $e');
      }
    }
  }

  Future<void> handleLogout() async {
    final result = await Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '退出登录',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: GlobalThemData.textPrimaryColor,
                ),
              ),
              SizedBox(height: 15.h),
              Text(
                '确定要退出登录吗？',
                style: TextStyle(
                  color: GlobalThemData.textSecondaryColor,
                ),
              ),
              SizedBox(height: 20.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () => Get.back(result: false),
                    style:ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                    ),
                    child: Text(
                      '取消',
                    ),
                  ),
                  SizedBox(width: 10.w),
                  ElevatedButton(
                    onPressed: () => Get.back(result: true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                    ),
                    child: Text('确定'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (result == true) {
      try {
        final storage = await StorageService.instance;
        await storage.removeToken();
        Get.offAllNamed(AppRoutes.SIGN_IN);
      } catch (e) {
        print('Logout error: $e');
        Get.snackbar(
          '错误',
          '退出登录失败',

        );
      }
    }
  }

  Future<void> handleDeleteAccount() async {
    final result = await Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        child: Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.warning_rounded,
                color: Colors.red,
                size: 50.sp,
              ),
              SizedBox(height: 15),
              Text(
                '删除账号',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: GlobalThemData.textPrimaryColor,
                ),
              ),
              SizedBox(height: 15.h),
              Text(
                '此操作不可恢复，是否继续？',
                style: TextStyle(
                  color: GlobalThemData.textSecondaryColor,
                ),
              ),
              SizedBox(height: 20.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                    ),
                    onPressed: () => Get.back(result: false),
                    child: Text(
                      '取消'
                    ),
                  ),
                  SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: () => Get.back(result: true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: Text('确定删除'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (result == true) {
      try {
        final storage = await StorageService.instance;
        final userRole = storage.getRole() ?? 'student';
        final response = await httpUtil.post('/$userRole/delete',
        data: {
          'username': username.value
        }
        
        );
        
        if (response.code == 200) {
          await storage.removeToken();
          Get.offAllNamed(AppRoutes.SIGN_IN);
          Get.snackbar(
            '成功',
            '账号已删除',
          );
        }
      } catch (e) {
        print('Delete account error: $e');
        Get.snackbar(
          '错误',
          '删除账号失败',
        );
      }
    }
  }
} 
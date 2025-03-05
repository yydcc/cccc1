import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import '../../common/utils/http.dart';
import '../../common/utils/storage.dart';
import '../../routes/app_pages.dart';
import '../../common/theme/color.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';

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
        duration: const Duration(seconds: 2),
      );
    }
  }

  Future<void> handleUpdateUsername() async {
    await Get.dialog(
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
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      usernameController.clear();
                      Get.back();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(Get.context!).primaryColor,
                    ),
                    child: Text('取消', style: TextStyle(fontSize: 14.sp)),
                  ),
                  SizedBox(width: 10.w),
                  ElevatedButton(
                    onPressed: () async {
                      if (usernameController.text.isEmpty) {
                        Get.snackbar('错误', '用户名不能为空', duration: const Duration(seconds: 2));
                        return;
                      }

                      try {
                        final storage = await StorageService.instance;
                        final userRole = storage.getRole() ?? 'student';
                        
                        final response = await httpUtil.post(
                          '/$userRole/update/username',
                          data: {
                            'username': username.value,
                            'newUsername': usernameController.text,
                          },
                        );

                        if (response.code == 200) {
                          username.value = usernameController.text;
                          await storage.setUsername(username.value);
                          Get.back(); // 只在成功时关闭对话框
                          usernameController.clear();
                          Get.snackbar('成功', '用户名修改成功', duration: const Duration(seconds: 2));
                        } else {
                          Get.snackbar('修改失败', response.msg, duration: const Duration(seconds: 2));
                        }
                      } catch (e) {
                        print('Update username error: $e');
                        Get.snackbar('错误', '修改用户名失败，请稍后重试', duration: const Duration(seconds: 2));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(Get.context!).primaryColor,
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
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      oldPasswordController.clear();
                      newPasswordController.clear();
                      confirmPasswordController.clear();
                      Get.back();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(Get.context!).primaryColor,
                    ),
                    child: Text('取消', style: TextStyle(fontSize: 14.sp)),
                  ),
                  SizedBox(width: 10.w),
                  ElevatedButton(
                    onPressed: () async {
                      if (newPasswordController.text != confirmPasswordController.text) {
                        Get.snackbar('错误', '两次输入的新密码不一致', duration: const Duration(seconds: 2));
                        return;
                      }
                      
                      try {
                        final storage = await StorageService.instance;
                        final userRole = storage.getRole() ?? 'student';
                        
                        final response = await httpUtil.post(
                          '/$userRole/update/password',
                          data: {
                            'username': username.value,
                            'password': oldPasswordController.text,
                            'newPassword': newPasswordController.text,
                          },
                        );

                        if (response.code == 200) {
                          Get.back(); // 只在成功时关闭对话框
                          oldPasswordController.clear();
                          newPasswordController.clear();
                          confirmPasswordController.clear();
                          Get.snackbar('成功', '密码修改成功', duration: const Duration(seconds: 2));
                          await storage.removeToken();
                          Get.offAllNamed(AppRoutes.SIGN_IN);
                        } else {
                          Get.snackbar("修改失败", response.msg, duration: const Duration(seconds: 2));
                        }
                      } catch (e) {
                        print('Change password error: $e');
                        Get.snackbar('错误', '修改密码失败，请稍后重试', duration: const Duration(seconds: 2));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(Get.context!).primaryColor,
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(Get.context!).primaryColor,
                    ),
                    onPressed: () => Get.back(result: false),
                    child: Text('取消'),
                  ),
                  SizedBox(width: 10.w),
                  ElevatedButton(
                    onPressed: () => Get.back(result: true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(Get.context!).primaryColor,
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
          duration: const Duration(seconds: 2),
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
                    onPressed: () => Get.back(result: false),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(Get.context!).primaryColor,
                    ),
                    child: Text('取消'),
                  ),
                  SizedBox(width: 10.w),
                  ElevatedButton(
                    onPressed: () => Get.back(result: true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: Text('确认删除'),
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
            duration: const Duration(seconds: 2),
          );
        }
      } catch (e) {
        print('Delete account error: $e');
        Get.snackbar(
          '错误',
          '删除账号失败',
          duration: const Duration(seconds: 2),
        );
      }
    }
  }

  Future<void> handleUpdateAvatar() async {
    try {
      // TODO: 使用 image_picker 选择图片
      // 这里需要添加 image_picker 依赖
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      
      if (image == null) return;

      // 创建 FormData
      String fileName = image.path.split('/').last;
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          image.path,
          filename: fileName,
        ),
        'username': username.value,
      });

      final storage = await StorageService.instance;
      final userRole = storage.getRole() ?? 'student';

      // 上传头像
      final response = await httpUtil.post(
        '/upload/image',
        data: formData,
      );

      if (response.code == 200) {
        // 更新头像地址
        final avatarPath = response.data['path'];
        final updateResponse = await httpUtil.post(
          '/$userRole/update',
          data: {
            'username': username.value,
            'avatar': avatarPath,
          },
        );

        if (updateResponse.code == 200) {
          avatarUrl.value = avatarPath;
          Get.snackbar('成功', '头像更新成功', duration: const Duration(seconds: 2));
        } else {
          Get.snackbar('更新失败', updateResponse.msg, duration: const Duration(seconds: 2));
        }
      } else {
        Get.snackbar('上传失败', response.msg, duration: const Duration(seconds: 2));
      }
    } catch (e) {
      print('Update avatar error: $e');
      Get.snackbar('错误', '更新头像失败，请稍后重试', duration: const Duration(seconds: 2));
    }
  }

  Future<void> handleChangeTheme() async {
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
                '选择主题',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: GlobalThemData.textPrimaryColor,
                ),
              ),
              SizedBox(height: 20.h),
              _buildThemeOption('blue', '蓝色主题'),
              SizedBox(height: 10.h),
              _buildThemeOption('green', '绿色主题'),
              SizedBox(height: 10.h),
              _buildThemeOption('purple', '紫色主题'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeOption(String themeName, String label) {
    return InkWell(
      onTap: () {
        GlobalThemData.changeTheme(themeName);
        Get.back();  // 只保留关闭对话框
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 20.w),
        decoration: BoxDecoration(
          color: GlobalThemData.themes[themeName]?.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: GlobalThemData.themes[themeName]?.primaryColor ?? Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 20.w,
              height: 20.w,
              decoration: BoxDecoration(
                color: GlobalThemData.themes[themeName]?.primaryColor,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 15.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 16.sp,
                color: GlobalThemData.textPrimaryColor,
              ),
            ),
            Spacer(),
            if (GlobalThemData.getCurrentThemeName() == themeName)
              Icon(
                Icons.check_circle,
                color: GlobalThemData.themes[themeName]?.primaryColor,
                size: 20.sp,
              ),
          ],
        ),
      ),
    );
  }
} 
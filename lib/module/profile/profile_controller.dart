import 'package:cccc1/common/api/api_service.dart';
import 'package:cccc1/common/api/student_api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import '../../common/utils/http.dart';
import '../../common/utils/storage.dart';
import '../../routes/app_pages.dart';
import '../../common/theme/color.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import '../../common/api/api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileController extends GetxController {
  final HttpUtil httpUtil = HttpUtil();
  final RxString username = ''.obs;
  final RxString role = ''.obs;
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
      avatarUrl.value = storage.getAvatarUrl()??'';
      username.value = storage.getUsername() ?? '';
      var response;
      if(userRole == 'student'){
        response = await API.students.getStudentInfo(storage.getUserId()??0);
      }
      else{
        response = await API.teachers.getTeacherInfo(storage.getUserId()??0);
      }
      if (response.code == 200) {
        if (response.data['username'] != null && response.data['username'] != username.value) {
          username.value = response.data['username'];
          await storage.setUsername(username.value);
        }
        if(response.data['avatar'] != null && response.data['avatar'] != avatarUrl.value){
          avatarUrl.value = response.data['avatar'];
          await storage.setAvaterUrl(avatarUrl.value);
        }
      }
    } catch (e) {
      print('Load user info error: $e');
      Get.snackbar('错误', '获取用户信息失败');
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
                    borderSide: BorderSide(color: Theme.of(Get.context!).primaryColor),
                  ),
                  hoverColor: Theme.of(Get.context!).primaryColor.withOpacity(0.1),
                  focusColor: Theme.of(Get.context!).primaryColor,
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
                        Get.snackbar('错误', '用户名不能为空');
                        return;
                      }
                      if(username.value == usernameController.text){
                        Get.snackbar("错误","新用户名不能与原用户名相同");
                        return;
                      }

                      try {
                        final storage = await StorageService.instance;
                        final userRole = storage.getRole() ?? 'student';
                        dynamic response;
                        final data = {
                          "username":username.value,
                          "newUsername":usernameController.text
                        };
                        if(userRole == 'student'){
                            print(data);
                              response = await API.students.changeUsername(storage.getUserId()??0,username.value,usernameController.text);
                        }
                        else{
                              response = await API.teachers.changeUsername(storage.getUserId()??0,username.value,usernameController.text);
                        }

                        if (response.code == 200) {
                          username.value = usernameController.text;
                          await storage.setUsername(username.value);
                          Get.back(); // 只在成功时关闭对话框
                          usernameController.clear();
                          Get.snackbar('成功', '用户名修改成功');
                        } else {
                          Get.snackbar('修改失败', response.msg);
                        }
                      } catch (e) {
                        print('Update username error: $e');
                        Get.snackbar('错误', '修改用户名失败，请稍后重试');
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
                        Get.snackbar('错误', '两次输入的新密码不一致');
                        return;
                      }
                      
                      try {
                        final storage = await StorageService.instance;
                        final userRole = storage.getRole() ?? 'student';
                        final userId = storage.getUserId()??0;
                        final response;
                        if(userRole == 'student'){
                          response = await API.students.changePassword(userId,oldPasswordController.text, newPasswordController.text);
                        }
                        else{
                          response = await API.teachers.changePassword(userId,oldPasswordController.text, newPasswordController.text);
                        }
                        if (response.code == 200) {
                          Get.back(); // 只在成功时关闭对话框
                          oldPasswordController.clear();
                          newPasswordController.clear();
                          confirmPasswordController.clear();
                          Get.snackbar('成功', '密码修改成功');
                          await storage.removeToken();
                          Get.offAllNamed(AppRoutes.SIGN_IN);
                        } else {
                          Get.snackbar("修改失败", response.msg);
                        }
                      } catch (e) {
                        print('Change password error: $e');
                        Get.snackbar('错误', '修改密码失败，请稍后重试');
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
        final prefs = await SharedPreferences.getInstance();
        
        // 清除所有本地缓存
        await prefs.clear();
        await storage.removeToken();
        Get.offAllNamed(AppRoutes.SIGN_IN);
      } catch (e) {
        print('Logout error: $e');
        Get.snackbar('错误', '退出登录失败');
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
        final prefs = await SharedPreferences.getInstance();
        final userRole = storage.getRole() ?? 'student';
        final userId = storage.getUserId()??0;
        dynamic response;
        if(userRole == 'student'){
          response = await API.students.deleteStudent(userId);
        }
        else{
          response = await API.teachers.deleteTeacher(userId);
        }
        if (response.code == 200) {
          // 清除所有本地缓存
          await prefs.clear();
          await storage.removeToken();
          Get.offAllNamed(AppRoutes.SIGN_IN);
          Get.snackbar('成功', '账号已删除');
        }
      } catch (e) {
        print('Delete account error: $e');
        Get.snackbar('错误', '删除账号失败');
      }
    }
  }

  Future<void> handleUpdateAvatar() async {
    try {
      final source = await Get.dialog<ImageSource>(
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
                  '选择图片来源',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: GlobalThemData.textPrimaryColor,
                  ),
                ),
                SizedBox(height: 20.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => Get.back(result: ImageSource.camera),
                      icon: Icon(Icons.camera_alt,color: GlobalThemData.backgroundColor),
                      label: Center(child: Text('相机')),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(Get.context!).primaryColor,
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => Get.back(result: ImageSource.gallery),
                      icon: Icon(Icons.photo_library,color: GlobalThemData.backgroundColor),
                      label: Center(child: Text('相册')),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(Get.context!).primaryColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

      if (source == null) return;

      final ImagePicker picker = ImagePicker();
      XFile? image;
      
      // 处理相机权限和异常
      try {
        image = await picker.pickImage(
          source: source,
          maxWidth: 1080,  // 限制图片大小
          maxHeight: 1080,
          imageQuality: 85,  // 压缩质量
        );
      } catch (e) {
        print('Pick image error: $e');
        Get.snackbar('错误', '无法访问${source == ImageSource.camera ? '相机' : '相册'}，请检查权限设置');
        return;
      }

      if (image == null) return;

      // 创建 FormData
      String fileName = image.path.split('/').last;
      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          image.path,
          filename: fileName,
        ),
      });

      final storage = await StorageService.instance;
      final userRole = storage.getRole() ?? 'student';
      final userId = storage.getUserId() ?? 0;

      // 上传头像
      final response = await API.files.uploadFile('image', formData);

      if (response.code == 200) {
        avatarUrl.value = response.data['path'];
        storage.setAvaterUrl(avatarUrl.value);
        
        // 更新用户信息
        dynamic updateResponse;
        if (userRole == 'student') {
          updateResponse = await API.students.updateStudentInfo(
            userId,
            {'avatar': avatarUrl.value}
          );
        } else {
          updateResponse = await API.teachers.updateTeacherInfo(
            userId,
            {'avatar': avatarUrl.value}
          );
        }

        if (updateResponse.code == 200) {
          Get.snackbar('成功', '头像更新成功');
        } else {
          Get.snackbar('更新失败', updateResponse.msg);
        }
      } else {
        Get.snackbar('上传失败', response.msg);
      }
    } catch (e) {
      print('Update avatar error: $e');
      Get.snackbar('错误', '更新头像失败，请稍后重试');
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
              _buildThemeOption('orange', '橙色主题'),
              SizedBox(height: 10.h),
              _buildThemeOption('black', '黑色主题'),
              SizedBox(height: 10.h),
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

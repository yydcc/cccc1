import 'package:cccc1/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../common/theme/color.dart';
import 'sign_in_controller.dart';

class SignInPage extends GetView<SignInController> {
  const SignInPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GlobalThemData.backgroundColor,
      appBar: AppBar(
        title: Text('登录'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 50.h),
                Text(
                  '欢迎登录',
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.bold,
                    color: GlobalThemData.textPrimaryColor,
                  ),
                ),
                SizedBox(height: 40.h),
                TextField(
                  controller: controller.usernameController,
                  decoration: InputDecoration(
                    labelText: '用户名',
                    labelStyle: TextStyle(color: GlobalThemData.textSecondaryColor),
                    prefixIcon: Icon(Icons.person_outline, color: Theme.of(context).primaryColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: BorderSide(color: Theme.of(context).primaryColor),
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                TextField(
                  controller: controller.passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: '密码',
                    labelStyle: TextStyle(color: GlobalThemData.textSecondaryColor),
                    prefixIcon: Icon(Icons.lock_outline, color: Theme.of(context).primaryColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                      borderSide: BorderSide(color: Theme.of(context).primaryColor),
                    ),
                  ),
                ),
                SizedBox(height: 25.h),
                Text(
                  '选择身份',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: GlobalThemData.textPrimaryColor,
                  ),
                ),
                SizedBox(height: 15.h),
                Row(
                  children: [
                    Expanded(child: _buildRoleChoice('student', '学生', Icons.school, context)),
                    SizedBox(width: 15.w),
                    Expanded(child: _buildRoleChoice('teacher', '教师', Icons.person, context)),
                  ],
                ),
                SizedBox(height: 40.h),
                SizedBox(
                  width: double.infinity,
                  height: 50.h,
                  child: ElevatedButton(
                    onPressed: controller.isLoading.value ? null : controller.handleSignIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      minimumSize: Size(double.infinity, 45.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                    child: Obx(() => controller.isLoading.value
                      ? SizedBox(
                          width: 24.w,
                          height: 24.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text('登录', style: TextStyle(fontSize: 16.sp))
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '没有账号？',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: GlobalThemData.textSecondaryColor,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Get.offNamed(AppRoutes.SIGN_UP),
                      child: Text(
                        '立即注册',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleChoice(String value, String label, IconData icon, BuildContext context) {
    return InkWell(
      onTap: () => controller.setRole(value),
      child: Obx(() => Container(
        padding: EdgeInsets.symmetric(vertical: 15.h),
        decoration: BoxDecoration(
          color: controller.selectedRole.value == value 
            ? Theme.of(context).primaryColor.withOpacity(0.1)
            : Colors.transparent,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: controller.selectedRole.value == value 
              ? Theme.of(context).primaryColor
              : GlobalThemData.dividerColor,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: controller.selectedRole.value == value 
                ? Theme.of(context).primaryColor
                : GlobalThemData.textSecondaryColor,
              size: 24.sp,
            ),
            SizedBox(height: 8.h),
            Text(
              label,
              style: TextStyle(
                color: controller.selectedRole.value == value 
                  ? Theme.of(context).primaryColor
                  : GlobalThemData.textSecondaryColor,
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
      )),
    );
  }
} 
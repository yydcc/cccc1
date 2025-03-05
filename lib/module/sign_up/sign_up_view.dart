import 'package:cccc1/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../common/theme/color.dart';
import 'sign_up_controller.dart';

class SignUpPage extends GetView<SignUpController> {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GlobalThemData.backgroundColor,
      extendBody: true,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('注册'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 30.h),
                Text(
                  '创建新账号',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: GlobalThemData.textPrimaryColor,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  '请填写以下信息完成注册',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: GlobalThemData.textSecondaryColor,
                  ),
                ),
                SizedBox(height: 30.h),
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
                SizedBox(height: 20.h),
                TextField(
                  controller: controller.confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: '确认密码',
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
                    onPressed: controller.handleSignUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                    child: Text('注册', style: TextStyle(fontSize: 16.sp)),
                  ),
                ),
                SizedBox(height: 20.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '已有账号？',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: GlobalThemData.textSecondaryColor,
                      ),
                    ),
                    TextButton(
                      onPressed: () => Get.offNamed(AppRoutes.SIGN_IN),
                      child: Text(
                        '立即登录',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
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
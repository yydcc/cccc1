import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../common/theme/color.dart';
import '../../common/utils/http.dart';
import 'profile_controller.dart';

class ProfilePage extends GetView<ProfileController> {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GlobalThemData.backgroundColor,
      appBar: AppBar(
        title: Text('个人中心'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            SizedBox(height: 20.h),
            _buildMenuSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(30.w),

      child: Column(
        children: [
          GestureDetector(
            onTap: controller.handleUpdateAvatar,
            child: Stack(
              children: [
                Obx(() => CircleAvatar(
                  radius: 50.r,
                  backgroundColor: GlobalThemData.primaryColor.withOpacity(0.1),
                  backgroundImage: controller.avatarUrl.value.isNotEmpty
                      ? NetworkImage('${HttpUtil.SERVER_API_URL}${controller.avatarUrl.value}')
                      : null,
                  child: controller.avatarUrl.value.isEmpty
                      ? Icon(
                          Icons.person,
                          size: 50.r,
                          color: GlobalThemData.primaryColor,
                        )
                      : null,
                )),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: EdgeInsets.all(8.r),
                    decoration: BoxDecoration(
                      color: GlobalThemData.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 20.r,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h),
          Obx(() => Text(
            controller.username.value,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: GlobalThemData.textPrimaryColor,
            ),
          )),
          SizedBox(height: 5.h),
          Obx(() => Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: GlobalThemData.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15.r),
            ),
            child: Text(
              controller.role.value,
              style: TextStyle(
                fontSize: 12.sp,
                color: GlobalThemData.primaryColor,
              ),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildMenuSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 40.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.person_outline,
            title: '修改用户名',
            onTap: controller.handleUpdateUsername,
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.color_lens_outlined,
            title: '更改主题',
            onTap: controller.handleChangeTheme,
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.lock_outline,
            title: '修改密码',
            onTap: controller.handleChangePassword,
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.logout,
            title: '退出登录',
            onTap: controller.handleLogout,
            textColor: Colors.orange,
          ),
          _buildDivider(),
          _buildMenuItem(
            icon: Icons.delete_outline,
            title: '删除账号',
            onTap: controller.handleDeleteAccount,
            textColor: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 15.h),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24.sp,
              color: textColor ?? GlobalThemData.textPrimaryColor,
            ),
            SizedBox(width: 15.w),
            Text(
              title,
              style: TextStyle(
                fontSize: 16.sp,
                color: textColor ?? GlobalThemData.textPrimaryColor,
              ),
            ),
            Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              size: 16.sp,
              color: GlobalThemData.textSecondaryColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: GlobalThemData.dividerColor,
    );
  }
} 
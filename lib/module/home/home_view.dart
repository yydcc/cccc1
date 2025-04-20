import 'package:cccc1/common/theme/color.dart';
import 'package:cccc1/routes/app_pages.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../common/utils/storage.dart';
import 'home_controller.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<StorageService>(
      future: StorageService.instance,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final String? role = snapshot.data!.getRole();
        if (role == null) {
          return Center(child: Text('无法获取角色信息', style: TextStyle(fontSize: 16.sp)));
        }

        return Scaffold(
          backgroundColor: GlobalThemData.backgroundColor,
          appBar: AppBar(
            title: const Text('首页'),
            centerTitle: true,
            elevation: 0,
          ),
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                // 根据屏幕宽度动态调整列数
                final crossAxisCount = constraints.maxWidth > 600 ? 3 : 2;
                return Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 16.h,
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: GridView.count(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 16.w,
                          mainAxisSpacing: 16.h,
                          childAspectRatio: 1.2,
                          children: _buildFeatureItems(context, role),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => Get.toNamed(AppRoutes.AI_CHAT),
            backgroundColor: Theme.of(context).primaryColor,
            child: Container(
              width: 40.w,
              height: 40.w,
              child: Icon(
                Icons.smart_toy_outlined,
                color: Colors.white,
                size: 24.sp,
              ),
            ),
          ),
        );
      },
    );
  }

  List<Widget> _buildFeatureItems(BuildContext context, String role) {
    if (role == 'teacher') {
      return [
        _buildFeatureItem(
          context,
          icon: Icons.class_,
          label: '班级详情',
          routeName: AppRoutes.TEACHER_CLASS_DETAIL,
        ),
        _buildFeatureItem(
          context,
          icon: Icons.assignment,
          label: '作业',
          routeName: AppRoutes.TEACHER_ASSIGNMENT,
        ),
        _buildFeatureItem(
          context,
          icon: Icons.add_task,
          label: '创建作业',
          routeName: AppRoutes.CREATE_ASSIGNMENT,
        ),
        _buildFeatureItem(
          context,
          icon: Icons.grade,
          label: '批改作业',
          routeName: AppRoutes.GRADE_SUBMISSION,
        ),
      ];
    } else {
      return [
        _buildFeatureItem(
          context,
          icon: Icons.class_,
          label: '班级详情',
          routeName: AppRoutes.CLASS_DETAIL,
        ),
        _buildFeatureItem(
          context,
          icon: Icons.assignment,
          label: '作业',
          routeName: AppRoutes.ASSIGNMENT,
        ),
        _buildFeatureItem(
          context,
          icon: Icons.quiz,
          label: '测验',
          routeName: AppRoutes.CLASS_QUIZ,
        ),
        _buildFeatureItem(
          context,
          icon: Icons.group,
          label: '班级成员',
          routeName: AppRoutes.CLASS_MEMBERS,
        ),
      ];
    }
  }

  Widget _buildFeatureItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String routeName,
    Object? arguments,
  }) {
    return GestureDetector(
      onTap: () async {
        try {
          await Get.toNamed(routeName, arguments: arguments);
        } catch (e) {
          _showError(context, e);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60.w,
              height: 60.w,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 30.sp,
                color: Theme.of(context).primaryColor,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: GlobalThemData.textPrimaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showError(BuildContext context, Object e) {
    final errorMessage = e is FlutterError ? e.message : e.toString();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('发生错误: $errorMessage'),
        backgroundColor: Colors.red,
      ),
    );
  }
}
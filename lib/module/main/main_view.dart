import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'main_controller.dart';
import '../home/home_view.dart';
import '../schedule/schedule_view.dart';
import '../profile/profile_view.dart';
import '../../common/theme/color.dart';
import '../classinfo/classinfo_view.dart';

class MainPage extends GetView<MainController> {
  const MainPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GlobalThemData.backgroundColor,
      body: Obx(() => IndexedStack(
        index: controller.currentPage.value,
        children: [
          HomePage(),
          SchedulePage(),
          ClassinfoView(),
          ProfilePage(),
        ],
      )),
      bottomNavigationBar: Obx(() => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: controller.currentPage.value,
          onTap: controller.changePage,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0,
          selectedItemColor: Theme.of(context).primaryColor,
          unselectedItemColor: GlobalThemData.textSecondaryColor,
          selectedFontSize: 12.sp,
          unselectedFontSize: 12.sp,
          selectedLabelStyle: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 12.sp,
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: 12.sp,
          ),
          items: [
            _buildBottomNavigationBarItem(
              Icons.home_outlined,
              Icons.home,
              '首页',
              0,
              context,
            ),
            _buildBottomNavigationBarItem(
              Icons.calendar_month_outlined,
              Icons.calendar_month,
              '课程表',
              1,
              context,
            ),
            _buildBottomNavigationBarItem(
              Icons.class_outlined,
              Icons.class_,
              '班级',
              2,
              context,
            ),
            _buildBottomNavigationBarItem(
              Icons.person_outline,
              Icons.person,
              '我的',
              3,
              context,
            ),
          ],
        ),
      )),
    );
  }

  BottomNavigationBarItem _buildBottomNavigationBarItem(
    IconData unselectedIcon,
    IconData selectedIcon,
    String label,
    int index,
    BuildContext context,
  ) {
    return BottomNavigationBarItem(
      icon: Obx(() => Icon(
        controller.currentPage.value == index ? selectedIcon : unselectedIcon,
        size: 26.sp,
        color: controller.currentPage.value == index 
          ? Theme.of(context).primaryColor 
          : GlobalThemData.textSecondaryColor,
      )),
      label: label,
    );
  }
}

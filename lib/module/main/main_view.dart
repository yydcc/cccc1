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
      bottomNavigationBar: Obx(() => _buildBottomNavigationBar(context)),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
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
        items: List.generate(4, (index) {
          return _buildBottomNavigationBarItem(
            context,
            index,
          );
        }),
      ),
    );
  }

  BottomNavigationBarItem _buildBottomNavigationBarItem(
      BuildContext context,
      int index,
      ) {
    final List<String> labels = ['首页', '课程表', '班级', '我的'];
    final List<IconData> unselectedIcons = [
      Icons.home_outlined,
      Icons.calendar_month_outlined,
      Icons.class_outlined,
      Icons.person_outline,
    ];
    final List<IconData> selectedIcons = [
      Icons.home,
      Icons.calendar_month,
      Icons.class_,
      Icons.person,
    ];

    final isSelected = controller.currentPage.value == index;

    return BottomNavigationBarItem(
      icon: Icon(
        isSelected ? selectedIcons[index] : unselectedIcons[index],
        size: 26.sp,
        color: isSelected
            ? Theme.of(context).primaryColor
            : GlobalThemData.textSecondaryColor,
      ),
      label: labels[index],
    );
  }
}
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../module/home/home_view.dart';
import '../module/schedule/schedule_view.dart';
import '../module/classinfo/classinfo_view.dart';
import '../module/profile/profile_view.dart';
import '../common/theme/color.dart';
import '../module/main/main_controller.dart';

class StudentHomePage extends StatelessWidget {
  final MainController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => IndexedStack(
        index: controller.currentPage.value,
        children: [
          HomePage(),
          SchedulePage(),
          ClassinfoView(),
          ProfilePage(),
        ],
      )),
      bottomNavigationBar: Obx(() => BottomNavigationBar(
        currentIndex: controller.currentPage.value,
        onTap: controller.changePage,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '首页',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: '备忘录',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.class_),
            label: '班级',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '我的',
          ),
        ],
      )),
    );
  }
}
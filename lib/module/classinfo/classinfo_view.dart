import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../common/theme/color.dart';
import 'classinfo_controller.dart';

class ClassinfoView extends GetView<ClassinfoController> {
  const ClassinfoView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GlobalThemData.backgroundColor,
      appBar: AppBar(
        title: const Text('我的班级'),
        centerTitle: true,
      ),
      body: Obx(() {
        return EasyRefresh(
          controller: controller.refreshController,
          header: const ClassicHeader(
            processedDuration: Duration(milliseconds: 0),
          ),
          footer: const ClassicFooter(
            processedDuration: Duration(milliseconds: 0),
          ),
          onRefresh: controller.onRefresh,
          onLoad: controller.onLoadMore,
          child: ListView.builder(
            padding: EdgeInsets.all(10.w),
            itemCount: controller.classList.length,
            itemBuilder: (context, index) {
              final classInfo = controller.classList[index];
              return Card(
                margin: EdgeInsets.symmetric(vertical: 8.h, horizontal: 10.w),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                elevation: 3,
                child: ListTile(
                  contentPadding: EdgeInsets.all(16.w),
                  leading: CircleAvatar(
                    backgroundColor: Colors.blueAccent,
                    child: Text(
                      classInfo.name.substring(0, 1),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                    classInfo.name,
                    style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '教师: ${classInfo.teacherNickname}\n学生人数: ${classInfo.studentCount}',
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey[700]),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16.sp, color: Colors.grey),
                  onTap: () => controller.goToClassDetail(classInfo.id),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
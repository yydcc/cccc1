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
      floatingActionButton: FloatingActionButton(
        shape: CircleBorder(),
        onPressed: () {
          controller.showJoinClassDialog();
        },
        child: Icon(Icons.add),
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
                    backgroundColor: Theme.of(context).primaryColor,
                    child: Text(
                      classInfo.className.substring(0, 1),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                    classInfo.className,
                    style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '教师: ${classInfo.teacherNickname}\n课程码: ${classInfo.courseCode}',
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey[700]),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16.sp, color: Colors.grey),
                  onTap: () => controller.goToClassDetail(classInfo.classId),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}

class CodeInputField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool autoFocus;

  CodeInputField({
    required this.controller,
    required this.focusNode,
    this.autoFocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40.w,
      height: 40.h,
      margin: EdgeInsets.symmetric(horizontal: 5.w),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(5.r),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        autofocus: autoFocus,
        textAlign: TextAlign.center,
        maxLength: 1,
        decoration: InputDecoration(
          counterText: '',
          border: InputBorder.none,
        ),
        onChanged: (value) {
          if (value.isNotEmpty) {
            FocusScope.of(context).nextFocus();
          }
        },
        onSubmitted: (value) {
          if (value.isEmpty) {
            FocusScope.of(context).previousFocus();
          }
        },
      ),
    );
  }
}

extension ClassinfoControllerExtension on ClassinfoController {
  void showJoinClassDialog() {
    Get.dialog(
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
                '加入班级',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: GlobalThemData.textPrimaryColor,
                ),
              ),
              SizedBox(height: 20.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) {
                  return CodeInputField(
                    controller: TextEditingController(),
                    focusNode: FocusNode(),
                    autoFocus: index == 0,
                  );
                }),
              ),
              SizedBox(height: 20.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Get.back();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(Get.context!).primaryColor,
                    ),
                    child: Text('取消', style: TextStyle(fontSize: 14.sp)),
                  ),
                  SizedBox(width: 10.w),
                  ElevatedButton(
                    onPressed: () {
                      // 确认加入班级的逻辑
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
}

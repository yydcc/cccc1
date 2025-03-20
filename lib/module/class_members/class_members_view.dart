import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../common/theme/color.dart';
import 'class_members_controller.dart';

class ClassMembersView extends GetView<ClassMembersController> {
  const ClassMembersView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GlobalThemData.backgroundColor,
      appBar: AppBar(
        title: Text('班级成员'),
        centerTitle: true,
      ),
      body: Obx(() => controller.isLoading.value
        ? Center(child: CircularProgressIndicator())
        : Center(child: Text('成员列表')), // TODO: 实现成员列表UI
      ),
    );
  }
} 
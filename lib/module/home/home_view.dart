import 'package:cccc1/common/theme/color.dart';
import 'package:cccc1/routes/app_pages.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';

import 'home_controller.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('首页'),
        centerTitle: true,
      ),
      body: Center(
        child: GestureDetector(
          onTap: () => controller.test(),
          child: Container(
            width: 200.w,
            height: 200.h,
            decoration: BoxDecoration(
              color: GlobalThemData.secondaryColor,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Center(
              child: Obx(() => Text(
                controller.info.value,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                ),
              )),
            ),
          ),
        ),
      ),
    );
  }
}
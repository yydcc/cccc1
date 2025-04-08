import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../common/utils/storage.dart';
import '../../model/classinfo_model.dart';
import 'package:cccc1/common/utils/http.dart';
import 'package:cccc1/common/widget/code_input_field.dart';
import 'dart:async';
import '../../routes/app_pages.dart';
import 'package:cccc1/common/api/api.dart';
import 'package:cccc1/model/classinfo_model.dart';

class ClassinfoController extends GetxController {
  var joinClassCode = ''.obs;
  var isJoining = false.obs; // 标记是否正在加入班级
  final List<TextEditingController> controllers = List.generate(
      6, (_) => TextEditingController());
  final List<FocusNode> focusNodes = List.generate(6, (_) => FocusNode());

  var classList = <ClassInfo>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchClassList();
  }

  Future<void> fetchClassList() async {
    // 模拟从API获取班级列表
    await Future.delayed(Duration(seconds: 2));
    // 这里可以根据实际情况从API获取数据并更新 classList
    classList.value = []; // 更新为实际获取的班级数据
  }

  void handleClassTap(ClassInfo classInfo) {
    // 处理班级点击事件
  }

  Future<void> showJoinClassDialog() async {
    // 清空输入框
    for (var controller in controllers) {
      controller.clear();
    }
    isJoining.value = false; // 重置按钮状态

    await Get.dialog(
      Obx(() =>
          Dialog(
            child: Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '请输入6位加课码',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Container(
                    width: 300.w,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(6, (index) {
                        return Expanded(
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 4.w),
                            child: CodeInputField(
                              controller: controllers[index],
                              focusNode: focusNodes[index],
                              index: index,
                              totalFields: 6,
                              controllers: controllers,
                              focusNodes: focusNodes,
                              autoFocus: index == 0,
                              onComplete: (value) {
                                String code = controllers
                                    .map((c) => c.text)
                                    .join();
                                if (code.length == 6) {
                                  joinClass(); // 发送请求
                                }
                              },
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          for (var controller in controllers) {
                            controller.clear();
                          }
                          Get.back();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(Get.context!).primaryColor,
                          padding: EdgeInsets.symmetric(
                              horizontal: 30.w, vertical: 10.h),
                        ),
                        child: Text('取消', style: TextStyle(fontSize: 14.sp)),
                      ),
                      SizedBox(width: 20.w),
                      ElevatedButton(
                        onPressed: isJoining.value ? null : joinClass,
                        // 请求进行中时禁用按钮
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(Get.context!).primaryColor,
                          padding: EdgeInsets.symmetric(
                              horizontal: 30.w, vertical: 10.h),
                        ),
                        child: isJoining.value
                            ? SizedBox(
                          width: 20.w,
                          height: 20.w,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                            : Text('确定', style: TextStyle(fontSize: 14.sp)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          )),
    );
  }

  Future<void> joinClass() async {
    isJoining.value = true;
    // 模拟加入班级的请求
    await Future.delayed(Duration(seconds: 2));
    isJoining.value = false;
    Get.back();
    fetchClassList();
  }
}
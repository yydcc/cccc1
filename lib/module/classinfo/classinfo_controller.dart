import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../common/utils/storage.dart';
import 'classinfo_model.dart';
import 'package:cccc1/common/utils/http.dart';
import 'package:cccc1/common/widget/code_input_field.dart';

class ClassinfoController extends GetxController {
  var joinClassCode = ''.obs;
  var isJoining = false.obs; // 标记是否正在加入班级
  final List<TextEditingController> controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> focusNodes = List.generate(6, (_) => FocusNode());

  Future<void> showJoinClassDialog() async {
    // 清空输入框
    for (var controller in controllers) {
      controller.clear();
    }
    isJoining.value = false; // 重置按钮状态

    await Get.dialog(
      Obx(() => Dialog(
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
                            String code = controllers.map((c) => c.text).join();
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
                      padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 10.h),
                    ),
                    child: Text('取消', style: TextStyle(fontSize: 14.sp)),
                  ),
                  SizedBox(width: 20.w),
                  ElevatedButton(
                    onPressed: isJoining.value ? null : joinClass, // 请求进行中时禁用按钮
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(Get.context!).primaryColor,
                      padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 10.h),
                    ),
                    child: isJoining.value
                        ? SizedBox(
                      width: 20.w,
                      height: 20.w,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                        : Text('确定', style: TextStyle(fontSize: 14.sp)),
                  ),
                ],
              ),
            ],
          ),
        ),
      )),
      barrierDismissible: false,
    );
  }

  Future<void> joinClass() async {
    String code = controllers.map((controller) => controller.text).join();
    if (code.length != 6) {
      Get.snackbar('提示', '请输入完整的6位加课码');
      return;
    }

    isJoining.value = true; // 显示加载状态
    joinClassCode.value = code;

    try {
      final response = await HttpUtil().post('/join_class', data: {"courseCode": code});

      if (response.code == 200) {
        Get.snackbar('成功', '成功加入班级');
        Get.back(); // 关闭对话框
      } else {
        Get.snackbar('错误', response.msg ?? '加入失败，请检查加课码');
      }
    } catch (e) {
      Get.snackbar('错误', '请求失败，请检查网络');
    } finally {
      isJoining.value = false; // 结束加载状态
    }
  }

  final HttpUtil httpUtil = HttpUtil();
  var classList = <ClassInfo>[].obs;
  late EasyRefreshController refreshController;
  var page = 1;
  var hasMore = true.obs;

  @override
  void onInit() {
    super.onInit();
    refreshController = EasyRefreshController(
      controlFinishRefresh: true,
      controlFinishLoad: true,
    );
    fetchClassList();
  }

  @override
  void onClose() {
    refreshController.dispose();
    for (var controller in controllers) {
      controller.dispose();
    }
    for (var focusNode in focusNodes) {
      focusNode.dispose();
    }
    super.onClose();
  }

  Future<void> fetchClassList() async {
    try {
      final storage = await StorageService.instance;
      final userRole = storage.getRole() ?? 'student';
      final response = await httpUtil.post("/$userRole/get_class", data: {
        "username": storage.getUsername(),
        "page": page,
        "limit": 10,
      });

      if (response.code == 200) {
        var classInfoList = (response.data['classInfoList'] as List<dynamic>)
            .map((json) => ClassInfo.fromJson(json))
            .toList();

        if (page == 1) {
          classList.value = classInfoList;
        } else {
          classList.addAll(classInfoList);
        }

        if (classInfoList.length < 10) {
          hasMore.value = false;
        } else {
          page++;
        }
      } else {
        Get.snackbar("错误", "请求班级数据失败");
      }
    } catch (e) {
      print('Fetch failed: $e');
    }
  }

  Future<void> onRefresh() async {
    try {
      await fetchClassList();
      refreshController.finishRefresh(IndicatorResult.success);
      refreshController.resetFooter();
      hasMore.value = true;
    } catch (e) {
      refreshController.finishRefresh(IndicatorResult.fail);
      print('Refresh failed: $e');
    }
  }

  Future<void> onLoadMore() async {
    if (!hasMore.value) {
      refreshController.finishLoad(IndicatorResult.noMore);
      return;
    }

    try {
      await fetchClassList();
      if (hasMore.value) {
        refreshController.finishLoad(IndicatorResult.success);
      } else {
        refreshController.finishLoad(IndicatorResult.noMore);
      }
    } catch (e) {
      refreshController.finishLoad(IndicatorResult.fail);
      print('Load more failed: $e');
    }
  }

  Future<void> goToClassDetail(int classId) async {
    Get.toNamed('/class_detail', arguments: {'classId': classId});
  }
}

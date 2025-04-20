import 'package:cccc1/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:oktoast/oktoast.dart';
import 'common/theme/color.dart';
import 'common/utils/storage.dart';
import 'module/main/main_binding.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GlobalThemData.init();
  Get.config(
    defaultTransition: Transition.fadeIn,
    defaultDurationTransition: Duration(milliseconds: 200),
  );
  final storage = await StorageService.instance;
  bool isLogined = storage.getToken() != null ? true : false;
  await storage.setRole('student'); // 设置用户角色为学生
  String? userRole = storage.getRole(); // 获取用户角色
  runApp(MyApp(isLogined: isLogined, userRole: userRole));
}

class MyApp extends StatelessWidget {
  final bool isLogined;
  final String? userRole;
  const MyApp({super.key, required this.isLogined, this.userRole});

  @override
  Widget build(BuildContext context) {
    return OKToast(
      child: ScreenUtilInit(
        designSize: Size(400, 640),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (_, child) {
          return Obx(() => GetMaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Flutter demo',
            theme: GlobalThemData.currentTheme.value,
            initialRoute: _getInitialRoute(),
            getPages: AppPages.routes,
            initialBinding: MainBinding(),
            builder: EasyLoading.init(),
          ));
        },
      ),
    );
  }

  String _getInitialRoute() {
    if (!isLogined) {
      return AppPages.INITIAL;
    }
    if (userRole == 'student') {
      return AppRoutes.STUDENT_HOME; // 学生的主页路由
    } else if (userRole == 'teacher') {
      return AppRoutes.TEACHER_HOME; // 教师的主页路由
    } else {
      return AppRoutes.HOME;
    }
  }
}
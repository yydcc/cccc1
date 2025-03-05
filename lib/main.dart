import 'package:cccc1/common/theme/color.dart';
import 'package:cccc1/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:oktoast/oktoast.dart';
import 'common/utils/storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GlobalThemData.init();
  Get.config(
    defaultTransition: Transition.fadeIn,
    defaultDurationTransition: Duration(milliseconds: 200),
  );
  final storage = await StorageService.instance;
  bool isLogined = storage.getToken() != null?true:false;
  runApp(MyApp(isLogined:isLogined));
}

class MyApp extends StatelessWidget {
  final bool isLogined;
  const MyApp({super.key, required this.isLogined});
  @override
  Widget build(BuildContext context) {
    return OKToast( // 包裹整个应用以启用 OKToast
      child: ScreenUtilInit(
        designSize: Size(375, 812), // 设计稿尺寸（根据你的 UI 设计调整）
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (_, child) {
          return Obx(() => GetMaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Flutter Demo',
            theme: GlobalThemData.currentTheme.value,
            initialRoute: isLogined?AppRoutes.HOME:AppPages.INITIAL,
            getPages: AppPages.routes,
            builder: EasyLoading.init(),
          ));
        },
      ),
    );
  }
}


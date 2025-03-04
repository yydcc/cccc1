import 'package:cccc1/common/theme/color.dart';
import 'package:cccc1/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:oktoast/oktoast.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return OKToast( // 包裹整个应用以启用 OKToast
      child: ScreenUtilInit(
        designSize: Size(375, 812), // 设计稿尺寸（根据你的 UI 设计调整）
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (_, child) {
          return GetMaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Flutter Demo',
            theme: GlobalThemData.lightThemeData,
            darkTheme: GlobalThemData.darkThemeData,
            themeMode: ThemeMode.system,
            initialRoute: AppPages.INITIAL,
            getPages:AppPages.routes,
            builder: EasyLoading.init(),
          );
        },
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../module/sign_in/sign_in_binding.dart';
import '../module/sign_in/sign_in_view.dart';
import '../module/sign_up/sign_up_binding.dart';
import '../module/sign_up/sign_up_view.dart';
import '../module/main/main_binding.dart';
import '../module/main/main_view.dart';
part 'app_routes.dart';

class AppPages {
  static const INITIAL = AppRoutes.SIGN_IN;

  static final routes = [
    GetPage(
      name: AppRoutes.SIGN_IN,
      page: () => const SignInPage(),
      binding: SignInBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 200),
    ),
    GetPage(
      name: AppRoutes.SIGN_UP,
      page: () => const SignUpPage(),
      binding: SignUpBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 200),
    ),
    GetPage(
      name: AppRoutes.HOME,
      page: () => const MainPage(),
      binding: MainBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 200),
    ),
  ];
}
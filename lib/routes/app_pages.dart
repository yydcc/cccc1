import 'package:cccc1/model/assignment_model.dart';
import 'package:cccc1/module/quiz_management/teacher_quiz_management_binding.dart';
import 'package:cccc1/module/quiz_management/teacher_quiz_management_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../module/sign_in/sign_in_binding.dart';
import '../module/sign_in/sign_in_view.dart';
import '../module/sign_up/sign_up_binding.dart';
import '../module/sign_up/sign_up_view.dart';
import '../module/main/main_binding.dart';
import '../module/main/main_view.dart';
import '../module/class_detail/class_detail_binding.dart';
import '../module/class_detail/class_detail_view.dart';

import '../module/quiz/quiz_binding.dart';
import '../module/quiz/quiz_view.dart';
import '../module/discussion/discussion_binding.dart';
import '../module/discussion/discussion_view.dart';
import '../module/class_members/class_members_binding.dart';
import '../module/class_members/class_members_view.dart';
import '../module/assignment/assignment_binding.dart';
import '../module/assignment/assignment_view.dart';
import '../module/assignment_detail/assignment_detail_binding.dart';
import '../module/assignment_detail/assignment_detail_view.dart';
import '../module/teacher_class_detail/teacher_class_detail_binding.dart';
import '../module/teacher_class_detail/teacher_class_detail_view.dart';
import '../module/create_assignment/create_assignment_binding.dart';
import '../module/create_assignment/create_assignment_view.dart';
import '../module/teacher_assignment/teacher_assignment_binding.dart';
import '../module/teacher_assignment/teacher_assignment_view.dart';
import '../module/teacher_assignment_detail/teacher_assignment_detail_binding.dart';
import '../module/teacher_assignment_detail/teacher_assignment_detail_view.dart';
import '../module/grade_submission/grade_submission_binding.dart';
import '../module/grade_submission/grade_submission_view.dart';
import '../module/ai_chat/ai_chat_binding.dart';
import '../module/ai_chat/ai_chat_view.dart';
import '../module/create_quiz/create_quiz_binding.dart';
import '../module/create_quiz/create_quiz_view.dart';
import '../module/quiz_detail/quiz_detail_binding.dart';
import '../module/quiz_detail/quiz_detail_view.dart';
import '../module/teacher_quiz_detail/teacher_quiz_detail_binding.dart';
import '../module/teacher_quiz_detail/teacher_quiz_detail_view.dart';
import '../module/schedule/schedule_binding.dart';
import '../module/schedule/schedule_view.dart';

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
    GetPage(
      name: AppRoutes.CLASS_DETAIL,
      page: () => const ClassDetailView(),
      binding: ClassDetailBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 200),
    ),
    GetPage(
      name: AppRoutes.CLASS_QUIZ,
      page: () => const QuizView(),
      binding: QuizBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 200),
    ),
    GetPage(
      name: AppRoutes.CLASS_DISCUSSION,
      page: () => const DiscussionView(),
      binding: DiscussionBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 200),
    ),
    GetPage(
      name: AppRoutes.CLASS_MEMBERS,
      page: () => const ClassMembersView(),
      binding: ClassMembersBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 200),
    ),
    GetPage(
      name: AppRoutes.ASSIGNMENT,
      page: () => AssignmentView(),
      binding: AssignmentBinding(),
    ),
    GetPage(
      name: AppRoutes.ASSIGNMENT_DETAIL,
      page: () => const AssignmentDetailView(),
      binding: AssignmentDetailBinding(),
      transition: Transition.fadeIn,
      transitionDuration: const Duration(milliseconds: 200),
    ),
    GetPage(
      name: AppRoutes.TEACHER_CLASS_DETAIL,
      page: () => TeacherClassDetailView(),
      binding: TeacherClassDetailBinding(),
    ),
    GetPage(
      name: AppRoutes.CREATE_ASSIGNMENT,
      page: () => CreateAssignmentView(),
      binding: CreateAssignmentBinding(),
    ),
    GetPage(
      name: AppRoutes.TEACHER_ASSIGNMENT,
      page: () => TeacherAssignmentView(),
      binding: TeacherAssignmentBinding(),
    ),
    GetPage(
      name: AppRoutes.TEACHER_ASSIGNMENT_DETAIL,
      page: () => TeacherAssignmentDetailView(),
      binding: TeacherAssignmentDetailBinding(),
    ),
    GetPage(
      name: AppRoutes.GRADE_SUBMISSION,
      page: () => const GradeSubmissionView(),
      binding: GradeSubmissionBinding(),
    ),
    GetPage(
      name: AppRoutes.AI_CHAT,
      page: () => const AIChatView(),
      binding: AIChatBinding(),
    ),
    GetPage(
      name: AppRoutes.CREATE_QUIZ,
      page: () => CreateQuizView(),
      binding: CreateQuizBinding(),
    ),
    GetPage(
      name: AppRoutes.QUIZ_DETAIL,
      page: () => QuizDetailView(),
      binding: QuizDetailBinding(),
    ),
    GetPage(name: AppRoutes.TEACHER_QUIZ_MANAGEMENT,
      page: ()=>TeacherQuizManagementView(),
      binding: TeacherQuizManagementBinding(),
    ),
    GetPage(
      name: AppRoutes.TEACHER_QUIZ_DETAIL,
      page: () => TeacherQuizDetailView(),
      binding: TeacherQuizDetailBinding(),
    ),
    GetPage(
      name: AppRoutes.SCHEDULE,
      page: () => ScheduleView(),
      binding: ScheduleBinding(),
    ),
  ];
}
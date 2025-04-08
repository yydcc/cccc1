import 'package:cccc1/module/teacher_classinfo/teacher_classinfo_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../common/theme/color.dart';
import '../../common/utils/storage.dart';
import 'classinfo_controller.dart';

class ClassinfoView extends StatelessWidget {
  const ClassinfoView({Key? key}) : super(key: key);

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.class_outlined,
          size: 80.sp,
          color: GlobalThemData.textSecondaryColor.withOpacity(0.5),
        ),
        SizedBox(height: 20.h),
        Text(
          '还没有加入任何班级',
          style: TextStyle(
            fontSize: 16.sp,
            color: GlobalThemData.textSecondaryColor,
          ),
        ),
        SizedBox(height: 10.h),
        Text(
          '点击右下角按钮加入班级',
          style: TextStyle(
            fontSize: 14.sp,
            color: GlobalThemData.textSecondaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildClassList(BuildContext context, ClassinfoController controller) {
    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: controller.classList.length,
      itemBuilder: (context, index) {
        if (index >= controller.classList.length) return null;
        final classInfo = controller.classList[index];
        return Container(
          margin: EdgeInsets.only(bottom: 16.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => controller.handleClassTap(classInfo),
              borderRadius: BorderRadius.circular(12.r),
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            classInfo.className,
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: Theme
                                  .of(context)
                                  .primaryColor,
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: Theme
                                .of(context)
                                .primaryColor
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(15.r),
                          ),
                          child: Text(
                            '课程码：${classInfo.courseCode}',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Theme
                                  .of(context)
                                  .primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Icon(
                          Icons.school_outlined,
                          size: 16.sp,
                          color: GlobalThemData.textSecondaryColor,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '教师：${classInfo.teacherNickname}',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: GlobalThemData.textSecondaryColor,
                          ),
                        ),
                        Spacer(),
                        Icon(
                          Icons.group_outlined,
                          size: 16.sp,
                          color: GlobalThemData.textSecondaryColor,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '学生：${classInfo.studentCount}',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: GlobalThemData.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<StorageService>(
      future: StorageService.instance,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final role = snapshot.data!.getRole();
        if (role == 'teacher') {
          return TeacherClassInfoView();
        } else {
          return GetBuilder<ClassinfoController>(
            builder: (controller) =>
                Scaffold(
                  backgroundColor: GlobalThemData.backgroundColor,
                  appBar: AppBar(
                    title: const Text('我的班级'),
                    centerTitle: true,
                  ),
                  floatingActionButton: FloatingActionButton(
                    heroTag: "join-class",
                    onPressed: () => controller.showJoinClassDialog(),
                    backgroundColor: Theme
                        .of(context)
                        .primaryColor,
                    child: Icon(Icons.add, color: Colors.white),
                  ),
                  body: EasyRefresh(
                    controller: controller.refreshController,
                    header: const ClassicHeader(
                      processedDuration: Duration(milliseconds: 0),
                    ),
                    footer: const ClassicFooter(
                      processedDuration: Duration(milliseconds: 0),
                    ),
                    onRefresh: controller.onRefresh,
                    onLoad: controller.onLoadMore,
                    child: CustomScrollView(
                      slivers: [
                        SliverFillRemaining(
                          child: Obx(() =>
                          controller.classList.isEmpty
                              ? _buildEmptyState()
                              : _buildClassList(context, controller)
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          );
        }
      },
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 处理加入班级的逻辑
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
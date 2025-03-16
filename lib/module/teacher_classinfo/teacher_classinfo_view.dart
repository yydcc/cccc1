import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../common/theme/color.dart';
import 'teacher_classinfo_controller.dart';
import 'package:easy_refresh/easy_refresh.dart';

class TeacherClassinfoView extends GetView<TeacherClassinfoController> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GlobalThemData.backgroundColor,
      appBar: AppBar(
        title: Text('我的班级'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => controller.showCreateClassDialog(),
        backgroundColor: Theme.of(context).primaryColor,
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
              child: Obx(() => controller.classList.isEmpty
                ? _buildEmptyState()
                : _buildClassList(context)
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.class_outlined,
            size: 80.sp,
            color: GlobalThemData.textSecondaryColor.withOpacity(0.5),
          ),
          SizedBox(height: 20.h),
          Text(
            '还没有创建任何班级',
            style: TextStyle(
              fontSize: 16.sp,
              color: GlobalThemData.textSecondaryColor,
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            '点击右下角按钮创建新班级',
            style: TextStyle(
              fontSize: 14.sp,
              color: GlobalThemData.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassList(BuildContext context) {
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
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(15.r),
                          ),
                          child: Text(
                            '课程码：${classInfo.courseCode}',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          size: 16.sp,
                          color: GlobalThemData.textSecondaryColor,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '创建时间：${classInfo.formattedDate}',
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
                          '学生人数：${classInfo.studentCount}',
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
} 
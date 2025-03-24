import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../common/theme/color.dart';
import '../../model/classinfo_model.dart';
import 'teacher_classinfo_controller.dart';

class TeacherClassInfoView extends GetView<TeacherClassInfoController> {
  const TeacherClassInfoView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GlobalThemData.backgroundColor,
      appBar: AppBar(
        title: const Text('我的班级'),
        centerTitle: true,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.showCreateClassDialog,
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.classList.isEmpty) {
          return _buildLoadingView();
        } else if (controller.hasError.value) {
          return _buildErrorView();
        } else {
          return EasyRefresh(
            controller: controller.refreshController,
            header: const ClassicHeader(

              processedDuration: Duration(milliseconds: 0),
            ),
            footer: const ClassicFooter(

              processedDuration: Duration(milliseconds: 0),
            ),
            onRefresh: controller.onRefresh,
            onLoad: controller.onLoadMore,
            child: controller.classList.isEmpty
                ? _buildEmptyView()
                : _buildClassList(context),
          );
        }
      }),
    );
  }
  
  Widget _buildLoadingView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 40.w,
            height: 40.w,
            child: CircularProgressIndicator(
              strokeWidth: 3.w,
              valueColor: AlwaysStoppedAnimation<Color>(Theme.of(Get.context!).primaryColor),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            '加载中...',
            style: TextStyle(
              fontSize: 16.sp,
              color: GlobalThemData.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 60.sp,
            color: Colors.red,
          ),
          SizedBox(height: 16.h),
          Text(
            '加载失败',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: GlobalThemData.textPrimaryColor,
            ),
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.w),
            child: Text(
              controller.errorMessage.value,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: GlobalThemData.textSecondaryColor,
              ),
            ),
          ),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: controller.fetchClassList,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(Get.context!).primaryColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.r),
              ),
            ),
            child: const Text('重试'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEmptyView() {
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
            '点击右下角按钮创建班级',
            style: TextStyle(
              fontSize: 14.sp,
              color: GlobalThemData.textSecondaryColor,
            ),
          ),
          SizedBox(height: 30.h),
          ElevatedButton.icon(
            onPressed: controller.showCreateClassDialog,
            icon: const Icon(Icons.add),
            label: const Text('创建班级'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(Get.context!).primaryColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.r),
              ),
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
        // 安全检查，防止越界
        if (index >= controller.classList.length) {
          return const SizedBox.shrink();
        }
        
        // 获取班级信息并进行空值检查
        final classInfo = controller.classList[index];
        final className = classInfo.className ?? '未命名班级';
        final courseCode = classInfo.courseCode ?? '无';
        final studentCount = classInfo.studentCount ?? 0;
        
        // 安全处理创建时间
        String createTime = '未知';
        if (classInfo.createAt != null && classInfo.createAt!.isNotEmpty) {
          try {
            createTime = classInfo.createAt!.length > 10 
                ? classInfo.createAt!.substring(0, 10) 
                : classInfo.createAt!;
          } catch (e) {
            print('处理创建时间出错: $e');
          }
        }
        
        return Container(
          margin: EdgeInsets.only(bottom: 16.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => controller.goToClassDetail(classInfo),
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
                            className,
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
                            '课程码：$courseCode',
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
                          Icons.people_outline,
                          size: 16.sp,
                          color: GlobalThemData.textSecondaryColor,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '学生人数：$studentCount',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: GlobalThemData.textSecondaryColor,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 16.sp,
                          color: GlobalThemData.textSecondaryColor,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '创建时间：$createTime',
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
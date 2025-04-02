import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../common/theme/color.dart';
import 'quiz_controller.dart';
import '../../model/assignment_model.dart';

class QuizView extends GetView<QuizController> {
  const QuizView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GlobalThemData.backgroundColor,
      appBar: AppBar(
        title: Text('课堂测验'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: controller.refreshQuizList,
            tooltip: '刷新',
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildLoadingView();
        } else if (controller.quizzes.isEmpty) {
          return _buildEmptyView();
        } else {
          return _buildQuizList();
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
  
  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.quiz_outlined,
            size: 60.sp,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: 16.h),
          Text(
            '暂无课堂测验',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: GlobalThemData.textSecondaryColor,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            '教师发布测验后将显示在这里',
            style: TextStyle(
              fontSize: 14.sp,
              color: GlobalThemData.textTertiaryColor,
            ),
          ),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: controller.refreshQuizList,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(Get.context!).primaryColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text(
              '刷新',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildQuizList() {
    return RefreshIndicator(
      onRefresh: controller.refreshQuizList,
      child: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: controller.quizzes.length,
        itemBuilder: (context, index) {
          final quiz = controller.quizzes[index];
          return _buildQuizItem(quiz);
        },
      ),
    );
  }
  
  Widget _buildQuizItem(Assignment quiz) {
    return Card(
      margin: EdgeInsets.only(bottom: 16.h),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: InkWell(
        onTap: () => controller.goToQuizDetail(quiz),
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: quiz.statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      quiz.statusText,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: quiz.statusColor,
                      ),
                    ),
                  ),
                  Spacer(),
                  Icon(
                    Icons.quiz,
                    size: 20.sp,
                    color: Theme.of(Get.context!).primaryColor,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    '课堂测验',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Theme.of(Get.context!).primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Text(
                quiz.title ?? '未命名测验',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: GlobalThemData.textPrimaryColor,
                ),
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Icon(
                    Icons.event,
                    size: 16.sp,
                    color: GlobalThemData.textSecondaryColor,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    '截止时间: ${quiz.formattedDeadline}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: quiz.isDeadlineNear ? Colors.orange : GlobalThemData.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
} 
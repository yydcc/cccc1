import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../common/utils/http.dart';
import '../../model/assignment_model.dart';
import '../../model/submission_model.dart';
import '../../routes/app_pages.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cccc1/common/api/api.dart';

class TeacherAssignmentDetailController extends GetxController {
  final HttpUtil httpUtil = HttpUtil();
  final assignment = Rx<Assignment?>(null);
  final RxList<Submission> submissions = <Submission>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isSubmissionsLoading = true.obs;

  final int assignmentId;

  TeacherAssignmentDetailController({required this.assignmentId});

  @override
  void onInit() {
    super.onInit();
    loadAssignmentDetail();
    loadSubmissions();
  }

  Future<void> loadAssignmentDetail() async {
    try {
      isLoading.value = true;

      final response = await API.assignments.getAssignmentDetail(assignmentId);

      if (response.code == 200 && response.data != null) {
        assignment.value = Assignment.fromJson(response.data);
      } else {
        Get.snackbar('错误', '获取作业详情失败: ${response.msg}');
      }
    } catch (e) {
      print('加载作业详情失败: $e');
      Get.snackbar('错误', '获取作业详情失败，请检查网络连接');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadSubmissions() async {
    try {
      isSubmissionsLoading.value = true;

      final response = await API.submissions.getAssignmentSubmissions(
          assignmentId);

      if (response.code == 200 && response.data != null) {
        final List<dynamic> submissionData = response.data is List
            ? response.data
            : (response.data['submissions'] is List ? response
            .data['submissions'] : []);

        submissions.value = submissionData
            .map((item) => Submission.fromJson(item))
            .toList();
      } else {
        Get.snackbar('提示', '暂无学生提交');
      }
    } catch (e) {
      print('加载提交列表失败: $e');
      Get.snackbar('错误', '获取提交列表失败，请检查网络连接');
    } finally {
      isSubmissionsLoading.value = false;
    }
  }

  Future<void> downloadAttachment() async {
    if (assignment.value == null ||
        assignment.value!.contentUrl == null ||
        assignment.value!.contentUrl!.isEmpty) {
      Get.snackbar('提示', '没有可下载的附件');
      return;
    }

    try {
      final String fullUrl = HttpUtil.SERVER_API_URL +
          assignment.value!.contentUrl!;
      print('尝试下载附件: $fullUrl');

      final Uri? url = Uri.tryParse(fullUrl);
      if (url != null && await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        Get.snackbar('错误', '无法打开附件链接');
      }
    } catch (e) {
      print('下载附件失败: $e');
      Get.snackbar('错误', '下载附件失败: $e');
    }
  }

  void goToGradeSubmission(Submission submission) {
    Get.toNamed(
        AppRoutes.GRADE_SUBMISSION,
        arguments: {'submissionId': submission.submissionId}
    )?.then((value) {
      if (value == true) {
        loadAssignmentDetail();
      }
    });
  }

  void editAssignment() {
    if (assignment.value == null) return;

    Get.toNamed(
        AppRoutes.EDIT_ASSIGNMENT,
        arguments: {'assignment': assignment.value}
    )?.then((value) {
      if (value == true) {
        loadAssignmentDetail();
      }
    });
  }

  void deleteAssignment() {
    Get.dialog(
      AlertDialog(
        title: const Text('删除作业'),
        content: const Text('确定要删除这个作业吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              try {
                final response = await API.assignments.deleteAssignment(
                    assignmentId);

                if (response.code == 200) {
                  Get.back(result: true);
                  Get.snackbar('成功', '作业已删除');
                } else {
                  Get.snackbar('错误', '删除作业失败: ${response.msg}');
                }
              } catch (e) {
                print('删除作业失败: $e');
                Get.snackbar('错误', '删除作业失败，请稍后重试');
              }
            },
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> autoGradeAll() async {
    if (isLoading.value) return;

    try {
      isLoading.value = true;

      final result = await Get.dialog(
        AlertDialog(
          title: Text('AI自动批改'),
          content: Text('确定要使用AI对所有未批改提交进行自动批改吗？'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: Text('取消'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: Text('确定'),
            ),
          ],
        ),
      );

      if (result == true) {
        final response = await API.quiz.autoGradeAll(assignmentId);

        if (response.code == 200) {
          Get.snackbar('成功', 'AI批改已启动，请稍后刷新查看结果');
          loadSubmissions();
        } else {
          Get.snackbar('操作失败', response.msg);
        }
      }
    } catch (e) {
      print('AI批改失败: $e');
      Get.snackbar('错误', 'AI批改失败，请稍后重试');
    } finally {
      isLoading.value = false;
    }
  }
}
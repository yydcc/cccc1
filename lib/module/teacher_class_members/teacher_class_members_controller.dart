import 'package:cccc1/common/utils/http.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:cccc1/model/class_member_model.dart';

class TeacherClassMembersController extends GetxController {
  final RxList<ClassMember> members = <ClassMember>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isAdding = false.obs;
  final http = HttpUtil();
  final int classId;
  final TextEditingController searchController = TextEditingController();
  final RxString searchText = ''.obs;

  TeacherClassMembersController({
    required this.classId,
  });

  @override
  void onInit() {
    super.onInit();
    fetchMembers();
    // 监听搜索文本变化
    searchController.addListener(() {
      searchText.value = searchController.text;
    });
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> fetchMembers() async {
    try {
      isLoading.value = true;
      final response = await http.get("/classes/$classId/students");
      if (response.data != null) {
        final list = (response.data as List)
            .map((item) => ClassMember.fromJson(item))
            .toList();
        members.value = list;
      }
    } catch (e) {
      debugPrint('获取成员列表失败: $e');
      Get.snackbar(
        '错误',
        '获取成员列表失败',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addMember(int studentId) async {
    try {
      isAdding.value = true;
      final response = await http.post("/classes/$classId/students", queryParameters: {
          "studentId": studentId,
      });

      if(response.code == 200){
        Get.snackbar(
          '添加成功',
          '已成功添加该学生到班级',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
          icon: const Icon(Icons.check_circle, color: Colors.white),
        );
        // 等待snackbar显示后再刷新列表
        await Future.delayed(const Duration(seconds: 2));
        await fetchMembers();
      }
      else{
        Get.snackbar(
            '添加失败',
             response.msg,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            duration: const Duration(seconds: 2),
            icon: const Icon(Icons.error, color: Colors.white));
      };
      await Future.delayed(const Duration(seconds: 2));

    } catch (e) {
      debugPrint('添加成员失败: $e');
      Get.snackbar(
        '添加失败',
        '请检查学号是否正确或该学生是否已在班级中',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.error, color: Colors.white),
      );
    } finally {
      isAdding.value = false;
    }
  }

  Future<void> removeMember(int studentId) async {
    try {
      await http.delete("/classes/$classId/students/$studentId");
      await fetchMembers();
      Get.snackbar(
        '成功',
        '移除成员成功',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      debugPrint('移除成员失败: $e');
      Get.snackbar(
        '错误',
        '移除成员失败',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  List<ClassMember> get filteredMembers {
    if (searchText.isEmpty) return members;
    return members.where((member) {
      return member.username.toLowerCase().contains(searchText.toLowerCase()) ||
          member.studentId.toString().toLowerCase().contains(searchText.toLowerCase());
    }).toList();
  }
} 
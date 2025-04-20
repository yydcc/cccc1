import 'package:cccc1/common/utils/http.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:cccc1/model/class_member_model.dart';

class ClassMembersController extends GetxController {
  final RxList<ClassMember> members = <ClassMember>[].obs;
  final RxBool isLoading = true.obs;
  final http = HttpUtil();
  final int classId;
  final TextEditingController searchController = TextEditingController();
  final RxString searchText = ''.obs;

  ClassMembersController({
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
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        icon: const Icon(Icons.error, color: Colors.white),
      );
    } finally {
      isLoading.value = false;
    }
  }

  List<ClassMember> get filteredMembers {
    if (searchText.isEmpty) return members;
    return members.where((member) {
      return member.studentId.toString().contains(searchText.value) ||
          member.username.toLowerCase().contains(searchText.value.toLowerCase());
    }).toList();
  }
} 
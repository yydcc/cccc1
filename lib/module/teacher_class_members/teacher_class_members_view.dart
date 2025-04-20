import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cccc1/model/class_member_model.dart';
import 'teacher_class_members_controller.dart';
import 'package:cccc1/common/utils/http.dart';

class TeacherClassMembersView extends GetView<TeacherClassMembersController> {
  const TeacherClassMembersView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('班级成员'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () => _showAddMemberDialog(),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              return RefreshIndicator(
                onRefresh: () => controller.fetchMembers(),
                child: _buildMemberList(),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: TextField(
        controller: controller.searchController,
        decoration: InputDecoration(
          hintText: '搜索成员',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      ),
    );
  }

  Widget _buildMemberList() {
    return Obx(() {
      final members = controller.filteredMembers;
      if (members.isEmpty) {
        return const Center(child: Text('暂无成员'));
      }
      return ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: members.length,
        itemBuilder: (context, index) {
          final member = members[index];
          return _buildMemberItem(member);
        },
      );
    });
  }

  Widget _buildMemberItem(ClassMember member) {
    return Card(
      margin: EdgeInsets.only(bottom: 8.h),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.blue,
          backgroundImage: member.avatar != null
              ? NetworkImage(HttpUtil.SERVER_API_URL + member.avatar!)
              : null,
          child: member.avatar == null
              ? const Icon(Icons.person, color: Colors.white)
              : null,
          onBackgroundImageError: (_, __) {
            // 当图片加载失败时，显示默认图标
            const Icon(Icons.person, color: Colors.white);
          },
        ),
        title: Text(member.username),
        subtitle: Text('学号: ${member.studentId}'),
        trailing: IconButton(
          icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
          onPressed: () => _showRemoveConfirmDialog(member),
        ),
      ),
    );
  }

  void _showAddMemberDialog() {
    final studentIdController = TextEditingController();
    Get.dialog(
      AlertDialog(
        title: const Text('添加成员'),
        content: TextField(
          controller: studentIdController,
          decoration: const InputDecoration(
            labelText: '学号',
            hintText: '请输入学生学号',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('取消'),
          ),
          Obx(() => TextButton(
            onPressed: controller.isAdding.value
                ? null
                : () async {
                    if (studentIdController.text.isEmpty) {
                      Get.snackbar(
                        '错误',
                        '请输入学号',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                      return;
                    }
                    await controller.addMember(int.parse(studentIdController.text.trim()));
                    Get.back();
                  },
            child: controller.isAdding.value
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('添加'),
          )),
        ],
      ),
    );
  }

  void _showRemoveConfirmDialog(ClassMember member) {
    Get.dialog(
      AlertDialog(
        title: const Text('确认移除'),
        content: Text('确定要移除 ${member.username} 吗？'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              await controller.removeMember(member.studentId);
              Get.back();
            },
            child: const Text('确定'),
          ),
        ],
      ),
    );
  }
} 
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cccc1/model/class_member_model.dart';
import 'package:cccc1/common/utils/http.dart';
import 'class_members_controller.dart';

class ClassMembersView extends GetView<ClassMembersController> {
  const ClassMembersView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('班级成员'),
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
      ),
    );
  }
} 
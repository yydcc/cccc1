import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../common/theme/color.dart';
import '../../routes/app_pages.dart';
import 'schedule_controller.dart';

class SchedulePage extends GetView<ScheduleController> {
  const SchedulePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GlobalThemData.backgroundColor,
      appBar: AppBar(
        title: const Text('课程表'),
        centerTitle:true,
      ),
      body: const Center(
        child: Text('课程表内容'),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "ai-chat",
        onPressed: () => Get.toNamed(AppRoutes.AI_CHAT),
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.smart_toy_outlined, color: Colors.white),
        tooltip: 'AI助手',
      ),
    );
  }
} 
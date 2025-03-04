import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'schedule_controller.dart';

class SchedulePage extends GetView<ScheduleController> {
  const SchedulePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('课程表'),
        centerTitle:true,
      ),
      body: const Center(
        child: Text('课程表内容'),
      ),
    );
  }
} 
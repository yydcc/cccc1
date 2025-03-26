import 'package:cccc1/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'message_controller.dart';


class MessagePage extends GetView<MessageController> {
  const MessagePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('消息'),
      ),
      body: const Center(
        child: Text('消息内容'),
      ),

    );
  }
} 
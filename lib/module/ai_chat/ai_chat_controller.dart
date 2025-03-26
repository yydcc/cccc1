import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:math';
import 'dart:async';
import '../../common/utils/http.dart';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/services.dart';

class Message {
  final bool isUser;
  final String content;
  final DateTime timestamp;

  Message({
    required this.isUser,
    required this.content,
    required this.timestamp,
  });
}

class AIChatController extends GetxController {
  final HttpUtil httpUtil = HttpUtil();
  final textController = TextEditingController();
  final scrollController = ScrollController();
  final RxList<Message> messages = <Message>[].obs;
  final RxBool isLoading = false.obs;
  final RxString currentResponse = ''.obs;
  
  late String sessionId;
  late dio.Dio dioInstance;
  late dio.CancelToken cancelToken;
  
  @override
  void onInit() {
    super.onInit();
    sessionId = _generateSessionId();
    dioInstance = dio.Dio();
    cancelToken = dio.CancelToken();
    
    // 添加欢迎消息
    messages.add(Message(
      isUser: false,
      content: '你好！我是AI助手，有什么我可以帮助你的吗？',
      timestamp: DateTime.now(),
    ));
    
    // 连接SSE
    connectToSSE();
  }
  
  @override
  void onClose() {
    textController.dispose();
    scrollController.dispose();
    cancelToken.cancel("控制器销毁");
    super.onClose();
  }
  
  void connectToSSE() async {
    try {
      // 创建EventSource连接
      final url = '${HttpUtil.SERVER_API_URL}/chat/connect?sessionId=$sessionId';
      print('连接到SSE: $url');
      
      final response = await dioInstance.get(
        url,
        options: dio.Options(
          responseType: dio.ResponseType.stream,
          headers: {'Accept': 'text/event-stream'},
        ),
        cancelToken: cancelToken,
      );
      
      final stream = response.data.stream;
      String buffer = '';
      
      stream.listen(
        (data) {
          final String chunk = utf8.decode(data);
          buffer += chunk;
          
          if (buffer.contains('\n\n')) {
            final parts = buffer.split('\n\n');
            buffer = parts.removeLast();
            
            for (final part in parts) {
              _processEventChunk(part);
            }
          }
        },
        onError: (error) {
          print('SSE流错误: $error');
          Get.snackbar('连接错误', '与AI助手的连接中断，请刷新页面重试');
          isLoading.value = false;
        },
        onDone: () {
          print('SSE连接关闭');
          isLoading.value = false;
        },
        cancelOnError: true,
      );
    } catch (e) {
      print('连接SSE失败: $e');
      Get.snackbar('连接错误', '无法连接到AI助手，请稍后重试');
      isLoading.value = false;
    }
  }
  
  void _processEventChunk(String chunk) {
    String? event;
    String? data;
    String? id;
    
    for (final line in chunk.split('\n')) {
      if (line.startsWith('event:')) {
        event = line.substring(6).trim();
      } else if (line.startsWith('data:')) {
        data = line.substring(5).trim();
      } else if (line.startsWith('id:')) {
        id = line.substring(3).trim();
      }
    }
    
    if (data != null) {
      print('收到SSE事件: $event, 数据: $data, ID: $id');
      
      if (event == 'connected') {
        print('SSE连接成功');
      } else if (event == 'message') {
        currentResponse.value += data;
        scrollToBottom();
      } else if (event == 'complete' || data == '[DONE]') {
        // 消息完成，添加到消息列表
        if (currentResponse.isNotEmpty) {
          messages.add(Message(
            isUser: false,
            content: currentResponse.value,
            timestamp: DateTime.now(),
          ));
          currentResponse.value = '';
          isLoading.value = false;
        }
      } else if (event == 'error') {
        // 处理错误
        Get.snackbar('错误', '与AI助手通信时出错: $data');
        isLoading.value = false;
      }
    }
    
    // 增加超时处理
    _resetLoadingIfNeeded();
  }
  
  // 增加超时处理机制
  Timer? _loadingTimer;
  
  void _resetLoadingIfNeeded() {
    _loadingTimer?.cancel();
    _loadingTimer = Timer(const Duration(seconds: 30), () {
      if (isLoading.value) {
        print('响应超时，强制结束加载状态');
        isLoading.value = false;
        if (currentResponse.isNotEmpty) {
          messages.add(Message(
            isUser: false,
            content: currentResponse.value,
            timestamp: DateTime.now(),
          ));
          currentResponse.value = '';
        }
        Get.snackbar('提示', '响应超时，已显示当前接收到的内容');
      }
    });
  }
  
  void sendMessage() async {
    final message = textController.text.trim();
    if (message.isEmpty) return;
    
    // 添加用户消息到列表
    messages.add(Message(
      isUser: true,
      content: message,
      timestamp: DateTime.now(),
    ));
    
    // 清空输入框
    textController.clear();
    
    // 滚动到底部
    scrollToBottom();
    
    // 设置加载状态
    isLoading.value = true;
    
    try {
      // 发送消息到服务器
      await dioInstance.post(
        '${HttpUtil.SERVER_API_URL}/chat/send',
        data: {
          'sessionId': sessionId,
          'message': message,
        },
        cancelToken: cancelToken,
      );
    } catch (e) {
      print('发送消息失败: $e');
      Get.snackbar('错误', '发送消息失败，请稍后重试');
      isLoading.value = false;
    }
  }
  
  void clearHistory() async {
    try {
      await dioInstance.post(
        '${HttpUtil.SERVER_API_URL}/chat/clear',
        data: {
          'sessionId': sessionId,
        },
        cancelToken: cancelToken,
      );
      
      // 清空本地消息，只保留欢迎消息
      messages.clear();
      messages.add(Message(
        isUser: false,
        content: '你好！我是AI助手，有什么我可以帮助你的吗？',
        timestamp: DateTime.now(),
      ));
      
      Get.snackbar('成功', '聊天历史已清空');
    } catch (e) {
      print('清空历史失败: $e');
      Get.snackbar('错误', '清空历史失败，请稍后重试');
    }
  }
  
  void copyMessage(String content) {
    Clipboard.setData(ClipboardData(text: content)).then((_) {
      Get.snackbar('成功', '文本已复制到剪贴板');
    });
  }
  
  void scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
  
  // 生成唯一会话ID
  String _generateSessionId() {
    final random = Random();
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final result = StringBuffer();
    
    for (var i = 0; i < 32; i++) {
      result.write(chars[random.nextInt(chars.length)]);
    }
    
    return result.toString();
  }
} 
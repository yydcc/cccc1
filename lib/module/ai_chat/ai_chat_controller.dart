import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:math';
import 'dart:async';
import '../../common/utils/http.dart';
import 'package:dio/dio.dart' as dio;
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  
  // 存储会话历史的键
  static const String CHAT_HISTORY_KEY = 'ai_chat_history';
  
  @override
  void onInit() {
    super.onInit();
    // 从本地存储加载历史记录
    _loadChatHistory();
    
    // 初始化会话
    _initSession();
  }
  
  void _initSession() {
    sessionId = _generateSessionId();
    dioInstance = dio.Dio();
    cancelToken = dio.CancelToken();
    
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
  
  // 加载聊天历史
  Future<void> _loadChatHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? historyJson = prefs.getString(CHAT_HISTORY_KEY);
      
      if (historyJson != null && historyJson.isNotEmpty) {
        final List<dynamic> history = jsonDecode(historyJson);
        
        messages.clear();
        for (var item in history) {
          messages.add(Message(
            isUser: item['isUser'],
            content: item['content'],
            timestamp: DateTime.parse(item['timestamp']),
          ));
        }
      }
      
      // 如果没有历史消息，添加欢迎消息
      if (messages.isEmpty) {
        messages.add(Message(
          isUser: false,
          content: '你好！我是AI助手，有什么我可以帮助你的吗？',
          timestamp: DateTime.now(),
        ));
      }
      
      // 保存历史记录
      _saveChatHistory();
    } catch (e) {
      print('加载聊天历史失败: $e');
    }
  }
  
  // 保存聊天历史
  Future<void> _saveChatHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final List<Map<String, dynamic>> historyData = messages.map((msg) => {
        'isUser': msg.isUser,
        'content': msg.content,
        'timestamp': msg.timestamp.toIso8601String(),
      }).toList();
      
      final String historyJson = jsonEncode(historyData);
      await prefs.setString(CHAT_HISTORY_KEY, historyJson);
    } catch (e) {
      print('保存聊天历史失败: $e');
    }
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
          
          // 保存聊天历史
          _saveChatHistory();
        }
      } else if (event == 'error') {
        // 处理错误
        Get.snackbar('错误', '与AI助手通信时出错: $data');
        isLoading.value = false;
      }
    }
  }
  
  void sendMessage() async {
    final message = textController.text.trim();
    if (message.isEmpty) return;
    
    // 添加用户消息
    messages.add(Message(
      isUser: true,
      content: message,
      timestamp: DateTime.now(),
    ));
    
    // 清空输入框
    textController.clear();
    
    // 滚动到底部
    scrollToBottom();
    
    // 保存会话历史
    await _saveChatHistory();
    
    // 显示加载状态
    isLoading.value = true;
    
    try {
      // 发送请求到后端的chat/send接口
      await dioInstance.post(
        '${HttpUtil.SERVER_API_URL}/chat/send',
        data: {
          'sessionId': sessionId,
          'message': message,
        },
        options: dio.Options(
          headers: {
            'Authorization': 'Bearer ${await _getToken()}',
            'Content-Type': 'application/json',
          },
        ),
      );
      
      // 注意：不需要在这里处理响应，因为响应会通过SSE连接返回
    } catch (e) {
      print('发送消息失败: $e');
      // 添加错误消息
      messages.add(Message(
        isUser: false,
        content: '抱歉，发生了网络错误，请稍后再试。',
        timestamp: DateTime.now(),
      ));
      isLoading.value = false;
      
      // 保存会话历史
      await _saveChatHistory();
      
      // 滚动到底部
      scrollToBottom();
    }
  }
  
  // 清除历史记录并建立新连接
  void clearHistory() async {
    try {
      // 1. 先向后端发送清除历史请求
      await dioInstance.post(
        '${HttpUtil.SERVER_API_URL}/chat/clear',
        data: {
          'sessionId': sessionId,
        },
        options: dio.Options(
          headers: {
            'Authorization': 'Bearer ${await _getToken()}',
            'Content-Type': 'application/json',
          },
        ),
      );
      
      // 2. 取消当前的SSE连接
      cancelToken.cancel("用户清除历史");
      
      // 3. 清除本地消息
      messages.clear();
      currentResponse.value = '';
      
      // 4. 清除本地存储
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(CHAT_HISTORY_KEY);
      
      // 5. 生成新的会话ID
      sessionId = _generateSessionId();
      
      // 6. 创建新的取消令牌
      cancelToken = dio.CancelToken();
      
      // 7. 添加欢迎消息
      messages.add(Message(
        isUser: false,
        content: '你好！我是AI助手，有什么我可以帮助你的吗？',
        timestamp: DateTime.now(),
      ));
      
      // 8. 保存新的欢迎消息到本地存储
      await _saveChatHistory();
      
      // 9. 重新连接SSE
      connectToSSE();
      
      Get.snackbar('成功', '聊天历史已清除，已建立新的对话');
    } catch (e) {
      print('清除聊天历史失败: $e');
      Get.snackbar('错误', '清除聊天历史失败: $e');
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
  
  // 获取token的辅助方法
  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? '';
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
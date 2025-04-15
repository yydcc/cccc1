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

  Map<String, dynamic> toJson() => {
    'isUser': isUser,
    'content': content,
    'timestamp': timestamp.toIso8601String(),
  };

  factory Message.fromJson(Map<String, dynamic> json) => Message(
    isUser: json['isUser'],
    content: json['content'],
    timestamp: DateTime.parse(json['timestamp']),
  );
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
  StreamSubscription? _sseSubscription;
  bool _isDisposed = false;

  // 存储会话历史和会话ID的键
  static const String CHAT_HISTORY_KEY = 'ai_chat_history';
  static const String SESSION_ID_KEY = 'ai_chat_session_id';

  // 添加一个标志变量来跟踪是否正在清除历史
  bool _isClearing = false;

  @override
  void onInit() {
    super.onInit();
    // 初始化
    _initialize();
  }

  Future<void> _initialize() async {
    dioInstance = dio.Dio();

    // 1. 尝试从本地存储获取会话ID
    final prefs = await SharedPreferences.getInstance();
    final savedSessionId = prefs.getString(SESSION_ID_KEY);

    if (savedSessionId != null && savedSessionId.isNotEmpty) {
      // 使用保存的会话ID
      sessionId = savedSessionId;
      print('使用保存的会话ID: $sessionId');
    } else {
      // 生成新的会话ID
      sessionId = _generateSessionId();
      // 保存会话ID
      await prefs.setString(SESSION_ID_KEY, sessionId);
      print('生成新的会话ID: $sessionId');
    }

    // 2. 从本地存储加载历史记录
    await _loadChatHistory();

    // 3. 创建新的取消令牌
    cancelToken = dio.CancelToken();

    // 4. 连接SSE
    connectToSSE();
  }

  @override
  void onClose() {
    _isDisposed = true;
    textController.dispose();
    scrollController.dispose();

    // 断开SSE连接，但不清除会话ID和历史记录
    _disconnectSSE();

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
          messages.add(Message.fromJson(item));
        }

        print('从本地存储加载了 ${messages.length} 条消息');
      }

      // 如果没有历史消息，添加欢迎消息
      if (messages.isEmpty) {
        messages.add(Message(
          isUser: false,
          content: '你好！我是AI助手，有什么我可以帮助你的吗？',
          timestamp: DateTime.now(),
        ));

        // 保存初始欢迎消息
        await _saveChatHistory();
      }
    } catch (e) {
      print('加载聊天历史失败: $e');
      // 出错时添加默认欢迎消息
      messages.clear();
      messages.add(Message(
        isUser: false,
        content: '你好！我是AI助手，有什么我可以帮助你的吗？',
        timestamp: DateTime.now(),
      ));
    }
  }

  // 保存聊天历史
  Future<void> _saveChatHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final List<Map<String, dynamic>> historyData = messages.map((msg) => msg.toJson()).toList();

      final String historyJson = jsonEncode(historyData);
      await prefs.setString(CHAT_HISTORY_KEY, historyJson);
      print('保存了 ${messages.length} 条消息到本地存储');
    } catch (e) {
      print('保存聊天历史失败: $e');
    }
  }

  void connectToSSE() async {
    // 如果正在清除历史，不显示错误
    final bool isClearing = _isClearing;
    
    try {
      // 创建EventSource连接
      final url = '${HttpUtil.SERVER_API_URL}/ai-chat/connect?sessionId=$sessionId';
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

      _sseSubscription = stream.listen(
        (data) {
          if (_isDisposed) return; // 如果控制器已销毁，不处理数据

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
          if (_isDisposed) return; // 如果控制器已销毁，不处理错误

          print('SSE流错误: $error');
          // 只有在不是清除历史记录后的重连时才显示错误
          if (!_isDisposed && !isClearing) {
            Get.snackbar('连接错误', '与AI助手的连接中断，请刷新页面重试');
          }
          isLoading.value = false;
        },
        onDone: () {
          if (_isDisposed) return; // 如果控制器已销毁，不处理完成事件

          print('SSE连接关闭');
          isLoading.value = false;
        },
        cancelOnError: false, // 不要在错误时取消订阅
      );
    } catch (e) {
      if (_isDisposed) return; // 如果控制器已销毁，不处理异常

      print('连接SSE失败: $e');
      // 只有在不是清除历史记录后的重连时才显示错误
      if (!_isDisposed && !isClearing) {
        Get.snackbar('连接错误', '无法连接到AI助手，请稍后重试');
      }
      isLoading.value = false;
    }
  }

  void _processEventChunk(String chunk) {
    if (_isDisposed) return; // 如果控制器已销毁，不处理事件

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

    if (event != null && data != null) {
      if (event == 'connected') {
        print('SSE连接成功: $data');
      } else if (event == 'message') {
        // 处理消息
        currentResponse.value += data;
      } else if (event == 'complete') {
        // 处理完成事件
        if (currentResponse.value.isNotEmpty) {
          // 添加AI回复到消息列表
          messages.add(Message(
            isUser: false,
            content: currentResponse.value,
            timestamp: DateTime.now(),
          ));

          // 保存聊天历史
          _saveChatHistory();

          // 清空当前响应
          currentResponse.value = '';

          // 滚动到底部
          scrollToBottom();
        }

        // 结束加载状态
        isLoading.value = false;
      } else if (event == 'error') {
        // 处理错误，但只在控制器未销毁时显示
        if (!_isDisposed) {
          print('AI助手错误: $data');
          isLoading.value = false;
        }
      } else if (event == 'close') {
        // 服务器要求关闭连接
        print('服务器要求关闭连接: $data');
        _disconnectSSE();

        // 重新连接
        if (!_isDisposed) {
          connectToSSE();
        }
      } else if (event == 'ping') {
        // 心跳检测，不需要特殊处理
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
    currentResponse.value = '';

    try {
      // 发送请求到后端的chat/send接口
      await dioInstance.post(
        '${HttpUtil.SERVER_API_URL}/ai-chat/send',
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
      if (_isDisposed) return; // 如果控制器已销毁，不处理异常

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
      // 设置清除标志
      _isClearing = true;
      
      // 1. 先向后端发送清除历史请求
      await dioInstance.post(
        '${HttpUtil.SERVER_API_URL}/ai-chat/clear',
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
      _disconnectSSE();

      // 3. 清除本地消息
      messages.clear();
      currentResponse.value = '';

      // 4. 清除本地存储的历史记录
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(CHAT_HISTORY_KEY);

      // 5. 生成新的会话ID
      sessionId = _generateSessionId();

      // 6. 保存新的会话ID
      await prefs.setString(SESSION_ID_KEY, sessionId);

      // 7. 创建新的取消令牌
      cancelToken = dio.CancelToken();

      // 8. 添加欢迎消息
      messages.add(Message(
        isUser: false,
        content: '你好！我是AI助手，有什么我可以帮助你的吗？',
        timestamp: DateTime.now(),
      ));

      // 9. 保存新的欢迎消息到本地存储
      await _saveChatHistory();

      // 10. 延迟一下再重新连接SSE，避免连接错误
      await Future.delayed(const Duration(milliseconds: 500));
      
      // 11. 重新连接SSE
      try {
        connectToSSE();
      } catch (e) {
        print('重新连接SSE失败: $e');
        // 不显示错误提示，因为已经显示了成功清除的提示
      }

      Get.snackbar('成功', '聊天历史已清除，已建立新的对话');
    } catch (e) {
      if (_isDisposed) return; // 如果控制器已销毁，不处理异常

      print('清除聊天历史失败: $e');
      Get.snackbar('错误', '清除聊天历史失败');
    } finally {
      // 重置清除标志
      _isClearing = false;
    }
  }

  // 断开SSE连接
  void _disconnectSSE() {
    try {
      // 取消流订阅
      _sseSubscription?.cancel();
      _sseSubscription = null;

      // 取消dio请求
      cancelToken.cancel("用户断开连接");

      // 通知后端断开连接
      dioInstance.post(
        '${HttpUtil.SERVER_API_URL}/ai-chat/disconnect',
        data: {
          'sessionId': sessionId,
        },
        options: dio.Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      ).catchError((e) {
        print('通知后端断开连接失败: $e');
      });

      print('已断开SSE连接');
    } catch (e) {
      print('断开SSE连接失败: $e');
    }
  }

  void copyMessage(String content) {
    Clipboard.setData(ClipboardData(text: content)).then((_) {
      if (!_isDisposed) {
        Get.snackbar('成功', '文本已复制到剪贴板');
      }
    });
  }

  void scrollToBottom() {
    if (_isDisposed) return; // 如果控制器已销毁，不执行滚动

    Future.delayed(const Duration(milliseconds: 100), () {
      if (_isDisposed) return; // 再次检查，防止延迟期间控制器被销毁

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
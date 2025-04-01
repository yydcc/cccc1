import 'api_service.dart';
import 'package:dio/dio.dart';
import '../utils/http.dart';

class ChatApi extends ApiService {
  final HttpUtil _httpUtil = HttpUtil();
  
  // 创建SSE连接
  Future<dynamic> connect(String sessionId) async {
    try {
      final response = await _httpUtil.get(
        '/chat/connect',
        queryParameters: {'sessionId': sessionId},
      );
      return response;
    } catch (e) {
      print('连接SSE错误: $e');
      rethrow;
    }
  }
  
  // 发送消息
  Future<dynamic> sendMessage(String sessionId, String message) async {
    try {
      final response = await _httpUtil.post(
        '/chat/send',
        data: {
          'sessionId': sessionId,
          'message': message,
        },
      );
      return response;
    } catch (e) {
      print('发送消息错误: $e');
      rethrow;
    }
  }
  
  // 清除历史
  Future<dynamic> clearHistory(String sessionId) async {
    try {
      final response = await _httpUtil.post(
        '/chat/clear',
        data: {
          'sessionId': sessionId,
        },
      );
      return response;
    } catch (e) {
      print('清除历史错误: $e');
      rethrow;
    }
  }
  
  // 断开连接
  Future<dynamic> disconnect(String sessionId) async {
    try {
      final response = await _httpUtil.post(
        '/chat/disconnect',
        data: {
          'sessionId': sessionId,
        },
      );
      return response;
    } catch (e) {
      print('断开连接错误: $e');
      rethrow;
    }
  }
} 
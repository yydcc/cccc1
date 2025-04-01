import 'package:dio/dio.dart';
import '../utils/http.dart';
import '../utils/storage.dart';

class ApiService {
  static final HttpUtil _httpUtil = HttpUtil();
  
  // 通用请求方法
  static Future<dynamic> request(
    String method,
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      switch (method.toUpperCase()) {
        case 'GET':
          return await _httpUtil.get(
            path,
            queryParameters: queryParameters,
            options: options,
            canceltoken: cancelToken,
          );
        case 'POST':
          return await _httpUtil.post(
            path,
            data: data,
            queryParameters: queryParameters,
            options: options,
          );
        case 'PUT':
          return await _httpUtil.put(
            path,
            data: data,
            queryParameters: queryParameters,
            options: options,
          );
        case 'DELETE':
          return await _httpUtil.delete(
            path,
            data: data,
            queryParameters: queryParameters,
            options: options,
          );
        case 'PATCH':
          return await _httpUtil.patch(
            path,
            data: data,
            queryParameters: queryParameters,
            options: options,
          );
        default:
          throw Exception('不支持的请求方法: $method');
      }
    } catch (e) {
      print('API请求错误: $e');
      rethrow;
    }
  }
  
  // 获取当前用户角色
  Future<String> _getUserRole() async {
    final storage = await StorageService.instance;
    return storage.getRole() ?? 'student';
  }
  
  // 获取当前用户名
  Future<String> _getUsername() async {
    final storage = await StorageService.instance;
    return storage.getUsername() ?? '';
  }
} 
import 'package:cccc1/routes/app_pages.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart' as tr;
import 'package:get/get_core/src/get_main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/storage.dart';

class DioResponse<T> {
  final int code;
  final String msg;
  final T data;

  DioResponse({
    required this.code,
    required this.msg,
    required this.data,
  });

  factory DioResponse.fromJson(Map<String, dynamic> json) {
    return DioResponse(
      code: json['code'] as int,
      msg: json['msg'] as String,
      data: json['data'] as T,
    );
  }
}

class HttpUtil {
  static final HttpUtil _instance = HttpUtil.internal();
  static final SERVER_API_URL = "http://yizhe.natapp1.cc";  // 替换为你的服务器地址
  factory HttpUtil() => _instance;

  late Dio dio;

  HttpUtil.internal() {
    BaseOptions options = BaseOptions(
      baseUrl: SERVER_API_URL,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      contentType: 'application/json; charset=utf-8',
      responseType: ResponseType.json,
    );
    dio = Dio(options);

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          print('REQUEST[${options.method}] => PATH: ${options.path}');
          print('REQUEST HEADERS: ${options.headers}'); // 调试用
          return handler.next(options);
        },
        onResponse: (response, handler) {
          print('RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
          if (response.statusCode == 200) {
            // 将服务器响应数据转换为 DioResponse
            final responseData = response.data as Map<String, dynamic>;
            response.data = DioResponse(
              code: responseData['code'] as int,
              msg: responseData['msg'] as String,
              data: responseData['data'],
            );
            return handler.next(response);
          }
          handler.reject(
            DioError(
              requestOptions: response.requestOptions,
              response: response,
              type: DioErrorType.badResponse,
            ),
          );
        },
        onError: (error, handler) async {
          print('ERROR[${error.response?.statusCode}] => PATH: ${error.requestOptions.path}');
          print('ERROR HEADERS: ${error.requestOptions.headers}'); // 调试用
          
          if (error.response?.statusCode == 401) {
            final storage = await StorageService.instance;
            await storage.removeToken();  // 移除 token
            Get.snackbar('提示', 'token已过期，请重新登录');
            Get.offAllNamed(AppRoutes.SIGN_IN);  // 跳转到登录页面
            return handler.next(error);
          }
          
          return handler.next(error);
        },
      ),
    );
  }

  Future<Map<String, dynamic>?> getAuthorizationHeader() async {
    var headers = <String, dynamic>{};
    final storage = await StorageService.instance;
    var token = storage.getToken();
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
      print('Adding token to header: Bearer $token'); // 调试用
    }
    return headers;
  }

  Future<DioResponse> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    Options requestOptions = options ?? Options();
    requestOptions.headers = requestOptions.headers ?? {};
    Map<String, dynamic>? authorization = await getAuthorizationHeader();
    if (authorization != null) {
      requestOptions.headers!.addAll(authorization);
    }

    try {
      var response = await dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: requestOptions,
      );
      return response.data;
    } catch (e) {
      print('HTTP Error: $e');
      rethrow;
    }
  }

  /// restful get 操作
  /// refresh 是否下拉刷新 默认 false
  /// noCache 是否不缓存 默认 true
  /// list 是否列表 默认 false
  /// cacheKey 缓存key
  /// cacheDisk 是否磁盘缓存
  Future get(
      String path, {
        Map<String, dynamic>? queryParameters,
        Options? options,
        bool refresh = false,
        bool list = false,
        String cacheKey = '',
        bool cacheDisk = false,
        CancelToken? canceltoken,
        Map<String, dynamic>? data,
      }) async {
    Options requestOptions = options ?? Options();
    requestOptions.headers = requestOptions.headers ?? {};
    Map<String, dynamic>? authorization = await getAuthorizationHeader();
    if (authorization != null) {
      requestOptions.headers!.addAll(authorization);
    }

    try {
      print("入参：$path--$data");
      var response = await dio.get(
        path,
        queryParameters: queryParameters,
        options: requestOptions,
        cancelToken: canceltoken,
        data: data,
      );
      print("+++++++++++++++:$response");
      return response.data;
    } catch (e) {
      print("出现了错误$e");
    }
  }

  /// restful put 操作
  Future put(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
      }) async {
    Options requestOptions = options ?? Options();
    requestOptions.headers = requestOptions.headers ?? {};
    Map<String, dynamic>? authorization = await getAuthorizationHeader();
    if (authorization != null) {
      requestOptions.headers!.addAll(authorization);
    }
    var response = await dio.put(
      path,
      data: data,
      queryParameters: queryParameters,
      options: requestOptions,
    );
    return response.data;
  }

  /// restful patch 操作
  Future patch(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
      }) async {
    Options requestOptions = options ?? Options();
    requestOptions.headers = requestOptions.headers ?? {};
    Map<String, dynamic>? authorization = await getAuthorizationHeader();
    if (authorization != null) {
      requestOptions.headers!.addAll(authorization);
    }
    var response = await dio.patch(
      path,
      data: data,
      queryParameters: queryParameters,
      options: requestOptions,
    );
    return response.data;
  }

  /// restful delete 操作
  Future delete(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
      }) async {
    Options requestOptions = options ?? Options();
    requestOptions.headers = requestOptions.headers ?? {};
    Map<String, dynamic>? authorization = await getAuthorizationHeader();
    if (authorization != null) {
      requestOptions.headers!.addAll(authorization);
    }
    var response = await dio.delete(
      path,
      data: data,
      queryParameters: queryParameters,
      options: requestOptions,
    );
    return response.data;
  }

  /// restful post form 表单提交操作
  Future postForm(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
      }) async {
    Options requestOptions = options ?? Options();
    requestOptions.headers = requestOptions.headers ?? {};
    Map<String, dynamic>? authorization = await getAuthorizationHeader();
    if (authorization != null) {
      requestOptions.headers!.addAll(authorization);
    }
    var response = await dio.post(
      path,
      data: FormData.fromMap(data),
      queryParameters: queryParameters,
      options: requestOptions,
    );
    return response.data;
  }

  /// restful post Stream 流数据
  Future postStream(
      String path, {
        dynamic data,
        int dataLength = 0,
        Map<String, dynamic>? queryParameters,
        Options? options,
      }) async {
    Options requestOptions = options ?? Options();
    requestOptions.headers = requestOptions.headers ?? {};
    Map<String, dynamic>? authorization = await getAuthorizationHeader();
    if (authorization != null) {
      requestOptions.headers!.addAll(authorization);
    }
    requestOptions.headers!.addAll({
      Headers.contentLengthHeader: dataLength.toString(),
    });
    var response = await dio.post(
      path,
      data: Stream.fromIterable(data.map((e) => [e])),
      queryParameters: queryParameters,
      options: requestOptions,
    );
    return response.data;
  }
}
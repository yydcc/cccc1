import 'package:dio/dio.dart';
import 'api_service.dart';

class FileApi extends ApiService {
  // 上传文件
  Future<dynamic> uploadFile(String category, FormData formData) async {
    return await ApiService.request(
      'POST', 
      '/files/$category', 
      data: formData
    );
  }
} 
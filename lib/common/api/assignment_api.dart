import 'package:dio/dio.dart' as dio;
import 'package:get/get_connect/http/src/multipart/form_data.dart';
import 'api_service.dart';
import 'dart:io';
import 'package:cccc1/common/api/api.dart';
class AssignmentApi extends ApiService {
  // 获取作业列表
  Future<dynamic> getAssignments(int classId, {int page = 1, int size = 10}) async {
    return await ApiService.request(
      'GET', 
      '/assignments',
      queryParameters: {
        'classId': classId,
        'page': page,
        'size': size,
      }
    );
  }
  
  // 获取班级作业列表
  Future<dynamic> getClassAssignments(int classId) async {
    return await ApiService.request('GET', '/assignments/classes/$classId');
  }
  
  // 获取作业详情
  Future<dynamic> getAssignmentDetail(int assignmentId) async {
    return await ApiService.request('GET', '/assignments/$assignmentId');
  }
  
  // 创建作业
  Future<dynamic> createAssignment(Map<String, dynamic> assignmentData, File? file) async {
    if (file != null) {
      // 如果有文件，先上传文件
      final fileName = file.path.split('/').last;
      final fileFormData = dio.FormData.fromMap({
        'file': await dio.MultipartFile.fromFile(file.path, filename: fileName),
      });
      
      final fileResponse = await API.files.uploadFile('assignment', fileFormData);
      
      if (fileResponse.code == 200 && fileResponse.data != null) {
        // 获取文件URL并添加到作业数据中
        assignmentData['contentUrl'] = fileResponse.data['url'];
      }
    }
    
    // 使用JSON格式发送作业数据
    return await ApiService.request(
      'POST', 
      '/assignments',
      data: assignmentData,
      options: dio.Options(
        contentType: 'application/json',
      ),
    );
  }
  
  // 更新作业
  Future<dynamic> updateAssignment(int assignmentId, Map<String, dynamic> data) async {
    return await ApiService.request('PUT', '/assignments/$assignmentId', data: data);
  }
  
  // 删除作业
  Future<dynamic> deleteAssignment(int assignmentId) async {
    return await ApiService.request('DELETE', '/assignments/$assignmentId');
  }
  
  // 获取作业提交列表
  Future<dynamic> getAssignmentSubmissions(int assignmentId) async {
    return await ApiService.request('GET', '/assignments/$assignmentId/submissions');
  }
  
  // 提交作业内容
  Future<dynamic> submitContent(int assignmentId, int studentId, String content) async {
    return await ApiService.request(
      'POST', 
      '/assignments/$assignmentId/submissions/content',
      data: {
        'assignmentId': assignmentId,
        'studentId': studentId,
        'content': content,
      },
    );
  }
  
  // 提交作业文件
  Future<dynamic> submitFile(int assignmentId, int studentId, dio.FormData formData) async {
    return await ApiService.request(
      'POST', 
      '/assignments/$assignmentId/submissions/file',
      data: formData,
    );
  }
  
  // 获取学生提交的作业
  Future<dynamic> getStudentSubmission(int assignmentId, int studentId) async {
    return await ApiService.request(
      'GET', 
      '/assignments/submission',
      queryParameters: {
        'assignmentId': assignmentId,
        'studentId': studentId,
      }
    );
  }
  
  // 自动批改作业
  Future<dynamic> autoGradeSubmission(int submissionId) async {
    return await ApiService.request(
      'POST', 
      '/assignments/grade/auto',
      queryParameters: {
        'submissionId': submissionId,
      }
    );
  }
} 
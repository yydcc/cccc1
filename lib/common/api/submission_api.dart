import 'package:dio/dio.dart';
import 'api_service.dart';

class SubmissionApi extends ApiService {
  // 提交作业
  Future<dynamic> submitAssignment(dynamic data) async {
    return await ApiService.request('POST', '/submissions', data: data);
  }
  
  // 获取提交详情
  Future<dynamic> getSubmissionDetail(int submissionId) async {
    return await ApiService.request('GET', '/submissions/$submissionId');
  }
  
  // 获取作业提交列表
  Future<dynamic> getAssignmentSubmissions(int assignmentId) async {
    return await ApiService.request('GET', '/submissions/assignments/$assignmentId');
  }
  
  // 获取学生提交
  Future<dynamic> getStudentSubmission(int assignmentId, int studentId) async {
    return await ApiService.request(
      'GET', 
      '/submissions',
      queryParameters: {
        'assignmentId': assignmentId,
        'studentId': studentId,
      }
    );
  }
  
  // 批改作业
  Future<dynamic> gradeSubmission(int submissionId, Map<String, dynamic> data) async {
    return await ApiService.request('PUT', '/submissions/$submissionId/grade', data: data);
  }
  
  // 自动批改
  Future<dynamic> autoGradeSubmission(int submissionId) async {
    return await ApiService.request('POST', '/submissions/$submissionId/autograde');
  }

  // 更新提交
  Future<dynamic> updateSubmission(int submissionId, Map<String, dynamic> data) async {
    return await ApiService.request('PUT', '/submissions/$submissionId', data: data);
  }
  
  // 获取提交列表（分页）
  Future<dynamic> getSubmissionList({
    int? assignmentId, 
    int? studentId, 
    int page = 1, 
    int size = 10
  }) async {
    Map<String, dynamic> queryParams = {
      'page': page,
      'size': size,
    };
    
    if (assignmentId != null) {
      queryParams['assignmentId'] = assignmentId;
    }
    
    if (studentId != null) {
      queryParams['studentId'] = studentId;
    }
    
    return await ApiService.request(
      'GET', 
      '/submissions',
      queryParameters: queryParams
    );
  }

  // 提交带附件的作业
  Future<dynamic> submitAssignmentWithFiles(dynamic formData) async {
    return await ApiService.request('POST', '/submissions', data: formData);
  }
} 
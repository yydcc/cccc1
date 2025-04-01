import 'package:dio/dio.dart';
import 'api_service.dart';

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
  Future<dynamic> createAssignment(FormData formData) async {
    return await ApiService.request('POST', '/assignments', data: formData);
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
  
  // 提交作业文件
  Future<dynamic> submitAssignmentFile(int assignmentId, int studentId, FormData formData) async {
    return await ApiService.request(
      'POST', 
      '/assignments/$assignmentId/submissions/file',
      queryParameters: {
        'studentId': studentId,
      },
      data: formData
    );
  }
  
  // 提交作业内容
  Future<dynamic> submitAssignmentContent(int assignmentId, Map<String, dynamic> data) async {
    return await ApiService.request(
      'POST', 
      '/assignments/$assignmentId/submissions/content', 
      data: data
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
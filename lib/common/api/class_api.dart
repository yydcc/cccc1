import 'package:dio/dio.dart';
import 'api_service.dart';

class ClassApi extends ApiService {
  // 获取班级列表
  Future<dynamic> getClasses() async {
    return await ApiService.request('GET', '/classes');
  }
  
  // 获取班级详情
  Future<dynamic> getClassDetail(int classId) async {
    return await ApiService.request('GET', '/classes/$classId');
  }
  
  // 获取班级学生列表
  Future<dynamic> getClassStudents(int classId) async {
    return await ApiService.request('GET', '/classes/$classId/students');
  } 
  
  // 获取班级作业列表
  Future<dynamic> getClassAssignments(int classId) async {
    return await ApiService.request('GET', '/classes/$classId/assignments');
  }
  
  // 创建班级
  Future<dynamic> createClass(Map<String, dynamic> data) async {
    return await ApiService.request('POST', '/classes', data: data);
  }
  
  // 更新班级信息
  Future<dynamic> updateClass(int classId, Map<String, dynamic> data) async {
    return await ApiService.request('PUT', '/classes/$classId', data: data);
  }
  
  // 删除班级
  Future<dynamic> deleteClass(int classId) async {
    return await ApiService.request('DELETE', '/classes/$classId');
  }
} 
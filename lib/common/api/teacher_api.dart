import 'api_service.dart';

class TeacherApi extends ApiService {
  // 教师登录
  Future<dynamic> login(String username, String password) async {
    return await ApiService.request('POST', '/teachers/login', data: {
      'username': username,
      'password': password,
    });
  }
  
  // 教师注册
  Future<dynamic> register(Map<String, dynamic> data) async {
    return await ApiService.request('POST', '/teachers', data: data);
  }
  
  // 获取教师信息
  Future<dynamic> getTeacherInfo(int teacherId) async {
    return await ApiService.request('GET', '/teachers/$teacherId');
  }
  
  // 获取教师班级列表
  Future<dynamic> getTeacherClasses(int teacherId, {int page = 1, int size = 10}) async {
    return await ApiService.request(
      'GET', 
      '/teachers/$teacherId/classes',
      queryParameters: {
        'page': page,
        'size': size,
      }
    );
  }
  
  // 创建班级
  Future<dynamic> createClass(int teacherId, Map<String, dynamic> data) async {
    return await ApiService.request(
      'POST', 
      '/teachers/$teacherId/classes', 
      data: {
        ...data,
        "teacherId":teacherId,
      }
    );
  }
  
  // 更新教师信息
  Future<dynamic> updateTeacherInfo(int teacherId, Map<String, dynamic> data) async {
    return await ApiService.request('PUT', '/teachers/$teacherId', data: data);
  }


  Future<dynamic> changeUsername(int userId,String username, String newUsername) async {
    return await ApiService.request(
        'PATCH',
        '/teachers/$userId/username',
        data: {
          'userId':userId,
          'username': username,
          'newUsername': newUsername,
        }
    );
  }

  // 修改密码
  Future<dynamic> changePassword(int teacherId, String password, String newPassword) async {
    return await ApiService.request(
      'PATCH', 
      '/teachers/$teacherId/password', 
      data: {
        'userId': teacherId,
        'password': password,
        'newPassword': newPassword,
      }
    );
  }
  
  // 删除教师账号
  Future<dynamic> deleteTeacher(int teacherId) async {
    return await ApiService.request('DELETE', '/teachers/$teacherId');
  }
} 
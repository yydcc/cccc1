import 'api_service.dart';

class StudentApi extends ApiService {
  // 学生登录
  Future<dynamic> login(String username, String password) async {
    return await ApiService.request('POST', '/students/login', data: {
      'username': username,
      'password': password,
    });
  }
  
  // 学生注册
  Future<dynamic> register(Map<String, dynamic> data) async {
    return await ApiService.request('POST', '/students', data: data);
  }
  
  // 获取学生信息
  Future<dynamic> getStudentInfo(int userId) async {
    return await ApiService.request('GET', '/students/$userId');
  }
  
  // 获取学生班级列表
  Future<dynamic> getStudentClasses(int userId, {int page = 1, int size = 10}) async {
    return await ApiService.request(
      'GET', 
      '/students/$userId/classes',
      queryParameters: {
        'page': page,
        'size': size,
      }
    );
  }
  
  // 加入班级
  Future<dynamic> joinClass(int userId, String courseCode) async {
    return await ApiService.request(
      'POST', 
      '/students/$userId/classes', 
      data: {
        'userId': userId,
        'courseCode': courseCode,
      }
    );
  }
  
  // 更新学生信息
  Future<dynamic> updateStudentInfo(int userId, Map<String, dynamic> data) async {
    return await ApiService.request('PUT', '/students/$userId', data: data);
  }
  
  // 修改密码
  Future<dynamic> changePassword(int userId, String password, String newPassword) async {
    return await ApiService.request(
      'PATCH', 
      '/students/$userId/password', 
      data: {
        'userId': userId,
        'password': password,
        'newPassword': newPassword,
      }
    );
  }
  
  // 修改用户名
  Future<dynamic> changeUsername(int userId,String username, String newUsername) async {
    return await ApiService.request(
      'PATCH', 
      '/students/$userId/username',
      data: {
        'userId':userId,
        'username': username,
        'newUsername': newUsername,
      }
    );
  }
  
  // 删除学生账号
  Future<dynamic> deleteStudent(int userId) async {
    return await ApiService.request('DELETE', '/students/$userId');
  }
} 
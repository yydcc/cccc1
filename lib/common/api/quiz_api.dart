import 'dart:io';
import 'package:dio/dio.dart';
import '../utils/http.dart';
class QuizApi {
  final HttpUtil httpUtil = HttpUtil();

  /// 保存测验答案（不提交为最终版本）
  Future<dynamic> saveAnswer(
    int assignmentId,
    int studentId,
    String? content,
    File? file,
    {bool isFinalSubmission = false}
  ) async {
    FormData formData = FormData.fromMap({
      'studentId': studentId.toString(),
      if (content != null) 'content': content,
      if (file != null) 'file': await MultipartFile.fromFile(file.path),
      'isFinalSubmission': isFinalSubmission.toString(),
    });

    // 根据是否为最终提交选择不同的接口
    String endpoint = isFinalSubmission 
        ? '/quiz/$assignmentId/submit' 
        : '/quiz/$assignmentId/save';
        
    return await httpUtil.post(
      endpoint,
      data: formData,
    );
  }

  /// 获取学生的最新测验答案
  Future<dynamic> getLatestAnswer(int assignmentId, int studentId) async {
    return await httpUtil.get(
      '/quiz/$assignmentId/student/$studentId/latest',
    );
  }

  /// 获取学生的最终测验答案
  Future<dynamic> getFinalAnswer(int assignmentId, int studentId) async {
    return await httpUtil.get(
      '/quiz/$assignmentId/student/$studentId/final',
    );
  }

  /// 教师结束课堂测验
  Future<dynamic> endTest(int assignmentId, Map<String, String> map) async {
    return await httpUtil.put(
      '/quiz/$assignmentId/end',
    );
  }

  Future<void>? autoGradeAll(int quizId) {
    return null;
  }
} 

import 'dart:ffi';

class ClassInfo {
  final int classId;
  final String className;
  final int teacherId;
  final String teacherNickname;
  final String courseCode;

  ClassInfo({
    required this.classId,
    required this.className,
    required this.teacherId,
    required this.teacherNickname,
    required this.courseCode,
  });
  factory ClassInfo.fromJson(Map<String, dynamic> json) {
    return ClassInfo(
      classId: json['classId'],
      className: json['className'],
      teacherId: json['teacherId'],
      teacherNickname: json['teacherNickname'],
      courseCode: json['courseCode'],
    );
  }
}

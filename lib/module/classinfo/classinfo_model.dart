

class ClassInfo {
  final int classId;
  final String className;
  final int teacherId;
  final String teacherNickname;
  final String courseCode;
  final String createAt;
  final String joinedAt;
  final int studentCount;

  ClassInfo({
    required this.classId,
    required this.className,
    required this.teacherId,
    required this.teacherNickname,
    required this.courseCode,
    required this.createAt,
    required this.joinedAt,
    required this.studentCount,

  });
  factory ClassInfo.fromJson(Map<String, dynamic> json) {
    return ClassInfo(
      classId: json['classId'],
      className: json['className'],
      teacherId: json['teacherId'],
      teacherNickname: json['teacherNickname'],
      courseCode: json['courseCode'],
      createAt: json['createAt'],
      joinedAt: json['joinedAt'],
      studentCount: json['studentCount']
    );
  }
}

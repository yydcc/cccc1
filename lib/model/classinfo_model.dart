class ClassInfo {
  final int classId;
  final String className;
  final int teacherId;
  final String teacherNickname;
  final String courseCode;
  final String createAt;
  final String joinedAt;
  final int studentCount;
  final int assignmentCount;
  final int quizCount;

  ClassInfo({
    required this.classId,
    required this.className,
    required this.teacherId,
    required this.teacherNickname,
    required this.courseCode,
    required this.createAt,
    required this.joinedAt,
    required this.studentCount,
    this.assignmentCount = 0,
    this.quizCount = 0,
  });
  factory ClassInfo.fromJson(Map<String, dynamic> json) {
    return ClassInfo(
      classId: json['classId'],
      className: json['className'],
      teacherId: json['teacherId'],
      teacherNickname: json['teacherNickname'],
      courseCode: json['courseCode'],
      createAt: json['createAt']??'',
      joinedAt: json['joinedAt']??'',
      studentCount: json['studentCount']??0,
      assignmentCount: json['assignmentCount'] ?? 0,
      quizCount: json['quizCount']??0,
    );
  }

  String get formattedDate {
    return createAt.isNotEmpty ? createAt.substring(0, 10) : '';
  }
}


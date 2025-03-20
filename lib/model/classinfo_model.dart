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
  final List<ClassActivity> activities;

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
    this.activities = const [],
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
      activities: (json['activities'] as List?)
          ?.map((e) => ClassActivity.fromJson(e))
          .toList() ?? [],
    );
  }

  String get formattedDate {
    return createAt.isNotEmpty ? createAt.substring(0, 10) : '';
  }
}

class ClassActivity {
  final String id;
  final String type;  // assignment, announcement, quiz
  final String title;
  final String content;
  final String createTime;
  final bool isRead;

  ClassActivity({
    required this.id,
    required this.type,
    required this.title,
    required this.content,
    required this.createTime,
    this.isRead = false,
  });

  factory ClassActivity.fromJson(Map<String, dynamic> json) {
    return ClassActivity(
      id: json['id'],
      type: json['type'],
      title: json['title'],
      content: json['content'],
      createTime: json['createTime'],
      isRead: json['isRead'] ?? false,
    );
  }
}

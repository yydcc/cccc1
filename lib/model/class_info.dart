class ClassInfo {
  final String? classId;
  final String? className;
  final String? description;
  final String? teacherName;
  final List<dynamic>? activities;
  
  ClassInfo({
    this.classId,
    this.className,
    this.description,
    this.teacherName,
    this.activities,
  });
  
  factory ClassInfo.fromJson(Map<String, dynamic> json) {
    return ClassInfo(
      classId: json['class_id']?.toString(),
      className: json['class_name']?.toString(),
      description: json['description']?.toString(),
      teacherName: json['teacher_name']?.toString(),
      activities: json['activities'] as List<dynamic>?,
    );
  }
} 
class ClassMember {
  final int studentId;
  final String username;
  final String? avatar;

  ClassMember({
    required this.studentId,
    required this.username,
    this.avatar,
  });

  factory ClassMember.fromJson(Map<String, dynamic> json) {
    return ClassMember(
      studentId: json['studentId'],
      username: json['username'],
      avatar: json['avatar'],
    );
  }
} 
class Submission {
  final int? submissionId;
  final int? assignmentId;
  final int? studentId;
  final String? filePath;
  final String? submitTime;
  final double score;
  final String? feedback;
  final String? content;
  final String? username;
  final String? status;
  final bool? isFinalSubmission;
  Submission({
    this.username,
    this.submissionId,
    this.assignmentId,
    this.studentId,
    this.filePath,
    this.submitTime,
    this.score = 0,
    this.feedback,
    this.content,
    this.status,
    this.isFinalSubmission,
  });

  factory Submission.fromJson(Map<String, dynamic> json) {
    return Submission(
      username: json['username']??'',
      submissionId: json['submissionId'] ?? 0,
      assignmentId: json['assignmentId'] ?? 0,
      studentId: json['studentId'] ?? 0,
      filePath: json['filePath'],
      submitTime: json['submitTime'],
      score: json['score'] ?? 0,
      feedback: json['feedback'],
      content: json['content'],
      status: json['status'],
      isFinalSubmission: json['isFinalSubmission'],
    );
  }

  String get formattedSubmitTime {
    return submitTime?.isNotEmpty == true 
        ? submitTime!.substring(0, 16).replaceAll('T', ' ') 
        : '刚刚提交';
  }

  bool get isGraded {
    return feedback != null && feedback!.isNotEmpty;
  }

  bool get isSubmitted {
    return submissionId != null && submissionId! > 0;
  }
  
  // 获取文件名
  String? get fileName {
    if (filePath == null || filePath!.isEmpty) return '';
    
    // 从路径中提取文件名
    final parts = filePath!.split('/');
    return parts.isNotEmpty ? parts.last : '';
  }
  
  // 判断是否有文件
  bool get hasFile {
    return filePath != null && filePath!.isNotEmpty;
  }
} 
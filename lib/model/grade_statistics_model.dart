class GradeStatistics {
  final int assignmentId;
  final String title;
  final double score;
  final double averageScore;
  final double maxScore;
  final double minScore;
  final bool isInClass; // 是否为课堂测验
  final String createTime;
  final List<int> distribution; // 分数区间分布

  GradeStatistics({
    required this.assignmentId,
    required this.title,
    required this.score,
    required this.averageScore,
    required this.maxScore,
    required this.minScore,
    required this.isInClass,
    required this.createTime,
    required this.distribution,
  });

  factory GradeStatistics.fromJson(Map<String, dynamic> json) {
    return GradeStatistics(
      assignmentId: json['assignmentId'],
      title: json['title'],
      score: json['score'].toDouble(),
      averageScore: json['averageScore'].toDouble(),
      maxScore: json['maxScore'].toDouble(),
      minScore: json['minScore'].toDouble(),
      isInClass: json['isInClass'] ?? false,
      createTime: json['createTime'],
      distribution: List<int>.from(json['distribution'] ?? []),
    );
  }
} 
import 'dart:ui';

import 'package:flutter/material.dart';

class Assignment {
  final int? assignmentId;
  final String? title;
  final String? description;
  final String? deadline;
  final String? createTime;
  final bool isSubmitted;
  final int score;
  final String status; // not_started, in_progress, submitted, graded
  final String? contentUrl; // 附件URL

  Assignment({
    this.assignmentId,
    this.title,
    this.description,
    this.deadline,
    this.createTime,
    this.isSubmitted = false,
    this.score = 0,
    this.status = 'not_started',
    this.contentUrl,
  });

  factory Assignment.fromJson(Map<String, dynamic> json) {
    // 打印完整的JSON数据，查看实际结构
    print('完整的作业数据: $json');
    
    // 尝试多种可能的字段名
    final id = json['assignment_id'] ?? json['id'] ?? json['assignmentId'] ?? 0;
    print('提取的ID: $id, 类型: ${id.runtimeType}');
    
    return Assignment(
      assignmentId: id is int ? id : int.tryParse(id.toString()) ?? 0,
      title: json['title']?.toString(),
      description: json['description']?.toString(),
      deadline: json['deadline']?.toString(),
      createTime: json['create_time'] ?? json['createTime'],
      isSubmitted: json['is_submitted'] ?? json['isSubmitted'] ?? false,
      score: json['score'] ?? 0,
      status: json['status'] ?? 'not_started',
      contentUrl: json['content_url'] ?? json['contentUrl'],
    );
  }

  String get formattedDeadline {
    return deadline?.isNotEmpty == true ? deadline!.substring(0, 16).replaceAll('T', ' ') : '';
  }

  Color get statusColor {
    switch (status) {
      case 'not_started':
        return Colors.grey;
      case 'in_progress':
        return Colors.blue;
      case 'submitted':
        return Colors.green;
      case 'graded':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String get statusText {
    switch (status) {
      case 'not_started':
        return '未开始';
      case 'in_progress':
        return '进行中';
      case 'submitted':
        return '已提交';
      case 'graded':
        return '已批改';
      default:
        return '未知';
    }
  }
} 
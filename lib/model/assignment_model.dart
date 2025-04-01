import 'dart:ui';

import 'package:flutter/material.dart';

// 添加作业状态枚举
enum AssignmentStatus {
  NOT_STARTED,
  IN_PROGRESS,
  COMPLETED,
  EXPIRED
}

class Assignment {
  final int? assignmentId;
  final String? title;
  final String? description;
  final String? deadline;
  final String? createTime;
  final String? contentUrl; // 附件URL
  int? submittedCount;
  int? totalStudents;
  int? gradedCount;
  AssignmentStatus? status;

  Assignment({
    this.assignmentId,
    this.title,
    this.description,
    this.deadline,
    this.createTime,
    this.contentUrl,
    this.submittedCount,
    this.totalStudents,
    this.gradedCount,
    this.status,
  });

  factory Assignment.fromJson(Map<String, dynamic> json) {
    return Assignment(
      assignmentId: json['assignment_id'] ?? json['id'] ?? json['assignmentId'] ?? 0,
      title: json['title']?.toString(),
      description: json['description']?.toString(),
      deadline: json['deadline']?.toString(),
      createTime: json['createTime'] ?? '',
      contentUrl: json['contentUrl'] ?? '',
      status: _parseStatus(json['status']),
    );
  }

  // 解析状态的辅助方法
  static AssignmentStatus _parseStatus(String? status) {
    switch (status) {
      case 'not_started':
        return AssignmentStatus.NOT_STARTED;
      case 'in_progress':
        return AssignmentStatus.IN_PROGRESS;
      case 'completed':
        return AssignmentStatus.COMPLETED;
      case 'expired':
        return AssignmentStatus.EXPIRED;
      default:
        return AssignmentStatus.NOT_STARTED;
    }
  }

  String get formattedDeadline {
    return deadline?.isNotEmpty == true ? deadline!.substring(0, 16).replaceAll('T', ' ') : '';
  }

  String get formattedCreateTime {
    return createTime?.isNotEmpty == true ? createTime!.substring(0, 16).replaceAll('T', ' ') : '';
  }

  // 根据当前时间与开始时间和截止时间判断作业状态
  String get statusText {
    final now = DateTime.now();
    
    // 如果有截止时间，检查是否已过期
    if (deadline != null && deadline!.isNotEmpty) {
      try {
        final deadlineDate = DateTime.parse(deadline!);
        if (now.isAfter(deadlineDate)) {
          return 'expired'; // 已过期
        }
      } catch (e) {
        print('解析截止时间出错: $e');
      }
    }
    
    // 如果有开始时间，检查是否已开始
    if (createTime != null && createTime!.isNotEmpty) {
      try {
        final startDate = DateTime.parse(createTime!);
        if (now.isBefore(startDate)) {
          return 'not_started'; // 未开始
        } else {
          return 'in_progress'; // 进行中
        }
      } catch (e) {
        print('解析开始时间出错: $e');
      }
    }
    
    // 默认状态为进行中
    return 'in_progress';
  }

  Color get statusColor {
    switch (statusText) {
      case 'not_started':
        return Colors.grey;
      case 'in_progress':
        return Colors.blue;
      case 'expired':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String get statusDisplay {
    switch (statusText) {
      case 'not_started':
        return '未开始';
      case 'in_progress':
        return '进行中';
      case 'expired':
        return '已过期';
      default:
        return '未知';
    }
  }
  
  // 计算剩余时间（天数）
  int get remainingDays {
    if (deadline == null || deadline!.isEmpty) return 0;
    
    try {
      final deadlineDate = DateTime.parse(deadline!);
      final now = DateTime.now();
      final difference = deadlineDate.difference(now);
      return difference.inDays;
    } catch (e) {
      print('计算剩余天数出错: $e');
      return 0;
    }
  }
  
  // 判断是否临近截止（3天内）
  bool get isDeadlineNear {
    return remainingDays >= 0 && remainingDays <= 3;
  }

  // 获取附件文件名
  String? get attachmentFileName {
    if (contentUrl == null || contentUrl!.isEmpty) return '';
    
    // 从URL中提取文件名
    final parts = contentUrl!.split('/');
    return parts.isNotEmpty ? parts.last : '';
  }
} 
import 'dart:ffi';
import 'dart:ui';

import 'package:cccc1/model/submission_model.dart';
import 'package:flutter/material.dart';



class Assignment {
  final int? assignmentId;
  String? title;
  String? description;
  final String? deadline;
  final String? createTime;
  final int? classId; // 添加班级ID字段
  final String? contentUrl; // 附件URL
  final bool? isInClass; // 是否为课堂测验
  int? submittedCount;
  int? totalStudents;
  int? gradedCount;
  final int? feedbackMode;
  final int? thresholdMinutes;
  DateTime? releaseTime;

  Assignment({
    this.assignmentId,
    this.title,
    this.description,
    this.deadline,
    this.createTime,
    this.classId, // 添加到构造函数
    this.contentUrl,
    this.submittedCount,
    this.totalStudents,
    this.gradedCount,
    this.isInClass = false,
    this.feedbackMode = 0,
    this.thresholdMinutes = 0,
    this.releaseTime,
  });

  factory Assignment.fromJson(Map<String, dynamic> json) {
    return Assignment(
      assignmentId: json['assignment_id'] ?? json['id'] ?? json['assignmentId'] ?? 0,
      title: json['title']?.toString(),
      description: json['description']?.toString(),
      deadline: json['deadline']?.toString(),
      createTime: json['createTime'] ?? '',
      classId: json['classId'], // 从JSON中解析
      contentUrl: json['contentUrl'] ?? '',
      isInClass: json['isInClass'] ?? false,
      feedbackMode: json['feedbackMode']??0,
      thresholdMinutes: json['thresholdMinutes']??0,
      releaseTime:json['releaseTime']
    );
  }

  String get formattedDeadline {
    return deadline?.isNotEmpty == true ? deadline!.substring(0, 16).replaceAll('T', ' ') : '';
  }

  String get formattedCreateTime {
    return createTime?.isNotEmpty == true ? createTime!.substring(0, 16).replaceAll('T', ' ') : '';
  }

  // 根据当前时间与开始时间和截止时间判断作业状态
  String get status {
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

  Color get statusColor => getStatusColor(null);

  String get statusText => getStatusText(null);

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

  // 判断作业是否已过期
  bool get isExpired {
    if (deadline == null) return false;

    final DateTime deadlineDate = DateTime.parse(deadline!);
    final DateTime now = DateTime.now();

    return now.isAfter(deadlineDate);
  }

  // 判断作业是否已开始
  bool get isStarted {
    if (createTime == null) return true; // 如果没有开始时间，默认已开始

    final DateTime startDate = DateTime.parse(createTime!);
    final DateTime now = DateTime.now();

    return now.isAfter(startDate);
  }


  // 获取作业状态文本
  String getStatusText(Submission? submission) {
    if (submission != null && submission.isSubmitted) {
      // 有提交记录
      if (submission.isGraded) {
        return "已批改";
      } else if (isExpired) {
        return "已过期";
      } else {
        return "已提交";
      }
    } else {
      // 无提交记录
      if (!isStarted) {
        return "未开始";
      } else if (isExpired) {
        return "已过期";
      } else {
        return "进行中";
      }
    }
  }

  // 获取作业状态颜色
  Color getStatusColor(Submission? submission) {
    if (submission != null && submission.isSubmitted) {
      // 有提交记录
      if (submission.isGraded) {
        return Colors.purple;
      } else if (isExpired) {
        return Colors.red;
      } else {
        return Colors.blue;
      }
    } else {
      if (!isStarted) {
        return Colors.grey;
      } else if (isExpired) {
        return Colors.red;
      } else {
        return Colors.green;
      }
    }
  }

  // 判断作业是否可提交
  bool get isSubmittable {
    final now = DateTime.now();
    
    // 解析创建时间和截止时间
    DateTime? createDateTime = parseDateTime(createTime);
    DateTime? deadlineDateTime = parseDateTime(deadline);
    
    // 如果作业还未开始，不可提交
    if (createDateTime != null && now.isBefore(createDateTime)) {
      return false;
    }
    
    // 如果已过截止时间，不可提交
    if (deadlineDateTime != null && now.isAfter(deadlineDateTime)) {
      return false;
    }
    
    // 作业进行中，可以提交
    return true;
  }

  // 辅助方法：解析日期时间字符串
  DateTime? parseDateTime(String? dateTimeStr) {
    if (dateTimeStr == null || dateTimeStr.isEmpty) {
      return null;
    }
    
    try {
      // 处理可能的格式差异
      if (dateTimeStr.contains('T')) {
        return DateTime.parse(dateTimeStr);
      } else {
        // 假设格式为 "yyyy-MM-dd HH:mm:ss"
        return DateTime.parse(dateTimeStr.replaceAll(' ', 'T'));
      }
    } catch (e) {
      print('日期解析错误: $e');
      return null;
    }
  }

  // 添加获取批改模式文本的方法
  String get feedbackModeText {
    switch (feedbackMode) {
      case 0:
        return '手动批改';
      case 1:
        return '截止后自动批改';
      case 2:
        return '指定时间自动批改';
      default:
        return '手动批改';
    }
  }

  // 添加获取批改时间文本的方法
  String get feedbackTimeText {
    if (feedbackMode == 1 && thresholdMinutes != null) {
      return '截止后 $thresholdMinutes 分钟';
    } else if (feedbackMode == 2 && releaseTime != null) {
      // 格式化发布时间
      final DateTime? releaseDateTime = parseDateTime(releaseTime.toString());
      if (releaseDateTime != null) {
        return '${releaseDateTime.year}-${_twoDigits(releaseDateTime.month)}-${_twoDigits(releaseDateTime.day)} ${_twoDigits(releaseDateTime.hour)}:${_twoDigits(releaseDateTime.minute)}';
      }
    }
    return '无';
  }

  // 辅助方法：两位数格式化
  String _twoDigits(int n) {
    if (n >= 10) return '$n';
    return '0$n';
  }
}
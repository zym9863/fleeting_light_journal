import 'dart:convert';

class MemoryCard {
  final int? id; // 数据库ID，新建时为null
  final String title; // 标题
  final String content; // 内容
  final List<String> imagePaths; // 图片路径列表
  final String emotion; // 情感标签
  final List<String> keywords; // 关键词列表
  final DateTime createdAt; // 创建时间
  final DateTime? timeCapsuleDate; // 时光胶囊解锁时间，null表示不是时光胶囊
  final bool isTimeCapsule; // 是否为时光胶囊
  final bool isLocked; // 时光胶囊是否锁定

  MemoryCard({
    this.id,
    required this.title,
    required this.content,
    required this.imagePaths,
    required this.emotion,
    required this.keywords,
    required this.createdAt,
    this.timeCapsuleDate,
    this.isTimeCapsule = false,
    this.isLocked = false,
  });

  // 从Map创建MemoryCard对象（用于从数据库读取）
  factory MemoryCard.fromMap(Map<String, dynamic> map) {
    return MemoryCard(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      imagePaths: List<String>.from(json.decode(map['imagePaths'])),
      emotion: map['emotion'],
      keywords: List<String>.from(json.decode(map['keywords'])),
      createdAt: DateTime.parse(map['createdAt']),
      timeCapsuleDate: map['timeCapsuleDate'] != null
          ? DateTime.parse(map['timeCapsuleDate'])
          : null,
      isTimeCapsule: map['isTimeCapsule'] == 1,
      isLocked: map['isLocked'] == 1,
    );
  }

  // 转换为Map（用于存入数据库）
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'imagePaths': json.encode(imagePaths),
      'emotion': emotion,
      'keywords': json.encode(keywords),
      'createdAt': createdAt.toIso8601String(),
      'timeCapsuleDate': timeCapsuleDate?.toIso8601String(),
      'isTimeCapsule': isTimeCapsule ? 1 : 0,
      'isLocked': isLocked ? 1 : 0,
    };
  }

  // 创建副本并更新属性
  MemoryCard copyWith({
    int? id,
    String? title,
    String? content,
    List<String>? imagePaths,
    String? emotion,
    List<String>? keywords,
    DateTime? createdAt,
    DateTime? timeCapsuleDate,
    bool? isTimeCapsule,
    bool? isLocked,
  }) {
    return MemoryCard(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      imagePaths: imagePaths ?? this.imagePaths,
      emotion: emotion ?? this.emotion,
      keywords: keywords ?? this.keywords,
      createdAt: createdAt ?? this.createdAt,
      timeCapsuleDate: timeCapsuleDate ?? this.timeCapsuleDate,
      isTimeCapsule: isTimeCapsule ?? this.isTimeCapsule,
      isLocked: isLocked ?? this.isLocked,
    );
  }
}
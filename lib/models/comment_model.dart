import 'user_model.dart';

class CommentModel {
  final String id;
  final String postId;
  final String userId;
  final String content;
  final bool isAnonymous;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Optional user data when fetched with joins
  final UserModel? user;

  const CommentModel({
    required this.id,
    required this.postId,
    required this.userId,
    required this.content,
    required this.isAnonymous,
    required this.createdAt,
    required this.updatedAt,
    this.user,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] as String,
      postId: json['post_id'] as String,
      userId: json['user_id'] as String,
      content: json['content'] as String,
      isAnonymous: json['is_anonymous'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      user: json['user'] != null ? UserModel.fromJson(json['user'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'post_id': postId,
      'user_id': userId,
      'content': content,
      'is_anonymous': isAnonymous,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  CommentModel copyWith({
    String? id,
    String? postId,
    String? userId,
    String? content,
    bool? isAnonymous,
    DateTime? createdAt,
    DateTime? updatedAt,
    UserModel? user,
  }) {
    return CommentModel(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      user: user ?? this.user,
    );
  }
}

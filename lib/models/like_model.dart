class LikeModel {
  final String id;
  final String postId;
  final String userId;
  final DateTime createdAt;

  const LikeModel({
    required this.id,
    required this.postId,
    required this.userId,
    required this.createdAt,
  });

  factory LikeModel.fromJson(Map<String, dynamic> json) {
    return LikeModel(
      id: json['id'] as String,
      postId: json['post_id'] as String,
      userId: json['user_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'post_id': postId,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
    };
  }

  LikeModel copyWith({
    String? id,
    String? postId,
    String? userId,
    DateTime? createdAt,
  }) {
    return LikeModel(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

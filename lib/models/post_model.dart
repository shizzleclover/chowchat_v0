import 'user_model.dart';

class PostModel {
  final String id;
  final String userId;
  final String content;
  final List<String> imageUrls;
  final String? videoUrl;
  final double? rating;
  final String storeName;
  final String location;
  final String foodDescription;
  final bool isAnonymous;
  final int likesCount;
  final int commentsCount;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Optional user data when fetched with joins
  final UserModel? user;

  const PostModel({
    required this.id,
    required this.userId,
    required this.content,
    required this.imageUrls,
    this.videoUrl,
    this.rating,
    required this.storeName,
    required this.location,
    required this.foodDescription,
    required this.isAnonymous,
    required this.likesCount,
    required this.commentsCount,
    required this.createdAt,
    required this.updatedAt,
    this.user,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      content: json['content'] as String,
      imageUrls: List<String>.from(json['image_urls'] as List? ?? []),
      videoUrl: json['video_url'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      storeName: json['store_name'] as String,
      location: json['location'] as String,
      foodDescription: json['food_description'] as String,
      isAnonymous: json['is_anonymous'] as bool,
      likesCount: json['likes_count'] as int? ?? 0,
      commentsCount: json['comments_count'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      user: json['user'] != null ? UserModel.fromJson(json['user'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'content': content,
      'image_urls': imageUrls,
      'video_url': videoUrl,
      'rating': rating,
      'store_name': storeName,
      'location': location,
      'food_description': foodDescription,
      'is_anonymous': isAnonymous,
      'likes_count': likesCount,
      'comments_count': commentsCount,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  PostModel copyWith({
    String? id,
    String? userId,
    String? content,
    List<String>? imageUrls,
    String? videoUrl,
    double? rating,
    String? storeName,
    String? location,
    String? foodDescription,
    bool? isAnonymous,
    int? likesCount,
    int? commentsCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    UserModel? user,
  }) {
    return PostModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      imageUrls: imageUrls ?? this.imageUrls,
      videoUrl: videoUrl ?? this.videoUrl,
      rating: rating ?? this.rating,
      storeName: storeName ?? this.storeName,
      location: location ?? this.location,
      foodDescription: foodDescription ?? this.foodDescription,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      user: user ?? this.user,
    );
  }
}

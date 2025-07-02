// models/post.dart
import 'package:celebrating/models/user.dart';
import 'package:flutter/material.dart';
import 'comment.dart';
import 'like.dart';

class Post {
  final String id;
  final String content;
  final User from;
  final List<String> categories;
  final List<String> hashtags;
  final DateTime timestamp;
  final String mediaLink; // This might become redundant if 'media' list fully replaces it
  final String timeAgo; // Assuming this is a string representation of creation time
  final List<MediaItem> media;
  final int initialRating; // e.g., the average rating of the post
  final List<Like> likes; // List of users who liked the post
  final List<Comment> comments; // List of comments on the post
  final String location;

  Post({
    required this.id,
    required this.content,
    required this.from,
    required this.categories,
    required this.hashtags,
    required this.timestamp,
    required this.mediaLink,
    required this.timeAgo,
    required this.media,
    this.initialRating = 0, // Default to 0 if not provided
    required this.likes,
    required this.comments,
    required this.location
  });

  factory Post.fromJson(Map<String, dynamic> json) => Post(
    id: json['id'] as String,
    content: json['content'] as String,
      from: User.fromJson(json['from'] as Map<String, dynamic>),
    categories: (json['categories'] as List<dynamic>)
        .map((e) => e as String)
        .toList(),
    hashtags: (json['hashtags'] as List<dynamic>)
        .map((e) => e as String)
        .toList(),
    timestamp: DateTime.parse(json['timestamp'] as String),
    mediaLink: json['mediaLink'] as String,
    timeAgo: json['createdAt'] as String,
    media: (json['media'] as List<dynamic>)
        .map((e) => MediaItem.fromJson(e as Map<String, dynamic>)) // Use MediaItem.fromJson
        .toList(),
    initialRating: json['initialRating'] as int? ?? 0, // Handle missing initialRating, default to 0
    likes: (json['likes'] as List<dynamic>?) // Likes can be optional or empty
        ?.map((e) => Like.fromJson(e as Map<String, dynamic>))
        .toList() ?? [], // Default to empty list if null
    comments: (json['comments'] as List<dynamic>?) // Comments can be optional or empty
        ?.map((e) => Comment.fromJson(e as Map<String, dynamic>))
        .toList() ?? [],
    location: json['location'], // Default to empty list if null
  );
}

class MediaItem {
  final String url;
  final String type; // 'image' or 'video'

  MediaItem({required this.url, required this.type});

  factory MediaItem.fromJson(Map<String, dynamic> json) => MediaItem(
    url: json['url'] as String,
    type: json['type'] as String,
  );
}
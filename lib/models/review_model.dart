import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String id;
  final String userId;
  final String userName;
  final String bookingId;
  final int rating;
  final String comment;
  final Timestamp createdAt;

  ReviewModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.bookingId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory ReviewModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ReviewModel(
      id: doc.id,
      userId: data['userId'],
      userName: data['userName'],
      bookingId: data['bookingId'],
      rating: data['rating'],
      comment: data['comment'],
      createdAt: data['createdAt'],
    );
  }
}

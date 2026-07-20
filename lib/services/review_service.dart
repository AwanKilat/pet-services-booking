import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewService {
  final _db = FirebaseFirestore.instance;

  Future<void> submitReview({
    required String userId,
    required String userName,
    required String bookingId,
    required int rating,
    required String comment,
  }) async {
    await _db.collection('reviews').add({
      'userId': userId,
      'userName': userName,
      'bookingId': bookingId,
      'rating': rating,
      'comment': comment,
      'createdAt': Timestamp.now(),
    });
  }

  Stream<QuerySnapshot> getUserReviews(String userId) {
    return _db
        .collection('reviews')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}

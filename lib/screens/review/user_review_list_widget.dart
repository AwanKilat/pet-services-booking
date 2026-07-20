import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pet_care_booking/services/review_service.dart';

class UserReviewListWidget extends StatelessWidget {
  const UserReviewListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Text("User not logged in");
    }

    final service = ReviewService();

    return StreamBuilder<QuerySnapshot>(
      stream: service.getUserReviews(user.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Text("No reviews yet");
        }

        return Column(
          children: snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                title: Row(
                  children: List.generate(
                    data['rating'],
                    (_) => const Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: 16,
                    ),
                  ),
                ),
                subtitle: Text(data['comment']),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

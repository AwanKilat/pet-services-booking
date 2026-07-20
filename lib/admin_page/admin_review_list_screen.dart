import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminReviewListScreen extends StatelessWidget {
  const AdminReviewListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    FirebaseFirestore.instance
        .collectionGroup('reviews')
        .get()
        .then((s) => print('REVIEWS COUNT = ${s.docs.length}'));

    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collectionGroup('reviews') // ✅ INI KUNCI UTAMA
            //.orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No reviews available"));
          }

          final reviews = snapshot.data!.docs;

          return ListView.builder(
            itemCount: reviews.length,
            itemBuilder: (context, index) {
              final data = reviews[index].data() as Map<String, dynamic>;

              final int rating = data['rating'] ?? 0;
              final String comment = data['comment'] ?? '-';

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Row(
                    children: List.generate(
                      rating,
                      (_) => const Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: 18,
                      ),
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(comment),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

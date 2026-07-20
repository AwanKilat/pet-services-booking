import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddViewScreen extends StatefulWidget {
  final String bookingId;
  final String userName; // 👈 pass dari booking

  const AddViewScreen({
    super.key,
    required this.bookingId,
    required this.userName,
  });

  @override
  State<AddViewScreen> createState() => _AddViewScreenState();
}

class _AddViewScreenState extends State<AddViewScreen> {
  final TextEditingController _reviewController = TextEditingController();
  int _rating = 5;
  bool _isSaving = false;

  Future<void> _submitReview() async {
    final comment = _reviewController.text.trim();
    final rating = _rating;
    print('REVIEW SAVED: ${widget.bookingId} - ${widget.userName}');

    if (comment.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review cannot be empty')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final bookingRef = FirebaseFirestore.instance
          .collection('bookings')
          .doc(widget.bookingId);

      // ✅ LETAK CODE NI DI SINI
      await bookingRef.collection('reviews').add({
        'comment': comment,
        'rating': rating,
        'bookingId': widget.bookingId,
        'userName': widget.userName,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // ✅ update booking
      await bookingRef.update({'hasReview': true});

      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit review: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Review')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _reviewController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Your Review',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _submitReview,
                child: const Text('Submit Review'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

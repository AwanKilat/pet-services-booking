import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'review/add_view_screen.dart';

class BookingDetailScreen extends StatelessWidget {
  final String bookingId;
  final Map<String, dynamic> bookingData;

  const BookingDetailScreen({
    super.key,
    required this.bookingId,
    required this.bookingData,
  });

  @override
  Widget build(BuildContext context) {
    final bool canReview = _canAddReview(bookingData);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Booking Detail'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _info('Package', bookingData['packageType']),
            _info('Name', bookingData['name']),
            _info('Phone', bookingData['phone']),
            _info(
              'Created',
              DateFormat('dd MMM yyyy')
                  .format(bookingData['createdAt'].toDate()),
            ),
            _info(
              'Optional Request',
              bookingData['optionalRequest'] ?? '-',
            ),
            _info(
              'Status',
              bookingData['status'],
            ),

            const SizedBox(height: 24),
            const Divider(),

            /// ⭐ ADD REVIEW BUTTON
            if (canReview) ...[
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.rate_review),
                  label: const Text('Add Review'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AddViewScreen(
                          bookingId: bookingId,
                          userName: bookingData['name'],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],

            /// INFO JIKA DAH REVIEW
            if (!canReview && bookingData['status'] == 'completed') ...[
              const SizedBox(height: 20),
              const Text(
                'You have already submitted a review.',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ],
        ),
      ),
    );
  }

  bool _canAddReview(Map<String, dynamic> data) {
    return data['status'] == 'completed' &&
        (data['hasReview'] == false || data['hasReview'] == null);
  }

  Widget _info(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

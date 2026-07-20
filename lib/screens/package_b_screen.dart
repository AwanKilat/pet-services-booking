import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../payment/booking_payment_screen.dart';
import '../services/notification_service.dart';

class PackageBScreen extends StatefulWidget {
  const PackageBScreen({super.key});

  @override
  State<PackageBScreen> createState() => _PackageBScreenState();
}

class _PackageBScreenState extends State<PackageBScreen> {
  // ================= CONTROLLERS =================
  final nameCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final optionalCtrl = TextEditingController();

  DateTime? bookingDate;
  TimeOfDay? bookingTime;

  final dateFormat = DateFormat('dd MMM yyyy');

  // ================= DATE PICKER =================
  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        bookingDate = picked;
        bookingTime = null; // reset time bila tukar date
      });
    }
  }

  // ================= TIME PICKER =================
  Future<void> pickTime() async {
    if (bookingDate == null) return;

    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );

    if (picked != null) {
      // ❗ LAST BOOKING 1 JAM SEBELUM TUTUP (7:30 PM)
      final minutes = picked.hour * 60 + picked.minute;
      final lastBookingMinutes = 19 * 60 + 30; // 7:30 PM

      if (minutes > lastBookingMinutes) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Last booking is 7:30 PM'),
          ),
        );
        return;
      }

      setState(() => bookingTime = picked);
    }
  }

  // ================= NEXT =================
  void goNext() {
    if (nameCtrl.text.isEmpty ||
        phoneCtrl.text.isEmpty ||
        bookingDate == null ||
        bookingTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all fields')),
      );
      return;
    }

    NotificationService.show(
      context,
      "Booking submitted successfully",
      color: Colors.green,
    );

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookingPaymentScreen(
          bookingData: {
            'packageType': 'B',
            'name': nameCtrl.text,
            'phone': phoneCtrl.text,
            'bookingDate': bookingDate,
            'bookingTime': bookingTime!.format(context),
            'optionalRequest': optionalCtrl.text,
          },
        ),
      ),
    );
  }

  // ================= BUILD =================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Package B')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Your Details',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            // NAME
            TextField(
              controller: nameCtrl,
              decoration: inputStyle('Enter your name'),
            ),
            const SizedBox(height: 12),

            // PHONE
            TextField(
              controller: phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: inputStyle('e.g. 0123456789'),
            ),

            const SizedBox(height: 24),
            const Text('Package B Includes',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            includeTile('Food & Drink'),
            includeTile('Baths'),
            includeTile('Nail Trimming'),
            includeTile('Ear Cleaning'),
            includeTile('Extra Brushing'),

            const SizedBox(height: 24),
            const Text('Booking Date & Time',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            // DATE
            ListTile(
              leading: const Icon(Icons.calendar_month),
              tileColor: const Color(0xFFF5F5F5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              title: Text(
                bookingDate == null
                    ? 'Select Date'
                    : dateFormat.format(bookingDate!),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: pickDate,
            ),
            const SizedBox(height: 8),

            // TIME
            ListTile(
              leading: const Icon(Icons.access_time),
              tileColor: const Color(0xFFF5F5F5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              title: Text(
                bookingTime == null
                    ? 'Select Time (Last: 7:30 PM)'
                    : bookingTime!.format(context),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: pickTime,
            ),

            const SizedBox(height: 24),
            const Text('Optional Request'),
            const SizedBox(height: 12),

            TextField(
              controller: optionalCtrl,
              maxLines: 3,
              decoration: inputStyle('Leave empty if none'),
            ),

            const SizedBox(height: 28),

            // NEXT BUTTON
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: goNext,
                child: const Text(
                  'Next',
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ================= REUSABLE =================
  InputDecoration inputStyle(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF5F5F5),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget includeTile(String text) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green),
          const SizedBox(width: 12),
          Text(text),
        ],
      ),
    );
  }
}

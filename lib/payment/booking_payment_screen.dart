import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class BookingPaymentScreen extends StatefulWidget {
  final Map<String, dynamic> bookingData;

  const BookingPaymentScreen({
    super.key,
    required this.bookingData,
  });

  @override
  State<BookingPaymentScreen> createState() => _BookingPaymentScreenState();
}

class _BookingPaymentScreenState extends State<BookingPaymentScreen> {
  File? receiptFile;
  String? fileName;
  bool isLoading = false;

  // ================= PICK FILE =================
  Future<void> pickReceipt() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'png', 'jpeg', 'pdf'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        receiptFile = File(result.files.single.path!);
        fileName = result.files.single.name;
      });
    }
  }

  // ================= UPLOAD RECEIPT =================
  Future<String> uploadReceipt(File file) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not logged in');

    final bookingId = widget.bookingData['bookingId'];

    final ref = FirebaseStorage.instance.ref(
      'receipts/$bookingId/${DateTime.now().millisecondsSinceEpoch}_$fileName',
    );

    await ref.putFile(file);
    return await ref.getDownloadURL();
  }

  // ================= SUBMIT PAYMENT =================
  Future<void> submitPayment() async {
    if (receiptFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload receipt')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final bookingId = widget.bookingData['bookingId'];

      // 1️⃣ Upload receipt
      final receiptUrl = await uploadReceipt(receiptFile!);

      // 2️⃣ Update booking (BUKAN add baru)
      await FirebaseFirestore.instance
          .collection('bookings')
          .doc(bookingId)
          .update({
        'receiptUrl': receiptUrl,
        'status': 'pending', // tunggu admin
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment submitted. Awaiting admin approval'),
        ),
      );

      // 3️⃣ Kembali ke home
      Navigator.popUntil(context, (route) => route.isFirst);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to submit payment')),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  // ================= UI HELPER =================
  Widget infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.bookingData;
    final dateFormat = DateFormat('dd MMM yyyy');

    return Scaffold(
      appBar: AppBar(title: const Text('Booking Summary')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            infoRow('Package', data['packageType']),
            infoRow('Name', data['name']),
            infoRow('Phone', data['phone']),
            if (data['checkInDate'] != null)
              infoRow('Check-in', dateFormat.format(data['checkInDate'])),
            if (data['checkOutDate'] != null)
              infoRow('Check-out', dateFormat.format(data['checkOutDate'])),
            infoRow(
              'Request',
              (data['optionalRequest']?.isEmpty ?? true)
                  ? '-'
                  : data['optionalRequest'],
            ),
            const Divider(height: 30),
            const Text(
              'Payment Details',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text('Bank: Maybank'),
            const Text('Account Name: Pets Mart Sdn Bhd'),
            const Text('Account No: 1234 5678 9012'),
            const SizedBox(height: 12),
            Center(
              child: Image.asset(
                'assets/images/qr_maybank.jpg',
                height: 180,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Booking Fee: RM 50',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: pickReceipt,
              icon: const Icon(Icons.upload),
              label: Text(
                fileName == null ? 'Upload Receipt (PDF / Image)' : fileName!,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed:
                  (receiptFile == null || isLoading) ? null : submitPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      'DONE',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

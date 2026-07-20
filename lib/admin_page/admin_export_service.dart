import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';

class AdminExportService {
  static Future<void> printBookingsPDF() async {
    final pdf = pw.Document();
    final snapshot =
        await FirebaseFirestore.instance.collection('bookings').get();

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Text(
            'Pets Mart Booking Report',
            style: pw.TextStyle(
              fontSize: 22,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Table.fromTextArray(
            headers: ['Package', 'Name', 'Status', 'Date'],
            data: snapshot.docs.map((doc) {
              final d = doc.data();
              return [
                d['packageType'],
                d['name'],
                d['status'],
                DateFormat('dd MMM yyyy').format(d['createdAt'].toDate()),
              ];
            }).toList(),
          ),
        ],
      ),
    );

    // 🔥 PRINT / SHARE TERUS
    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }
}

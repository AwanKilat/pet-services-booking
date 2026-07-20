import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ReceiptPreviewScreen extends StatelessWidget {
  final String url;

  const ReceiptPreviewScreen({
    super.key,
    required this.url,
  });

  Future<void> _openPdf() async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw 'Could not open receipt';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment Receipt')),
      body: Center(
        child: ElevatedButton.icon(
          icon: const Icon(Icons.picture_as_pdf),
          label: const Text('Open Receipt'),
          onPressed: _openPdf,
        ),
      ),
    );
  }
}

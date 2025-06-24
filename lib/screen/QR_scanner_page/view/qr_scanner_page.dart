import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScannerPage extends StatelessWidget {
  const QRScannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scan QR Code")),
      body: MobileScanner(
        onDetect: (barcodeCapture) {
          if (barcodeCapture.barcodes.isNotEmpty && barcodeCapture.barcodes.first.rawValue != null) {
            final String code = barcodeCapture.barcodes.first.rawValue!;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Scanned: $code")),
            );
            Navigator.pop(context, code); // return scanned value
          }
        },
      ),
    );
  }
}


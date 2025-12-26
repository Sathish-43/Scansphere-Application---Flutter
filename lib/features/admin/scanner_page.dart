// lib/features/admin/scanner_page.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScannerPage extends StatefulWidget {
  const ScannerPage({super.key});

  @override
  State<ScannerPage> createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage> {
  bool _processing = false;
  final MobileScannerController _controller = MobileScannerController();

  void _onDetect(BarcodeCapture capture) async {
    if (_processing) return;
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;
    final raw = barcodes.first.rawValue ?? '';
    setState(() => _processing = true);

    try {
      final obj = jsonDecode(raw);
      // Show decoded data to admin
      await showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('QR scanned'),
          content: SingleChildScrollView(child: Text(const JsonEncoder.withIndent('  ').convert(obj))),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close')),
          ],
        ),
      );
    } catch (e) {
      await showDialog(context: context, builder: (_) => AlertDialog(title: const Text('Invalid QR'), content: Text('Could not decode QR: $e'), actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK'))]));
    } finally {
      // small delay before allowing next scan
      await Future.delayed(const Duration(milliseconds: 700));
      setState(() => _processing = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner'),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => _controller.toggleTorch(),
          ),
          IconButton(icon: const Icon(Icons.flip_camera_ios), onPressed: () => _controller.switchCamera()),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(controller: _controller, onDetect: _onDetect),
          if (_processing)
            const Center(
              child: Card(child: Padding(padding: EdgeInsets.all(12), child: Text('Processing...'))),
            )
        ],
      ),
    );
  }
}

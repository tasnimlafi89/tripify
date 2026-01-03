import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens the booking URL correctly on ALL platforms
Future<void> openBookingInApp(String url) async {
  final uri = Uri.tryParse(url);

  if (uri == null) {
    throw Exception('Invalid booking URL');
  }

  // 🌐 Flutter Web → open in new tab
  if (kIsWeb) {
    final success = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!success) {
      throw Exception('Could not open booking site');
    }
    return;
  }

  // 📱 Mobile (Android / iOS)
  final success = await launchUrl(
    uri,
    mode: LaunchMode.inAppWebView,
    webViewConfiguration: const WebViewConfiguration(
      enableJavaScript: true,
      enableDomStorage: true,
    ),
  );

  if (!success) {
    throw Exception('Could not open booking site');
  }
}

/// Opens booking page, then asks user if booking is complete
Future<void> openBookingAndReturn(
  BuildContext context,
  String url,
  VoidCallback onBooked,
) async {
  try {
    await openBookingInApp(url);
  } catch (e) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Unable to open booking website"),
      ),
    );
    return;
  }

  if (!context.mounted) return;

  // ⏳ Small delay to avoid instant dialog
  await Future.delayed(const Duration(milliseconds: 400));

  if (!context.mounted) return;

  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text("Booking status"),
      content: const Text("Did you complete your booking?"),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Not yet"),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            onBooked(); // ✅ mark trip booked
          },
          child: const Text("Yes, booked"),
        ),
      ],
    ),
  );
}

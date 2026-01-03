// ignore: file_names
import 'package:flutter/material.dart';
import 'package:frontend/features/auth/data/models/Flight.dart';
import 'package:frontend/features/auth/presentation/pages/open_booking_in_app.dart';

class FlightSummaryPage extends StatelessWidget {
  final Flight flight;

  const FlightSummaryPage({super.key, required this.flight});

  bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1024;

  @override
  Widget build(BuildContext context) {
    final desktop = isDesktop(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Review your flight"),
        centerTitle: desktop,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: desktop ? 900 : double.infinity,
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: desktop
                ? _DesktopLayout(flight: flight)
                : _MobileLayout(flight: flight),
          ),
        ),
      ),
    );
  }
}

/* ---------------- MOBILE LAYOUT ---------------- */

class _MobileLayout extends StatelessWidget {
  final Flight flight;

  const _MobileLayout({required this.flight});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _FlightHeader(flight: flight),
        const SizedBox(height: 24),
        _FlightDetails(flight: flight),
        const SizedBox(height: 24),
        const _BookingNotice(),
        const Spacer(),
        _BookButton(flight: flight),
      ],
    );
  }
}

/* ---------------- DESKTOP LAYOUT ---------------- */

class _DesktopLayout extends StatelessWidget {
  final Flight flight;

  const _DesktopLayout({required this.flight});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left: flight info
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _FlightHeader(flight: flight),
              const SizedBox(height: 24),
              _FlightDetails(flight: flight),
              const SizedBox(height: 24),
              const _BookingNotice(),
            ],
          ),
        ),

        const SizedBox(width: 40),

        // Right: action card
        Expanded(
          flex: 1,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  blurRadius: 20,
                  color: Colors.black.withOpacity(0.05),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Total price",
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  "${flight.price} ${flight.currency}",
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                _BookButton(flight: flight),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/* ---------------- COMPONENTS ---------------- */

class _FlightHeader extends StatelessWidget {
  final Flight flight;

  const _FlightHeader({required this.flight});

  @override
  Widget build(BuildContext context) {
    return Text(
      "✈ ${flight.airline}",
      style: Theme.of(context)
          .textTheme
          .headlineSmall
          ?.copyWith(fontWeight: FontWeight.bold),
    );
  }
}

class _FlightDetails extends StatelessWidget {
  final Flight flight;

  const _FlightDetails({required this.flight});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _InfoRow(label: "Route", value: "${flight.departure} → ${flight.arrival}"),
        const SizedBox(height: 12),
        _InfoRow(
          label: "Price",
          value: "${flight.price} ${flight.currency}",
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          "$label:",
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        const SizedBox(width: 8),
        Text(value),
      ],
    );
  }
}

class _BookingNotice extends StatelessWidget {
  const _BookingNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        "You’ll complete the booking securely on the airline’s website. "
        "Prices may change.",
        style: TextStyle(fontSize: 13),
      ),
    );
  }
}

class _BookButton extends StatelessWidget {
  final Flight flight;

  const _BookButton({required this.flight});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.lock_rounded),
        label: const Text(
          "Book securely",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        onPressed: () => openBookingInApp(flight.bookingUrl),
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}

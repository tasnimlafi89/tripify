import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/theme/theme.dart';

class HotelsPage extends ConsumerStatefulWidget {
  const HotelsPage({super.key});

  @override
  ConsumerState<HotelsPage> createState() => _HotelsPageState();
}

class _HotelsPageState extends ConsumerState<HotelsPage> {
  DateTimeRange? _dateRange;
  int _guests = 2;

  @override
  Widget build(BuildContext context) {
    final colors = ref.watch(appColorsProvider);

    return Scaffold(
      backgroundColor: colors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: colors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Hotels",
          style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.hotel_rounded, size: 60, color: colors.primary),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              "Find your perfect stay",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Select dates and guests to find the best hotels.",
              style: TextStyle(fontSize: 16, color: colors.textSecondary),
            ),
            const SizedBox(height: 32),
            
            // Date Picker
            InkWell(
              onTap: () async {
                final result = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: ColorScheme.light(
                          primary: colors.primary,
                          onPrimary: Colors.white,
                          surface: colors.surface,
                          onSurface: colors.textPrimary,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (result != null) {
                  setState(() => _dateRange = result);
                }
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colors.textHint.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today_rounded, color: colors.primary),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Dates", style: TextStyle(color: colors.textSecondary, fontSize: 12)),
                          Text(
                            _dateRange == null
                                ? "Select Dates"
                                : "${_dateRange!.start.day}/${_dateRange!.start.month} - ${_dateRange!.end.day}/${_dateRange!.end.month}",
                            style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Guest Counter
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: colors.textHint.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.person_rounded, color: colors.primary),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Guests", style: TextStyle(color: colors.textSecondary, fontSize: 12)),
                        Text(
                          "$_guests Guests",
                          style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => setState(() => _guests = _guests > 1 ? _guests - 1 : 1),
                        icon: Icon(Icons.remove_circle_outline, color: colors.textHint),
                      ),
                      IconButton(
                        onPressed: () => setState(() => _guests++),
                        icon: Icon(Icons.add_circle_outline, color: colors.primary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const Spacer(),
            
            // Confirm Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text("Confirm Booking", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/theme/theme.dart';

class BudgetPage extends ConsumerStatefulWidget {
  const BudgetPage({super.key});

  @override
  ConsumerState<BudgetPage> createState() => _BudgetPageState();
}

class _BudgetPageState extends ConsumerState<BudgetPage> {
  double _budget = 1000;
  String _selectedTier = "Medium";

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
          "Budget",
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
                  color: colors.success.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.attach_money_rounded, size: 60, color: colors.success),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              "Set your Budget",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "How much do you want to spend?",
              style: TextStyle(fontSize: 16, color: colors.textSecondary),
            ),
            const SizedBox(height: 48),
            
            // Amount Display
            Center(
              child: Text(
                "\$${_budget.toInt()}",
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: colors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 24),
            
            // Slider
            SliderTheme(
              data: SliderThemeData(
                activeTrackColor: colors.success,
                inactiveTrackColor: colors.success.withOpacity(0.2),
                thumbColor: colors.success,
                overlayColor: colors.success.withOpacity(0.1),
              ),
              child: Slider(
                value: _budget,
                min: 100,
                max: 10000,
                divisions: 99,
                label: _budget.round().toString(),
                onChanged: (double value) {
                  setState(() {
                    _budget = value;
                    if (_budget < 1000) _selectedTier = "Low";
                    else if (_budget < 5000) _selectedTier = "Medium";
                    else _selectedTier = "High";
                  });
                },
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Tiers
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: ["Low", "Medium", "High"].map((tier) {
                final isSelected = _selectedTier == tier;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? colors.success : colors.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? Colors.transparent : colors.textHint.withOpacity(0.2),
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: colors.success.withOpacity(0.4),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            )
                          ]
                        : [],
                  ),
                  child: Text(
                    tier,
                    style: TextStyle(
                      color: isSelected ? Colors.white : colors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }).toList(),
            ),
            
            const Spacer(),
            
            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context, true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.success,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: const Text("Save Budget", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

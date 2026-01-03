import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/widgets/loading_screen.dart';

class AIPlannerPage extends ConsumerStatefulWidget {
  const AIPlannerPage({super.key});

  @override
  ConsumerState<AIPlannerPage> createState() => _AIPlannerPageState();
}

class _AIPlannerPageState extends ConsumerState<AIPlannerPage> {
  final _destinationController = TextEditingController();
  int _selectedDays = 5;
  double _budget = 1500;
  String _travelStyle = 'Balanced';
  final List<String> _selectedInterests = [];
  bool _isGenerating = false;
  Map<String, dynamic>? _generatedItinerary;

  final List<String> _travelStyles = ['Budget', 'Balanced', 'Luxury'];
  final List<Map<String, dynamic>> _interests = [
    {'name': 'Culture', 'icon': Icons.museum_rounded},
    {'name': 'Food', 'icon': Icons.restaurant_rounded},
    {'name': 'Adventure', 'icon': Icons.terrain_rounded},
    {'name': 'Beach', 'icon': Icons.beach_access_rounded},
    {'name': 'Shopping', 'icon': Icons.shopping_bag_rounded},
    {'name': 'Nightlife', 'icon': Icons.nightlife_rounded},
    {'name': 'Nature', 'icon': Icons.forest_rounded},
    {'name': 'History', 'icon': Icons.account_balance_rounded},
  ];

  @override
  void dispose() {
    _destinationController.dispose();
    super.dispose();
  }

  void _generateItinerary() async {
    if (_destinationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a destination')),
      );
      return;
    }

    setState(() => _isGenerating = true);

    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isGenerating = false;
      _generatedItinerary = {
        'destination': _destinationController.text,
        'days': _selectedDays,
        'itinerary': List.generate(_selectedDays, (index) => {
          'day': index + 1,
          'title': 'Day ${index + 1}',
          'activities': [
            {'time': '09:00', 'activity': 'Breakfast at local café', 'icon': Icons.coffee_rounded},
            {'time': '10:30', 'activity': 'Visit main attractions', 'icon': Icons.location_on_rounded},
            {'time': '13:00', 'activity': 'Lunch break', 'icon': Icons.restaurant_rounded},
            {'time': '15:00', 'activity': 'Explore local area', 'icon': Icons.explore_rounded},
            {'time': '19:00', 'activity': 'Dinner & evening activities', 'icon': Icons.dinner_dining_rounded},
          ],
        }),
      };
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFF8F7FF), Color(0xFFEDE9FE), Color(0xFFE0D6FF)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: _generatedItinerary != null
                    ? _buildItineraryView()
                    : _buildPlannerForm(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFA78BFA).withOpacity(0.1),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: const Icon(Icons.arrow_back_rounded, color: Color(0xFF7C3AED)),
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "AI Trip Planner",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF374151),
                  ),
                ),
                Text(
                  "Create your perfect itinerary",
                  style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFA78BFA), Color(0xFF818CF8)],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.auto_awesome, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildPlannerForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDestinationInput(),
          const SizedBox(height: 24),
          _buildDaysSelector(),
          const SizedBox(height: 24),
          _buildBudgetSlider(),
          const SizedBox(height: 24),
          _buildTravelStyleSelector(),
          const SizedBox(height: 24),
          _buildInterestsSelector(),
          const SizedBox(height: 32),
          _buildGenerateButton(),
        ],
      ),
    );
  }

  Widget _buildDestinationInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Where do you want to go?",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF374151)),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFA78BFA).withOpacity(0.1),
                blurRadius: 15,
              ),
            ],
          ),
          child: TextField(
            controller: _destinationController,
            decoration: const InputDecoration(
              hintText: "e.g., Paris, Tokyo, New York...",
              hintStyle: TextStyle(color: Color(0xFF9CA3AF)),
              prefixIcon: Icon(Icons.location_on_rounded, color: Color(0xFFA78BFA)),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(18),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDaysSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Duration: $_selectedDays days",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF374151)),
        ),
        const SizedBox(height: 12),
        Row(
          children: List.generate(7, (index) {
            final days = index + 1;
            final isSelected = _selectedDays == days;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedDays = days),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? const LinearGradient(colors: [Color(0xFFA78BFA), Color(0xFF818CF8)])
                        : null,
                    color: isSelected ? null : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: isSelected
                        ? [BoxShadow(color: const Color(0xFFA78BFA).withOpacity(0.3), blurRadius: 10)]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      '$days',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : const Color(0xFF6B7280),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildBudgetSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Budget: \$${_budget.toInt()}",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF374151)),
        ),
        const SizedBox(height: 12),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: const Color(0xFFA78BFA),
            inactiveTrackColor: const Color(0xFFE5E7EB),
            thumbColor: const Color(0xFF7C3AED),
            overlayColor: const Color(0xFFA78BFA).withOpacity(0.2),
          ),
          child: Slider(
            value: _budget,
            min: 500,
            max: 10000,
            divisions: 19,
            onChanged: (value) => setState(() => _budget = value),
          ),
        ),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('\$500', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 12)),
            Text('\$10,000', style: TextStyle(color: Color(0xFF9CA3AF), fontSize: 12)),
          ],
        ),
      ],
    );
  }

  Widget _buildTravelStyleSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Travel Style",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF374151)),
        ),
        const SizedBox(height: 12),
        Row(
          children: _travelStyles.map((style) {
            final isSelected = _travelStyle == style;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _travelStyle = style),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? const LinearGradient(colors: [Color(0xFFA78BFA), Color(0xFF818CF8)])
                        : null,
                    color: isSelected ? null : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: isSelected
                        ? [BoxShadow(color: const Color(0xFFA78BFA).withOpacity(0.3), blurRadius: 10)]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      style,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : const Color(0xFF6B7280),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildInterestsSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Interests",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF374151)),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _interests.map((interest) {
            final isSelected = _selectedInterests.contains(interest['name']);
            return GestureDetector(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _selectedInterests.remove(interest['name']);
                  } else {
                    _selectedInterests.add(interest['name']);
                  }
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: isSelected
                      ? const LinearGradient(colors: [Color(0xFFA78BFA), Color(0xFF818CF8)])
                      : null,
                  color: isSelected ? null : Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: isSelected
                      ? [BoxShadow(color: const Color(0xFFA78BFA).withOpacity(0.3), blurRadius: 10)]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      interest['icon'],
                      size: 18,
                      color: isSelected ? Colors.white : const Color(0xFF7C3AED),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      interest['name'],
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: isSelected ? Colors.white : const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildGenerateButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(colors: [Color(0xFFA78BFA), Color(0xFF818CF8)]),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFA78BFA).withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isGenerating ? null : _generateItinerary,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: _isGenerating
            ? const CompactLoadingIndicator(
                size: 24,
                color: Colors.white,
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.auto_awesome, color: Colors.white),
                  SizedBox(width: 10),
                  Text(
                    "Generate Itinerary",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildItineraryView() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  "${_generatedItinerary!['destination']} - ${_generatedItinerary!['days']} Days",
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF374151)),
                ),
              ),
              TextButton.icon(
                onPressed: () => setState(() => _generatedItinerary = null),
                icon: const Icon(Icons.refresh_rounded, color: Color(0xFF7C3AED)),
                label: const Text("New Plan", style: TextStyle(color: Color(0xFF7C3AED))),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: (_generatedItinerary!['itinerary'] as List).length,
            itemBuilder: (context, index) {
              final day = _generatedItinerary!['itinerary'][index];
              return _buildDayCard(day);
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Container(
            width: double.infinity,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: const LinearGradient(colors: [Color(0xFF10B981), Color(0xFF34D399)]),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF10B981).withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Trip saved successfully!')),
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.save_rounded, color: Colors.white),
                  SizedBox(width: 10),
                  Text("Save Trip", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDayCard(Map<String, dynamic> day) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFA78BFA).withOpacity(0.1),
            blurRadius: 15,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFFA78BFA), Color(0xFF818CF8)]),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    "Day ${day['day']}",
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  day['title'],
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: (day['activities'] as List).map<Widget>((activity) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFA78BFA).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(activity['icon'], color: const Color(0xFF7C3AED), size: 20),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              activity['time'],
                              style: const TextStyle(color: Color(0xFF9CA3AF), fontSize: 12),
                            ),
                            Text(
                              activity['activity'],
                              style: const TextStyle(color: Color(0xFF374151), fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

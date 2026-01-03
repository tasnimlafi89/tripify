import 'package:flutter/material.dart';
import '../../../destination/presentation/pages/destination_detail_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String _query = '';

  final List<String> _recentSearches = [
    'Paris',
    'Tokyo',
    'New York',
    'Barcelona',
  ];

  final List<Map<String, dynamic>> _popularDestinations = [
    {'name': 'Bali', 'country': 'Indonesia', 'icon': Icons.beach_access_rounded, 'color': const Color(0xFF10B981)},
    {'name': 'Paris', 'country': 'France', 'icon': Icons.location_city_rounded, 'color': const Color(0xFF7C3AED)},
    {'name': 'Tokyo', 'country': 'Japan', 'icon': Icons.temple_buddhist_rounded, 'color': const Color(0xFFEF4444)},
    {'name': 'Dubai', 'country': 'UAE', 'icon': Icons.apartment_rounded, 'color': const Color(0xFFF59E0B)},
  ];

  final List<Map<String, dynamic>> _allDestinations = [
    {'name': 'Paris', 'country': 'France', 'color': const Color(0xFF7C3AED)},
    {'name': 'Tokyo', 'country': 'Japan', 'color': const Color(0xFFEF4444)},
    {'name': 'New York', 'country': 'USA', 'color': const Color(0xFF3B82F6)},
    {'name': 'Barcelona', 'country': 'Spain', 'color': const Color(0xFFF59E0B)},
    {'name': 'Bali', 'country': 'Indonesia', 'color': const Color(0xFF10B981)},
    {'name': 'Dubai', 'country': 'UAE', 'color': const Color(0xFFF59E0B)},
    {'name': 'London', 'country': 'UK', 'color': const Color(0xFF6366F1)},
    {'name': 'Sydney', 'country': 'Australia', 'color': const Color(0xFF06B6D4)},
    {'name': 'Rome', 'country': 'Italy', 'color': const Color(0xFFEC4899)},
    {'name': 'Bangkok', 'country': 'Thailand', 'color': const Color(0xFF8B5CF6)},
  ];

  List<Map<String, dynamic>> get _searchResults {
    if (_query.isEmpty) return [];
    return _allDestinations
        .where((d) =>
            d['name'].toString().toLowerCase().contains(_query.toLowerCase()) ||
            d['country'].toString().toLowerCase().contains(_query.toLowerCase()))
        .toList();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _navigateToDestination(String name, String country, Color color) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DestinationDetailPage(
          name: name,
          country: country,
          accentColor: color,
        ),
      ),
    );
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
              _buildSearchField(),
              Expanded(
                child: _query.isNotEmpty
                    ? _buildSearchResults()
                    : SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildRecentSearches(),
                            _buildPopularDestinations(),
                          ],
                        ),
                      ),
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
                    color: const Color(0xFF7C3AED).withOpacity(0.1),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: const Icon(Icons.arrow_back_rounded, color: Color(0xFF7C3AED)),
            ),
          ),
          const SizedBox(width: 16),
          const Text(
            'Search Destinations',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF374151),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF7C3AED).withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          focusNode: _focusNode,
          onChanged: (value) => setState(() => _query = value),
          decoration: InputDecoration(
            hintText: 'Where do you want to go?',
            hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
            prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF7C3AED)),
            suffixIcon: _query.isNotEmpty
                ? GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      setState(() => _query = '');
                    },
                    child: const Icon(Icons.close_rounded, color: Color(0xFF9CA3AF)),
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentSearches() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Searches',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF374151),
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: const Text(
                  'Clear all',
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFFA78BFA),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _recentSearches.map((search) {
              final destination = _allDestinations.firstWhere(
                (d) => d['name'] == search,
                orElse: () => {'name': search, 'country': 'Unknown', 'color': const Color(0xFF7C3AED)},
              );
              return GestureDetector(
                onTap: () => _navigateToDestination(
                  destination['name'],
                  destination['country'],
                  destination['color'],
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.history_rounded, size: 18, color: Color(0xFF9CA3AF)),
                      const SizedBox(width: 8),
                      Text(
                        search,
                        style: const TextStyle(
                          color: Color(0xFF374151),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPopularDestinations() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Popular Destinations',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF374151),
            ),
          ),
          const SizedBox(height: 16),
          ...List.generate(_popularDestinations.length, (index) {
            final destination = _popularDestinations[index];
            return GestureDetector(
              onTap: () => _navigateToDestination(
                destination['name'],
                destination['country'],
                destination['color'],
              ),
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: (destination['color'] as Color).withOpacity(0.1),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: (destination['color'] as Color).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        destination['icon'] as IconData,
                        color: destination['color'] as Color,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            destination['name'] as String,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Color(0xFF374151),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            destination['country'] as String,
                            style: const TextStyle(
                              color: Color(0xFF9CA3AF),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: (destination['color'] as Color).withOpacity(0.5),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 64,
              color: const Color(0xFF7C3AED).withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            const Text(
              'No destinations found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF374151),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try searching for a different destination',
              style: TextStyle(
                fontSize: 14,
                color: const Color(0xFF374151).withOpacity(0.6),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final result = _searchResults[index];
        return GestureDetector(
          onTap: () => _navigateToDestination(
            result['name'],
            result['country'],
            result['color'],
          ),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: (result['color'] as Color).withOpacity(0.1),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        result['color'] as Color,
                        (result['color'] as Color).withOpacity(0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.location_on_rounded,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        result['name'] as String,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: Color(0xFF374151),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.flag_rounded,
                            size: 14,
                            color: const Color(0xFF9CA3AF).withOpacity(0.8),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            result['country'] as String,
                            style: const TextStyle(
                              color: Color(0xFF9CA3AF),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: (result['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.arrow_forward_rounded,
                    size: 18,
                    color: result['color'] as Color,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

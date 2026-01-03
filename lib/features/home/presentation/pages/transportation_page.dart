import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/services/location_service.dart';
import 'package:frontend/core/theme/theme.dart';
import 'package:frontend/features/home/domain/entities/flight.dart';
import 'package:frontend/features/home/presentation/viewmodels/flight_search_provider.dart';
import 'package:frontend/features/home/data/mock_flight_service.dart';
import 'package:intl/intl.dart';

class TransportationPage extends ConsumerStatefulWidget {
  final double? destLat;
  final double? destLng;
  final double? originLat; // Optional: user's current location
  final double? originLng;

  const TransportationPage({
    super.key,
    this.destLat,
    this.destLng,
    this.originLat,
    this.originLng,
  });

  @override
  ConsumerState<TransportationPage> createState() => _TransportationPageState();
}

class _TransportationPageState extends ConsumerState<TransportationPage> with TickerProviderStateMixin {
  int _currentStep = 0; // 0: Search, 1: Results, 2: Seats, 3: Payment, 4: Success
  Flight? _selectedFlight;
  Set<String> _selectedSeats = {};
  
  // Controllers
  final TextEditingController _originController = TextEditingController();
  final TextEditingController _destController = TextEditingController();
  
  late AnimationController _fadeController;
  late AnimationController _planeController;

  final _locationService = LocationService();

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _planeController = AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _fadeController.forward();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _prefillAirports();
    });
  }

  void _prefillAirports() async {
    // Destination
    if (widget.destLat != null && widget.destLng != null) {
      final destAirport = MockFlightService.findClosestAirport(widget.destLat!, widget.destLng!);
      if (destAirport != null) {
        _destController.text = "${destAirport.city} (${destAirport.code})";
        ref.read(flightSearchProvider.notifier).setDestination(destAirport);
      }
    }

    // Origin (User Location)
    if (widget.originLat != null && widget.originLng != null) {
       final originAirport = MockFlightService.findClosestAirport(widget.originLat!, widget.originLng!);
       if (originAirport != null) {
         _originController.text = "${originAirport.city} (${originAirport.code})";
         ref.read(flightSearchProvider.notifier).setOrigin(originAirport);
       }
    } else {
      // Fetch current location if not provided
      try {
        final position = await _locationService.getCurrentLocation();
        if (position != null) {
          final originAirport = MockFlightService.findClosestAirport(position.latitude, position.longitude);
          if (originAirport != null) {
             _originController.text = "${originAirport.city} (${originAirport.code})";
             ref.read(flightSearchProvider.notifier).setOrigin(originAirport);
             return;
          }
        }
      } catch (e) {
        debugPrint("Error fetching location: $e");
      }
      
      // Fallback if location fails or no airport found near user
      try {
        final defaultOrigin = MockFlightService.airports.firstWhere((a) => a.code == 'TUN');
        if (_originController.text.isEmpty) {
           _originController.text = "${defaultOrigin.city} (${defaultOrigin.code})";
           ref.read(flightSearchProvider.notifier).setOrigin(defaultOrigin);
        }
      } catch (_) {}
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _planeController.dispose();
    _originController.dispose();
    _destController.dispose();
    super.dispose();
  }

  void _nextStep() {
    setState(() => _currentStep++);
    _fadeController.reset();
    _fadeController.forward();
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _fadeController.reset();
      _fadeController.forward();
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = ref.watch(appColorsProvider);
    
    return Scaffold(
      backgroundColor: colors.background,
      appBar: _currentStep < 4 ? AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: colors.textPrimary),
          onPressed: _prevStep,
        ),
        title: Text(
          _getStepTitle(),
          style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          if (_currentStep == 0)
            IconButton(
              icon: Icon(Icons.history_rounded, color: colors.textPrimary),
              onPressed: () {}, // TODO: Recent searches
            ),
        ],
      ) : null,
      body: FadeTransition(
        opacity: _fadeController,
        child: _buildStepContent(colors),
      ),
    );
  }

  String _getStepTitle() {
    switch (_currentStep) {
      case 0: return "Book Flight";
      case 1: return "Select Flight";
      case 2: return "Choose Seats";
      case 3: return "Payment";
      default: return "";
    }
  }

  Widget _buildStepContent(AppColors colors) {
    switch (_currentStep) {
      case 0: return _buildSearchForm(colors);
      case 1: return _buildResultsList(colors);
      case 2: return _buildSeatMap(colors);
      case 3: return _buildPaymentForm(colors);
      case 4: return _buildSuccessView(colors);
      default: return Container();
    }
  }

  // STEP 0: SEARCH FORM
  Widget _buildSearchForm(AppColors colors) {
    final searchState = ref.watch(flightSearchProvider);
    final origin = ref.watch(originAirportProvider);
    final dest = ref.watch(destinationAirportProvider);
    final date = ref.watch(departureDateProvider);
    final passengers = ref.watch(passengersProvider);
    final cabinClass = ref.watch(cabinClassProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Text(
            "Where to next?",
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: colors.textPrimary),
          ),
          const SizedBox(height: 24),

          // Origin & Dest Inputs (Autocomplete)
          _buildAirportField("From", _originController, origin, (a) {
            ref.read(originAirportProvider.notifier).state = a;
            _originController.text = a.city; // Show city name
          }, colors),
          
          const SizedBox(height: 16),
          
          Center(
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.surfaceVariant,
                border: Border.all(color: colors.background, width: 4),
              ),
              child: Icon(Icons.swap_vert_rounded, color: colors.primary),
            ),
          ),
          
          const SizedBox(height: 16),
          
          _buildAirportField("To", _destController, dest, (a) {
            ref.read(destinationAirportProvider.notifier).state = a;
            _destController.text = a.city;
          }, colors),

          const SizedBox(height: 32),

          // Date & Passengers Row
          Row(
            children: [
              Expanded(
                child: _buildOptionTile(
                  "Departure",
                  DateFormat('d MMM, y').format(date),
                  Icons.calendar_today_rounded,
                  colors,
                  () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: date,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      ref.read(departureDateProvider.notifier).state = picked;
                    }
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildOptionTile(
                  "Travelers",
                  "$passengers Adult(s)",
                  Icons.person_rounded,
                  colors,
                  () {
                    // Simple increment for demo
                    ref.read(passengersProvider.notifier).state = (passengers % 5) + 1;
                  },
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Class Selection
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.textHint.withOpacity(0.1)),
            ),
            child: Row(
              children: ["Economy", "Business", "First"].map((c) {
                final isSelected = cabinClass == c;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => ref.read(cabinClassProvider.notifier).state = c,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? colors.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        c,
                        style: TextStyle(
                          color: isSelected ? Colors.white : colors.textSecondary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 40),

          // Search Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: (origin != null && dest != null) ? () async {
                await ref.read(flightSearchProvider.notifier).searchFlights(origin, dest, date);
                _nextStep();
              } : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 8,
                shadowColor: colors.primary.withOpacity(0.4),
              ),
              child: searchState.isLoading 
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text("SEARCH FLIGHTS", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            ),
          ),
          
          if (searchState.error != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(searchState.error!, style: TextStyle(color: colors.error, fontSize: 14)),
            ),
        ],
      ),
    );
  }

  Widget _buildAirportField(String label, TextEditingController controller, Airport? value, Function(Airport) onSelect, AppColors colors) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: TextStyle(color: colors.textSecondary, fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Autocomplete<Airport>(
          displayStringForOption: (Airport option) => option.displayName,
          optionsBuilder: (TextEditingValue textEditingValue) async {
             return await ref.read(flightServiceProvider).searchAirports(textEditingValue.text);
          },
          onSelected: onSelect,
          fieldViewBuilder: (context, textController, focusNode, onFieldSubmitted) {
            // Sync initial value
            if (value != null && textController.text.isEmpty) {
              textController.text = value.city;
            }
            return TextField(
              controller: textController,
              focusNode: focusNode,
              style: TextStyle(color: colors.textPrimary, fontSize: 18, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                filled: true,
                fillColor: colors.surface,
                prefixIcon: Icon(Icons.flight_takeoff_rounded, color: colors.primary),
                hintText: "Select City or Airport",
                hintStyle: TextStyle(color: colors.textHint),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              ),
            );
          },
          optionsViewBuilder: (context, onSelected, options) {
            return Align(
              alignment: Alignment.topLeft,
              child: Material(
                elevation: 4,
                borderRadius: BorderRadius.circular(16),
                color: colors.surface,
                child: Container(
                  width: MediaQuery.of(context).size.width - 48,
                  constraints: const BoxConstraints(maxHeight: 250),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    itemCount: options.length,
                    itemBuilder: (BuildContext context, int index) {
                      final Airport option = options.elementAt(index);
                      return ListTile(
                        title: Text(option.city, style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.bold)),
                        subtitle: Text('${option.name} (${option.code})', style: TextStyle(color: colors.textSecondary)),
                        onTap: () => onSelected(option),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildOptionTile(String title, String value, IconData icon, AppColors colors, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colors.textHint.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title.toUpperCase(), style: TextStyle(color: colors.textSecondary, fontSize: 10, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(icon, size: 18, color: colors.primary),
                const SizedBox(width: 8),
                Expanded(child: Text(value, style: TextStyle(color: colors.textPrimary, fontWeight: FontWeight.bold, fontSize: 14))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // STEP 1: RESULTS LIST
  Widget _buildResultsList(AppColors colors) {
    final searchState = ref.watch(flightSearchProvider);

    if (searchState.isLoading) {
      return Center(child: CircularProgressIndicator(color: colors.primary));
    }
    
    if (searchState.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline_rounded, size: 64, color: colors.error),
              const SizedBox(height: 16),
              Text("No Flights Found", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colors.textPrimary)),
              const SizedBox(height: 8),
              Text(searchState.error!, textAlign: TextAlign.center, style: TextStyle(color: colors.textSecondary)),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _prevStep,
                child: const Text("Modify Search"),
              )
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: searchState.flights.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("${searchState.flights.length} Flights Found", style: TextStyle(color: colors.textSecondary, fontWeight: FontWeight.bold)),
                Text("${searchState.distance?.toStringAsFixed(0)} km", style: TextStyle(color: colors.primary, fontWeight: FontWeight.bold)),
              ],
            ),
          );
        }
        final flight = searchState.flights[index - 1];
        return GestureDetector(
          onTap: () {
            setState(() => _selectedFlight = flight);
            _nextStep();
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    // Airline Logo (Mock)
                    CircleAvatar(
                      backgroundColor: colors.surfaceVariant,
                      child: Icon(Icons.airlines, color: colors.primary),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(flight.airline.name, style: TextStyle(fontWeight: FontWeight.bold, color: colors.textPrimary)),
                        Text(flight.flightNumber, style: TextStyle(color: colors.textSecondary, fontSize: 12)),
                      ],
                    ),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text("\$${flight.priceUsd.toStringAsFixed(0)}", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: colors.primary)),
                        Text("${flight.priceTnd.toStringAsFixed(0)} TND", style: TextStyle(color: colors.textSecondary, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildTimeColumn(flight.departureTime, flight.origin.code, colors),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            "${flight.duration.inHours}h ${flight.duration.inMinutes % 60}m",
                            style: TextStyle(color: colors.textSecondary, fontSize: 12),
                          ),
                          const SizedBox(height: 4),
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              Divider(color: colors.textHint.withOpacity(0.3), thickness: 2),
                              Icon(Icons.flight_takeoff_rounded, color: colors.primary, size: 20),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            flight.stops.isEmpty ? "Direct" : "${flight.stops.length} Stop(s)",
                            style: TextStyle(color: flight.stops.isEmpty ? colors.success : colors.warning, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    _buildTimeColumn(flight.arrivalTime, flight.destination.code, colors, isRight: true),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTimeColumn(DateTime time, String code, AppColors colors, {bool isRight = false}) {
    return Column(
      crossAxisAlignment: isRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(DateFormat('HH:mm').format(time), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colors.textPrimary)),
        Text(code, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: colors.textSecondary)),
      ],
    );
  }

  // STEP 2: SEAT MAP (Gamified)
  Widget _buildSeatMap(AppColors colors) {
    // 6 Columns: A B C  D E F
    // 10 Rows
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: colors.surface,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Select Seat", style: TextStyle(fontWeight: FontWeight.bold, color: colors.textPrimary)),
                  Text("Economy Class", style: TextStyle(color: colors.textSecondary, fontSize: 12)),
                ],
              ),
              Row(
                children: [
                  _buildLegendItem(colors.surfaceVariant, "Taken", colors),
                  const SizedBox(width: 12),
                  _buildLegendItem(colors.background, "Free", colors),
                  const SizedBox(width: 12),
                  _buildLegendItem(colors.primary, "Your", colors),
                ],
              )
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // Cockpit shape
                Container(
                  height: 60,
                  decoration: BoxDecoration(
                    color: colors.surfaceVariant.withOpacity(0.3),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(100)),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colors.surfaceVariant.withOpacity(0.1),
                    border: Border.symmetric(vertical: BorderSide(color: colors.textHint.withOpacity(0.1))),
                  ),
                  child: Column(
                    children: List.generate(10, (rowIndex) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildSeat(rowIndex, 'A', colors),
                            _buildSeat(rowIndex, 'B', colors),
                            _buildSeat(rowIndex, 'C', colors),
                            const SizedBox(width: 24), // Aisle
                            _buildSeat(rowIndex, 'D', colors),
                            _buildSeat(rowIndex, 'E', colors),
                            _buildSeat(rowIndex, 'F', colors),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(24),
          color: colors.surface,
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedSeats.isNotEmpty ? _nextStep : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: Text("Confirm ${_selectedSeats.length} Seats", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSeat(int row, String col, AppColors colors) {
    final seatId = "${row + 1}$col";
    // Mock occupied logic (random deterministically)
    final isOccupied = (row * col.codeUnitAt(0)) % 5 == 0;
    final isSelected = _selectedSeats.contains(seatId);

    return GestureDetector(
      onTap: isOccupied ? null : () {
        setState(() {
          if (isSelected) {
            _selectedSeats.remove(seatId);
          } else {
            // Only 1 seat for demo unless we handle multiple pax logic complexity
            _selectedSeats.clear();
            _selectedSeats.add(seatId);
          }
        });
      },
      child: Container(
        width: 36,
        height: 36,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: isOccupied 
              ? colors.surfaceVariant 
              : isSelected ? colors.primary : colors.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? colors.primary : colors.textHint.withOpacity(0.2),
          ),
        ),
        alignment: Alignment.center,
        child: isOccupied 
            ? Icon(Icons.close_rounded, size: 16, color: colors.textHint)
            : Text(
                seatId,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : colors.textPrimary,
                ),
              ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label, AppColors colors) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4))),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(color: colors.textSecondary, fontSize: 12)),
      ],
    );
  }

  // STEP 3: PAYMENT FORM
  Widget _buildPaymentForm(AppColors colors) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Payment Details", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: colors.textPrimary)),
          const SizedBox(height: 24),
          
          // Credit Card Mock
          Container(
            height: 200,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [colors.primary, colors.secondary], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [BoxShadow(color: colors.primary.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8))],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(Icons.nfc_rounded, color: Colors.white),
                    Text("VISA", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                  ],
                ),
                Text("**** **** **** 4242", style: const TextStyle(color: Colors.white, fontSize: 22, letterSpacing: 2, fontFamily: 'monospace')),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Card Holder", style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 10)),
                        const Text("JOHN DOE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Expires", style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 10)),
                        const Text("12/25", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                )
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          TextField(
            decoration: InputDecoration(
              labelText: "Card Number",
              prefixIcon: const Icon(Icons.credit_card_rounded),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: "Expiry Date",
                    prefixIcon: const Icon(Icons.calendar_today_rounded),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: "CVV",
                    prefixIcon: const Icon(Icons.lock_rounded),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 40),
          
          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Total Amount", style: TextStyle(color: colors.textSecondary, fontSize: 16)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("\$${_selectedFlight?.priceUsd.toStringAsFixed(2)}", style: TextStyle(color: colors.primary, fontSize: 24, fontWeight: FontWeight.w900)),
                  Text("${_selectedFlight?.priceTnd.toStringAsFixed(2)} TND", style: TextStyle(color: colors.textSecondary, fontSize: 14)),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                 _nextStep();
                 _planeController.forward();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.success,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text("PAY & BOOK", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            ),
          ),
        ],
      ),
    );
  }

  // STEP 4: SUCCESS VIEW
  Widget _buildSuccessView(AppColors colors) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: colors.success.withOpacity(0.1),
                ),
              ),
              ScaleTransition(
                scale: CurvedAnimation(parent: _fadeController, curve: Curves.elasticOut),
                child: Icon(Icons.check_circle_rounded, size: 100, color: colors.success),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Text("Booking Confirmed!", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: colors.textPrimary)),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              "Your flight to ${_selectedFlight?.destination.city} has been booked successfully.",
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.textSecondary, fontSize: 16),
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: colors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
            child: const Text("DONE"),
          ),
        ],
      ),
    );
  }
}

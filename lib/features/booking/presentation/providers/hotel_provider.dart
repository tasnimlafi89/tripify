import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../data/models/hotel_model.dart';
import '../../data/services/hotel_service.dart';

final hotelServiceProvider = Provider<HotelService>((ref) => HotelService());

final hotelsProvider = FutureProvider.autoDispose<List<Hotel>>((ref) async {
  final service = ref.watch(hotelServiceProvider);
  return service.getHotels();
});

final featuredHotelsProvider = FutureProvider.autoDispose<List<Hotel>>((ref) async {
  final service = ref.watch(hotelServiceProvider);
  return service.getFeaturedHotels();
});

final hotelByIdProvider = FutureProvider.autoDispose.family<Hotel?, String>((ref, id) async {
  final service = ref.watch(hotelServiceProvider);
  return service.getHotelById(id);
});

final hotelSearchProvider = FutureProvider.autoDispose.family<List<Hotel>, String>((ref, query) async {
  final service = ref.watch(hotelServiceProvider);
  if (query.isEmpty) {
    return service.getHotels();
  }
  return service.searchHotels(query);
});

/// Provider to search hotels by city with optional sorting
final hotelsByCityProvider = FutureProvider.autoDispose.family<List<Hotel>, ({String city, String? sortBy})>((ref, params) async {
  final service = ref.watch(hotelServiceProvider);
  return service.searchHotelsByCity(params.city, sortBy: params.sortBy);
});

/// Provider to get available cities
final availableCitiesProvider = Provider<List<String>>((ref) {
  final service = ref.watch(hotelServiceProvider);
  return service.getAvailableCities();
});

final selectedHotelProvider = StateProvider<Hotel?>((ref) => null);
final selectedRoomProvider = StateProvider<HotelRoom?>((ref) => null);
final selectedHotelIndexProvider = StateProvider<int>((ref) => 0);

final checkInDateProvider = StateProvider<DateTime>((ref) => DateTime.now().add(const Duration(days: 1)));
final checkOutDateProvider = StateProvider<DateTime>((ref) => DateTime.now().add(const Duration(days: 3)));
final guestCountProvider = StateProvider<int>((ref) => 2);
final roomCountProvider = StateProvider<int>((ref) => 1);

final sortOptionProvider = StateProvider<String>((ref) => 'rating');

final sortedHotelsProvider = FutureProvider.autoDispose<List<Hotel>>((ref) async {
  final service = ref.watch(hotelServiceProvider);
  final sortBy = ref.watch(sortOptionProvider);
  return service.getHotels(sortBy: sortBy);
});

final bookingFormProvider = StateNotifierProvider<BookingFormNotifier, BookingFormState>((ref) {
  return BookingFormNotifier();
});

class BookingFormState {
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String specialRequests;
  final String cardNumber;
  final String cardHolder;
  final String expiryDate;
  final String cvv;
  final PaymentMethod paymentMethod;
  final bool isLoading;
  final String? error;
  final HotelBooking? booking;

  const BookingFormState({
    this.firstName = '',
    this.lastName = '',
    this.email = '',
    this.phone = '',
    this.specialRequests = '',
    this.cardNumber = '',
    this.cardHolder = '',
    this.expiryDate = '',
    this.cvv = '',
    this.paymentMethod = PaymentMethod.creditCard,
    this.isLoading = false,
    this.error,
    this.booking,
  });

  BookingFormState copyWith({
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? specialRequests,
    String? cardNumber,
    String? cardHolder,
    String? expiryDate,
    String? cvv,
    PaymentMethod? paymentMethod,
    bool? isLoading,
    String? error,
    HotelBooking? booking,
  }) {
    return BookingFormState(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      specialRequests: specialRequests ?? this.specialRequests,
      cardNumber: cardNumber ?? this.cardNumber,
      cardHolder: cardHolder ?? this.cardHolder,
      expiryDate: expiryDate ?? this.expiryDate,
      cvv: cvv ?? this.cvv,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      booking: booking ?? this.booking,
    );
  }

  bool get isGuestInfoValid =>
      firstName.isNotEmpty &&
      lastName.isNotEmpty &&
      email.isNotEmpty &&
      email.contains('@') &&
      phone.isNotEmpty;

  bool get isPaymentInfoValid =>
      cardNumber.length >= 16 &&
      cardHolder.isNotEmpty &&
      expiryDate.length == 5 &&
      cvv.length >= 3;

  bool get isFormValid => isGuestInfoValid && isPaymentInfoValid;
}

class BookingFormNotifier extends StateNotifier<BookingFormState> {
  BookingFormNotifier() : super(const BookingFormState());

  void updateFirstName(String value) => state = state.copyWith(firstName: value);
  void updateLastName(String value) => state = state.copyWith(lastName: value);
  void updateEmail(String value) => state = state.copyWith(email: value);
  void updatePhone(String value) => state = state.copyWith(phone: value);
  void updateSpecialRequests(String value) => state = state.copyWith(specialRequests: value);
  void updateCardNumber(String value) => state = state.copyWith(cardNumber: value);
  void updateCardHolder(String value) => state = state.copyWith(cardHolder: value);
  void updateExpiryDate(String value) => state = state.copyWith(expiryDate: value);
  void updateCvv(String value) => state = state.copyWith(cvv: value);
  void updatePaymentMethod(PaymentMethod method) => state = state.copyWith(paymentMethod: method);

  void setLoading(bool loading) => state = state.copyWith(isLoading: loading);
  void setError(String? error) => state = state.copyWith(error: error);
  void setBooking(HotelBooking booking) => state = state.copyWith(booking: booking, isLoading: false);

  void reset() => state = const BookingFormState();

  Future<HotelBooking?> submitBooking({
    required HotelService service,
    required Hotel hotel,
    required HotelRoom room,
    required DateTime checkIn,
    required DateTime checkOut,
    required int guests,
    required int rooms,
    bool skipValidation = false,
  }) async {
    if (!skipValidation && !state.isFormValid) {
      state = state.copyWith(error: 'Please fill in all required fields');
      return null;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      final guestInfo = GuestInfo(
        firstName: state.firstName.isNotEmpty ? state.firstName : 'Guest',
        lastName: state.lastName.isNotEmpty ? state.lastName : 'User',
        email: state.email.isNotEmpty ? state.email : 'guest@example.com',
        phone: state.phone.isNotEmpty ? state.phone : '+1234567890',
        specialRequests: state.specialRequests.isNotEmpty ? state.specialRequests : null,
      );

      final paymentInfo = PaymentInfo(
        cardNumber: state.cardNumber.isNotEmpty ? state.cardNumber : '4242424242424242',
        cardHolder: state.cardHolder.isNotEmpty ? state.cardHolder : 'Demo User',
        expiryDate: state.expiryDate.isNotEmpty ? state.expiryDate : '12/28',
        cvv: state.cvv.isNotEmpty ? state.cvv : '123',
        method: state.paymentMethod,
      );

      final booking = await service.createBooking(
        hotel: hotel,
        room: room,
        checkIn: checkIn,
        checkOut: checkOut,
        guests: guests,
        rooms: rooms,
        guestInfo: guestInfo,
        paymentInfo: paymentInfo,
      );

      state = state.copyWith(booking: booking, isLoading: false);
      return booking;
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
      return null;
    }
  }
}

final totalPriceProvider = Provider<double>((ref) {
  final room = ref.watch(selectedRoomProvider);
  final checkIn = ref.watch(checkInDateProvider);
  final checkOut = ref.watch(checkOutDateProvider);
  final roomCount = ref.watch(roomCountProvider);

  if (room == null) return 0;

  final nights = checkOut.difference(checkIn).inDays;
  return room.pricePerNight * nights * roomCount;
});

final nightsCountProvider = Provider<int>((ref) {
  final checkIn = ref.watch(checkInDateProvider);
  final checkOut = ref.watch(checkOutDateProvider);
  return checkOut.difference(checkIn).inDays;
});

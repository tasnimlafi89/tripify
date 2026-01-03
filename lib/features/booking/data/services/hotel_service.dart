import 'package:flutter/material.dart';
import '../models/hotel_model.dart';

class HotelService {
  static final List<Hotel> _mockHotels = [
    Hotel(
      id: 'hotel_1',
      name: 'The Ritz-Carlton',
      description: 'Experience luxury at its finest with stunning city views, world-class dining, and impeccable service. Our hotel offers an oasis of comfort in the heart of the city, featuring award-winning restaurants, a full-service spa, and elegant accommodations.',
      latitude: 48.8566,
      longitude: 2.3522,
      address: '15 Place Vendôme',
      city: 'Paris',
      country: 'France',
      rating: 4.9,
      reviewCount: 2847,
      pricePerNight: 450,
      currency: '\$',
      photos: [
        'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800',
        'https://images.unsplash.com/photo-1582719508461-905c673771fd?w=800',
        'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=800',
        'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=800',
        'https://images.unsplash.com/photo-1618773928121-c32242e63f39?w=800',
      ],
      facilities: _luxuryFacilities,
      rooms: _luxuryRooms,
      checkInTime: '15:00',
      checkOutTime: '11:00',
      isFeatured: true,
      discountPercentage: 15,
      policies: [
        'Free cancellation up to 24 hours before check-in',
        'No pets allowed',
        'Non-smoking rooms',
        'Children of all ages welcome',
      ],
    ),
    Hotel(
      id: 'hotel_2',
      name: 'Grand Hyatt',
      description: 'A sophisticated urban retreat offering panoramic views, exceptional dining experiences, and state-of-the-art amenities. Perfect for both business and leisure travelers seeking the ultimate in comfort and convenience.',
      latitude: 48.8584,
      longitude: 2.2945,
      address: '2 Rue de la Paix',
      city: 'Paris',
      country: 'France',
      rating: 4.7,
      reviewCount: 1923,
      pricePerNight: 320,
      currency: '\$',
      photos: [
        'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=800',
        'https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=800',
        'https://images.unsplash.com/photo-1590490360182-c33d57733427?w=800',
        'https://images.unsplash.com/photo-1584132967334-10e028bd69f7?w=800',
      ],
      facilities: _premiumFacilities,
      rooms: _premiumRooms,
      checkInTime: '14:00',
      checkOutTime: '12:00',
      isFeatured: true,
      discountPercentage: 10,
      policies: [
        'Free cancellation up to 48 hours before check-in',
        'Pets allowed with additional fee',
        'Non-smoking property',
      ],
    ),
    Hotel(
      id: 'hotel_3',
      name: 'Four Seasons',
      description: 'Timeless elegance meets modern luxury in our iconic hotel. Featuring exquisite accommodations, Michelin-starred dining, and personalized service that anticipates your every need.',
      latitude: 48.8606,
      longitude: 2.3376,
      address: '31 Avenue George V',
      city: 'Paris',
      country: 'France',
      rating: 4.8,
      reviewCount: 3156,
      pricePerNight: 580,
      currency: '\$',
      photos: [
        'https://images.unsplash.com/photo-1578683010236-d716f9a3f461?w=800',
        'https://images.unsplash.com/photo-1564501049412-61c2a3083791?w=800',
        'https://images.unsplash.com/photo-1611892440504-42a792e24d32?w=800',
        'https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=800',
      ],
      facilities: _luxuryFacilities,
      rooms: _luxuryRooms,
      checkInTime: '15:00',
      checkOutTime: '12:00',
      isFeatured: true,
      policies: [
        'Flexible cancellation policy',
        'Pet-friendly',
        'Smoke-free property',
      ],
    ),
    Hotel(
      id: 'hotel_4',
      name: 'Marriott Champs-Élysées',
      description: 'Located on the famous Champs-Élysées, our hotel combines French elegance with modern comfort. Enjoy easy access to major attractions, luxury shopping, and fine dining.',
      latitude: 48.8698,
      longitude: 2.3078,
      address: '70 Avenue des Champs-Élysées',
      city: 'Paris',
      country: 'France',
      rating: 4.5,
      reviewCount: 1456,
      pricePerNight: 275,
      currency: '\$',
      photos: [
        'https://images.unsplash.com/photo-1596436889106-be35e843f974?w=800',
        'https://images.unsplash.com/photo-1616594039964-ae9021a400a0?w=800',
        'https://images.unsplash.com/photo-1591088398332-8a7791972843?w=800',
      ],
      facilities: _premiumFacilities,
      rooms: _standardRooms,
      checkInTime: '15:00',
      checkOutTime: '11:00',
      discountPercentage: 20,
      policies: [
        'Free cancellation up to 24 hours before check-in',
        'No pets allowed',
      ],
    ),
    Hotel(
      id: 'hotel_5',
      name: 'Shangri-La Paris',
      description: 'A former royal residence transformed into an ultra-luxury hotel, offering breathtaking Eiffel Tower views, exceptional Asian-inspired cuisine, and legendary hospitality.',
      latitude: 48.8625,
      longitude: 2.2875,
      address: '10 Avenue d\'Iéna',
      city: 'Paris',
      country: 'France',
      rating: 4.9,
      reviewCount: 2089,
      pricePerNight: 720,
      currency: '\$',
      photos: [
        'https://images.unsplash.com/photo-1445019980597-93fa8acb246c?w=800',
        'https://images.unsplash.com/photo-1522771739844-6a9f6d5f14af?w=800',
        'https://images.unsplash.com/photo-1560185893-a55cbc8c57e8?w=800',
        'https://images.unsplash.com/photo-1587874522487-fe10e954d035?w=800',
      ],
      facilities: _luxuryFacilities,
      rooms: _luxuryRooms,
      checkInTime: '15:00',
      checkOutTime: '12:00',
      isFeatured: true,
      policies: [
        'Full prepayment required',
        'Non-refundable',
        'Pet-friendly with restrictions',
      ],
    ),
    Hotel(
      id: 'hotel_6',
      name: 'Ibis Styles Montmartre',
      description: 'A charming boutique hotel in the artistic Montmartre district. Perfect for travelers seeking authentic Parisian atmosphere with modern amenities at an affordable price.',
      latitude: 48.8867,
      longitude: 2.3431,
      address: '3 Rue Caulaincourt',
      city: 'Paris',
      country: 'France',
      rating: 4.2,
      reviewCount: 876,
      pricePerNight: 95,
      currency: '\$',
      photos: [
        'https://images.unsplash.com/photo-1618773928121-c32242e63f39?w=800',
        'https://images.unsplash.com/photo-1590490360182-c33d57733427?w=800',
      ],
      facilities: _standardFacilities,
      rooms: _standardRooms,
      checkInTime: '14:00',
      checkOutTime: '11:00',
      policies: [
        'Free cancellation up to 24 hours before check-in',
      ],
    ),
    Hotel(
      id: 'hotel_7',
      name: 'Novotel Paris Tour Eiffel',
      description: 'Modern hotel with stunning Eiffel Tower views, contemporary rooms, and excellent facilities for families and business travelers alike.',
      latitude: 48.8534,
      longitude: 2.2921,
      address: '61 Quai de Grenelle',
      city: 'Paris',
      country: 'France',
      rating: 4.4,
      reviewCount: 1234,
      pricePerNight: 185,
      currency: '\$',
      photos: [
        'https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?w=800',
        'https://images.unsplash.com/photo-1584132915807-fd1f5fbc078f?w=800',
        'https://images.unsplash.com/photo-1595576508898-0ad5c879a061?w=800',
      ],
      facilities: _premiumFacilities,
      rooms: _standardRooms,
      checkInTime: '15:00',
      checkOutTime: '12:00',
      discountPercentage: 25,
      policies: [
        'Free cancellation up to 48 hours before check-in',
        'Children stay free',
      ],
    ),
    Hotel(
      id: 'hotel_8',
      name: 'Le Bristol Paris',
      description: 'An iconic palace hotel on Rue du Faubourg Saint-Honoré, featuring a rooftop garden, three-star Michelin restaurant, and timeless Parisian elegance.',
      latitude: 48.8711,
      longitude: 2.3165,
      address: '112 Rue du Faubourg Saint-Honoré',
      city: 'Paris',
      country: 'France',
      rating: 4.9,
      reviewCount: 1876,
      pricePerNight: 890,
      currency: '\$',
      photos: [
        'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800',
        'https://images.unsplash.com/photo-1582719508461-905c673771fd?w=800',
        'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=800',
      ],
      facilities: _luxuryFacilities,
      rooms: _luxuryRooms,
      checkInTime: '15:00',
      checkOutTime: '12:00',
      isFeatured: true,
      policies: [
        'Luxury concierge service',
        'Butler service available',
        'Pet-friendly',
      ],
    ),
    // London Hotels
    Hotel(
      id: 'hotel_9',
      name: 'The Savoy',
      description: 'Iconic luxury hotel on the Strand, offering legendary service, Art Deco elegance, and Thames views since 1889.',
      latitude: 51.5101,
      longitude: -0.1204,
      address: 'Strand',
      city: 'London',
      country: 'United Kingdom',
      rating: 4.8,
      reviewCount: 2456,
      pricePerNight: 520,
      currency: '\$',
      photos: [
        'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800',
        'https://images.unsplash.com/photo-1582719508461-905c673771fd?w=800',
      ],
      facilities: _luxuryFacilities,
      rooms: _luxuryRooms,
      checkInTime: '15:00',
      checkOutTime: '11:00',
      isFeatured: true,
      policies: ['Free cancellation up to 48 hours'],
    ),
    Hotel(
      id: 'hotel_10',
      name: 'Premier Inn London',
      description: 'Comfortable and affordable hotel in central London with modern amenities.',
      latitude: 51.5074,
      longitude: -0.1278,
      address: 'Leicester Square',
      city: 'London',
      country: 'United Kingdom',
      rating: 4.2,
      reviewCount: 1823,
      pricePerNight: 120,
      currency: '\$',
      photos: [
        'https://images.unsplash.com/photo-1618773928121-c32242e63f39?w=800',
      ],
      facilities: _standardFacilities,
      rooms: _standardRooms,
      checkInTime: '14:00',
      checkOutTime: '11:00',
      policies: ['Free cancellation up to 24 hours'],
    ),
    // New York Hotels
    Hotel(
      id: 'hotel_11',
      name: 'The Plaza Hotel',
      description: 'Legendary luxury hotel overlooking Central Park, offering timeless elegance and world-class service.',
      latitude: 40.7644,
      longitude: -73.9745,
      address: '768 5th Avenue',
      city: 'New York',
      country: 'United States',
      rating: 4.9,
      reviewCount: 3567,
      pricePerNight: 750,
      currency: '\$',
      photos: [
        'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800',
        'https://images.unsplash.com/photo-1578683010236-d716f9a3f461?w=800',
      ],
      facilities: _luxuryFacilities,
      rooms: _luxuryRooms,
      checkInTime: '15:00',
      checkOutTime: '12:00',
      isFeatured: true,
      policies: ['Luxury concierge service'],
    ),
    Hotel(
      id: 'hotel_12',
      name: 'Hilton Times Square',
      description: 'Modern hotel in the heart of Times Square with stunning city views.',
      latitude: 40.7580,
      longitude: -73.9855,
      address: '234 W 42nd Street',
      city: 'New York',
      country: 'United States',
      rating: 4.4,
      reviewCount: 2134,
      pricePerNight: 280,
      currency: '\$',
      photos: [
        'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=800',
      ],
      facilities: _premiumFacilities,
      rooms: _premiumRooms,
      checkInTime: '15:00',
      checkOutTime: '11:00',
      discountPercentage: 15,
      policies: ['Free cancellation up to 24 hours'],
    ),
    // Tokyo Hotels
    Hotel(
      id: 'hotel_13',
      name: 'Park Hyatt Tokyo',
      description: 'Sophisticated luxury hotel in Shinjuku, famous for panoramic views and exceptional service.',
      latitude: 35.6867,
      longitude: 139.6906,
      address: '3-7-1-2 Nishi Shinjuku',
      city: 'Tokyo',
      country: 'Japan',
      rating: 4.8,
      reviewCount: 2789,
      pricePerNight: 480,
      currency: '\$',
      photos: [
        'https://images.unsplash.com/photo-1578683010236-d716f9a3f461?w=800',
        'https://images.unsplash.com/photo-1564501049412-61c2a3083791?w=800',
      ],
      facilities: _luxuryFacilities,
      rooms: _luxuryRooms,
      checkInTime: '15:00',
      checkOutTime: '12:00',
      isFeatured: true,
      policies: ['Japanese hospitality'],
    ),
    // Dubai Hotels
    Hotel(
      id: 'hotel_14',
      name: 'Burj Al Arab',
      description: 'The worlds most luxurious hotel, featuring opulent suites and iconic sail-shaped architecture.',
      latitude: 25.1412,
      longitude: 55.1853,
      address: 'Jumeirah Beach Road',
      city: 'Dubai',
      country: 'United Arab Emirates',
      rating: 4.9,
      reviewCount: 4123,
      pricePerNight: 1500,
      currency: '\$',
      photos: [
        'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800',
        'https://images.unsplash.com/photo-1582719508461-905c673771fd?w=800',
      ],
      facilities: _luxuryFacilities,
      rooms: _luxuryRooms,
      checkInTime: '14:00',
      checkOutTime: '12:00',
      isFeatured: true,
      policies: ['Butler service', 'Private beach'],
    ),
    // Barcelona Hotels
    Hotel(
      id: 'hotel_15',
      name: 'Hotel Arts Barcelona',
      description: 'Beachfront luxury hotel with stunning Mediterranean views and contemporary design.',
      latitude: 41.3879,
      longitude: 2.1942,
      address: 'Carrer de la Marina 19-21',
      city: 'Barcelona',
      country: 'Spain',
      rating: 4.7,
      reviewCount: 2345,
      pricePerNight: 350,
      currency: '\$',
      photos: [
        'https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=800',
        'https://images.unsplash.com/photo-1590490360182-c33d57733427?w=800',
      ],
      facilities: _premiumFacilities,
      rooms: _premiumRooms,
      checkInTime: '15:00',
      checkOutTime: '12:00',
      discountPercentage: 10,
      policies: ['Beach access', 'Rooftop pool'],
    ),
    // Rome Hotels
    Hotel(
      id: 'hotel_16',
      name: 'Hotel Hassler Roma',
      description: 'Historic luxury hotel atop the Spanish Steps with panoramic views of Rome.',
      latitude: 41.9059,
      longitude: 12.4834,
      address: 'Piazza Trinità dei Monti 6',
      city: 'Rome',
      country: 'Italy',
      rating: 4.8,
      reviewCount: 1987,
      pricePerNight: 420,
      currency: '\$',
      photos: [
        'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=800',
      ],
      facilities: _luxuryFacilities,
      rooms: _luxuryRooms,
      checkInTime: '14:00',
      checkOutTime: '11:00',
      isFeatured: true,
      policies: ['Historic landmark'],
    ),
    // Sousse, Tunisia Hotels
    Hotel(
      id: 'hotel_17',
      name: 'Mövenpick Resort & Marine Spa Sousse',
      description: 'Luxurious beachfront resort with private beach, spa, and multiple pools. Experience Mediterranean hospitality at its finest.',
      latitude: 35.8288,
      longitude: 10.6405,
      address: 'Boulevard du 14 Janvier',
      city: 'Sousse',
      country: 'Tunisia',
      rating: 4.7,
      reviewCount: 1543,
      pricePerNight: 180,
      currency: '\$',
      photos: [
        'https://images.unsplash.com/photo-1571003123894-1f0594d2b5d9?w=800',
        'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?w=800',
      ],
      facilities: _luxuryFacilities,
      rooms: _luxuryRooms,
      checkInTime: '14:00',
      checkOutTime: '12:00',
      isFeatured: true,
      discountPercentage: 15,
      policies: ['Private beach', 'All-inclusive available'],
    ),
    Hotel(
      id: 'hotel_18',
      name: 'Sousse Pearl Marriott Resort & Spa',
      description: 'Elegant resort overlooking the Mediterranean Sea with world-class dining and spa facilities.',
      latitude: 35.8312,
      longitude: 10.6089,
      address: 'Avenue Hedi Chaker',
      city: 'Sousse',
      country: 'Tunisia',
      rating: 4.5,
      reviewCount: 987,
      pricePerNight: 145,
      currency: '\$',
      photos: [
        'https://images.unsplash.com/photo-1582719508461-905c673771fd?w=800',
        'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=800',
      ],
      facilities: _premiumFacilities,
      rooms: _premiumRooms,
      checkInTime: '15:00',
      checkOutTime: '11:00',
      discountPercentage: 20,
      policies: ['Beach access', 'Kids club'],
    ),
    Hotel(
      id: 'hotel_19',
      name: 'El Mouradi Palace',
      description: 'Traditional Tunisian palace hotel in the heart of Sousse Medina with authentic architecture.',
      latitude: 35.8256,
      longitude: 10.6380,
      address: 'Port El Kantaoui',
      city: 'Sousse',
      country: 'Tunisia',
      rating: 4.3,
      reviewCount: 756,
      pricePerNight: 95,
      currency: '\$',
      photos: [
        'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=800',
      ],
      facilities: _premiumFacilities,
      rooms: _standardRooms,
      checkInTime: '14:00',
      checkOutTime: '11:00',
      policies: ['Near Medina', 'Airport shuttle'],
    ),
    Hotel(
      id: 'hotel_20',
      name: 'Iberostar Diar El Andalous',
      description: 'Family-friendly all-inclusive resort with water park, animation team, and direct beach access.',
      latitude: 35.8945,
      longitude: 10.5234,
      address: 'Port El Kantaoui',
      city: 'Sousse',
      country: 'Tunisia',
      rating: 4.4,
      reviewCount: 1234,
      pricePerNight: 120,
      currency: '\$',
      photos: [
        'https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=800',
        'https://images.unsplash.com/photo-1590490360182-c33d57733427?w=800',
      ],
      facilities: _premiumFacilities,
      rooms: _standardRooms,
      checkInTime: '14:00',
      checkOutTime: '12:00',
      isFeatured: true,
      policies: ['All-inclusive', 'Water park', 'Kids activities'],
    ),
    // Tunis Hotels
    Hotel(
      id: 'hotel_21',
      name: 'The Residence Tunis',
      description: 'Ultra-luxury thalassotherapy resort with stunning sea views and world-renowned spa.',
      latitude: 36.8610,
      longitude: 10.3355,
      address: 'Les Côtes de Carthage',
      city: 'Tunis',
      country: 'Tunisia',
      rating: 4.8,
      reviewCount: 892,
      pricePerNight: 280,
      currency: '\$',
      photos: [
        'https://images.unsplash.com/photo-1578683010236-d716f9a3f461?w=800',
      ],
      facilities: _luxuryFacilities,
      rooms: _luxuryRooms,
      checkInTime: '15:00',
      checkOutTime: '12:00',
      isFeatured: true,
      policies: ['Thalassotherapy', 'Golf course nearby'],
    ),
    Hotel(
      id: 'hotel_22',
      name: 'Laico Tunis Hotel',
      description: 'Modern business hotel in the city center with conference facilities and rooftop restaurant.',
      latitude: 36.8028,
      longitude: 10.1797,
      address: 'Avenue Mohamed V',
      city: 'Tunis',
      country: 'Tunisia',
      rating: 4.2,
      reviewCount: 654,
      pricePerNight: 85,
      currency: '\$',
      photos: [
        'https://images.unsplash.com/photo-1618773928121-c32242e63f39?w=800',
      ],
      facilities: _standardFacilities,
      rooms: _standardRooms,
      checkInTime: '14:00',
      checkOutTime: '11:00',
      policies: ['City center', 'Business facilities'],
    ),
  ];

  static final List<HotelFacility> _luxuryFacilities = [
    const HotelFacility(name: 'Free WiFi', icon: Icons.wifi),
    const HotelFacility(name: 'Swimming Pool', icon: Icons.pool),
    const HotelFacility(name: 'Spa & Wellness', icon: Icons.spa),
    const HotelFacility(name: 'Fitness Center', icon: Icons.fitness_center),
    const HotelFacility(name: 'Restaurant', icon: Icons.restaurant),
    const HotelFacility(name: 'Room Service', icon: Icons.room_service),
    const HotelFacility(name: 'Concierge', icon: Icons.support_agent),
    const HotelFacility(name: 'Valet Parking', icon: Icons.local_parking),
    const HotelFacility(name: 'Bar & Lounge', icon: Icons.local_bar),
    const HotelFacility(name: 'Business Center', icon: Icons.business_center),
    const HotelFacility(name: 'Laundry', icon: Icons.local_laundry_service),
    const HotelFacility(name: 'Airport Shuttle', icon: Icons.airport_shuttle),
  ];

  static final List<HotelFacility> _premiumFacilities = [
    const HotelFacility(name: 'Free WiFi', icon: Icons.wifi),
    const HotelFacility(name: 'Fitness Center', icon: Icons.fitness_center),
    const HotelFacility(name: 'Restaurant', icon: Icons.restaurant),
    const HotelFacility(name: 'Room Service', icon: Icons.room_service),
    const HotelFacility(name: 'Parking', icon: Icons.local_parking),
    const HotelFacility(name: 'Bar', icon: Icons.local_bar),
    const HotelFacility(name: 'Business Center', icon: Icons.business_center),
    const HotelFacility(name: 'Laundry', icon: Icons.local_laundry_service),
  ];

  static final List<HotelFacility> _standardFacilities = [
    const HotelFacility(name: 'Free WiFi', icon: Icons.wifi),
    const HotelFacility(name: 'Restaurant', icon: Icons.restaurant),
    const HotelFacility(name: 'Parking', icon: Icons.local_parking),
    const HotelFacility(name: 'Air Conditioning', icon: Icons.ac_unit),
    const HotelFacility(name: 'Elevator', icon: Icons.elevator),
  ];

  static final List<HotelRoom> _luxuryRooms = [
    const HotelRoom(
      id: 'room_1',
      name: 'Deluxe Suite',
      description: 'Spacious suite with separate living area, king bed, and city views',
      pricePerNight: 450,
      maxGuests: 2,
      size: 55,
      amenities: ['King Bed', 'City View', 'Mini Bar', 'Bathtub', 'Smart TV', 'Nespresso Machine'],
      photos: ['https://images.unsplash.com/photo-1631049307264-da0ec9d70304?w=800'],
      availableRooms: 3,
    ),
    const HotelRoom(
      id: 'room_2',
      name: 'Executive Suite',
      description: 'Premium suite with panoramic views, workspace, and luxury amenities',
      pricePerNight: 650,
      maxGuests: 2,
      size: 75,
      amenities: ['King Bed', 'Panoramic View', 'Executive Lounge Access', 'Jacuzzi', 'Butler Service'],
      photos: ['https://images.unsplash.com/photo-1590490360182-c33d57733427?w=800'],
      availableRooms: 2,
    ),
    const HotelRoom(
      id: 'room_3',
      name: 'Presidential Suite',
      description: 'Ultimate luxury with multiple bedrooms, private terrace, and dedicated staff',
      pricePerNight: 1200,
      maxGuests: 4,
      size: 150,
      amenities: ['2 Bedrooms', 'Private Terrace', 'Dining Room', 'Kitchen', '24/7 Butler', 'Private Elevator'],
      photos: ['https://images.unsplash.com/photo-1578683010236-d716f9a3f461?w=800'],
      availableRooms: 1,
    ),
  ];

  static final List<HotelRoom> _premiumRooms = [
    const HotelRoom(
      id: 'room_4',
      name: 'Superior Room',
      description: 'Comfortable room with modern amenities and city views',
      pricePerNight: 250,
      maxGuests: 2,
      size: 32,
      amenities: ['Queen Bed', 'City View', 'Work Desk', 'Rain Shower'],
      photos: ['https://images.unsplash.com/photo-1616594039964-ae9021a400a0?w=800'],
      availableRooms: 8,
    ),
    const HotelRoom(
      id: 'room_5',
      name: 'Deluxe Room',
      description: 'Spacious room with premium bedding and enhanced amenities',
      pricePerNight: 350,
      maxGuests: 2,
      size: 42,
      amenities: ['King Bed', 'Garden View', 'Mini Bar', 'Bathtub', 'Smart TV'],
      photos: ['https://images.unsplash.com/photo-1591088398332-8a7791972843?w=800'],
      availableRooms: 5,
    ),
  ];

  static final List<HotelRoom> _standardRooms = [
    const HotelRoom(
      id: 'room_6',
      name: 'Standard Room',
      description: 'Cozy room with all essential amenities for a comfortable stay',
      pricePerNight: 95,
      maxGuests: 2,
      size: 22,
      amenities: ['Double Bed', 'WiFi', 'TV', 'Air Conditioning'],
      photos: ['https://images.unsplash.com/photo-1618773928121-c32242e63f39?w=800'],
      availableRooms: 12,
    ),
    const HotelRoom(
      id: 'room_7',
      name: 'Twin Room',
      description: 'Room with two single beds, perfect for friends traveling together',
      pricePerNight: 110,
      maxGuests: 2,
      size: 24,
      amenities: ['2 Single Beds', 'WiFi', 'TV', 'Shower'],
      photos: ['https://images.unsplash.com/photo-1590490360182-c33d57733427?w=800'],
      availableRooms: 6,
    ),
  ];

  Future<List<Hotel>> getHotels({String? city, String? sortBy}) async {
    await Future.delayed(const Duration(milliseconds: 800));
    
    List<Hotel> hotels = List.from(_mockHotels);
    
    if (city != null && city.isNotEmpty) {
      hotels = hotels.where((h) => 
        h.city.toLowerCase().contains(city.toLowerCase())
      ).toList();
    }
    
    switch (sortBy) {
      case 'price_low':
        hotels.sort((a, b) => a.discountedPrice.compareTo(b.discountedPrice));
        break;
      case 'price_high':
        hotels.sort((a, b) => b.discountedPrice.compareTo(a.discountedPrice));
        break;
      case 'rating':
        hotels.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'reviews':
        hotels.sort((a, b) => b.reviewCount.compareTo(a.reviewCount));
        break;
    }
    
    return hotels;
  }

  Future<Hotel?> getHotelById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      return _mockHotels.firstWhere((h) => h.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<List<Hotel>> getFeaturedHotels() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockHotels.where((h) => h.isFeatured).toList();
  }

  Future<List<Hotel>> searchHotels(String query) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final lowerQuery = query.toLowerCase().trim();
    
    if (lowerQuery.isEmpty) return _mockHotels;
    
    // First, try exact city match
    final exactCityMatch = _mockHotels.where((h) => 
      h.city.toLowerCase() == lowerQuery
    ).toList();
    
    if (exactCityMatch.isNotEmpty) return exactCityMatch;
    
    // Then try partial matches
    return _mockHotels.where((h) => 
      h.name.toLowerCase().contains(lowerQuery) ||
      h.city.toLowerCase().contains(lowerQuery) ||
      h.country.toLowerCase().contains(lowerQuery) ||
      h.address.toLowerCase().contains(lowerQuery)
    ).toList();
  }

  /// Search hotels by city name with fuzzy matching
  Future<List<Hotel>> searchHotelsByCity(String cityName, {String? sortBy}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    
    if (cityName.isEmpty) return getHotels(sortBy: sortBy);
    
    final lowerCity = cityName.toLowerCase().trim();
    
    // City name aliases for common variations
    final cityAliases = <String, List<String>>{
      'paris': ['paris'],
      'london': ['london'],
      'new york': ['new york', 'nyc', 'new york city'],
      'tokyo': ['tokyo'],
      'dubai': ['dubai'],
      'barcelona': ['barcelona'],
      'rome': ['rome', 'roma'],
      'sousse': ['sousse', 'susa', 'susah'],
      'tunis': ['tunis', 'tunisia'],
    };
    
    // Check if the input matches any alias
    String? matchedCity;
    for (final entry in cityAliases.entries) {
      if (entry.value.any((alias) => 
        lowerCity.contains(alias) || alias.contains(lowerCity)
      )) {
        matchedCity = entry.key;
        break;
      }
    }
    
    List<Hotel> hotels;
    if (matchedCity != null) {
      // Use the canonical city name for matching
      hotels = _mockHotels.where((h) => 
        h.city.toLowerCase() == matchedCity
      ).toList();
    } else {
      // Fallback to fuzzy matching
      hotels = _mockHotels.where((h) => 
        h.city.toLowerCase().contains(lowerCity) ||
        lowerCity.contains(h.city.toLowerCase())
      ).toList();
    }
    
    // Apply sorting
    switch (sortBy) {
      case 'price_low':
        hotels.sort((a, b) => a.discountedPrice.compareTo(b.discountedPrice));
        break;
      case 'price_high':
        hotels.sort((a, b) => b.discountedPrice.compareTo(a.discountedPrice));
        break;
      case 'rating':
        hotels.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'reviews':
        hotels.sort((a, b) => b.reviewCount.compareTo(a.reviewCount));
        break;
    }
    
    return hotels;
  }

  /// Get list of available cities
  List<String> getAvailableCities() {
    return _mockHotels
        .map((h) => h.city)
        .toSet()
        .toList()
      ..sort();
  }

  Future<HotelBooking> createBooking({
    required Hotel hotel,
    required HotelRoom room,
    required DateTime checkIn,
    required DateTime checkOut,
    required int guests,
    required int rooms,
    required GuestInfo guestInfo,
    required PaymentInfo paymentInfo,
  }) async {
    await Future.delayed(const Duration(seconds: 2));
    
    final nights = checkOut.difference(checkIn).inDays;
    final totalPrice = room.pricePerNight * nights * rooms;
    
    return HotelBooking(
      id: 'BK${DateTime.now().millisecondsSinceEpoch}',
      hotel: hotel,
      room: room,
      checkIn: checkIn,
      checkOut: checkOut,
      guests: guests,
      rooms: rooms,
      guestInfo: guestInfo,
      paymentInfo: paymentInfo,
      status: BookingStatus.confirmed,
      totalPrice: totalPrice,
      createdAt: DateTime.now(),
    );
  }
}

import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_models.dart';

class WhatsMarketApi {
  WhatsMarketApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const String _defaultBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8080',
  );

  Uri _uri(String path, [Map<String, String>? query]) =>
      Uri.parse('$_defaultBaseUrl$path').replace(queryParameters: query);

  Future<Map<String, dynamic>> register({
    required String name,
    required String phone,
    required String email,
    required String password,
    String role = 'customer',
  }) async {
    final response = await _client.post(
      _uri('/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'phone': phone,
        'email': email,
        'password': password,
        'role': role,
      }),
    );
    _throwIfError(response);
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> login({
    required String phone,
    required String password,
  }) async {
    final response = await _client.post(
      _uri('/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'phone': phone, 'password': password}),
    );
    _throwIfError(response);
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<List<Vendor>> getNearbyVendors({
    required double lat,
    required double lng,
    String type = '',
    double maxKm = 10,
  }) async {
    final response = await _client.get(
      _uri('/vendors/nearby', {
        'lat': '$lat',
        'lng': '$lng',
        'max_km': '$maxKm',
        if (type.isNotEmpty) 'type': type,
      }),
    );
    _throwIfError(response);
    final map = jsonDecode(response.body) as Map<String, dynamic>;
    final list = (map['results'] as List<dynamic>? ?? []);
    return list.map((e) => Vendor.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<Product>> getProducts({
    String category = '',
    String suburb = '',
    bool inStockOnly = false,
  }) async {
    final response = await _client.get(
      _uri('/products', {
        if (category.isNotEmpty && category != 'All') 'category': category,
        if (suburb.isNotEmpty) 'suburb': suburb,
        if (inStockOnly) 'in_stock': 'true',
      }),
    );
    _throwIfError(response);
    final list = jsonDecode(response.body) as List<dynamic>;
    return list.map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Map<String, dynamic>> compareProducts(String name) async {
    final response = await _client.get(_uri('/products/compare', {'name': name}));
    _throwIfError(response);
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  Future<Booking> createBooking({
    required String phone,
    required String vendorId,
    required String service,
    required String scheduledAt,
    String notes = '',
  }) async {
    final response = await _client.post(
      _uri('/bookings'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'phone': phone,
        'vendor_id': vendorId,
        'service': service,
        'scheduled_at': scheduledAt,
        'notes': notes,
      }),
    );
    _throwIfError(response);
    return Booking.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<List<Booking>> getBookings(String phone) async {
    final response = await _client.get(_uri('/bookings', {'phone': phone}));
    _throwIfError(response);
    final list = jsonDecode(response.body) as List<dynamic>;
    return list.map((e) => Booking.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> updateBookingStatus({
    required String bookingId,
    required String status,
  }) async {
    final response = await _client.patch(
      _uri('/bookings/status'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'booking_id': bookingId, 'status': status}),
    );
    _throwIfError(response);
  }

  Future<Map<String, dynamic>> getStats() async {
    final response = await _client.get(_uri('/stats'));
    _throwIfError(response);
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  void _throwIfError(http.Response response) {
    if (response.statusCode >= 400) {
      throw Exception('API error ${response.statusCode}: ${response.body}');
    }
  }
}

class Vendor {
  const Vendor({
    required this.id,
    required this.name,
    required this.type,
    required this.phone,
    required this.city,
    required this.suburb,
    required this.address,
    required this.lat,
    required this.lng,
    required this.verified,
    required this.rating,
    required this.badge,
  });

  final String id;
  final String name;
  final String type;
  final String phone;
  final String city;
  final String suburb;
  final String address;
  final double lat;
  final double lng;
  final bool verified;
  final double rating;
  final String badge;

  factory Vendor.fromJson(Map<String, dynamic> json) => Vendor(
        id: '${json['id'] ?? ''}',
        name: '${json['name'] ?? ''}',
        type: '${json['type'] ?? ''}',
        phone: '${json['phone'] ?? ''}',
        city: '${json['city'] ?? ''}',
        suburb: '${json['suburb'] ?? ''}',
        address: '${json['address'] ?? ''}',
        lat: (json['lat'] as num?)?.toDouble() ?? 0,
        lng: (json['lng'] as num?)?.toDouble() ?? 0,
        verified: json['verified'] == true,
        rating: (json['rating'] as num?)?.toDouble() ?? 0,
        badge: '${json['badge'] ?? ''}',
      );
}

class Product {
  const Product({
    required this.id,
    required this.vendorId,
    required this.name,
    required this.category,
    required this.price,
    required this.currency,
    required this.city,
    required this.suburb,
    required this.address,
    required this.lat,
    required this.lng,
    required this.inStock,
    required this.direction,
  });

  final String id;
  final String vendorId;
  final String name;
  final String category;
  final double price;
  final String currency;
  final String city;
  final String suburb;
  final String address;
  final double lat;
  final double lng;
  final bool inStock;
  final String direction;

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: '${json['id'] ?? ''}',
        vendorId: '${json['vendor_id'] ?? ''}',
        name: '${json['name'] ?? ''}',
        category: '${json['category'] ?? ''}',
        price: (json['price'] as num?)?.toDouble() ?? 0,
        currency: '${json['currency'] ?? 'USD'}',
        city: '${json['city'] ?? ''}',
        suburb: '${json['suburb'] ?? ''}',
        address: '${json['address'] ?? ''}',
        lat: (json['lat'] as num?)?.toDouble() ?? 0,
        lng: (json['lng'] as num?)?.toDouble() ?? 0,
        inStock: json['in_stock'] == true,
        direction: '${json['direction'] ?? ''}',
      );
}

class Booking {
  const Booking({
    required this.id,
    required this.userPhone,
    required this.vendorId,
    required this.service,
    required this.status,
    required this.scheduledAt,
    required this.notes,
  });

  final String id;
  final String userPhone;
  final String vendorId;
  final String service;
  final String status;
  final String scheduledAt;
  final String notes;

  factory Booking.fromJson(Map<String, dynamic> json) => Booking(
        id: '${json['id'] ?? ''}',
        userPhone: '${json['user_phone'] ?? ''}',
        vendorId: '${json['vendor_id'] ?? ''}',
        service: '${json['service'] ?? ''}',
        status: '${json['status'] ?? ''}',
        scheduledAt: '${json['scheduled_at'] ?? ''}',
        notes: '${json['notes'] ?? ''}',
      );
}


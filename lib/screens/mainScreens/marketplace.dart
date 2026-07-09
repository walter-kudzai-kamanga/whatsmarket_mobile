import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mutswe/screens/mainScreens/home.dart';
import 'package:mutswe/screens/rest/comparePage.dart';

// Theme Colors
const Color _primaryGreen = Color(0xFF2E7D32);
const Color _beigeLight = Color(0xFFFDFBF7);

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String currency;
  final String category;
  final String vendorId;
  final String vendorName;
  final String vendorPhone;
  final String vendorEmail;
  final String vendorAddress;
  final double vendorLat;
  final double vendorLng;
  final double rating;
  final int reviews;
  final bool inStock;
  final String imageUrl;
  final List<String> images;
  final String condition; // New, Like New, Used, Refurbished
  final String deliveryTime;
  final String warranty;
  final List<String> specifications;
  final String paymentMethods;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.currency,
    required this.category,
    required this.vendorId,
    required this.vendorName,
    required this.vendorPhone,
    required this.vendorEmail,
    required this.vendorAddress,
    required this.vendorLat,
    required this.vendorLng,
    required this.rating,
    required this.reviews,
    required this.inStock,
    required this.imageUrl,
    required this.images,
    required this.condition,
    required this.deliveryTime,
    required this.warranty,
    required this.specifications,
    required this.paymentMethods,
  });
}

// Sample products data
final List<Product> _sampleProducts = [
  Product(
    id: '1',
    name: 'PVC Pipe 20mm x 3m',
    description:
        'High-quality PVC pipe for plumbing applications. Durable, rust-proof, and easy to install. Perfect for residential and commercial plumbing projects.',
    price: 3.50,
    currency: 'USD',
    category: 'Hardware',
    vendorId: 'v1',
    vendorName: 'Moyo Plumbing',
    vendorPhone: '+263 700 000 001',
    vendorEmail: 'info@moyoplumbing.co.zw',
    vendorAddress: '12 Samora Machel Avenue, Avondale, Harare',
    vendorLat: -17.793,
    vendorLng: 31.049,
    rating: 4.8,
    reviews: 127,
    inStock: true,
    imageUrl: '',
    images: [],
    condition: 'New',
    deliveryTime: '2-3 days',
    warranty: '6 months',
    specifications: [
      'Material: PVC',
      'Length: 3m',
      'Diameter: 20mm',
      'Color: White',
      'Weight: 2.5kg',
    ],
    paymentMethods: 'Cash, EcoCash, Bank Transfer',
  ),
  Product(
    id: '2',
    name: 'LED Bulb 9W - Pack of 4',
    description:
        'Energy-efficient LED bulbs with warm white light. Save up to 80% on electricity bills. Long-lasting with 25,000 hours lifespan.',
    price: 8.00,
    currency: 'USD',
    category: 'Electrical',
    vendorId: 'v2',
    vendorName: 'Bright Spark Electric',
    vendorPhone: '+263 700 000 002',
    vendorEmail: 'info@brightspark.co.zw',
    vendorAddress: '8 Churchill Avenue, Belvedere, Harare',
    vendorLat: -17.806,
    vendorLng: 31.032,
    rating: 4.9,
    reviews: 156,
    inStock: true,
    imageUrl: '',
    images: [],
    condition: 'New',
    deliveryTime: '1-2 days',
    warranty: '2 years',
    specifications: [
      'Power: 9W',
      'Color: Warm White',
      'Base: E27',
      'Lifespan: 25,000 hours',
      'Pack: 4 bulbs',
    ],
    paymentMethods: 'Cash, EcoCash, ZIPIT, Bank Transfer',
  ),
  Product(
    id: '3',
    name: 'Hair Treatment Kit - Premium',
    description:
        'Complete hair treatment kit with shampoo, conditioner, and deep conditioning mask. Perfect for damaged and color-treated hair.',
    price: 15.00,
    currency: 'USD',
    category: 'Beauty',
    vendorId: 'v3',
    vendorName: 'Style Salon',
    vendorPhone: '+263 700 000 003',
    vendorEmail: 'info@stylesalon.co.zw',
    vendorAddress: '89 Borrowdale Road, Borrowdale, Harare',
    vendorLat: -17.790,
    vendorLng: 31.050,
    rating: 4.6,
    reviews: 234,
    inStock: true,
    imageUrl: '',
    images: [],
    condition: 'New',
    deliveryTime: '2-4 days',
    warranty: 'No warranty',
    specifications: [
      'Kit includes: Shampoo 250ml',
      'Conditioner 250ml',
      'Mask 200ml',
      'For: All hair types',
    ],
    paymentMethods: 'Cash, EcoCash, Bank Transfer',
  ),
  Product(
    id: '4',
    name: 'LED Bulb 12W - Pack of 2',
    description:
        'Bright daylight LED bulbs for maximum illumination. Perfect for outdoor and high-ceiling applications.',
    price: 6.00,
    currency: 'USD',
    category: 'Electrical',
    vendorId: 'v2',
    vendorName: 'Bright Spark Electric',
    vendorPhone: '+263 700 000 002',
    vendorEmail: 'info@brightspark.co.zw',
    vendorAddress: '8 Churchill Avenue, Belvedere, Harare',
    vendorLat: -17.806,
    vendorLng: 31.032,
    rating: 4.7,
    reviews: 89,
    inStock: true,
    imageUrl: '',
    images: [],
    condition: 'New',
    deliveryTime: '1-2 days',
    warranty: '2 years',
    specifications: [
      'Power: 12W',
      'Color: Daylight',
      'Base: E27',
      'Lifespan: 20,000 hours',
    ],
    paymentMethods: 'Cash, EcoCash, ZIPIT',
  ),
  Product(
    id: '5',
    name: 'Plumbing Tool Kit - 15 Piece',
    description:
        'Complete plumbing tool kit with essential tools for every plumber. Includes wrenches, pliers, cutters, and more.',
    price: 45.00,
    currency: 'USD',
    category: 'Hardware',
    vendorId: 'v1',
    vendorName: 'Moyo Plumbing',
    vendorPhone: '+263 700 000 001',
    vendorEmail: 'info@moyoplumbing.co.zw',
    vendorAddress: '12 Samora Machel Avenue, Avondale, Harare',
    vendorLat: -17.793,
    vendorLng: 31.049,
    rating: 4.5,
    reviews: 72,
    inStock: false,
    imageUrl: '',
    images: [],
    condition: 'Like New',
    deliveryTime: '3-5 days',
    warranty: '3 months',
    specifications: [
      '15 pieces',
      'Includes: Wrenches, Pliers, Cutters',
      'Heavy-duty case',
      'Suitable for: Professional use',
    ],
    paymentMethods: 'Cash, EcoCash, Bank Transfer',
  ),
  Product(
    id: '6',
    name: 'Digital Thermometer - Medical Grade',
    description:
        'Accurate digital thermometer for quick and precise temperature readings. Suitable for adults and children.',
    price: 12.50,
    currency: 'USD',
    category: 'Medical',
    vendorId: 'v4',
    vendorName: 'Health Clinic',
    vendorPhone: '+263 700 000 004',
    vendorEmail: 'info@healthclinic.co.zw',
    vendorAddress: '56 Chiremba Road, Highlands, Harare',
    vendorLat: -17.816,
    vendorLng: 31.045,
    rating: 4.9,
    reviews: 203,
    inStock: true,
    imageUrl: '',
    images: [],
    condition: 'New',
    deliveryTime: '1-2 days',
    warranty: '12 months',
    specifications: [
      'Accuracy: ±0.1°C',
      'Range: 32-43°C',
      'Battery: Included',
      'Water-resistant',
    ],
    paymentMethods: 'Cash, EcoCash, Bank Transfer',
  ),
  Product(
    id: '7',
    name: 'Hair Dryer - Professional 2000W',
    description:
        'Professional hair dryer with multiple heat and speed settings. Ionic technology for frizz-free styling.',
    price: 35.00,
    currency: 'USD',
    category: 'Beauty',
    vendorId: 'v3',
    vendorName: 'Style Salon',
    vendorPhone: '+263 700 000 003',
    vendorEmail: 'info@stylesalon.co.zw',
    vendorAddress: '89 Borrowdale Road, Borrowdale, Harare',
    vendorLat: -17.790,
    vendorLng: 31.050,
    rating: 4.8,
    reviews: 156,
    inStock: true,
    imageUrl: '',
    images: [],
    condition: 'Like New',
    deliveryTime: '2-3 days',
    warranty: '12 months',
    specifications: [
      'Power: 2000W',
      '3 heat settings',
      '2 speed settings',
      'Ionic technology',
      'Includes: Diffuser',
    ],
    paymentMethods: 'Cash, EcoCash, Bank Transfer',
  ),
  Product(
    id: '8',
    name: 'Blood Pressure Monitor - Digital',
    description:
        'Digital blood pressure monitor for home use. Easy to use with large display and memory storage.',
    price: 28.00,
    currency: 'USD',
    category: 'Medical',
    vendorId: 'v4',
    vendorName: 'Health Clinic',
    vendorPhone: '+263 700 000 004',
    vendorEmail: 'info@healthclinic.co.zw',
    vendorAddress: '56 Chiremba Road, Highlands, Harare',
    vendorLat: -17.816,
    vendorLng: 31.045,
    rating: 4.7,
    reviews: 134,
    inStock: true,
    imageUrl: '',
    images: [],
    condition: 'New',
    deliveryTime: '1-2 days',
    warranty: '24 months',
    specifications: [
      'Range: 30-280 mmHg',
      'Memory: 120 readings',
      'Size: Medium',
      'Includes: Carrying case',
    ],
    paymentMethods: 'Cash, EcoCash, Bank Transfer, ZIPIT',
  ),
  Product(
    id: '9',
    name: 'Used PVC Pipe 25mm x 2m',
    description:
        'Good quality used PVC pipe. Perfect for non-critical plumbing applications or budget projects.',
    price: 1.50,
    currency: 'USD',
    category: 'Hardware',
    vendorId: 'v1',
    vendorName: 'Moyo Plumbing',
    vendorPhone: '+263 700 000 001',
    vendorEmail: 'info@moyoplumbing.co.zw',
    vendorAddress: '12 Samora Machel Avenue, Avondale, Harare',
    vendorLat: -17.793,
    vendorLng: 31.049,
    rating: 4.2,
    reviews: 45,
    inStock: true,
    imageUrl: '',
    images: [],
    condition: 'Used',
    deliveryTime: '3-5 days',
    warranty: 'No warranty',
    specifications: [
      'Length: 2m',
      'Diameter: 25mm',
      'Material: PVC',
      'Condition: Used but functional',
    ],
    paymentMethods: 'Cash, EcoCash',
  ),
  Product(
    id: '10',
    name: 'First Aid Kit - Complete Set',
    description:
        'Comprehensive first aid kit for home, office, or travel. Contains all essential medical supplies.',
    price: 20.00,
    currency: 'USD',
    category: 'Medical',
    vendorId: 'v4',
    vendorName: 'Health Clinic',
    vendorPhone: '+263 700 000 004',
    vendorEmail: 'info@healthclinic.co.zw',
    vendorAddress: '56 Chiremba Road, Highlands, Harare',
    vendorLat: -17.816,
    vendorLng: 31.045,
    rating: 4.9,
    reviews: 178,
    inStock: true,
    imageUrl: '',
    images: [],
    condition: 'New',
    deliveryTime: '1-2 days',
    warranty: '6 months',
    specifications: [
      '100+ pieces',
      'Contains: Bandages, Plasters, Antiseptics',
      'Premium case',
      'Suitable for: Home, Travel, Office',
    ],
    paymentMethods: 'Cash, EcoCash, Bank Transfer, ZIPIT',
  ),
];

// Compare Product Model
class CompareProduct {
  final Product product;
  final double distance;
  final String condition;
  final double price;
  final double rating;
  final int reviews;
  final bool inStock;
  final String deliveryTime;

  CompareProduct({
    required this.product,
    required this.distance,
    required this.condition,
    required this.price,
    required this.rating,
    required this.reviews,
    required this.inStock,
    required this.deliveryTime,
  });

  Map<String, dynamic> toJson() => {
    'product': product.name,
    'distance': distance,
    'condition': condition,
    'price': price,
    'rating': rating,
    'reviews': reviews,
    'inStock': inStock,
    'deliveryTime': deliveryTime,
  };
}

class MarketplacePage extends StatefulWidget {
  const MarketplacePage({super.key});

  @override
  State<MarketplacePage> createState() => _MarketplacePageState();
}

class _MarketplacePageState extends State<MarketplacePage> {
  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  String _searchQuery = '';
  String _selectedCategory = 'All';
  bool _isLoading = true;
  Position? _userPosition;
  final Set<String> _compareList = {};

  final List<String> _categories = [
    'All',
    'Hardware',
    'Electrical',
    'Beauty',
    'Medical',
  ];

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _getUserLocation();
  }

  void _loadProducts() {
    setState(() {
      _products = _sampleProducts;
      _filteredProducts = _products;
      _isLoading = false;
    });
  }

  Future<bool> _ensureLocationPermission() async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      final requested = await Geolocator.requestPermission();
      return requested == LocationPermission.whileInUse ||
          requested == LocationPermission.always;
    }

    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  Future<void> _getUserLocation() async {
    try {
      final hasPermission = await _ensureLocationPermission();
      if (!hasPermission) {
        if (!mounted) return;
        return;
      }

      if (!mounted) return;

      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (!mounted) return;

      setState(() {
        _userPosition = position;
      });
    } catch (error) {
      if (!mounted) return;
      debugPrint('Location lookup failed: $error');
    }
  }

  void _filterProducts() {
    setState(() {
      _filteredProducts = _products.where((product) {
        final matchesSearch =
            _searchQuery.isEmpty ||
            product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            product.description.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ) ||
            product.vendorName.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            );

        final matchesCategory =
            _selectedCategory == 'All' || product.category == _selectedCategory;

        return matchesSearch && matchesCategory;
      }).toList();
    });
  }

  void _toggleCompare(String productId) {
    setState(() {
      if (_compareList.contains(productId)) {
        _compareList.remove(productId);
      } else {
        if (_compareList.length < 4) {
          _compareList.add(productId);
        } else {
          _showSnackBar('You can compare up to 4 products');
        }
      }
    });
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: _primaryGreen),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: _beigeLight,
      appBar: CupertinoNavigationBar(
        backgroundColor: _primaryGreen,
        middle: const Text(
          'Marketplace',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_compareList.isNotEmpty)
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () {
                  _navigateToCompare();
                },
                child: Stack(
                  children: [
                    const Icon(
                      CupertinoIcons.square_grid_2x2,
                      color: Colors.white,
                      size: 24,
                    ),
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.amber,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${_compareList.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search products...',
                  prefixIcon: const Icon(
                    CupertinoIcons.search,
                    color: Colors.grey,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(CupertinoIcons.clear, size: 18),
                          onPressed: () {
                            setState(() {
                              _searchQuery = '';
                              _filterProducts();
                            });
                          },
                        )
                      : null,
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                    _filterProducts();
                  });
                },
              ),
            ),
          ),

          // Category filter
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(
                      category,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                        _filterProducts();
                      });
                    },
                    backgroundColor: Colors.white,
                    selectedColor: _primaryGreen.withOpacity(0.1),
                    side: BorderSide(
                      color: isSelected ? _primaryGreen : Colors.grey.shade300,
                      width: isSelected ? 1.5 : 0.5,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 6,
                    ),
                    shape: const StadiumBorder(),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 8),

          // Product count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_filteredProducts.length} products found',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
                if (_compareList.isNotEmpty)
                  Text(
                    '${_compareList.length} selected for compare',
                    style: TextStyle(
                      fontSize: 13,
                      color: _primaryGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Product grid
          Expanded(
            child: _filteredProducts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          CupertinoIcons.search_circle,
                          size: 80,
                          color: Colors.grey[300],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No products found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Try adjusting your search or filters',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(12),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.75,
                        ),
                    itemCount: _filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = _filteredProducts[index];
                      final isInCompare = _compareList.contains(product.id);
                      return _buildProductCard(product, isInCompare);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Product product, bool isInCompare) {
    return GestureDetector(
      onTap: () {
        _navigateToProductDetails(product);
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isInCompare ? _primaryGreen : Colors.grey.shade200,
            width: isInCompare ? 2 : 0.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image placeholder
            Container(
              height: 100,
              width: double.infinity,
              decoration: BoxDecoration(
                color: _primaryGreen.withOpacity(0.05),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      _getCategoryIcon(product.category),
                      size: 40,
                      color: _primaryGreen.withOpacity(0.3),
                    ),
                  ),
                  // Stock badge
                  if (!product.inStock)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Out of Stock',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  // Compare checkbox
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () {
                        _toggleCompare(product.id);
                      },
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: isInCompare ? _primaryGreen : Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isInCompare
                                ? _primaryGreen
                                : Colors.grey.shade300,
                          ),
                        ),
                        child: Icon(
                          isInCompare
                              ? CupertinoIcons.checkmark
                              : CupertinoIcons.square,
                          color: isInCompare
                              ? Colors.white
                              : Colors.grey.shade400,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product name
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Vendor name
                  Text(
                    product.vendorName,
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Rating and condition
                  Row(
                    children: [
                      const Icon(
                        CupertinoIcons.star_fill,
                        color: Colors.amber,
                        size: 12,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        product.rating.toString(),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${product.reviews})',
                        style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getConditionColor(
                            product.condition,
                          ).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          product.condition,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: _getConditionColor(product.condition),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Price and add to compare
                  Row(
                    children: [
                      Text(
                        '${product.currency} ${product.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: _primaryGreen,
                        ),
                      ),
                      const Spacer(),
                      if (product.inStock)
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            _navigateToProductDetails(product);
                          },
                          child: const Icon(
                            CupertinoIcons.forward,
                            color: _primaryGreen,
                            size: 20,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Hardware':
        return CupertinoIcons.hammer;
      case 'Electrical':
        return CupertinoIcons.bolt;
      case 'Beauty':
        return CupertinoIcons.sparkles;
      case 'Medical':
        return CupertinoIcons.heart;
      default:
        return CupertinoIcons.cube_box;
    }
  }

  Color _getConditionColor(String condition) {
    switch (condition) {
      case 'New':
        return _primaryGreen;
      case 'Like New':
        return Colors.blue;
      case 'Used':
        return Colors.orange;
      case 'Refurbished':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  void _navigateToProductDetails(Product product) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => ProductDetailsPage(
          productName: '',
          // product: product,
          // userPosition: _userPosition,
          // /hasLocationPermission: _hasLocationPermission,
        ),
      ),
    );
  }

  void _navigateToCompare() {
    final productsToCompare = _products
        .where((p) => _compareList.contains(p.id))
        .toList();

    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => ComparePage(
          products: productsToCompare,
          userPosition: _userPosition,
        ),
      ),
    );
  }
}

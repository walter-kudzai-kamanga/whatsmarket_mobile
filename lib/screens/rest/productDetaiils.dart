import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mhj_maps/mhj_maps.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mutswe/screens/mainScreens/marketplace.dart';
import 'package:url_launcher/url_launcher.dart';

const Color _primaryGreen = Color(0xFF2E7D32);
const Color _primaryLightGreen = Color(0xFF4CAF50);
const Color _secondaryBeige = Color(0xFFF5F0E8);
const Color _beigeDark = Color(0xFFE8DCC8);
const Color _beigeLight = Color(0xFFFDFBF7);

class ProductDetailsPage extends StatefulWidget {
  final Product product;
  final Position? userPosition;
  final bool hasLocationPermission;

  const ProductDetailsPage({
    super.key,
    required this.product,
    this.userPosition,
    required this.hasLocationPermission,
  });

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  late MhjMapsMapController _mapController;
  bool _showDirections = false;
  double _distance = 0;
  String _selectedTab = 'Details';

  @override
  void initState() {
    super.initState();
    _calculateDistance();
  }

  void _calculateDistance() {
    if (widget.userPosition != null && widget.hasLocationPermission) {
      _distance = _calculateDistanceBetween(
        widget.userPosition!.latitude,
        widget.userPosition!.longitude,
        widget.product.vendorLat,
        widget.product.vendorLng,
      );
    }
  }

  double _calculateDistanceBetween(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double R = 6371;
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    final a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRadians(lat1)) *
            math.cos(_toRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return R * c;
  }

  double _toRadians(double degree) => degree * 3.141592653589793 / 180;

  void _handleMapCreated(MhjMapsMapController controller) {
    _mapController = controller;
    _addMarker();

    if (widget.userPosition != null && widget.hasLocationPermission) {
      // Show route from user to seller
      // _mapController.addPolyline(
      //   points: [
      //     MhjMapsLatLng(
      //       lat: widget.userPosition!.latitude,
      //       lng: widget.userPosition!.longitude,
      //     ),
      //     MhjMapsLatLng(
      //       lat: widget.product.vendorLat,
      //       lng: widget.product.vendorLng,
      //     ),
      //   ],
      //   color: _primaryGreen,
      //   width: 3,
      // );
    }
  }

  void _addMarker() {
    _mapController.addCustomMarker(
      position: MhjMapsLatLng(
        lat: widget.product.vendorLat,
        lng: widget.product.vendorLng,
      ),
      width: 50,
      height: 50,
      child: Container(
        decoration: BoxDecoration(
          color: _primaryGreen,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: _primaryGreen.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: const Icon(
          CupertinoIcons.shopping_cart,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }

  void _openGoogleMaps() async {
    final url =
        'https://www.google.com/maps/dir/?api=1&destination=${widget.product.vendorLat},${widget.product.vendorLng}';
    if (await canLaunch(url)) {
      await launch(url);
    }
  }

  void _makePhoneCall() async {
    final url = 'tel:${widget.product.vendorPhone.replaceAll(' ', '')}';
    if (await canLaunch(url)) {
      await launch(url);
    }
  }

  void _sendEmail() async {
    final url =
        'mailto:${widget.product.vendorEmail}?subject=Product Inquiry: ${widget.product.name}';
    if (await canLaunch(url)) {
      await launch(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CupertinoNavigationBar(
        backgroundColor: _primaryGreen,
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.pop(context),
          child: const Icon(CupertinoIcons.back, color: Colors.white),
        ),
        middle: const Text(
          'Product Details',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: _openGoogleMaps,
              child: const Icon(
                CupertinoIcons.map,
                color: Colors.white,
                size: 24,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Map section - top half
          Expanded(
            flex: 1,
            child: Stack(
              children: [
                MhjMapsMap(
                  center: MhjMapsLatLng(
                    lat: widget.product.vendorLat,
                    lng: widget.product.vendorLng,
                  ),
                  zoom: 15,
                  theme: MhjMapsMapThemes.standard,
                  showAttribution: true,
                  showCompass: false,
                  showScale: false,
                  showZoomControls: false,
                  onMapCreated: _handleMapCreated,
                ),
                // Distance overlay
                if (widget.hasLocationPermission && widget.userPosition != null)
                  Positioned(
                    top: 60,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            CupertinoIcons.location_solid,
                            color: _primaryGreen,
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${_distance.toStringAsFixed(1)} km away',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                // Get directions button
                Positioned(
                  bottom: 20,
                  left: 20,
                  right: 20,
                  child: CupertinoButton(
                    color: _primaryGreen,
                    borderRadius: BorderRadius.circular(12),
                    onPressed: _openGoogleMaps,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          CupertinoIcons.refresh,
                          color: Colors.white,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Get Directions',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom section - product details
          Container(
            height: 4,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.white.withOpacity(0.3),
                  Colors.white,
                ],
              ),
            ),
          ),

          Expanded(
            flex: 1,
            child: Container(
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tabs
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        _buildTab('Details', _selectedTab == 'Details'),
                        _buildTab('Vendor', _selectedTab == 'Vendor'),
                        _buildTab('Specs', _selectedTab == 'Specs'),
                      ],
                    ),
                  ),
                  const Divider(height: 1),

                  // Tab content
                  Expanded(
                    child: _selectedTab == 'Details'
                        ? _buildDetailsTab()
                        : _selectedTab == 'Vendor'
                        ? _buildVendorTab()
                        : _buildSpecsTab(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String title, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTab = title;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? _primaryGreen : Colors.transparent,
              width: 3,
            ),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? _primaryGreen : Colors.grey[600],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsTab() {
    final product = widget.product;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product name and price
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${product.currency} ${product.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: _primaryGreen,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
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
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _getConditionColor(product.condition),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Rating
          Row(
            children: [
              const Icon(
                CupertinoIcons.star_fill,
                color: Colors.amber,
                size: 18,
              ),
              const SizedBox(width: 4),
              Text(
                product.rating.toString(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '(${product.reviews} reviews)',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: product.inStock
                      ? Colors.green.shade50
                      : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  product.inStock ? 'In Stock' : 'Out of Stock',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: product.inStock
                        ? Colors.green.shade700
                        : Colors.red.shade700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Description
          const Text(
            'Description',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            product.description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),

          // Quick info
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _beigeLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _beigeDark),
            ),
            child: Column(
              children: [
                _buildInfoRow('Delivery Time', product.deliveryTime),
                _buildInfoRow('Warranty', product.warranty),
                _buildInfoRow('Payment Methods', product.paymentMethods),
                _buildInfoRow('Category', product.category),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
              color: Colors.black87,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 13, color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVendorTab() {
    final product = widget.product;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _beigeLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _beigeDark),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: _primaryGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        CupertinoIcons.home,
                        color: _primaryGreen,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.vendorName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(
                                CupertinoIcons.star_fill,
                                color: Colors.amber,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${product.rating} (${product.reviews} reviews)',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 12),
                _buildContactInfo(
                  CupertinoIcons.location_solid,
                  product.vendorAddress,
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _makePhoneCall,
                  child: _buildContactInfo(
                    CupertinoIcons.phone,
                    product.vendorPhone,
                    isClickable: true,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _sendEmail,
                  child: _buildContactInfo(
                    CupertinoIcons.mail,
                    product.vendorEmail,
                    isClickable: true,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: CupertinoButton(
                        color: _primaryGreen,
                        borderRadius: BorderRadius.circular(10),
                        onPressed: _makePhoneCall,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              CupertinoIcons.phone,
                              color: Colors.white,
                              size: 18,
                            ),
                            SizedBox(width: 8),
                            Text('Call', style: TextStyle(color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CupertinoButton(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(10),
                        onPressed: _sendEmail,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              CupertinoIcons.mail,
                              color: Colors.white,
                              size: 18,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Email',
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfo(
    IconData icon,
    String text, {
    bool isClickable = false,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: isClickable ? _primaryGreen : Colors.grey[600],
          size: 18,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: isClickable ? _primaryGreen : Colors.grey[700],
              decoration: isClickable
                  ? TextDecoration.underline
                  : TextDecoration.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSpecsTab() {
    final product = widget.product;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Specifications',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: product.specifications.length,
            itemBuilder: (context, index) {
              final spec = product.specifications[index];
              return Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 12,
                ),
                margin: const EdgeInsets.only(bottom: 6),
                decoration: BoxDecoration(
                  color: _beigeLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: _beigeDark),
                ),
                child: Row(
                  children: [
                    Icon(
                      CupertinoIcons.checkmark_circle_fill,
                      color: _primaryGreen,
                      size: 16,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      spec,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _primaryGreen.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _primaryGreen.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Payment Options',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 6),
                Text(
                  product.paymentMethods,
                  style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
}

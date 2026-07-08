import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mutswe/screens/mainScreens/marketplace.dart';

const Color _primaryGreen = Color(0xFF2E7D32);
const Color _primaryLightGreen = Color(0xFF4CAF50);
const Color _secondaryBeige = Color(0xFFF5F0E8);
const Color _beigeDark = Color(0xFFE8DCC8);
const Color _beigeLight = Color(0xFFFDFBF7);

class ComparePage extends StatefulWidget {
  final List<Product> products;
  final Position? userPosition;

  const ComparePage({super.key, required this.products, this.userPosition});

  @override
  State<ComparePage> createState() => _ComparePageState();
}

class _ComparePageState extends State<ComparePage> {
  final List<String> _comparisonFields = [
    'Product',
    'Price',
    'Condition',
    'Rating',
    'Reviews',
    'In Stock',
    'Vendor',
    'Delivery',
    'Distance',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _beigeLight,
      appBar: CupertinoNavigationBar(
        backgroundColor: _primaryGreen,
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.pop(context),
          child: const Icon(CupertinoIcons.back, color: Colors.white),
        ),
        middle: const Text(
          'Compare Products',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            // Share comparison
            _shareComparison();
          },
          child: const Icon(
            CupertinoIcons.share,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
      body: widget.products.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    CupertinoIcons.square_grid_2x2,
                    size: 80,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No products to compare',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add products by tapping the compare icon',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Header row
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeaderCell('Features'),
                        ...widget.products.map(
                          (product) =>
                              _buildHeaderCell(product.name, isProduct: true),
                        ),
                      ],
                    ),
                    // Comparison rows
                    ..._comparisonFields.map(
                      (field) => _buildComparisonRow(field),
                    ),

                    // Best value indicator
                    Container(
                      margin: const EdgeInsets.only(top: 20),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _primaryGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _primaryGreen.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            CupertinoIcons.app_badge,
                            color: Colors.amber,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Best Value: ${_findBestValue()}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildHeaderCell(String text, {bool isProduct = false}) {
    return Container(
      width: isProduct ? 120 : 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isProduct ? _primaryGreen : Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: isProduct ? 12 : 13,
          color: isProduct ? Colors.white : Colors.black87,
        ),
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildComparisonRow(String field) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Container(
            width: 100,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                bottomLeft: Radius.circular(8),
              ),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Text(
              field,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: Colors.black87,
              ),
            ),
          ),
          ...widget.products.map((product) {
            final value = _getComparisonValue(product, field);
            return Container(
              width: 120,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _isBestValue(product, field)
                    ? _primaryGreen.withOpacity(0.05)
                    : Colors.white,
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: _buildComparisonValue(value, field),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildComparisonValue(dynamic value, String field) {
    if (value == null) {
      return const SizedBox();
    }

    if (field == 'In Stock') {
      return Icon(
        value
            ? CupertinoIcons.checkmark_circle_fill
            : CupertinoIcons.xmark_circle_fill,
        color: value ? _primaryGreen : Colors.red,
        size: 20,
      );
    }

    if (field == 'Rating') {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(CupertinoIcons.star_fill, color: Colors.amber, size: 14),
          const SizedBox(width: 4),
          Text(
            value.toString(),
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ],
      );
    }

    if (field == 'Price') {
      return Text(
        value.toString(),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: _isBestValueForPrice(value) ? Colors.green : Colors.black,
        ),
        textAlign: TextAlign.center,
      );
    }

    return Text(
      value.toString(),
      style: const TextStyle(fontSize: 12, color: Colors.black87),
      textAlign: TextAlign.center,
    );
  }

  dynamic _getComparisonValue(Product product, String field) {
    switch (field) {
      case 'Product':
        return product.name;
      case 'Price':
        return '${product.currency} ${product.price.toStringAsFixed(2)}';
      case 'Condition':
        return product.condition;
      case 'Rating':
        return product.rating;
      case 'Reviews':
        return product.reviews;
      case 'In Stock':
        return product.inStock;
      case 'Vendor':
        return product.vendorName;
      case 'Delivery':
        return product.deliveryTime;
      case 'Distance':
        if (widget.userPosition != null) {
          final distance = _calculateDistance(
            widget.userPosition!.latitude,
            widget.userPosition!.longitude,
            product.vendorLat,
            product.vendorLng,
          );
          return '${distance.toStringAsFixed(1)} km';
        }
        return 'N/A';
      default:
        return null;
    }
  }

  bool _isBestValue(Product product, String field) {
    if (field == 'Price') {
      final minPrice = widget.products
          .map((p) => p.price)
          .reduce((a, b) => a < b ? a : b);
      return product.price == minPrice;
    }
    if (field == 'Rating') {
      final maxRating = widget.products
          .map((p) => p.rating)
          .reduce((a, b) => a > b ? a : b);
      return product.rating == maxRating;
    }
    if (field == 'Condition') {
      final conditionRank = {
        'New': 3,
        'Like New': 2,
        'Used': 1,
        'Refurbished': 0,
      };
      final maxRank = widget.products
          .map((p) => conditionRank[p.condition] ?? 0)
          .reduce((a, b) => a > b ? a : b);
      return (conditionRank[product.condition] ?? 0) == maxRank && maxRank > 0;
    }
    return false;
  }

  bool _isBestValueForPrice(String priceStr) {
    final prices = widget.products.map((p) => p.price).toList();
    final minPrice = prices.reduce((a, b) => a < b ? a : b);
    final currentPrice = double.parse(
      priceStr.replaceAll('USD ', '').replaceAll('\$', ''),
    );
    return currentPrice == minPrice;
  }

  double _calculateDistance(
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

  String _findBestValue() {
    if (widget.products.isEmpty) return 'No products';

    // Simple scoring: balance price, rating, and condition
    Product? bestProduct;
    double bestScore = -1;

    for (final product in widget.products) {
      double score = 0;

      // Price score (lower is better)
      final minPrice = widget.products
          .map((p) => p.price)
          .reduce((a, b) => a < b ? a : b);
      score += (minPrice / product.price) * 30;

      // Rating score
      score += (product.rating / 5) * 40;

      // Condition score
      final conditionScore =
          {
            'New': 30,
            'Like New': 20,
            'Used': 10,
            'Refurbished': 5,
          }[product.condition] ??
          0;
      score += conditionScore;

      // Stock bonus
      if (product.inStock) score += 10;

      if (score > bestScore) {
        bestScore = score;
        bestProduct = product;
      }
    }

    return bestProduct?.name ?? 'No products';
  }

  void _shareComparison() {
    // Create comparison text
    String comparisonText = '🛍️ Product Comparison\n\n';
    for (final field in _comparisonFields) {
      comparisonText += '${field}:\n';
      for (final product in widget.products) {
        final value = _getComparisonValue(product, field);
        comparisonText += '  ${product.name}: ${value ?? 'N/A'}\n';
      }
      comparisonText += '\n';
    }
    comparisonText += '🏆 Best Value: ${_findBestValue()}';

    // Show share dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _beigeLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Share Comparison'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(CupertinoIcons.share, size: 60, color: _primaryGreen),
            const SizedBox(height: 16),
            Text(
              'Comparison details copied to clipboard',
              style: TextStyle(color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          CupertinoButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

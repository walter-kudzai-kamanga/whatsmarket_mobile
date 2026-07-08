import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/api/api_models.dart';
import '../../core/api/whatsmarket_api.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/app_shimmer.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  final WhatsMarketApi _api = WhatsMarketApi();
  final TextEditingController _compareController = TextEditingController();
  final List<String> _categories = const ['All', 'Hardware', 'Electrical', 'Beauty', 'Medical'];

  List<Product> _products = [];
  bool _loading = true;
  String _category = 'All';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final products = await _api.getProducts(category: _category);
      if (!mounted) return;
      setState(() => _products = products);
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _compare() async {
    final q = _compareController.text.trim();
    if (q.isEmpty) return;
    try {
      final data = await _api.compareProducts(q);
      if (!mounted) return;
      final rawResults = (data['results'] as List<dynamic>? ?? []);
      final results = rawResults
          .whereType<Map<String, dynamic>>()
          .map(CompareOffer.fromJson)
          .toList()
        ..sort((a, b) => a.price.compareTo(b.price));
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => CompareResultsScreen(query: q, offers: results),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.primaryGreen,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Text(
                'Marketplace',
                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _compareController,
              decoration: InputDecoration(
                hintText: 'Compare product prices, e.g. LED bulb',
                filled: true,
                fillColor: Colors.white,
                suffixIcon: IconButton(icon: const Icon(CupertinoIcons.search), onPressed: _compare),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              ),
              onSubmitted: (_) => _compare(),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: _categories
                    .map(
                      (c) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(c),
                          selected: _category == c,
                          selectedColor: AppColors.lightGreen.withOpacity(0.25),
                          onSelected: (_) {
                            setState(() => _category = c);
                            _load();
                          },
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 10),
            if (_loading) const _MarketplaceShimmer(),
            if (!_loading && _products.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.beigeDark),
                ),
                child: const Row(
                  children: [
                    Icon(CupertinoIcons.tray, color: AppColors.primaryGreen),
                    SizedBox(width: 10),
                    Expanded(child: Text('No products found for this category yet.')),
                  ],
                ),
              ),
            ..._products.map(
              (p) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.beigeDark),
                ),
                child: ListTile(
                  title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text('${p.category} • ${p.suburb}\n${p.inStock ? "In stock" : "Out of stock"}'),
                  isThreeLine: true,
                  trailing: Text(
                    '${p.currency} ${p.price.toStringAsFixed(2)}',
                    style: const TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MarketplaceShimmer extends StatelessWidget {
  const _MarketplaceShimmer();

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Column(
        children: List.generate(
          5,
          (index) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(height: 16, width: 200),
                SizedBox(height: 8),
                ShimmerBox(height: 12, width: 140),
                SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: ShimmerBox(height: 14, width: 90),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CompareOffer {
  const CompareOffer({
    required this.productId,
    required this.vendorId,
    required this.name,
    required this.price,
    required this.currency,
    required this.suburb,
    required this.city,
    required this.direction,
    required this.inStock,
  });

  final String productId;
  final String vendorId;
  final String name;
  final double price;
  final String currency;
  final String suburb;
  final String city;
  final String direction;
  final bool inStock;

  factory CompareOffer.fromJson(Map<String, dynamic> json) => CompareOffer(
        productId: '${json['id'] ?? ''}',
        vendorId: '${json['vendor_id'] ?? ''}',
        name: '${json['name'] ?? ''}',
        price: (json['price'] as num?)?.toDouble() ?? 0,
        currency: '${json['currency'] ?? 'USD'}',
        suburb: '${json['suburb'] ?? ''}',
        city: '${json['city'] ?? ''}',
        direction: '${json['direction'] ?? ''}',
        inStock: json['in_stock'] == true,
      );
}

class CompareResultsScreen extends StatelessWidget {
  const CompareResultsScreen({
    super.key,
    required this.query,
    required this.offers,
  });

  final String query;
  final List<CompareOffer> offers;

  Future<void> _openDirection(String direction) async {
    if (direction.trim().isEmpty) {
      return;
    }
    final uri = Uri.parse(direction);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Compare: $query'),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.beige,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.beigeDark),
            ),
            child: Text(
              offers.isEmpty
                  ? 'No offers found for "$query".'
                  : '${offers.length} offers found, sorted by lowest price.',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 10),
          ...offers.map(
            (o) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.beigeDark),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          o.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Text(
                        '${o.currency} ${o.price.toStringAsFixed(2)}',
                        style: const TextStyle(
                          color: AppColors.primaryGreen,
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('${o.suburb}, ${o.city}'),
                  const SizedBox(height: 4),
                  Text(
                    o.inStock ? 'In stock' : 'Out of stock',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: o.inStock ? AppColors.primaryGreen : const Color(0xFFB42318),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      CupertinoButton(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        color: AppColors.primaryGreen,
                        borderRadius: BorderRadius.circular(10),
                        onPressed: o.direction.trim().isEmpty ? null : () => _openDirection(o.direction),
                        child: const Text('Directions'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

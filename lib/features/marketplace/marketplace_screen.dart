import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MarketplaceScreen extends StatelessWidget {
  const MarketplaceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1C3F66), Color(0xFF2D5C8D)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        CupertinoIcons.bag_fill,
                        color: Colors.white,
                        size: 24,
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.14),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Text(
                          'Marketplace',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Text(
                    'Find tools, offers, and service supplies.',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Browse curated items for service providers and busy teams.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withOpacity(0.78),
                          height: 1.4,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFE7EBF0)),
              ),
              child: const Row(
                children: [
                  Icon(CupertinoIcons.search, color: Color(0xFF7C8794)),
                  SizedBox(width: 10),
                  Text(
                    'Search marketplace',
                    style: TextStyle(color: Color(0xFF7C8794)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: const [
                _Pill(label: 'All'),
                _Pill(label: 'Tools'),
                _Pill(label: 'Supplies'),
                _Pill(label: 'Offers'),
                _Pill(label: 'Popular'),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              'Featured picks',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF102033),
                  ),
            ),
            const SizedBox(height: 12),
            _MarketplaceCard(
              title: 'Service starter kit',
              subtitle: 'Essential tools for field work and quick repairs.',
              price: '\$129',
              rating: '4.9',
              accent: const Color(0xFF0E7490),
            ),
            _MarketplaceCard(
              title: 'Client booking pack',
              subtitle: 'Stationery and signage for a better checkout flow.',
              price: '\$84',
              rating: '4.8',
              accent: const Color(0xFF8B5CF6),
            ),
            _MarketplaceCard(
              title: 'Workshop bundle',
              subtitle: 'Organize your service desk with storage and labels.',
              price: '\$176',
              rating: '4.7',
              accent: const Color(0xFF059669),
            ),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFFE6EBF1)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF223042),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _MarketplaceCard extends StatelessWidget {
  const _MarketplaceCard({
    required this.title,
    required this.subtitle,
    required this.price,
    required this.rating,
    required this.accent,
  });

  final String title;
  final String subtitle;
  final String price;
  final String rating;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE6EBF1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(
              CupertinoIcons.bag_fill,
              color: accent,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF102033),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey[700],
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(
                      CupertinoIcons.star_fill,
                      size: 14,
                      color: Colors.amber,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      rating,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF102033),
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Icon(
                      CupertinoIcons.location_solid,
                      size: 14,
                      color: Color(0xFF8391A3),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Harare',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                price,
                style: TextStyle(
                  color: accent,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 22),
              const Icon(
                CupertinoIcons.chevron_forward,
                color: Color(0xFF8391A3),
                size: 18,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

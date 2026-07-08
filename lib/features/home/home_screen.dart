import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import '../../core/api/api_models.dart';
import '../../core/api/whatsmarket_api.dart';
import '../../core/auth/session.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/app_shimmer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final WhatsMarketApi _api = WhatsMarketApi();
  final Session _session = Session();
  final List<String> _types = const ['all', 'plumber', 'electrician', 'salon', 'clinic'];
  final TextEditingController _notesController = TextEditingController();

  List<Vendor> _vendors = [];
  bool _loading = true;
  String _selectedType = 'all';
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final pos = await Geolocator.getCurrentPosition();
      final vendors = await _api.getNearbyVendors(
        lat: pos.latitude,
        lng: pos.longitude,
        type: _selectedType == 'all' ? '' : _selectedType,
        maxKm: 20,
      );
      if (!mounted) return;
      setState(() => _vendors = vendors);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _bookVendor(Vendor v) async {
    final now = DateTime.now().add(const Duration(hours: 2)).toIso8601String();
    try {
      final phone = await _session.phone;
      if (!mounted) return;
      if (phone == null || phone.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please sign in again to book.')),
        );
        return;
      }
      await _api.createBooking(
        phone: phone.trim(),
        vendorId: v.id,
        service: v.type,
        scheduledAt: now,
        notes: _notesController.text.trim(),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Booking request sent to ${v.name}.'),
          backgroundColor: AppColors.primaryGreen,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booking failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _load,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Text(
                  'Nearby verified services',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 20),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: _types
                    .map(
                      (t) => ChoiceChip(
                        label: Text(t == 'all' ? 'All' : t),
                        selected: _selectedType == t,
                        selectedColor: AppColors.lightGreen.withOpacity(0.25),
                        onSelected: (_) {
                          setState(() => _selectedType = t);
                          _load();
                        },
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 10),
              if (_loading) const _HomeShimmer(),
              if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
              if (!_loading && _error == null && _vendors.isEmpty)
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.beigeDark),
                  ),
                  child: const Row(
                    children: [
                      Icon(CupertinoIcons.location_solid, color: AppColors.primaryGreen),
                      SizedBox(width: 10),
                      Expanded(child: Text('No vendors found nearby. Try a different category or refresh.')),
                    ],
                  ),
                ),
              ..._vendors.map((v) => _VendorCard(vendor: v, onBook: () => _bookVendor(v))),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeShimmer extends StatelessWidget {
  const _HomeShimmer();

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Column(
        children: List.generate(
          4,
          (index) => Container(
            margin: const EdgeInsets.only(top: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(height: 16, width: 180),
                SizedBox(height: 10),
                ShimmerBox(height: 12),
                SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: ShimmerBox(height: 34, width: 90, radius: 10),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _VendorCard extends StatelessWidget {
  const _VendorCard({required this.vendor, required this.onBook});

  final Vendor vendor;
  final VoidCallback onBook;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.beigeDark),
      ),
      child: ListTile(
        title: Text(vendor.name, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text('${vendor.type} • ${vendor.suburb}, ${vendor.city} • ★ ${vendor.rating.toStringAsFixed(1)}'),
        trailing: CupertinoButton(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          color: AppColors.primaryGreen,
          onPressed: onBook,
          child: const Text('Book', style: TextStyle(color: Colors.white)),
        ),
      ),
    );
  }
}

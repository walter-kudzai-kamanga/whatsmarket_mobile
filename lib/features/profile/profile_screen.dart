import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/api/whatsmarket_api.dart';
import '../../core/auth/session.dart';
import '../../core/theme/app_colors.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.onLoggedOut});

  final VoidCallback onLoggedOut;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final WhatsMarketApi _api = WhatsMarketApi();
  final Session _session = Session();
  Map<String, dynamic>? _stats;
  bool _loading = true;
  String _name = '';
  String _phone = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final name = await _session.name;
      final phone = await _session.phone;
      final stats = await _api.getStats();
      if (!mounted) return;
      setState(() {
        _stats = stats;
        _name = name ?? 'WhatsMarket User';
        _phone = phone ?? '';
      });
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _logout() async {
    await _session.clear();
    if (!mounted) return;
    widget.onLoggedOut();
  }

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
                color: AppColors.primaryGreen,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  const Icon(CupertinoIcons.person_crop_circle_fill, color: Colors.white, size: 64),
                  const SizedBox(height: 8),
                  Text(
                    _name,
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
                    textAlign: TextAlign.center,
                  ),
                  if (_phone.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(_phone, style: TextStyle(color: Colors.white.withOpacity(0.85))),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            if (_loading) const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator())),
            if (_stats != null) ...[
              _StatTile(label: 'Vendors', value: '${_stats!['vendors_total'] ?? 0}'),
              _StatTile(label: 'Verified Vendors', value: '${_stats!['vendors_verified'] ?? 0}'),
              _StatTile(label: 'Products', value: '${_stats!['products_total'] ?? 0}'),
              _StatTile(label: 'Bookings', value: '${_stats!['bookings_total'] ?? 0}'),
            ],
            const SizedBox(height: 6),
            CupertinoButton(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              padding: const EdgeInsets.symmetric(vertical: 14),
              onPressed: _logout,
              child: const Text(
                'Log out',
                style: TextStyle(color: Color(0xFFB42318), fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.beigeDark),
      ),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          const Spacer(),
          Text(value, style: const TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

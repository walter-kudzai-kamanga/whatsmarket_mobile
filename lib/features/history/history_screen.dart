import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/api/api_models.dart';
import '../../core/api/whatsmarket_api.dart';
import '../../core/auth/session.dart';
import '../../core/theme/app_colors.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final WhatsMarketApi _api = WhatsMarketApi();
  final Session _session = Session();
  final TextEditingController _phoneController = TextEditingController();

  List<Booking> _bookings = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final phone = await _session.phone;
    if (!mounted) return;
    _phoneController.text = phone ?? '';
    await _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final phone = _phoneController.text.trim();
      if (phone.isEmpty) {
        if (!mounted) return;
        setState(() => _bookings = []);
        return;
      }
      final bookings = await _api.getBookings(phone);
      if (!mounted) return;
      setState(() => _bookings = bookings);
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _markCompleted(Booking b) async {
    await _api.updateBookingStatus(bookingId: b.id, status: 'completed');
    _load();
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
              decoration: BoxDecoration(color: AppColors.primaryGreen, borderRadius: BorderRadius.circular(22)),
              child: const Text('Booking History', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(
                hintText: 'Customer phone',
                suffixIcon: IconButton(onPressed: _load, icon: const Icon(CupertinoIcons.refresh)),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              ),
            ),
            const SizedBox(height: 12),
            if (_loading) const Center(child: Padding(padding: EdgeInsets.all(40), child: CircularProgressIndicator())),
            if (!_loading && _bookings.isEmpty)
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.beigeDark),
                ),
                child: const Row(
                  children: [
                    Icon(CupertinoIcons.tray, color: AppColors.primaryGreen),
                    SizedBox(width: 10),
                    Expanded(child: Text('No bookings yet. Book a vendor from Home to see history here.')),
                  ],
                ),
              ),
            ..._bookings.map(
              (b) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.beigeDark)),
                child: ListTile(
                  title: Text(b.service, style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text('Status: ${b.status}\nAt: ${b.scheduledAt}'),
                  trailing: b.status == 'completed'
                      ? const Icon(CupertinoIcons.checkmark_seal_fill, color: AppColors.primaryGreen)
                      : CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: () => _markCompleted(b),
                          child: const Text('Complete'),
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

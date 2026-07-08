import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
                  colors: [Color(0xFF1C3F66), Color(0xFF17314F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Column(
                children: [
                  const Icon(
                    CupertinoIcons.person_crop_circle_fill,
                    color: Colors.white,
                    size: 72,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Mutswe User',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Service buyer and provider dashboard',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.78),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: const [
                Expanded(
                  child: _StatCard(
                    label: 'Bookings',
                    value: '24',
                    icon: CupertinoIcons.clock_fill,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    label: 'Reviews',
                    value: '18',
                    icon: CupertinoIcons.star_fill,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _StatCard(
                    label: 'Saved',
                    value: '9',
                    icon: CupertinoIcons.bag_fill,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              'Account',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF102033),
                  ),
            ),
            const SizedBox(height: 12),
            _ProfileTile(
              icon: CupertinoIcons.person,
              title: 'Edit profile',
              subtitle: 'Update name, phone, and preferences',
            ),
            _ProfileTile(
              icon: CupertinoIcons.bell,
              title: 'Notifications',
              subtitle: 'Booking alerts and service updates',
            ),
            _ProfileTile(
              icon: CupertinoIcons.lock_fill,
              title: 'Privacy',
              subtitle: 'Manage account security',
            ),
            _ProfileTile(
              icon: CupertinoIcons.gear,
              title: 'Settings',
              subtitle: 'App theme, support, and help',
            ),
            _ProfileTile(
              icon: CupertinoIcons.question_circle,
              title: 'Help center',
              subtitle: 'Get support or send feedback',
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE6EBF1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF1C3F66), size: 22),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF102033),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(color: Colors.grey[700], fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE6EBF1)),
      ),
      child: ListTile(
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5FA),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: const Color(0xFF1C3F66), size: 22),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: Color(0xFF102033),
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(
          CupertinoIcons.chevron_forward,
          color: Color(0xFF8391A3),
          size: 16,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 8,
        ),
      ),
    );
  }
}

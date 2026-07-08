import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mhj_maps/mhj_maps.dart';
import 'package:permission_handler/permission_handler.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _ServiceSpot {
  const _ServiceSpot({
    required this.position,
    required this.name,
    required this.color,
  });

  final MhjMapsLatLng position;
  final String name;
  final Color color;
}

class _HomeScreenState extends State<HomeScreen> {
  static const MhjMapsLatLng _fallbackCenter = MhjMapsLatLng(
    lat: -17.825,
    lng: 31.033,
  );

  static const List<_ServiceSpot> _serviceSpots = [
    _ServiceSpot(
      position: MhjMapsLatLng(lat: -17.825, lng: 31.033),
      name: 'Moyo Plumbing',
      color: Color(0xFF1C3F66),
    ),
    _ServiceSpot(
      position: MhjMapsLatLng(lat: -17.806, lng: 31.032),
      name: 'Bright Spark Electric',
      color: Color(0xFF0E7490),
    ),
    _ServiceSpot(
      position: MhjMapsLatLng(lat: -17.79, lng: 31.05),
      name: 'Style Salon',
      color: Color(0xFF8B5CF6),
    ),
    _ServiceSpot(
      position: MhjMapsLatLng(lat: -17.816, lng: 31.045),
      name: 'Health Clinic',
      color: Color(0xFF059669),
    ),
  ];

  Position? _userPosition;
  bool _isLoading = true;
  bool _hasLocationPermission = false;
  bool _markersSeeded = false;
  String? _locationNotice;

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  Future<void> _getUserLocation() async {
    try {
      var status = await Permission.location.status;
      if (!status.isGranted) {
        status = await Permission.location.request();
      }

      if (!mounted) {
        return;
      }

      if (!status.isGranted) {
        setState(() {
          _isLoading = false;
          _hasLocationPermission = false;
          _locationNotice =
              'Location permission is off. Showing the default service area.';
        });
        return;
      }

      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) {
          return;
        }
        setState(() {
          _isLoading = false;
          _hasLocationPermission = false;
          _locationNotice =
              'Location services are disabled. Showing the default service area.';
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _userPosition = position;
        _hasLocationPermission = true;
        _isLoading = false;
        _locationNotice = null;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
        _hasLocationPermission = false;
        _locationNotice =
            'Could not read your location right now. Showing the default service area.';
      });

      debugPrint('Location lookup failed: $error');
    }
  }

  void _handleMapCreated(MhjMapsMapController controller) {
    if (_markersSeeded) {
      return;
    }

    _markersSeeded = true;

    for (final spot in _serviceSpots) {
      controller.addCustomMarker(
        position: spot.position,
        width: 44,
        height: 44,
        child: _buildMarkerWidget(spot.color),
      );
    }
  }

  Widget _buildMarkerWidget(Color color) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.35),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Icon(CupertinoIcons.location_solid,
          color: Colors.white, size: 20),
    );
  }

  MhjMapsLatLng get _currentCenter {
    return MhjMapsLatLng(
      lat: _userPosition?.latitude ?? _fallbackCenter.lat,
      lng: _userPosition?.longitude ?? _fallbackCenter.lng,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: 1,
            child: Stack(
              children: [
                MhjMapsMap(
                  center: _currentCenter,
                  zoom: 14,
                  theme: MhjMapsMapThemes.standard,
                  showAttribution: true,
                  showCompass: false,
                  showScale: false,
                  showUserLocation: _hasLocationPermission,
                  showZoomControls: false,
                  onMapCreated: _handleMapCreated,
                  onTap: (position) {
                    debugPrint(
                      'Map tapped at: ${position.lat}, ${position.lng}',
                    );
                  },
                ),
                Positioned(
                  top: 40,
                  right: 16,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _MapActionButton(
                        icon: CupertinoIcons.search,
                        onPressed: _showSearchDialog,
                        semanticLabel: 'Search',
                      ),
                      const SizedBox(width: 8),
                      _MapActionButton(
                        icon: CupertinoIcons.bell,
                        onPressed: _showNotifications,
                        semanticLabel: 'Notifications',
                        badgeCount: 3,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 30,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.white.withOpacity(0.3),
                  Colors.white.withOpacity(0.7),
                  Colors.white,
                ],
                stops: const [0.0, 0.3, 0.6, 1.0],
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    const Text(
                      'Nearby Services',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    if (_locationNotice != null) ...[
                      const SizedBox(height: 12),
                      _LocationBanner(message: _locationNotice!),
                    ],
                    const SizedBox(height: 16),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildCategoryChip('All', true),
                          _buildCategoryChip('Plumbing', false),
                          _buildCategoryChip('Electrician', false),
                          _buildCategoryChip('Salon', false),
                          _buildCategoryChip('Clinic', false),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: ListView(
                        children: [
                          _buildVendorCard(
                            'Moyo Plumbing',
                            'Plumbing Services',
                            '4.8 ★',
                            'Harare, Avondale',
                          ),
                          _buildVendorCard(
                            'Bright Spark Electric',
                            'Electrical Services',
                            '4.9 ★',
                            'Harare, Belvedere',
                          ),
                          _buildVendorCard(
                            'Style Salon',
                            'Hair & Beauty',
                            '4.6 ★',
                            'Harare, Borrowdale',
                          ),
                          _buildVendorCard(
                            'Health Clinic',
                            'Medical Services',
                            '4.7 ★',
                            'Harare, Highlands',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          // TODO: Filter by category
        },
        backgroundColor: Colors.grey[200],
        selectedColor: Colors.blue[100],
        labelStyle: TextStyle(
          color: isSelected ? Colors.blue[800] : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
    );
  }

  Widget _buildVendorCard(
    String name,
    String type,
    String rating,
    String location,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            CupertinoIcons.briefcase_fill,
            color: Colors.blue[700],
            size: 28,
          ),
        ),
        title: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(type, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(CupertinoIcons.star_fill,
                    color: Colors.amber, size: 16),
                const SizedBox(width: 4),
                Text(
                  rating,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 12),
                Icon(CupertinoIcons.location_solid,
                    color: Colors.grey[400], size: 14),
                const SizedBox(width: 4),
                Text(
                  location,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          onPressed: () {
            // TODO: Navigate to vendor details
          },
          icon: const Icon(
            CupertinoIcons.chevron_forward,
            color: Colors.grey,
            size: 16,
          ),
        ),
        onTap: () {
          // TODO: Navigate to vendor details
        },
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search'),
        content: TextField(
          decoration: InputDecoration(
            hintText: 'Search for services...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            prefixIcon: const Icon(CupertinoIcons.search),
          ),
          onSubmitted: (value) {
            // TODO: Implement search
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showNotifications() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        height: 400,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Notifications',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: const [
                  ListTile(
                    leading: Icon(
                      CupertinoIcons.bell_fill,
                      color: Colors.blue,
                    ),
                    title: Text('New booking request'),
                    subtitle: Text('Moyo Plumbing - 2 min ago'),
                  ),
                  ListTile(
                    leading: Icon(
                      CupertinoIcons.doc_text,
                      color: Colors.green,
                    ),
                    title: Text('New message'),
                    subtitle: Text('Bright Spark Electric - 15 min ago'),
                  ),
                  ListTile(
                    leading: Icon(
                      CupertinoIcons.star_fill,
                      color: Colors.amber,
                    ),
                    title: Text('New review'),
                    subtitle: Text('Style Salon - 1 hour ago'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationBanner extends StatelessWidget {
  const _LocationBanner({
    required this.message,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4E5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF5D19C)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(CupertinoIcons.info_circle, color: Color(0xFF9A6B17)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF6F4C0B),
                    height: 1.35,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapActionButton extends StatelessWidget {
  const _MapActionButton({
    required this.icon,
    required this.onPressed,
    required this.semanticLabel,
    this.badgeCount,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String semanticLabel;
  final int? badgeCount;

  @override
  Widget build(BuildContext context) {
    final count = badgeCount ?? 0;
    final button = Material(
      color: Colors.white,
      elevation: 1.5,
      shadowColor: Colors.black.withOpacity(0.15),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: 34,
          height: 34,
          child: Center(
            child: Icon(
              icon,
              color: Colors.black87,
              size: 16,
            ),
          ),
        ),
      ),
    );

    return Semantics(
      button: true,
      label: semanticLabel,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          button,
          if (count > 0)
            Positioned(
              top: -4,
              right: -4,
              child: Container(
                width: 16,
                height: 16,
                decoration: const BoxDecoration(
                  color: Color(0xFFE11D48),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '$count',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    height: 1,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

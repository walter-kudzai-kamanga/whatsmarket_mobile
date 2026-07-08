import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mhj_maps/mhj_maps.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

// Theme Colors (matching your main app)
const Color _primaryGreen = Color(0xFF2E7D32);
const Color _primaryLightGreen = Color(0xFF4CAF50);
const Color _secondaryBeige = Color(0xFFF5F0E8);
const Color _beigeDark = Color(0xFFE8DCC8);
const Color _beigeLight = Color(0xFFFDFBF7);

class ServiceProvider {
  final String id;
  final String name;
  final String type;
  final double rating;
  final int reviews;
  final String phone;
  final String email;
  final String address;
  final String suburb;
  final String city;
  final double lat;
  final double lng;
  final String description;
  final List<String> services;
  final String workingHours;
  final bool isAvailable;
  final String imageUrl;

  ServiceProvider({
    required this.id,
    required this.name,
    required this.type,
    required this.rating,
    required this.reviews,
    required this.phone,
    required this.email,
    required this.address,
    required this.suburb,
    required this.city,
    required this.lat,
    required this.lng,
    required this.description,
    required this.services,
    required this.workingHours,
    required this.isAvailable,
    required this.imageUrl,
  });
}

// Sample data for service providers
final Map<String, List<ServiceProvider>> _serviceProviders = {
  'plumber': [
    ServiceProvider(
      id: 'p1',
      name: 'Moyo Plumbing',
      type: 'Plumber',
      rating: 4.8,
      reviews: 127,
      phone: '+263 700 000 001',
      email: 'info@moyoplumbing.co.zw',
      address: '12 Samora Machel Avenue',
      suburb: 'Avondale',
      city: 'Harare',
      lat: -17.793,
      lng: 31.049,
      description:
          'Professional plumbing services with over 10 years of experience. We handle everything from emergency repairs to full installations.',
      services: [
        'Emergency Plumbing',
        'Pipe Installation',
        'Drain Cleaning',
        'Water Heater Repair',
        'Bathroom Renovation',
      ],
      workingHours: 'Mon-Sat: 7am - 6pm',
      isAvailable: true,
      imageUrl: '',
    ),
    ServiceProvider(
      id: 'p2',
      name: 'City Plumbers',
      type: 'Plumber',
      rating: 4.6,
      reviews: 89,
      phone: '+263 700 000 002',
      email: 'info@cityplumbers.co.zw',
      address: '45 Jason Moyo Street',
      suburb: 'CBD',
      city: 'Harare',
      lat: -17.825,
      lng: 31.033,
      description:
          'Reliable plumbing solutions for residential and commercial properties. Fast response times and quality workmanship.',
      services: [
        'Leak Detection',
        'Pipe Repair',
        'Toilet Installation',
        'Water Filtration',
        'Gas Fitting',
      ],
      workingHours: 'Mon-Fri: 8am - 5pm',
      isAvailable: true,
      imageUrl: '',
    ),
    ServiceProvider(
      id: 'p3',
      name: 'Quick Fix Plumbing',
      type: 'Plumber',
      rating: 4.9,
      reviews: 203,
      phone: '+263 700 000 003',
      email: 'hello@quickfixplumbing.co.zw',
      address: '78 Borrowdale Road',
      suburb: 'Borrowdale',
      city: 'Harare',
      lat: -17.780,
      lng: 31.065,
      description:
          'Your go-to plumber for all emergencies. 24/7 availability and competitive pricing.',
      services: [
        '24/7 Emergency',
        'Burst Pipe Repair',
        'Water Tank Installation',
        'Solar Water Heating',
      ],
      workingHours: '24/7',
      isAvailable: true,
      imageUrl: '',
    ),
  ],
  'electrician': [
    ServiceProvider(
      id: 'e1',
      name: 'Bright Spark Electric',
      type: 'Electrician',
      rating: 4.9,
      reviews: 156,
      phone: '+263 700 000 004',
      email: 'info@brightspark.co.zw',
      address: '8 Churchill Avenue',
      suburb: 'Belvedere',
      city: 'Harare',
      lat: -17.806,
      lng: 31.032,
      description:
          'Certified electricians providing safe and reliable electrical solutions for homes and businesses.',
      services: [
        'Wiring Installation',
        'Electrical Repairs',
        'Lighting Design',
        'Solar Installation',
        'Security Systems',
      ],
      workingHours: 'Mon-Fri: 7am - 7pm',
      isAvailable: true,
      imageUrl: '',
    ),
    ServiceProvider(
      id: 'e2',
      name: 'Power Electric',
      type: 'Electrician',
      rating: 4.7,
      reviews: 98,
      phone: '+263 700 000 005',
      email: 'hello@powerelectric.co.zw',
      address: '23 Fife Avenue',
      suburb: 'CBD',
      city: 'Harare',
      lat: -17.818,
      lng: 31.040,
      description:
          'Specializing in commercial and industrial electrical work. Fully licensed and insured.',
      services: [
        'Industrial Wiring',
        'Motor Repairs',
        'Transformer Installation',
        'Maintenance',
        'Testing',
      ],
      workingHours: 'Mon-Sat: 8am - 6pm',
      isAvailable: true,
      imageUrl: '',
    ),
  ],
  'salon': [
    ServiceProvider(
      id: 's1',
      name: 'Style Salon',
      type: 'Salon',
      rating: 4.6,
      reviews: 234,
      phone: '+263 700 000 006',
      email: 'info@stylesalon.co.zw',
      address: '89 Borrowdale Road',
      suburb: 'Borrowdale',
      city: 'Harare',
      lat: -17.790,
      lng: 31.050,
      description:
          'Premium hair and beauty services in a relaxing atmosphere. Our team of experts will make you look and feel great.',
      services: [
        'Hair Cutting',
        'Styling',
        'Coloring',
        'Blow-dry',
        'Bridal Makeup',
      ],
      workingHours: 'Mon-Sat: 8am - 8pm',
      isAvailable: true,
      imageUrl: '',
    ),
  ],
  'clinic': [
    ServiceProvider(
      id: 'c1',
      name: 'Health Clinic',
      type: 'Clinic',
      rating: 4.7,
      reviews: 178,
      phone: '+263 700 000 007',
      email: 'info@healthclinic.co.zw',
      address: '56 Chiremba Road',
      suburb: 'Highlands',
      city: 'Harare',
      lat: -17.816,
      lng: 31.045,
      description:
          'Modern medical clinic offering comprehensive healthcare services. We care for you and your family.',
      services: [
        'General Consultation',
        'Vaccinations',
        'Health Checkups',
        'Emergency Care',
        'Lab Tests',
      ],
      workingHours: 'Mon-Fri: 8am - 8pm',
      isAvailable: true,
      imageUrl: '',
    ),
  ],
};

class ServiceProviderMapPage extends StatefulWidget {
  final String serviceType;
  final String serviceTypeDisplayName;

  const ServiceProviderMapPage({
    super.key,
    required this.serviceType,
    required this.serviceTypeDisplayName,
  });

  @override
  State<ServiceProviderMapPage> createState() => _ServiceProviderMapPageState();
}

class _ServiceProviderMapPageState extends State<ServiceProviderMapPage> {
  late MhjMapsMapController _mapController;
  List<ServiceProvider> _providers = [];
  ServiceProvider? _selectedProvider;
  Position? _userPosition;
  bool _isLoading = true;
  bool _hasLocationPermission = false;
  String? _locationNotice;
  bool _showNearbyOnly = false;

  @override
  void initState() {
    super.initState();
    _loadProviders();
    _getUserLocation();
  }

  void _loadProviders() {
    setState(() {
      _providers = _serviceProviders[widget.serviceType] ?? [];
      _isLoading = false;
    });
  }

  Future<void> _getUserLocation() async {
    try {
      var status = await Permission.location.status;
      if (!status.isGranted) {
        status = await Permission.location.request();
      }

      if (!mounted) return;

      if (!status.isGranted) {
        setState(() {
          _hasLocationPermission = false;
          _locationNotice =
              'Location permission denied. Showing all providers.';
        });
        return;
      }

      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        setState(() {
          _hasLocationPermission = false;
          _locationNotice =
              'Location services disabled. Showing all providers.';
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (!mounted) return;

      setState(() {
        _userPosition = position;
        _hasLocationPermission = true;
        _locationNotice = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _hasLocationPermission = false;
        _locationNotice = 'Could not get location. Showing all providers.';
      });
      debugPrint('Location lookup failed: $error');
    }
  }

  void _handleMapCreated(MhjMapsMapController controller) {
    _mapController = controller;
    _addMarkers();
  }

  void _addMarkers() {
    final providersToShow = _showNearbyOnly && _userPosition != null
        ? _getNearbyProviders()
        : _providers;

    for (final provider in providersToShow) {
      _mapController.addCustomMarker(
        position: MhjMapsLatLng(lat: provider.lat, lng: provider.lng),
        width: 60,
        height: 60,
        child: _buildMarkerWidget(provider),
      );
    }

    // If showing nearby, center map on user location
    // if (_showNearbyOnly && _userPosition != null) {
    //   // Use moveTo instead of animateTo
    //   _mapController.moveTo(
    //     lat: _userPosition!.latitude,
    //     lng: _userPosition!.longitude,
    //     zoom: 13,
    //   );
    // }
  }

  Widget _buildMarkerWidget(ServiceProvider provider) {
    final isSelected = _selectedProvider?.id == provider.id;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedProvider = provider;
        });
        _showProviderDrawer(provider);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: isSelected ? 70 : 50,
        height: isSelected ? 70 : 50,
        decoration: BoxDecoration(
          color: _primaryGreen,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.amber : Colors.white,
            width: isSelected ? 4 : 2,
          ),
          boxShadow: [
            BoxShadow(
              color: _primaryGreen.withOpacity(isSelected ? 0.4 : 0.2),
              blurRadius: isSelected ? 15 : 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getProviderIcon(provider.type),
              color: Colors.white,
              size: isSelected ? 28 : 20,
            ),
            if (isSelected)
              Container(
                margin: const EdgeInsets.only(top: 2),
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: Colors.amber,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 8),
              ),
          ],
        ),
      ),
    );
  }

  IconData _getProviderIcon(String type) {
    switch (type.toLowerCase()) {
      case 'plumber':
        return CupertinoIcons.wrench;
      case 'electrician':
        return CupertinoIcons.bolt;
      case 'salon':
        return CupertinoIcons.scissors;
      case 'clinic':
        return CupertinoIcons.heart;
      default:
        return CupertinoIcons.location_solid;
    }
  }

  List<ServiceProvider> _getNearbyProviders() {
    if (_userPosition == null) return _providers;

    return _providers.map((provider) {
      return provider;
    }).toList()..sort((a, b) {
      final distA = _calculateDistance(
        _userPosition!.latitude,
        _userPosition!.longitude,
        a.lat,
        a.lng,
      );
      final distB = _calculateDistance(
        _userPosition!.latitude,
        _userPosition!.longitude,
        b.lat,
        b.lng,
      );
      return distA.compareTo(distB);
    });
  }

  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double R = 6371; // Earth's radius in km
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    final a =
        _sin(dLat / 2) * _sin(dLat / 2) +
        _cos(_toRadians(lat1)) *
            _cos(_toRadians(lat2)) *
            _sin(dLon / 2) *
            _sin(dLon / 2);
    final c = 2 * _atan2(_sqrt(a), _sqrt(1 - a));
    return R * c;
  }

  double _toRadians(double degree) => degree * 3.141592653589793 / 180;

  // Fixed math functions using dart:math
  double _sin(double x) => math.sin(x);
  double _cos(double x) => math.cos(x);
  double _sqrt(double x) => math.sqrt(x);
  double _atan2(double a, double b) => math.atan2(a, b);

  void _showProviderDrawer(ServiceProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProviderDrawer(
        provider: provider,
        onClose: () {
          setState(() {
            _selectedProvider = null;
          });
        },
      ),
    );
  }

  void _toggleNearby() {
    setState(() {
      _showNearbyOnly = !_showNearbyOnly;
      _selectedProvider = null;
    });
    // Clear and re-add markers
    _mapController.clearMarkers();
    _addMarkers();
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
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.pop(context),
          child: const Icon(CupertinoIcons.back, color: Colors.white),
        ),
        middle: Text(
          '${widget.serviceTypeDisplayName} Providers',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Nearby toggle button
            CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: _toggleNearby,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _showNearbyOnly
                      ? Colors.amber
                      : Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Icon(
                      CupertinoIcons.location_solid,
                      color: _showNearbyOnly ? Colors.black87 : Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Nearby',
                      style: TextStyle(
                        color: _showNearbyOnly ? Colors.black87 : Colors.white,
                        fontSize: 12,
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
      body: Stack(
        children: [
          // Full screen map
          MhjMapsMap(
            center: MhjMapsLatLng(
              lat: _userPosition?.latitude ?? -17.825,
              lng: _userPosition?.longitude ?? 31.033,
            ),
            zoom: 14,
            theme: MhjMapsMapThemes.standard,
            showAttribution: true,
            showCompass: false,
            showScale: false,
            showUserLocation: _hasLocationPermission,
            showZoomControls: false,
            onMapCreated: _handleMapCreated,
            onTap: (position) {
              setState(() {
                _selectedProvider = null;
              });
            },
          ),

          // Provider count overlay
          Positioned(
            top: 60,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                  Icon(
                    _getProviderIcon(widget.serviceType),
                    color: _primaryGreen,
                    size: 14,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${_providers.length} providers available',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Location notice if any
          if (_locationNotice != null)
            Positioned(
              bottom: 20,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
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
                      CupertinoIcons.info_circle,
                      color: _primaryGreen,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _locationNotice!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
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

// Provider Drawer (Bottom Sheet)
class ProviderDrawer extends StatefulWidget {
  final ServiceProvider provider;
  final VoidCallback onClose;

  const ProviderDrawer({
    super.key,
    required this.provider,
    required this.onClose,
  });

  @override
  State<ProviderDrawer> createState() => _ProviderDrawerState();
}

class _ProviderDrawerState extends State<ProviderDrawer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = widget.provider;
    final bool isAvailable = provider.isAvailable;

    return GestureDetector(
      onTap: () {
        widget.onClose();
        Navigator.pop(context);
      },
      child: Container(
        alignment: Alignment.bottomCenter,
        child: GestureDetector(
          onTap: () {},
          child: ScaleTransition(
            scale: _animation,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.55,
              decoration: BoxDecoration(
                color: _beigeLight,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(top: 12, bottom: 8),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // Close button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            widget.onClose();
                            Navigator.pop(context);
                          },
                          child: const Icon(
                            CupertinoIcons.xmark_circle_fill,
                            color: Colors.grey,
                            size: 28,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Provider name and rating
                          Row(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: _primaryGreen.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Icon(
                                  _getProviderIcon(provider.type),
                                  color: _primaryGreen,
                                  size: 30,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      provider.name,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(
                                          CupertinoIcons.star_fill,
                                          color: Colors.amber,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${provider.rating}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '(${provider.reviews} reviews)',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isAvailable
                                                ? Colors.green.shade50
                                                : Colors.red.shade50,
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: Text(
                                            isAvailable
                                                ? 'Available'
                                                : 'Unavailable',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w600,
                                              color: isAvailable
                                                  ? Colors.green.shade700
                                                  : Colors.red.shade700,
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

                          const SizedBox(height: 16),
                          const Divider(height: 1),
                          const SizedBox(height: 16),

                          // Description
                          Text(
                            'About',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            provider.description,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                              height: 1.5,
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Services
                          Text(
                            'Services Offered',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: provider.services.map((service) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: _primaryGreen.withOpacity(0.08),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: _primaryGreen.withOpacity(0.2),
                                  ),
                                ),
                                child: Text(
                                  service,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: _primaryGreen,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),

                          const SizedBox(height: 12),

                          // Contact information
                          Text(
                            'Contact Information',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[700],
                            ),
                          ),
                          const SizedBox(height: 6),
                          _buildContactRow(
                            CupertinoIcons.phone,
                            provider.phone,
                          ),
                          _buildContactRow(CupertinoIcons.mail, provider.email),
                          _buildContactRow(
                            CupertinoIcons.location_solid,
                            '${provider.suburb}, ${provider.city}',
                          ),
                          _buildContactRow(
                            CupertinoIcons.clock,
                            provider.workingHours,
                          ),

                          const SizedBox(height: 20),

                          // Action buttons
                          Row(
                            children: [
                              Expanded(
                                child: CupertinoButton(
                                  color: _primaryGreen,
                                  borderRadius: BorderRadius.circular(12),
                                  onPressed: () {
                                    _showBookingDialog(context, provider);
                                  },
                                  child: const Text(
                                    'Book Now',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: CupertinoButton(
                                  color: Colors.amber,
                                  borderRadius: BorderRadius.circular(12),
                                  onPressed: () {
                                    _showQuotationDialog(context, provider);
                                  },
                                  child: const Text(
                                    'Get Quote',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey[600], size: 16),
          const SizedBox(width: 10),
          Text(text, style: TextStyle(fontSize: 13, color: Colors.grey[700])),
        ],
      ),
    );
  }

  IconData _getProviderIcon(String type) {
    switch (type.toLowerCase()) {
      case 'plumber':
        return CupertinoIcons.wrench;
      case 'electrician':
        return CupertinoIcons.bolt;
      case 'salon':
        return CupertinoIcons.scissors;
      case 'clinic':
        return CupertinoIcons.heart;
      default:
        return CupertinoIcons.location_solid;
    }
  }

  void _showBookingDialog(BuildContext context, ServiceProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _beigeLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Book Service',
          style: TextStyle(color: _primaryGreen),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Booking with ${provider.name}'),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Date',
                hintText: 'YYYY-MM-DD',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(CupertinoIcons.calendar),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                labelText: 'Time',
                hintText: 'HH:MM',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(CupertinoIcons.clock),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Description',
                hintText: 'Describe what you need...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          CupertinoButton(
            color: _primaryGreen,
            borderRadius: BorderRadius.circular(8),
            onPressed: () {
              Navigator.pop(context);
              _showSuccessDialog(context, 'Booking', provider.name);
            },
            child: const Text(
              'Confirm Booking',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showQuotationDialog(BuildContext context, ServiceProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _beigeLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Request Quotation',
          style: TextStyle(color: _primaryGreen),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Get a quote from ${provider.name}'),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Service Type',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(CupertinoIcons.hammer),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Project Details',
                hintText: 'Describe your project...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          CupertinoButton(
            color: Colors.amber,
            borderRadius: BorderRadius.circular(8),
            onPressed: () {
              Navigator.pop(context);
              _showSuccessDialog(context, 'Quotation Request', provider.name);
            },
            child: const Text(
              'Send Request',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(
    BuildContext context,
    String action,
    String providerName,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _beigeLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              CupertinoIcons.checkmark_alt_circle_fill,
              color: _primaryGreen,
              size: 60,
            ),
            const SizedBox(height: 16),
            const Text(
              'Success!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _primaryGreen,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$action with $providerName has been submitted.',
              style: TextStyle(color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            CupertinoButton(
              color: _primaryGreen,
              borderRadius: BorderRadius.circular(8),
              onPressed: () => Navigator.pop(context),
              child: const Text('OK', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

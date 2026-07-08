import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mhj_maps/mhj_maps.dart';
import 'package:mutswe/screens/rest/service_provider_map.dart';
import 'package:permission_handler/permission_handler.dart';

// Theme Colors
const Color _primaryGreen = Color(0xFF2E7D32);
const Color _primaryLightGreen = Color(0xFF4CAF50);
const Color _secondaryBeige = Color(0xFFF5F0E8);
const Color _beigeDark = Color(0xFFE8DCC8);
const Color _beigeLight = Color(0xFFFDFBF7);

const String _searchIconSvg = '''
<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <circle cx="11" cy="11" r="6.25" stroke="#000000" stroke-width="2"/>
  <path d="M16.25 16.25L20 20" stroke="#000000" stroke-width="2" stroke-linecap="round"/>
</svg>
''';

const String _notificationIconSvg = '''
<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path d="M6 16.5H18L16.85 14.9C16.3 14.15 16 13.26 16 12.35V10.5C16 8.01 14.35 6 12 6C9.65 6 8 8.01 8 10.5V12.35C8 13.26 7.7 14.15 7.15 14.9L6 16.5Z" stroke="#000000" stroke-width="2" stroke-linejoin="round"/>
  <path d="M10 18.5C10 19.6 10.9 20.5 12 20.5C13.1 20.5 14 19.6 14 18.5" stroke="#000000" stroke-width="2" stroke-linecap="round"/>
</svg>
''';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
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

class _HomeState extends State<Home> {
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
  int _selectedIndex = 0;

  final List<BottomNavigationBarItem> _navItems = const [
    BottomNavigationBarItem(icon: Icon(CupertinoIcons.home), label: 'Home'),
    BottomNavigationBarItem(
      icon: Icon(CupertinoIcons.shopping_cart),
      label: 'Marketplace',
    ),
    BottomNavigationBarItem(icon: Icon(CupertinoIcons.time), label: 'History'),
    BottomNavigationBarItem(
      icon: Icon(CupertinoIcons.person),
      label: 'Profile',
    ),
  ];

  final List<Widget> _pages = [
    const _HomeContent(),
    const _MarketplaceContent(),
    const _HistoryContent(),
    const _ProfileContent(),
  ];

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
      child: const Icon(CupertinoIcons.home, color: Colors.white, size: 20),
    );
  }

  MhjMapsLatLng get _currentCenter {
    return MhjMapsLatLng(
      lat: _userPosition?.latitude ?? _fallbackCenter.lat,
      lng: _userPosition?.longitude ?? _fallbackCenter.lng,
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: _secondaryBeige,
        selectedItemColor: _primaryGreen,
        unselectedItemColor: Colors.grey[600],
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        elevation: 8,
        items: _navItems,
      ),
    );
  }
}

// Home Page Content
class _HomeContent extends StatefulWidget {
  const _HomeContent();

  @override
  State<_HomeContent> createState() => __HomeContentState();
}

class __HomeContentState extends State<_HomeContent> {
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
  bool _hasLocationPermission = false;
  bool _markersSeeded = false;
  String? _locationNotice;

  // Sample recent jobs/products with more items for grid
  final List<Map<String, dynamic>> _recentItems = [
    {
      'title': 'Emergency Plumbing',
      'subtitle': 'Moyo Plumbing',
      'time': '2 hours ago',
      'status': 'Completed',
      'icon': CupertinoIcons.wrench,
      'color': Color(0xFF1C3F66),
    },
    {
      'title': 'Electrical Installation',
      'subtitle': 'Bright Spark Electric',
      'time': '5 hours ago',
      'status': 'Pending',
      'icon': CupertinoIcons.bolt,
      'color': Color(0xFF0E7490),
    },
    {
      'title': 'Hair Cut & Styling',
      'subtitle': 'Style Salon',
      'time': '1 day ago',
      'status': 'Completed',
      'icon': CupertinoIcons.scissors,
      'color': Color(0xFF8B5CF6),
    },
    {
      'title': 'Medical Checkup',
      'subtitle': 'Health Clinic',
      'time': '2 days ago',
      'status': 'Completed',
      'icon': CupertinoIcons.heart,
      'color': Color(0xFF059669),
    },
    {
      'title': 'AC Repair',
      'subtitle': 'Cool Tech Services',
      'time': '3 days ago',
      'status': 'Cancelled',
      'icon': CupertinoIcons.snow,
      'color': Color(0xFFE67E22),
    },
    {
      'title': 'Roof Fixing',
      'subtitle': 'Builders Inc',
      'time': '4 days ago',
      'status': 'Pending',
      'icon': CupertinoIcons.hammer,
      'color': Color(0xFF8E44AD),
    },
  ];

  // Trending products
  final List<Map<String, dynamic>> _trendingProducts = [
    {
      'title': 'PVC Pipe 20mm',
      'subtitle': 'Moyo Plumbing',
      'price': '\$3.50',
      'icon': CupertinoIcons.cube_box,
      'trending': true,
    },
    {
      'title': 'LED Bulb 9W',
      'subtitle': 'Bright Spark',
      'price': '\$2.00',
      'icon': CupertinoIcons.lightbulb_fill,
      'trending': true,
    },
    {
      'title': 'Hair Treatment Kit',
      'subtitle': 'Style Salon',
      'price': '\$15.00',
      'icon': CupertinoIcons.sparkles,
      'trending': true,
    },
  ];

  // Quick request buttons - made smaller
  final List<Map<String, dynamic>> _quickRequests = [
    {
      'title': 'Plumber',
      'icon': CupertinoIcons.wrench,
      'color': Color(0xFF1C3F66),
      'route': '/request/plumber',
    },
    {
      'title': 'Electrician',
      'icon': CupertinoIcons.bolt,
      'color': Color(0xFF0E7490),
      'route': '/request/electrician',
    },
    {
      'title': 'Salon',
      'icon': CupertinoIcons.scissors,
      'color': Color(0xFF8B5CF6),
      'route': '/request/salon',
    },
    {
      'title': 'Clinic',
      'icon': CupertinoIcons.heart,
      'color': Color(0xFF059669),
      'route': '/request/clinic',
    },
  ];

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

      if (!mounted) return;

      if (!status.isGranted) {
        setState(() {
          _hasLocationPermission = false;
          _locationNotice =
              'Location permission is off. Showing the default service area.';
        });
        return;
      }

      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        setState(() {
          _hasLocationPermission = false;
          _locationNotice =
              'Location services are disabled. Showing the default service area.';
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
        _locationNotice =
            'Could not read your location right now. Showing the default service area.';
      });
      debugPrint('Location lookup failed: $error');
    }
  }

  void _handleMapCreated(MhjMapsMapController controller) {
    if (_markersSeeded) return;
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
      child: const Icon(CupertinoIcons.home, color: Colors.white, size: 20),
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
    return Scaffold(
      backgroundColor: Colors.white,
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
                        svg: _searchIconSvg,
                        onPressed: _showSearchDialog,
                        semanticLabel: 'Search',
                      ),
                      const SizedBox(width: 8),
                      _MapActionButton(
                        svg: _notificationIconSvg,
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
                    const SizedBox(height: 8),

                    // Quick Request Section - Smaller chips
                    _buildQuickRequestSection(),

                    const SizedBox(height: 12),

                    // Recent Items or Trending Products in Grid
                    _buildContentSection(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickRequestSection() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _quickRequests.length,
        itemBuilder: (context, index) {
          final request = _quickRequests[index];
          return GestureDetector(
            onTap: () {
              // Navigate to ServiceProviderMapPage
              Navigator.push(
                context,
                CupertinoPageRoute(
                  builder: (context) => ServiceProviderMapPage(
                    serviceType: request['route'].toString().replaceAll(
                      '/request/',
                      '',
                    ),
                    serviceTypeDisplayName: request['title'] as String,
                  ),
                ),
              );
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: _beigeLight,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: request['color'] as Color,
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    request['icon'] as IconData,
                    color: request['color'] as Color,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    request['title'] as String,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: request['color'] as Color,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContentSection() {
    final hasHistory = _recentItems.isNotEmpty;

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_locationNotice != null) ...[
            _LocationBanner(message: _locationNotice!),
            const SizedBox(height: 10),
          ],

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                hasHistory ? 'Recent Activity' : 'Trending Products',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: _primaryGreen,
                ),
              ),
              if (hasHistory)
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    // Navigate to full history
                  },
                  child: Text(
                    'See All',
                    style: TextStyle(
                      fontSize: 12,
                      color: _primaryGreen.withOpacity(0.7),
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(height: 8),

          Expanded(
            child: hasHistory
                ? GridView.builder(
                    padding: EdgeInsets.zero,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 0.85,
                        ),
                    itemCount: _recentItems.length,
                    itemBuilder: (context, index) {
                      final item = _recentItems[index];
                      return _buildRecentItemGridCard(item);
                    },
                  )
                : ListView.builder(
                    itemCount: _trendingProducts.length,
                    itemBuilder: (context, index) {
                      final product = _trendingProducts[index];
                      return _buildTrendingProductCard(product);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentItemGridCard(Map<String, dynamic> item) {
    final bool isPending = item['status'] == 'Pending';
    final bool isCancelled = item['status'] == 'Cancelled';

    Color statusColor;
    if (isPending) {
      statusColor = Colors.orange;
    } else if (isCancelled) {
      statusColor = Colors.red;
    } else {
      statusColor = _primaryGreen;
    }

    return GestureDetector(
      onTap: () {
        _navigateToRequestPage('/request/details/${item['title']}');
      },
      child: Container(
        decoration: BoxDecoration(
          color: _beigeLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isPending ? Colors.orange.shade200 : _beigeDark,
            width: 0.5,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Icon and Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: (item['color'] as Color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      item['icon'] as IconData,
                      color: item['color'] as Color,
                      size: 16,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      item['status'] as String,
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              // Title
              Text(
                item['title'] as String,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.black87,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              // Subtitle
              Text(
                item['subtitle'] as String,
                style: TextStyle(color: Colors.grey[600], fontSize: 10),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              // Time
              Row(
                children: [
                  Icon(
                    CupertinoIcons.time_solid,
                    size: 10,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    item['time'] as String,
                    style: TextStyle(color: Colors.grey[500], fontSize: 9),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrendingProductCard(Map<String, dynamic> product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _beigeLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _beigeDark, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: _primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              product['icon'] as IconData,
              color: _primaryGreen,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      product['title'] as String,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            CupertinoIcons.flame_fill,
                            size: 10,
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            'Trending',
                            style: TextStyle(
                              fontSize: 8,
                              color: Colors.amber.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Text(
                  product['subtitle'] as String,
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            product['price'] as String,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: _primaryGreen,
              fontSize: 14,
            ),
          ),
          IconButton(
            onPressed: () {
              _navigateToProductDetails(product['title']);
            },
            icon: const Icon(
              CupertinoIcons.forward,
              color: Colors.grey,
              size: 16,
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToRequestPage(String route) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => RequestDetailsPage(route: route),
      ),
    );
  }

  void _navigateToProductDetails(String productName) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) => ProductDetailsPage(productName: productName),
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _beigeLight,
        title: const Text('Search'),
        content: TextField(
          decoration: InputDecoration(
            hintText: 'Search for services...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _primaryGreen),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _primaryGreen, width: 2),
            ),
            prefixIcon: const Icon(CupertinoIcons.search, color: _primaryGreen),
          ),
          onSubmitted: (value) {
            // TODO: Implement search
            Navigator.pop(context);
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: _primaryGreen)),
          ),
        ],
      ),
    );
  }

  void _showNotifications() {
    // Sample notification data
    final List<Map<String, dynamic>> notifications = [
      {
        'title': 'Booking Confirmed',
        'subtitle': 'Moyo Plumbing - Emergency Plumbing Fix',
        'time': '2 min ago',
        'type': 'booking',
        'status': 'confirmed',
        'icon': CupertinoIcons.checkmark_circle_fill,
        'color': _primaryGreen,
      },
      {
        'title': 'New Message',
        'subtitle': 'Bright Spark Electric sent you a message',
        'time': '15 min ago',
        'type': 'message',
        'status': 'unread',
        'icon': CupertinoIcons.chat_bubble_fill,
        'color': _primaryLightGreen,
      },
      {
        'title': 'New Review',
        'subtitle': 'Style Salon - 5 star rating',
        'time': '1 hour ago',
        'type': 'review',
        'status': 'read',
        'icon': CupertinoIcons.star_fill,
        'color': Colors.amber,
      },
      {
        'title': 'Booking Request',
        'subtitle': 'Health Clinic - Medical Checkup requested',
        'time': '2 hours ago',
        'type': 'booking',
        'status': 'pending',
        'icon': CupertinoIcons.clock_fill,
        'color': Colors.orange,
      },
      {
        'title': 'Quotation Received',
        'subtitle': 'Quick Fix Plumbing - \$150 estimate',
        'time': '3 hours ago',
        'type': 'quotation',
        'status': 'read',
        'icon': CupertinoIcons.doc_text_fill,
        'color': Color(0xFF8E44AD),
      },
      {
        'title': 'Payment Successful',
        'subtitle': 'You paid \$45.00 to City Plumbers',
        'time': '5 hours ago',
        'type': 'payment',
        'status': 'read',
        'icon': CupertinoIcons.money_dollar_circle_fill,
        'color': Color(0xFF27AE60),
      },
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: _beigeLight,
            borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header with actions
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Notifications',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: _primaryGreen,
                      ),
                    ),
                    Row(
                      children: [
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            // Mark all as read
                          },
                          child: Text(
                            'Mark all read',
                            style: TextStyle(
                              fontSize: 13,
                              color: _primaryGreen.withOpacity(0.7),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        CupertinoButton(
                          padding: EdgeInsets.zero,
                          onPressed: () => Navigator.pop(context),
                          child: const Icon(
                            CupertinoIcons.xmark_circle_fill,
                            color: Colors.grey,
                            size: 28,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Filter chips
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  height: 36,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildFilterChip('All', true),
                      _buildFilterChip('Unread', false),
                      _buildFilterChip('Bookings', false),
                      _buildFilterChip('Messages', false),
                      _buildFilterChip('Payments', false),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Notifications list
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    final bool isUnread =
                        notification['status'] == 'unread' ||
                        notification['status'] == 'pending';

                    return _buildNotificationCard(
                      notification['title'],
                      notification['subtitle'],
                      notification['time'],
                      notification['icon'],
                      notification['color'],
                      isUnread,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        selected: isSelected,
        onSelected: (selected) {
          // Filter notifications
        },
        backgroundColor: Colors.white,
        selectedColor: _primaryGreen.withOpacity(0.1),
        side: BorderSide(
          color: isSelected ? _primaryGreen : Colors.grey.shade300,
          width: isSelected ? 1.5 : 0.5,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        shape: StadiumBorder(),
      ),
    );
  }

  Widget _buildNotificationCard(
    String title,
    String subtitle,
    String time,
    IconData icon,
    Color color,
    bool isUnread,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isUnread ? Colors.white : _beigeLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isUnread
              ? _primaryGreen.withOpacity(0.2)
              : Colors.grey.shade200,
          width: isUnread ? 1.5 : 0.5,
        ),
        boxShadow: isUnread
            ? [
                BoxShadow(
                  color: _primaryGreen.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : [],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 14),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: isUnread
                              ? FontWeight.w700
                              : FontWeight.w600,
                          color: isUnread ? Colors.black87 : Colors.grey[800],
                        ),
                      ),
                    ),
                    Text(
                      time,
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    // Status badge
                    if (isUnread)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _primaryGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'New',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: _primaryGreen,
                          ),
                        ),
                      ),
                    if (isUnread) const SizedBox(width: 8),
                    // Action button
                    CupertinoButton(
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        // Navigate to notification details
                      },
                      child: Text(
                        'View',
                        style: TextStyle(
                          fontSize: 12,
                          color: _primaryGreen,
                          fontWeight: FontWeight.w600,
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
}

// Request Details Page
class RequestDetailsPage extends StatelessWidget {
  final String route;

  const RequestDetailsPage({super.key, required this.route});

  @override
  Widget build(BuildContext context) {
    String title = 'Request';
    if (route.contains('plumber'))
      title = 'Request Plumber';
    else if (route.contains('electrician'))
      title = 'Request Electrician';
    else if (route.contains('salon'))
      title = 'Request Salon';
    else if (route.contains('clinic'))
      title = 'Request Clinic';
    else if (route.contains('details'))
      title = 'Request Details';

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
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                CupertinoIcons.hammer,
                size: 80,
                color: _primaryGreen.withOpacity(0.3),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _primaryGreen,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Request a service provider near you',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 30),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _beigeDark),
                ),
                child: Column(
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Your Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Phone Number',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    CupertinoButton(
                      color: _primaryGreen,
                      borderRadius: BorderRadius.circular(10),
                      onPressed: () {
                        Navigator.pop(context);
                        _showSuccessDialog(context);
                      },
                      child: const Text(
                        'Submit Request',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
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

  void _showSuccessDialog(BuildContext context) {
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
              'Request Submitted!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _primaryGreen,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'We\'ll find the best service provider for you.',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),
            CupertinoButton(
              color: _primaryGreen,
              borderRadius: BorderRadius.circular(10),
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'OK',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Product Details Page
class ProductDetailsPage extends StatelessWidget {
  final String productName;

  const ProductDetailsPage({super.key, required this.productName});

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
          'Product Details',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                CupertinoIcons.cube_box,
                size: 80,
                color: _primaryGreen.withOpacity(0.3),
              ),
              const SizedBox(height: 20),
              Text(
                productName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: _primaryGreen,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Available from local vendors near you',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              const SizedBox(height: 30),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _beigeDark),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Price:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const Text(
                          '\$3.50',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _primaryGreen,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Vendor:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text('Moyo Plumbing', style: TextStyle(fontSize: 16)),
                      ],
                    ),
                    const Divider(height: 20),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Stock:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '✅ In Stock',
                          style: TextStyle(color: _primaryGreen, fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    CupertinoButton(
                      color: _primaryGreen,
                      borderRadius: BorderRadius.circular(10),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Buy Now',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
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
}

class _LocationBanner extends StatelessWidget {
  const _LocationBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _beigeLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _beigeDark),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            CupertinoIcons.info_circle,
            color: _primaryGreen,
            size: 16,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[800],
                fontSize: 12,
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
    required this.svg,
    required this.onPressed,
    required this.semanticLabel,
    this.badgeCount,
  });

  final String svg;
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
          width: 36,
          height: 36,
          child: Center(
            child: SvgPicture.string(
              svg,
              width: 16,
              height: 16,
              colorFilter: const ColorFilter.mode(
                Colors.black87,
                BlendMode.srcIn,
              ),
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

// Placeholder pages for bottom navigation
class _MarketplaceContent extends StatelessWidget {
  const _MarketplaceContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _beigeLight,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                CupertinoIcons.shopping_cart,
                size: 80,
                color: _primaryGreen.withOpacity(0.3),
              ),
              const SizedBox(height: 20),
              const Text(
                'Marketplace',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: _primaryGreen,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Browse products from local vendors',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HistoryContent extends StatelessWidget {
  const _HistoryContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _beigeLight,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                CupertinoIcons.time,
                size: 80,
                color: _primaryGreen.withOpacity(0.3),
              ),
              const SizedBox(height: 20),
              const Text(
                'History',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: _primaryGreen,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'View your past bookings and activities',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  const _ProfileContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _beigeLight,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: _primaryGreen.withOpacity(0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: _primaryGreen, width: 3),
                ),
                child: const Icon(
                  CupertinoIcons.person,
                  size: 60,
                  color: _primaryGreen,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Profile',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: _primaryGreen,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Manage your account and preferences',
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/screens/merchant/menu_drawer.dart'; // Make sure this path is correct
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:math' as math;
import 'dart:ui'; // Required for blur effect

class LandingPage extends StatefulWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _cardAnimationController;
  late AnimationController _drawerAnimationController;
  late AnimationController _paginationAnimationController;

  int _selectedCardIndex = -1;
  bool _isDrawerOpen = false;
  int _currentPage = 0;
  final int _totalPages = 4;
  
  // BUG FIX: Added state for interactive bar chart
  int _selectedBarIndex = 8; // Default to the last month with data (September)

  late PageController _pageController;

  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Data for bar chart
  final List<String> _barChartMonths = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep'];
  final List<double> _barChartValues = [6.0, 5.0, 7.0, 8.0, 9.0, 8.0, 10.0, 9.8, 2.0];

  final List<Map<String, String>> _allDeals = [
    {'client': 'Apex Retail Co.', 'project': 'FW26 Apparel Line', 'value': '\$1.2M', 'status': 'Negotiation', 'manager': 'A. Patel'},
    {'client': 'Innovate Tech', 'project': 'Custom Circuit Boards', 'value': '\$750K', 'status': 'Awaiting PO', 'manager': 'J. Chen'},
    {'client': 'Global Homewares', 'project': 'Ceramic Dinnerware', 'value': '\$400K', 'status': 'RFQ Sent', 'manager': 'S. Khan'},
    {'client': 'BuildRight Inc.', 'project': 'Construction Fasteners', 'value': '\$2.1M', 'status': 'Negotiation', 'manager': 'A. Patel'},
    {'client': 'Quantum Motors', 'project': 'Machined Engine Parts', 'value': '\$850K', 'status': 'On Hold', 'manager': 'J. Chen'},
    {'client': 'Apex Retail Co.', 'project': 'FW26 Apparel Line', 'value': '\$1.2M', 'status': 'Negotiation', 'manager': 'A. Patel'},
    {'client': 'Innovate Tech', 'project': 'Custom Circuit Boards', 'value': '\$750K', 'status': 'Awaiting PO', 'manager': 'J. Chen'},
    {'client': 'Global Homewares', 'project': 'Ceramic Dinnerware', 'value': '\$400K', 'status': 'RFQ Sent', 'manager': 'S. Khan'},
    {'client': 'BuildRight Inc.', 'project': 'Construction Fasteners', 'value': '\$2.1M', 'status': 'Negotiation', 'manager': 'A. Patel'},
    {'client': 'Quantum Motors', 'project': 'Machined Engine Parts', 'value': '\$850K', 'status': 'On Hold', 'manager': 'J. Chen'},
    {'client': 'Apex Retail Co.', 'project': 'FW26 Apparel Line', 'value': '\$1.2M', 'status': 'Negotiation', 'manager': 'A. Patel'},
    {'client': 'Innovate Tech', 'project': 'Custom Circuit Boards', 'value': '\$750K', 'status': 'Awaiting PO', 'manager': 'J. Chen'},
    {'client': 'Global Homewares', 'project': 'Ceramic Dinnerware', 'value': '\$400K', 'status': 'RFQ Sent', 'manager': 'S. Khan'},
    {'client': 'BuildRight Inc.', 'project': 'Construction Fasteners', 'value': '\$2.1M', 'status': 'Negotiation', 'manager': 'A. Patel'},
    {'client': 'Quantum Motors', 'project': 'Machined Engine Parts', 'value': '\$850K', 'status': 'On Hold', 'manager': 'J. Chen'},
    {'client': 'Apex Retail Co.', 'project': 'FW26 Apparel Line', 'value': '\$1.2M', 'status': 'Negotiation', 'manager': 'A. Patel'},
    {'client': 'Innovate Tech', 'project': 'Custom Circuit Boards', 'value': '\$750K', 'status': 'Awaiting PO', 'manager': 'J. Chen'},
    {'client': 'Global Homewares', 'project': 'Ceramic Dinnerware', 'value': '\$400K', 'status': 'RFQ Sent', 'manager': 'S. Khan'},
    {'client': 'BuildRight Inc.', 'project': 'Construction Fasteners', 'value': '\$2.1M', 'status': 'Negotiation', 'manager': 'A. Patel'},
    {'client': 'Quantum Motors', 'project': 'Machined Engine Parts', 'value': '\$850K', 'status': 'On Hold', 'manager': 'J. Chen'},
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _cardAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _drawerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _paginationAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _pageController = PageController();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _cardAnimationController.dispose();
    _drawerAnimationController.dispose();
    _paginationAnimationController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      await _googleSignIn.signOut();
      print('✅ User signed out successfully');
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/roles');
      }
    } catch (e) {
      print('❌ Sign out error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error signing out: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _toggleDrawer() {
    setState(() {
      _isDrawerOpen = !_isDrawerOpen;
    });
    if (_isDrawerOpen) {
      _drawerAnimationController.forward();
    } else {
      _drawerAnimationController.reverse();
    }
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      setState(() {
        _currentPage++;
      });
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      setState(() {
        _currentPage--;
      });
    }
  }

  List<Map<String, String>> _getCurrentPageDeals() {
    int startIndex = _currentPage * 5;
    int endIndex = math.min(startIndex + 5, _allDeals.length);
    return _allDeals.sublist(startIndex, endIndex);
  }

  String _getInitials(String name) {
    if (name.trim().isEmpty) return 'U';
    List<String> nameParts = name.trim().split(' ').where((part) => part.isNotEmpty).toList();
    if (nameParts.length > 1) {
      return (nameParts[0][0] + nameParts.last[0]).toUpperCase();
    } else if (nameParts.isNotEmpty) {
      return nameParts[0][0].toUpperCase();
    } else {
      return "U";
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final String userName = user?.displayName ?? user?.email?.split('@')[0] ?? 'Merchant';
    final String userInitials = _getInitials(userName);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: Stack(
          children: [
            GestureDetector(
              onTap: _isDrawerOpen ? _toggleDrawer : null,
              child: AnimatedBuilder(
                animation: _drawerAnimationController,
                builder: (context, child) {
                  final sigma = _drawerAnimationController.value * 5.0;
                  return ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
                    child: child,
                  );
                },
                child: AbsorbPointer(
                  absorbing: _isDrawerOpen,
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(userName, userInitials),
                          const SizedBox(height: 30),
                          _buildStatsCards(),
                          const SizedBox(height: 30),
                          _buildVolumeCard(),
                          const SizedBox(height: 30),
                          _buildChartsRow(),
                          const SizedBox(height: 30),
                          _buildOpenPosCard(),
                          const SizedBox(height: 30),
                          _buildVolumeShippedOverTimeCard(),
                          const SizedBox(height: 30),
                          _buildTopSourcingRegionsCard(),
                          const SizedBox(height: 30),
                          _buildProjectCards(),
                          const SizedBox(height: 30),
                          _buildPipelineSection(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            _buildDrawer(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String userName, String userInitials) {
    // This widget seems fine and doesn't need changes for responsiveness.
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, -1),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOutBack),
      )),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: _toggleDrawer,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.menu,
                  color: Color(0xFF2D3748),
                  size: 24,
                ),
              ),
            ),
            const Spacer(),
            Column(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF667EEA).withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      userInitials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  userName.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                    letterSpacing: 1.2,
                  ),
                ),
                Text(
                  'Merchant | JNitin',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Row(
              children: [
                _buildHeaderIcon(Icons.home, () {}),
                const SizedBox(width: 10),
                _buildHeaderIcon(Icons.logout, _signOut),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderIcon(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: icon == Icons.logout ? Colors.black : const Color(0xFF3B82F6),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: (icon == Icons.logout ? Colors.black : const Color(0xFF3B82F6))
                  .withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildStatsCards() {
    final screenWidth = MediaQuery.of(context).size.width;
    const breakpoint = 600;

    final cards = [
      _buildStatCard(
        '\$2,893,601.34', 'TOTAL POS', Colors.green, Icons.attach_money, 0,
      ),
      _buildStatCard(
        '2.8%', 'CONVERSION RATE', Colors.blue, Icons.trending_up, 1,
      ),
    ];

    Widget content;
    if (screenWidth < breakpoint) {
      content = Column(
        // BUG FIX: Added stretch to make cards full-width
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          cards[0],
          const SizedBox(height: 20),
          cards[1],
        ],
      );
    } else {
      content = Row(
        children: [
          Expanded(child: cards[0]),
          const SizedBox(width: 20),
          Expanded(child: cards[1]),
        ],
      );
    }

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 1), end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.5, curve: Curves.easeOut),
      )),
      child: content,
    );
  }

  Widget _buildChartsRow() {
    final screenWidth = MediaQuery.of(context).size.width;
    const breakpoint = 600;

    final cards = [
      _buildChartCard('ACTIVE ACCOUNTS', '1', 'This Quarter', 3),
      _buildChartCard('OTIF RATE', '91%', '+2% vs Last Quarter', 4),
    ];

    Widget content;
    if (screenWidth < breakpoint) {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          cards[0],
          const SizedBox(height: 20),
          cards[1],
        ],
      );
    } else {
      content = Row(
        children: [
          Expanded(child: cards[0]),
          const SizedBox(width: 20),
          Expanded(child: cards[1]),
        ],
      );
    }

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1, 0), end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.6, 0.9, curve: Curves.easeOut),
      )),
      child: content,
    );
  }

  Widget _buildProjectCards() {
    final screenWidth = MediaQuery.of(context).size.width;
    const breakpoint = 600;

    final cards = [
      _buildProjectCard('NEW PROJECTS INITIATED', '58', 'This Month', Colors.purple, 5),
      _buildProjectCard('CONTRACTS SIGNED', '16', 'This Month', Colors.orange, 6),
    ];

    Widget content;
    if (screenWidth < breakpoint) {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          cards[0],
          const SizedBox(height: 20),
          cards[1],
        ],
      );
    } else {
      content = Row(
        children: [
          Expanded(child: cards[0]),
          const SizedBox(width: 20),
          Expanded(child: cards[1]),
        ],
      );
    }

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 1), end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
      )),
      child: content,
    );
  }
  
  // The rest of your individual card widgets
  // ... _buildStatCard, _buildVolumeCard, etc. ...
    Widget _buildStatCard(String value, String label, Color color, IconData icon, int index) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCardIndex = index;
        });
        _cardAnimationController.forward().then((_) {
          Future.delayed(const Duration(milliseconds: 100), () {
            _cardAnimationController.reverse();
            setState(() {
              _selectedCardIndex = -1;
            });
          });
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateX(_selectedCardIndex == index ? -0.1 : 0.0)
          ..translate(0.0, _selectedCardIndex == index ? -10.0 : 0.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _selectedCardIndex == index ? const Color(0xFF3B82F6) : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: _selectedCardIndex == index
                  ? const Color(0xFF3B82F6).withOpacity(0.3)
                  : Colors.black.withOpacity(0.08),
              blurRadius: _selectedCardIndex == index ? 20 : 15,
              offset: Offset(0, _selectedCardIndex == index ? 10 : 5),
            ),
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3748),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildVolumeCard() {
  return SlideTransition(
    position: Tween<Offset>(
      begin: const Offset(-1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.4, 0.7, curve: Curves.easeOut),
    )),
    child: GestureDetector(
      onTap: () {
        setState(() {
          _selectedCardIndex = 2;
        });
        _cardAnimationController.forward().then((_) {
          Future.delayed(const Duration(milliseconds: 100), () {
            _cardAnimationController.reverse();
            setState(() {
              _selectedCardIndex = -1;
            });
          });
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateX(_selectedCardIndex == 2 ? -0.1 : 0.0)
          ..translate(0.0, _selectedCardIndex == 2 ? -10.0 : 0.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _selectedCardIndex == 2 ? const Color(0xFF3B82F6) : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: _selectedCardIndex == 2
                  ? const Color(0xFF3B82F6).withOpacity(0.3)
                  : Colors.black.withOpacity(0.08),
              blurRadius: _selectedCardIndex == 2 ? 25 : 20,
              offset: Offset(0, _selectedCardIndex == 2 ? 15 : 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(30),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'VOLUME SHIPPED (YTD)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'View Report',
                    style: TextStyle(
                      color: Color(0xFF3B82F6),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Column(
              children: [
                const Text(
                  '2.11M TEUs',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 20),
                Center(child: _buildProgressIndicator(47)),
                const SizedBox(height: 10),
                Text(
                  'Target: 4.50M TEUs',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildProgressIndicator(int percentage) {
  return SizedBox(
    width: 120,
    height: 120,
    child: Stack(
      alignment: Alignment.center,
      children: [
        CustomPaint(
          size: const Size(120, 120),
          painter: CircularProgressPainter(
            percentage: percentage,
            strokeWidth: 8,
            backgroundColor: Colors.grey.shade200,
            progressColor: const Color(0xFF3B82F6),
          ),
        ),
        Text(
          '$percentage%',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3748),
          ),
        ),
      ],
    ),
  );
}

Widget _buildChartCard(String title, String value, String subtitle, int index) {
  return GestureDetector(
    onTap: () {
      setState(() {
        _selectedCardIndex = index;
      });
      _cardAnimationController.forward().then((_) {
        Future.delayed(const Duration(milliseconds: 100), () {
          _cardAnimationController.reverse();
          setState(() {
            _selectedCardIndex = -1;
          });
        });
      });
    },
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..rotateX(_selectedCardIndex == index ? -0.1 : 0.0)
        ..translate(0.0, _selectedCardIndex == index ? -10.0 : 0.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _selectedCardIndex == index ? const Color(0xFF3B82F6) : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: _selectedCardIndex == index
                ? const Color(0xFF3B82F6).withOpacity(0.3)
                : Colors.black.withOpacity(0.08),
            blurRadius: _selectedCardIndex == index ? 20 : 15,
            offset: Offset(0, _selectedCardIndex == index ? 10 : 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF718096),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              _buildPeriodBox(subtitle),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          if (subtitle.contains('%') || subtitle.contains('+'))
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  Icon(
                    subtitle.contains('+') ? Icons.arrow_upward : Icons.info_outline,
                    size: 16,
                    color: subtitle.contains('+') ? Colors.green : Colors.blue,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: subtitle.contains('+') ? Colors.green : Colors.blue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    ),
  );
}

Widget _buildPeriodBox(String text) {
  Color bgColor;
  if (text.toLowerCase().contains('quarter')) {
    bgColor = const Color(0xFF2D3748);
  } else {
    bgColor = const Color(0xFF3B82F6);
  }

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: bgColor,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      text.contains('Quarter') ? 'This Quarter' : text.contains('Month') ? 'This Month' : text,
      style: const TextStyle(
        fontSize: 10,
        color: Colors.white,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

Widget _buildOpenPosCard() {
  return GestureDetector(
    onTap: () {
      setState(() {
        _selectedCardIndex = 8;
      });
      _cardAnimationController.forward().then((_) {
        Future.delayed(const Duration(milliseconds: 100), () {
          _cardAnimationController.reverse();
          setState(() {
            _selectedCardIndex = -1;
          });
        });
      });
    },
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..rotateX(_selectedCardIndex == 8 ? -0.1 : 0.0)
        ..translate(0.0, _selectedCardIndex == 8 ? -10.0 : 0.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _selectedCardIndex == 8 ? const Color(0xFF3B82F6) : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: _selectedCardIndex == 8
                ? const Color(0xFF3B82F6).withOpacity(0.3)
                : Colors.black.withOpacity(0.08),
            blurRadius: _selectedCardIndex == 8 ? 25 : 20,
            offset: Offset(0, _selectedCardIndex == 8 ? 15 : 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'OPEN POS',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D3748),
                ),
              ),
              Text(
                '-4% vs Last Quarter',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            '\$783,492.73',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.arrow_downward, size: 16, color: Colors.red),
              const SizedBox(width: 4),
              Text(
                '-4% vs Last Q',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

Widget _buildVolumeShippedOverTimeCard() {
  return GestureDetector(
    onTap: () {
      setState(() {
        _selectedCardIndex = 9;
      });
      _cardAnimationController.forward().then((_) {
        Future.delayed(const Duration(milliseconds: 100), () {
          _cardAnimationController.reverse();
          setState(() {
            _selectedCardIndex = -1;
          });
        });
      });
    },
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..rotateX(_selectedCardIndex == 9 ? -0.1 : 0.0)
        ..translate(0.0, _selectedCardIndex == 9 ? -10.0 : 0.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _selectedCardIndex == 9 ? const Color(0xFF3B82F6) : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: _selectedCardIndex == 9
                ? const Color(0xFF3B82F6).withOpacity(0.3)
                : Colors.black.withOpacity(0.08),
            blurRadius: _selectedCardIndex == 9 ? 25 : 20,
            offset: Offset(0, _selectedCardIndex == 9 ? 15 : 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Text(
                  'VOLUME SHIPPED OVER TIME',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D3748),
                  ),
                ),
              ),
              TextButton(
                onPressed: () {},
                child: const Text(
                  'View Full Report',
                  style: TextStyle(
                    color: Color(0xFF3B82F6),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            width: double.infinity,
            child: _buildBarChart(),
          ),
        ],
      ),
    ),
  );
}

// BUG FIX: Bar chart is now interactive and horizontally scrollable
Widget _buildBarChart() {
  return SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: List.generate(_barChartMonths.length, (index) {
        final isHighlighted = index == _selectedBarIndex;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedBarIndex = index;
              });
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (isHighlighted)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    margin: const EdgeInsets.only(bottom: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2D3748),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'GMV: \$${_barChartValues[index]}M',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 20,
                  height: _barChartValues[index] * 15,
                  decoration: BoxDecoration(
                    color: isHighlighted ? const Color(0xFF3B82F6) : Colors.grey.shade300,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _barChartMonths[index],
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    ),
  );
}

Widget _buildTopSourcingRegionsCard() {
  return GestureDetector(
    onTap: () {
      setState(() {
        _selectedCardIndex = 10;
      });
      _cardAnimationController.forward().then((_) {
        Future.delayed(const Duration(milliseconds: 100), () {
          _cardAnimationController.reverse();
          setState(() {
            _selectedCardIndex = -1;
          });
        });
      });
    },
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..rotateX(_selectedCardIndex == 10 ? -0.1 : 0.0)
        ..translate(0.0, _selectedCardIndex == 10 ? -10.0 : 0.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: _selectedCardIndex == 10 ? const Color(0xFF3B82F6) : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: _selectedCardIndex == 10
                ? const Color(0xFF3B82F6).withOpacity(0.3)
                : Colors.black.withOpacity(0.08),
            blurRadius: _selectedCardIndex == 10 ? 25 : 20,
            offset: Offset(0, _selectedCardIndex == 10 ? 15 : 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TOP SOURCING REGIONS',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
          const SizedBox(height: 30),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: SizedBox(
                  height: 120,
                  child: CustomPaint(
                    size: const Size(120, 120),
                    painter: PieChartPainter(),
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                flex: 3, // Give legend more space
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLegendItem('UK', '40%', const Color(0xFF3B82F6)),
                    _buildLegendItem('USA', '26%', const Color(0xFF10B981)),
                    _buildLegendItem('India', '19%', const Color(0xFFF59E0B)),
                    _buildLegendItem('Bangladesh', '10%', const Color(0xFFEF4444)),
                    _buildLegendItem('Other', '5%', Colors.grey),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

Widget _buildLegendItem(String label, String percentage, Color color) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF2D3748),
          ),
        ),
        const Spacer(),
        Text(
          percentage,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3748),
          ),
        ),
      ],
    ),
  );
}

Widget _buildProjectCard(String title, String value, String period, Color color, int index) {
  return GestureDetector(
    onTap: () {
      setState(() {
        _selectedCardIndex = index;
      });
      _cardAnimationController.forward().then((_) {
        Future.delayed(const Duration(milliseconds: 100), () {
          _cardAnimationController.reverse();
          setState(() {
            _selectedCardIndex = -1;
          });
        });
      });
    },
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..rotateX(_selectedCardIndex == index ? -0.1 : 0.0)
        ..translate(0.0, _selectedCardIndex == index ? -10.0 : 0.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _selectedCardIndex == index ? const Color(0xFF3B82F6) : Colors.transparent,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: _selectedCardIndex == index
                ? const Color(0xFF3B82F6).withOpacity(0.3)
                : Colors.black.withOpacity(0.08),
            blurRadius: _selectedCardIndex == index ? 20 : 15,
            offset: Offset(0, _selectedCardIndex == index ? 10 : 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF718096),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              _buildPeriodBox(period),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            value,
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D3748),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildPipelineSection() {
  return SlideTransition(
    position: Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.8, 1.0, curve: Curves.easeOut),
    )),
    child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'ACTIVE PIPELINE DEALS',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3748),
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'View All',
                      style: TextStyle(
                        color: Color(0xFF3B82F6),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildPipelineTable(),
          ],
        ),
      ),
  );
}

// BUG FIX: Replaced buggy animation with AnimatedSwitcher for smooth transitions.
Widget _buildPipelineTable() {
  return Column(
    children: [
      AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: Column(
          key: ValueKey<int>(_currentPage), // Important: Tells switcher content has changed
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F9FA),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Expanded(flex: 2, child: Text('Client', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF718096)))),
                  Expanded(flex: 2, child: Text('Project', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF718096)))),
                  Expanded(flex: 1, child: Text('Est.', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF718096)))),
                  Expanded(flex: 1, child: Text('Stage', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF718096)))),
                  Expanded(flex: 1, child: Text('Manager', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF718096)))),
                ],
              ),
            ),
            const SizedBox(height: 8),
            ..._getCurrentPageDeals().map((deal) => _buildTableRow(
                  deal['client']!,
                  deal['project']!,
                  deal['value']!,
                  deal['status']!,
                  deal['manager']!,
                )).toList(),
          ],
        ),
      ),
      const SizedBox(height: 16),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildPaginationButton('Prev', _currentPage > 0, _prevPage),
          const SizedBox(width: 20),
          Text('Page ${_currentPage + 1} of $_totalPages', style: const TextStyle(color: Color(0xFF718096))),
          const SizedBox(width: 20),
          _buildPaginationButton('Next', _currentPage < _totalPages - 1, _nextPage),
        ],
      ),
    ],
  );
}

Widget _buildTableRow(String client, String project, String value, String status, String manager) {
  Color statusColor;
  switch (status.toLowerCase()) {
    case 'negotiation': statusColor = Colors.orange; break;
    case 'awaiting po': statusColor = Colors.green; break;
    case 'rfq sent': statusColor = const Color(0xFF8B5CF6); break;
    case 'on hold': statusColor = Colors.grey; break;
    default: statusColor = Colors.grey;
  }

  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    margin: const EdgeInsets.only(bottom: 4),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.grey.shade100),
    ),
    child: Row(
      children: [
        Expanded(flex: 2, child: Text(client, style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF2D3748), fontSize: 14))),
        Expanded(flex: 2, child: Text(project, style: TextStyle(color: Colors.grey.shade700, fontSize: 14))),
        Expanded(flex: 1, child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF2D3748), fontSize: 14))),
        Expanded(
          flex: 1,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(status, style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
          ),
        ),
        Expanded(flex: 1, child: Text(manager, style: const TextStyle(color: Color(0xFF2D3748), fontSize: 14, fontWeight: FontWeight.w500))),
      ],
    ),
  );
}

Widget _buildPaginationButton(String text, bool isEnabled, VoidCallback onTap) {
  return GestureDetector(
    onTap: isEnabled ? onTap : null,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isEnabled ? Colors.grey.shade100 : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isEnabled ? const Color(0xFF718096) : Colors.grey.shade400,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
  );
}

Widget _buildDrawer() {
  return Align(
    alignment: Alignment.centerLeft,
    child: AnimatedBuilder(
      animation: _drawerAnimationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(
            (-1 + _drawerAnimationController.value) * (MediaQuery.of(context).size.width * 0.85),
            0,
          ),
          child: child,
        );
      },
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 20,
            )
          ]
        ),
        child: SafeArea(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF4A5568), Color(0xFF2D3748)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Image.asset('assets/images/logo.png'),
                    ),
                    const SizedBox(width: 15),
                    const Expanded(
                      child: Text(
                        'Merchant Portal',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: _toggleDrawer,
                      child: const Icon(Icons.close, color: Colors.white, size: 24),
                    ),
                  ],
                ),
              ),
              MenuDrawer(
                onClose: _toggleDrawer,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
}

// Custom Painter for Circular Progress
class CircularProgressPainter extends CustomPainter {
  final int percentage;
  final double strokeWidth;
  final Color backgroundColor;
  final Color progressColor;

  CircularProgressPainter({
    required this.percentage,
    required this.strokeWidth,
    required this.backgroundColor,
    required this.progressColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    final progressPaint = Paint()
      ..color = progressColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final sweepAngle = (percentage / 100) * 2 * math.pi;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom Painter for Pie Chart
class PieChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final colors = [
      const Color(0xFF3B82F6),
      const Color(0xFF10B981),
      const Color(0xFFF59E0B),
      const Color(0xFFEF4444),
      Colors.grey,
    ];

    final percentages = [40.0, 26.0, 19.0, 10.0, 5.0];
    double startAngle = -math.pi / 2;

    for (int i = 0; i < percentages.length; i++) {
      final sweepAngle = (percentages[i] / 100) * 2 * math.pi;
      final paint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.fill;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );

      startAngle += sweepAngle;
    }

    final centerPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius * 0.5, centerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/global_background.dart';
import '../services/notification_service.dart';
import 'login_screen.dart';

// Tabs
import 'dashboard_tabs/home_tab.dart';
import 'dashboard_tabs/bills_tab.dart';
import 'dashboard_tabs/pay_tab.dart';
import 'dashboard_tabs/history_tab.dart';
import 'dashboard_tabs/profile_tab.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  String userName = '';

  // Ang 5 screens tig-isa bawat menu button natin
  final List<Widget> _pages = [
    const HomeTab(),
    const BillsTab(),
    const PayTab(), // Central floating option
    const HistoryTab(),
    const ProfileTab(),
  ];

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userName = prefs.getString('user_name') ?? 'User';
    });
  }

  Future<void> _handleLogout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    // We intentionally keep the saved_email for biometric purposes

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Papayagan nitong pumasok sa loob ng Navbar and AppBar yung Background natin
      extendBodyBehindAppBar: true,
      extendBody: true,

      // PROFESSIONAL HEADER
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(65.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(
                color: Colors.black.withValues(alpha: 0.5),
                width: 1.0,
              ),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Row(
                children: [
                  // Avatar Indicator
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.black12, width: 2),
                    ),
                    child: const CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.black12,
                      child: Icon(
                        Icons.person,
                        color: Colors.black54,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // User Greetings
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Good Day,',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Text(
                        userName,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                // Notification Bell with Red Dot
                AnimatedBuilder(
                  animation: NotificationService(),
                  builder: (context, child) {
                    bool hasUnread = NotificationService().hasUnread;
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.notifications_none_rounded,
                            color: Colors.black87,
                            size: 28,
                          ),
                          onPressed: () {
                            if (!NotificationService().hasUnread) return;

                            showModalBottomSheet(
                              context: context,
                              backgroundColor: Colors.white,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(20),
                                ),
                              ),
                              builder: (context) {
                                return Container(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'Notifications',
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              NotificationService().clearAll();
                                              Navigator.pop(context);
                                            },
                                            child: const Text('Clear All'),
                                          ),
                                        ],
                                      ),
                                      const Divider(),
                                      ...NotificationService().notifications
                                          .map((notif) {
                                            return ListTile(
                                              leading: const Icon(
                                                Icons.info,
                                                color: Colors.blueAccent,
                                              ),
                                              title: Text(
                                                notif.message,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 13,
                                                ),
                                              ),
                                              contentPadding: EdgeInsets.zero,
                                              visualDensity:
                                                  VisualDensity.compact,
                                            );
                                          }),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),
                        if (hasUnread)
                          Positioned(
                            right: 12,
                            top: 14,
                            child: Container(
                              padding: const EdgeInsets.all(3),
                              decoration: const BoxDecoration(
                                color: Colors.redAccent,
                                shape: BoxShape.circle,
                              ),
                              constraints: const BoxConstraints(
                                minWidth: 10,
                                minHeight: 10,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
                // Minimal Logout Button
                IconButton(
                  icon: const Icon(
                    Icons.logout_rounded,
                    color: Colors.black54,
                    size: 20,
                  ),
                  onPressed: _handleLogout,
                  tooltip: 'Logout',
                ),
                const SizedBox(width: 4),
              ],
            ),
          ),
        ),
      ),

      // BODY WITH GLOBAL BACKGROUND
      body: GlobalBackground(
        child: SafeArea(
          // Important: False 'to para tulong sa extendBody paramater
          bottom: false,
          // Pinapalitan natin ang body page base sa kung ano nai-click sa bottom menu
          child: _pages[_currentIndex],
        ),
      ),

      // TINANGGAL ANG FLOATING CENTER BUTTON DITO

      // BOTTOM MENU
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        elevation: 12, // Stronger shadow for modern floating feel
        // DITO TAYO MAGSESET NG EXACT HEIGHT. Tanggal din padding
        padding: EdgeInsets.zero,
        height: 55, // Strict height parameter of BottomAppBar
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: Colors.black.withValues(alpha: 0.5), width: 1.0),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavButton(
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
                label: 'Home',
                index: 0,
              ),
              _buildNavButton(
                icon: Icons.receipt_long_outlined,
                activeIcon: Icons.receipt_long,
                label: 'Bills',
                index: 1,
              ),
              _buildNavButton(
                icon: Icons.qr_code_scanner_rounded, // or payload icon
                activeIcon: Icons.qr_code_scanner,
                label: 'Pay',
                index: 2,
              ),
              _buildNavButton(
                icon: Icons.history_outlined,
                activeIcon: Icons.history,
                label: 'History',
                index: 3,
              ),
              _buildNavButton(
                icon: Icons.more_horiz_outlined,
                activeIcon: Icons.more_horiz,
                label: 'More',
                index: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Builder func to clean up navigation menus logic
  Widget _buildNavButton({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
  }) {
    final bool isSelected = _currentIndex == index;
    // Bago natin pinalitan ng white background ang menu, dapat visible ang text dito kaya dark ang kulay kapag unselected.
    final Color color = isSelected ? const Color(0xFF0072FF) : Colors.black54;

    return MaterialButton(
      minWidth: 40,
      padding: EdgeInsets.zero,
      onPressed: () {
        if (index == 2) {
          // Disable natin pansamantala lagyan lang ng "Coming soon" Snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Payment Center is coming soon!'),
              duration: Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          setState(() {
            _currentIndex = index;
          });
        }
      },
      splashColor: Colors.transparent, // Disable splash
      highlightColor: Colors.transparent, // Disable tap hold effect
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSelected ? activeIcon : icon,
            color: color,
            size: isSelected ? 26 : 24, // Medyo mas malaki pag pinindot sya
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:ctt/pages/admin/admin_bookings_page.dart';
import 'package:ctt/pages/admin/admin_events_page.dart';
import 'package:ctt/pages/admin/admin_requests_page.dart';
import 'package:ctt/pages/admin/admin_users_page.dart';
import 'package:flutter/material.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _currentIndex = 1;

  final List<Widget> _screens = const [
    AdminEventsScreen(),
    AdminRequestsScreen(),
    AdminBookingsScreen(),
    AdminUsersScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFDF7B3E),
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            const Padding(
              padding: EdgeInsets.only(right: 12),
              child: Icon(
                Icons.dashboard_customize_outlined,
                color: Colors.white,
                size: 28,
              ),
            ),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Admin Dashboard',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    'Ctt Management',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFFFFE0B2),
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            TextButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.keyboard_backspace, size: 20),
              label: const Text('Back'),
              style: TextButton.styleFrom(foregroundColor: Colors.white),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: IndexedStack(index: _currentIndex, children: _screens),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      padding: const EdgeInsets.only(top: 12.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildTabItem(icon: Icons.calendar_today, label: 'Events', index: 0),
          _buildTabItem(
            icon: Icons.description_outlined,
            label: 'Requests',
            index: 1,
          ),
          _buildTabItem(icon: Icons.menu_book, label: 'Bookings', index: 2),
          _buildTabItem(icon: Icons.people_outline, label: 'Users', index: 3),
        ],
      ),
    );
  }

  Widget _buildTabItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final bool isActive = _currentIndex == index;
    final color = isActive ? const Color(0xFFDF7B3E) : Colors.grey.shade500;

    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 3,
              width: 60,
              color: isActive ? const Color(0xFFDF7B3E) : Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }
}

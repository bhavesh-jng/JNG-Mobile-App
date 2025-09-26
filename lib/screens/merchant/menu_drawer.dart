import 'package:flutter/material.dart';

class MenuDrawer extends StatefulWidget {
  final VoidCallback onClose;
  const MenuDrawer({Key? key, required this.onClose}) : super(key: key);

  @override
  State<MenuDrawer> createState() => _MenuDrawerState();
}

class _MenuDrawerState extends State<MenuDrawer> {
  bool _isHrExpanded = false;
  bool _isCustomerProfileExpanded = false;

  @override
  Widget build(BuildContext context) {
    // This widget is now just the scrollable list of menu items.
    // The "Expanded" makes it fill the remaining space in the drawer.
    return Expanded(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          children: [
            // HR One & TRF Section
            _buildDrawerItem(
              title: 'Hr One & TRF',
              icon: Icons.work_outline,
              isExpanded: _isHrExpanded,
              onTap: () {
                setState(() {
                  _isHrExpanded = !_isHrExpanded;
                  if (_isHrExpanded) _isCustomerProfileExpanded = false;
                });
              },
            ),
            if (_isHrExpanded) ...[
              _buildDrawerSubItem('Hr One', () => widget.onClose()),
              _buildDrawerSubItem('Travel Request Form', () => widget.onClose()),
            ],
            const Divider(height: 1, indent: 20, endIndent: 20, thickness: 0.2),

            // Customer Profile Section
            _buildDrawerItem(
              title: 'Customer Profile',
              icon: Icons.person_outline,
              isExpanded: _isCustomerProfileExpanded,
              onTap: () {
                setState(() {
                  _isCustomerProfileExpanded = !_isCustomerProfileExpanded;
                  if (_isCustomerProfileExpanded) _isHrExpanded = false;
                });
              },
            ),
            if (_isCustomerProfileExpanded) ...[
              _buildDrawerSubItem('Pending Requests', () => widget.onClose()),
              _buildDrawerSubItem('Verified Profiles', () => widget.onClose()),
            ],
            const Divider(height: 1, indent: 20, endIndent: 20, thickness: 0.2),
          ],
        ),
      ),
    );
  }

  // The helper methods for building items remain inside this file.
  Widget _buildDrawerItem({
    required String title,
    required IconData icon,
    required bool isExpanded,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        color: isExpanded ? Colors.grey.shade100 : Colors.white,
        child: Row(
          children: [
            Icon(icon, color: Colors.grey.shade700, size: 22),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade800,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: Colors.grey.shade700,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerSubItem(String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: Colors.grey.shade50,
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
        child: Row(
          children: [
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade600,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 37), // Indent to align with text
            Text(
              title,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
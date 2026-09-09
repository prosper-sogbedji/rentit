import 'package:flutter/material.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Widget _buildStatCard({
    required String value,
    required String label,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF6FF),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF2563EB), size: 22),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Color(0xFF64748B),
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Color iconColor = const Color(0xFF2563EB),
    Color iconBg = const Color(0xFFEFF6FF),
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.025),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: Color(0xFFCBD5E1),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'My Profile',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF0F172A),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_none_outlined,
              color: Color(0xFF0F172A),
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // ──── Profile Card ────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Avatar + VerifiedPro badge
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 44,
                        backgroundColor: const Color(0xFF2563EB),
                        child: const Text(
                          'AJ',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Color(0xFF10B981),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Name
                  const Text(
                    'Alex Johnson',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),

                  // VerifiedPro badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFBFDBFE)),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.verified,
                          size: 13,
                          color: Color(0xFF2563EB),
                        ),
                        SizedBox(width: 4),
                        Text(
                          'VerifiedPro',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          '4.9',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        SizedBox(width: 2),
                        Icon(Icons.star, size: 12, color: Color(0xFFF59E0B)),
                        Text(
                          '(128)',
                          style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Description
                  const Text(
                    'Premium tools owner. Always keeping my gear in top shape for every rental.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF64748B),
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Stats Row: 42 RENTALS | $1.2k EARNINGS | 2y MEMBER
                  Row(
                    children: [
                      _buildStatCard(
                        value: '42',
                        label: 'RENTALS',
                        icon: Icons.calendar_today_outlined,
                      ),
                      const SizedBox(width: 10),
                      _buildStatCard(
                        value: '\$1.2k',
                        label: 'EARNINGS',
                        icon: Icons.attach_money,
                      ),
                      const SizedBox(width: 10),
                      _buildStatCard(
                        value: '2y',
                        label: 'MEMBER',
                        icon: Icons.access_time,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ──── RENTAL MANAGEMENT ────
            _buildSectionTitle('RENTAL MANAGEMENT'),
            _buildMenuTile(
              icon: Icons.history,
              title: 'Rental History',
              subtitle: 'View your past and active rentals',
            ),
            _buildMenuTile(
              icon: Icons.credit_card_outlined,
              title: 'Payment Methods',
              subtitle: 'Cards, Wallet, and Billing info',
            ),
            _buildMenuTile(
              icon: Icons.notifications_outlined,
              title: 'Notifications',
              subtitle: 'Alerts for bookings and messages',
            ),

            const SizedBox(height: 8),

            // ──── GENERAL SETTINGS ────
            _buildSectionTitle('GENERAL SETTINGS'),
            _buildMenuTile(
              icon: Icons.person_outline,
              title: 'Personal Information',
              subtitle: 'Edit your name, email, and bio',
              iconColor: const Color(0xFF7C3AED),
              iconBg: const Color(0xFFF5F3FF),
            ),
            _buildMenuTile(
              icon: Icons.security_outlined,
              title: 'Security',
              subtitle: 'Password, 2FA, and Privacy',
              iconColor: const Color(0xFF059669),
              iconBg: const Color(0xFFECFDF5),
            ),
            _buildMenuTile(
              icon: Icons.help_outline,
              title: 'Help & Support',
              subtitle: 'FAQs, Contact us, Terms of Service',
              iconColor: const Color(0xFFF59E0B),
              iconBg: const Color(0xFFFFFBEB),
            ),

            const SizedBox(height: 16),

            // ──── Log Out ────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                },
                icon: const Icon(
                  Icons.logout,
                  color: Color(0xFFEF4444),
                  size: 20,
                ),
                label: const Text(
                  'Log Out',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFFEF4444),
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFFECACA)),
                  backgroundColor: const Color(0xFFFFF5F5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Version Footer
            const Center(
              child: Text(
                'RentIt v1.0.0 (Stable build)',
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFFCBD5E1),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
      // BottomNavigationBar managed by MainShell
    );
  }
}

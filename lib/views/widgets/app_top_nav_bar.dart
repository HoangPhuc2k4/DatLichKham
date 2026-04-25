import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTopNavBar extends StatelessWidget {
  final bool isDesktop;
  final bool isLoggedIn;
  final String activeKey; // 'find_care' | 'specialists' | 'schedule' | 'my_health'
  final VoidCallback onTapFindCare;
  final VoidCallback onTapSpecialists;
  final VoidCallback onTapSchedule;
  final VoidCallback onTapMyHealth;
  final VoidCallback onTapAuth;

  const AppTopNavBar({
    super.key,
    required this.isDesktop,
    required this.isLoggedIn,
    required this.activeKey,
    required this.onTapFindCare,
    required this.onTapSpecialists,
    required this.onTapSchedule,
    required this.onTapMyHealth,
    required this.onTapAuth,
  });

  static const Color _primaryContainer = Color(0xFF2EC4B6);
  static const Color _primary = Color(0xFF006A62);
  static const Color _onSurfaceVariant = Color(0xFF3C4947);

  @override
  Widget build(BuildContext context) {
    void openMobileMenu() {
      showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        ),
        builder: (context) {
          Widget item({
            required IconData icon,
            required String label,
            required bool active,
            required VoidCallback onTap,
          }) {
            return ListTile(
              leading: Icon(icon, color: active ? _primary : _onSurfaceVariant),
              title: Text(
                label,
                style: GoogleFonts.manrope(
                  fontWeight: active ? FontWeight.w900 : FontWeight.w700,
                  color: active ? _primary : _onSurfaceVariant,
                ),
              ),
              onTap: () {
                Navigator.of(context).pop();
                onTap();
              },
            );
          }

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  item(
                    icon: Icons.search,
                    label: 'Tìm bác sĩ',
                    active: activeKey == 'find_care',
                    onTap: onTapFindCare,
                  ),
                  item(
                    icon: Icons.medical_services_outlined,
                    label: 'Chuyên gia',
                    active: activeKey == 'specialists',
                    onTap: onTapSpecialists,
                  ),
                  item(
                    icon: Icons.calendar_today_outlined,
                    label: 'Lịch hẹn',
                    active: activeKey == 'schedule',
                    onTap: onTapSchedule,
                  ),
                  item(
                    icon: Icons.favorite_border,
                    label: 'Sức khỏe',
                    active: activeKey == 'my_health',
                    onTap: onTapMyHealth,
                  ),
                  const Divider(height: 18),
                  ListTile(
                    leading: Icon(
                      isLoggedIn ? Icons.logout : Icons.login,
                      color: _primary,
                    ),
                    title: Text(
                      isLoggedIn ? 'Đăng xuất' : 'Đăng nhập',
                      style: GoogleFonts.manrope(
                        fontWeight: FontWeight.w900,
                        color: _primary,
                      ),
                    ),
                    onTap: () {
                      Navigator.of(context).pop();
                      onTapAuth();
                    },
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    return SizedBox(
      height: 64,
      child: ClipRect(
        child: Stack(
        children: [
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                color: Colors.white.withValues(alpha: 0.80),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                InkWell(
                  onTap: () => Navigator.of(context).pushReplacementNamed('/user/home'),
                  child: Text(
                    'Curated Clinic',
                    style: GoogleFonts.epilogue(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.4,
                      color: const Color(0xFF191C1D),
                    ),
                  ),
                ),
                if (isDesktop)
                  Row(
                    children: [
                      _NavItem(
                        label: 'Tìm bác sĩ',
                        active: activeKey == 'find_care',
                        onTap: onTapFindCare,
                      ),
                      const SizedBox(width: 18),
                      _NavItem(
                        label: 'Chuyên gia',
                        active: activeKey == 'specialists',
                        onTap: onTapSpecialists,
                      ),
                      const SizedBox(width: 18),
                      _NavItem(
                        label: 'Lịch hẹn',
                        active: activeKey == 'schedule',
                        onTap: onTapSchedule,
                      ),
                      const SizedBox(width: 18),
                      _NavItem(
                        label: 'Sức khỏe',
                        active: activeKey == 'my_health',
                        onTap: onTapMyHealth,
                      ),
                    ],
                  ),
                Row(
                  children: [
                    if (isDesktop)
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: _primaryContainer,
                          side: BorderSide.none,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: onTapAuth,
                        child: Text(
                          isLoggedIn ? 'Đăng xuất' : 'Đăng nhập',
                          style: GoogleFonts.manrope(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      )
                    else
                      IconButton(
                        tooltip: 'Menu',
                        onPressed: openMobileMenu,
                        icon: const Icon(Icons.menu),
                      ),
                    const SizedBox(width: 12),
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.black.withValues(alpha: 0.08),
                      child: Icon(
                        Icons.person,
                        size: 16,
                        color: isLoggedIn ? _primary : _onSurfaceVariant,
                      ),
                    ),
                  ],
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

class _NavItem extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({
    required this.label,
    required this.active,
    required this.onTap,
  });

  static const Color _primaryContainer = Color(0xFF2EC4B6);
  static const Color _onSurfaceVariant = Color(0xFF3C4947);

  @override
  Widget build(BuildContext context) {
    final color = active ? _primaryContainer : _onSurfaceVariant;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: GoogleFonts.manrope(
                fontSize: 13,
                fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                color: color,
              ),
            ),
            const SizedBox(height: 6),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              height: 2,
              width: active ? 34 : 0,
              color: _primaryContainer,
            ),
          ],
        ),
      ),
    );
  }
}


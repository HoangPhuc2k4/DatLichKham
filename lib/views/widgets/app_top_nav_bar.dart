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

  // Hệ màu đồng bộ với thiết kế Curated Clinic
  static const Color _tealPrimary = Color(0xFF0D9488);
  static const Color _slate900 = Color(0xFF0F172A);
  static const Color _slate600 = Color(0xFF475569);

  @override
  Widget build(BuildContext context) {
    void openMobileMenu() {
      showModalBottomSheet<void>(
        context: context,
        showDragHandle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        builder: (context) {
          Widget item({
            required IconData icon,
            required String label,
            required bool active,
            required VoidCallback onTap,
          }) {
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
              leading: Icon(icon, color: active ? _tealPrimary : _slate600),
              title: Text(
                label,
                style: GoogleFonts.manrope(
                  fontSize: 16,
                  fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                  color: active ? _tealPrimary : _slate600,
                ),
              ),
              onTap: () {
                Navigator.of(context).pop();
                onTap();
              },
            );
          }

          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                item(icon: Icons.search_rounded, label: 'Tìm bác sĩ', active: activeKey == 'find_care', onTap: onTapFindCare),
                item(icon: Icons.medical_services_outlined, label: 'Chuyên gia', active: activeKey == 'specialists', onTap: onTapSpecialists),
                item(icon: Icons.calendar_today_rounded, label: 'Lịch hẹn', active: activeKey == 'schedule', onTap: onTapSchedule),
                item(icon: Icons.health_and_safety_outlined, label: 'Sức khỏe', active: activeKey == 'my_health', onTap: onTapMyHealth),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Divider(height: 32, thickness: 1),
                ),
                item(
                  icon: isLoggedIn ? Icons.logout_rounded : Icons.login_rounded,
                  label: isLoggedIn ? 'Đăng xuất' : 'Đăng nhập',
                  active: false,
                  onTap: onTapAuth,
                ),
                const SizedBox(height: 12),
              ],
            ),
          );
        },
      );
    }

    return Container(
      height: 72,
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.black.withOpacity(0.05))),
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            color: Colors.white.withOpacity(0.85),
            padding: EdgeInsets.symmetric(horizontal: isDesktop ? 40 : 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Logo Section
                InkWell(
                  onTap: () => Navigator.of(context).pushReplacementNamed('/user/home'),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _tealPrimary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.health_and_safety, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Curated Clinic',
                        style: GoogleFonts.epilogue(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: _slate900,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),

                // Desktop Navigation
                if (isDesktop)
                  Row(
                    children: [
                      _NavItem(label: 'Tìm bác sĩ', active: activeKey == 'find_care', onTap: onTapFindCare),
                      const SizedBox(width: 32),
                      _NavItem(label: 'Chuyên gia', active: activeKey == 'specialists', onTap: onTapSpecialists),
                      const SizedBox(width: 32),
                      _NavItem(label: 'Lịch hẹn', active: activeKey == 'schedule', onTap: onTapSchedule),
                      const SizedBox(width: 32),
                      _NavItem(label: 'Sức khỏe', active: activeKey == 'my_health', onTap: onTapMyHealth),
                    ],
                  ),

                // Auth Section
                Row(
                  children: [
                    if (isDesktop)
                      ElevatedButton(
                        onPressed: onTapAuth,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isLoggedIn ? Colors.white : _slate900,
                          foregroundColor: isLoggedIn ? _slate900 : Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: isLoggedIn ? BorderSide(color: Colors.grey[200]!) : BorderSide.none,
                          ),
                        ),
                        child: Text(
                          isLoggedIn ? 'Đăng xuất' : 'Đăng nhập',
                          style: GoogleFonts.manrope(fontWeight: FontWeight.w800, fontSize: 14),
                        ),
                      )
                    else
                      IconButton(
                        onPressed: openMobileMenu,
                        icon: const Icon(Icons.menu_rounded, color: _slate900),
                      ),

                    if (isLoggedIn && isDesktop) ...[
                      const SizedBox(width: 16),
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: _tealPrimary.withOpacity(0.1),
                        child: const Icon(Icons.person_rounded, color: _tealPrimary, size: 22),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      hoverColor: Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: GoogleFonts.manrope(
              fontSize: 14,
              fontWeight: active ? FontWeight.w800 : FontWeight.w600,
              color: active ? const Color(0xFF0D9488) : const Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 4),
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            height: 3,
            width: active ? 20 : 0,
            decoration: BoxDecoration(
              color: const Color(0xFF0D9488),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ],
      ),
    );
  }
}
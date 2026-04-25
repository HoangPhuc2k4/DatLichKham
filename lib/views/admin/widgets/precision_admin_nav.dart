import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../controllers/session_controller.dart';
import '../precision_admin_shell.dart';

class PrecisionAdminSidebar extends StatelessWidget {
  final PrecisionAdminRoute active;
  const PrecisionAdminSidebar({super.key, required this.active});

  static const _navBg = Color(0xFF012435);
  static const _accent = Color(0xFF006A62);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _navBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 28),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'QUẢN TRỊ',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Bảng điều khiển v1.0',
                  style: GoogleFonts.manrope(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2,
                    color: Colors.white.withValues(alpha: 0.45),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _NavItem(
            label: 'Tổng quan',
            icon: Icons.dashboard_outlined,
            active: active == PrecisionAdminRoute.dashboard,
            onTap: () => Navigator.of(context).pushReplacementNamed('/admin/dashboard'),
          ),
          _NavItem(
            label: 'Quản lý lịch khám',
            icon: Icons.group_outlined,
            active: active == PrecisionAdminRoute.appointments,
            onTap: () => Navigator.of(context).pushReplacementNamed('/admin/appointments'),
          ),
          _NavItem(
            label: 'Quản lý bác sĩ',
            icon: Icons.badge_outlined,
            active: active == PrecisionAdminRoute.doctors,
            onTap: () => Navigator.of(context).pushReplacementNamed('/admin/doctors'),
          ),
          _NavItem(
            label: 'Xếp lịch',
            icon: Icons.calendar_today_outlined,
            active: active == PrecisionAdminRoute.schedules,
            onTap: () => Navigator.of(context).pushReplacementNamed('/admin/schedules'),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(18),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF341C00),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              ),
              onPressed: () {},
              child: Text(
                'CHẾ ĐỘ KHẨN CẤP',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {},
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  color: Colors.white70,
                  icon: const Icon(Icons.settings_outlined, size: 18),
                ),
                IconButton(
                  onPressed: () {},
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                  color: Colors.white70,
                  icon: const Icon(Icons.contact_support_outlined, size: 18),
                ),
                const Spacer(),
                Flexible(
                  child: TextButton(
                    onPressed: () {
                      SessionController.instance.logout();
                      Navigator.of(context).pushReplacementNamed('/');
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: _accent,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Đăng xuất',
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PrecisionAdminTopBar extends StatelessWidget {
  final String? hint;
  final ValueChanged<String>? onQueryChanged;
  const PrecisionAdminTopBar({super.key, this.hint, this.onQueryChanged});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: ClipRect(
        child: Stack(
          children: [
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Container(color: Colors.white.withValues(alpha: 0.80)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F5),
                        border: Border.all(
                          color: const Color(0xFFC2C7CC).withValues(alpha: 0.55),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          Icon(Icons.search, size: 18, color: Colors.black.withValues(alpha: 0.35)),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextField(
                              onChanged: onQueryChanged,
                              decoration: InputDecoration(
                                hintText: (hint ?? 'TÌM KIẾM...').toUpperCase(),
                                hintStyle: GoogleFonts.manrope(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1.6,
                                  color: Colors.black.withValues(alpha: 0.35),
                                ),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                              style: GoogleFonts.manrope(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.6,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_none)),
                  IconButton(onPressed: () {}, icon: const Icon(Icons.help_outline)),
                  const SizedBox(width: 8),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(color: Color(0xFF1B3A4B)),
                    child: const Icon(Icons.person, color: Colors.white, size: 18),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  const _NavItem({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  static const _accent = Color(0xFF006A62);

  @override
  Widget build(BuildContext context) {
    final bg = active ? Colors.white.withValues(alpha: 0.10) : Colors.transparent;
    final fg = active ? _accent : Colors.white.withValues(alpha: 0.60);
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          border: Border(
            right: BorderSide(color: active ? _accent : Colors.transparent, width: 4),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 18, color: fg),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label.toUpperCase(),
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                  letterSpacing: 1.2,
                  color: fg,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


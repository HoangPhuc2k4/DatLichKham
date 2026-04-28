import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTopNavBar extends StatelessWidget {
  final bool isDesktop;
  final bool isLoggedIn;
  final String activeKey;
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

  // Hệ màu đồng bộ với thiết kế Premium
  static const Color _primary = Color(0xFF006A62);
  static const Color _accent = Color(0xFF2EC4B6);
  static const Color _textMain = Color(0xFF191C1D);
  static const Color _textSub = Color(0xFF3C4947);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80, // Tăng độ cao một chút để trông thoáng hơn
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20), // Hiệu ứng kính mờ (Frosted Glass)
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: isDesktop ? 40 : 20),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Colors.black.withOpacity(0.05), width: 1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildLogo(context),
                if (isDesktop) _buildDesktopNav(),
                _buildActions(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context).pushReplacementNamed('/user/home'),
      borderRadius: BorderRadius.circular(8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Text(
            'Curated Clinic',
            style: GoogleFonts.epilogue(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
              color: _textMain,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopNav() {
    return Row(
      children: [
        _ModernNavItem(label: 'Tìm bác sĩ', active: activeKey == 'find_care', onTap: onTapFindCare),
        const SizedBox(width: 32),
        _ModernNavItem(label: 'Chuyên gia', active: activeKey == 'specialists', onTap: onTapSpecialists),
        const SizedBox(width: 32),
        _ModernNavItem(label: 'Lịch hẹn', active: activeKey == 'schedule', onTap: onTapSchedule),
        const SizedBox(width: 32),
        _ModernNavItem(label: 'Sức khỏe', active: activeKey == 'my_health', onTap: onTapMyHealth),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    return Row(
      children: [
        if (isDesktop)
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isLoggedIn ? Colors.white : _primary,
              foregroundColor: isLoggedIn ? _textMain : Colors.white,
              elevation: 0,
              side: isLoggedIn ? BorderSide(color: Colors.black.withOpacity(0.1)) : BorderSide.none,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: onTapAuth,
            child: Text(
              isLoggedIn ? 'Đăng xuất' : 'Đăng nhập',
              style: GoogleFonts.manrope(fontWeight: FontWeight.w800, fontSize: 14),
            ),
          )
        else
          IconButton(
            onPressed: () => _showMobileMenu(context),
            icon: const Icon(Icons.notes_rounded, size: 28), // Icon menu nghệ thuật hơn
          ),
        const SizedBox(width: 16),
        // Avatar Indicator
        Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: isLoggedIn ? _accent : Colors.transparent, width: 2),
          ),
          child: CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFFF2F4F4),
            child: Icon(Icons.person_outline, size: 20, color: isLoggedIn ? _primary : _textSub),
          ),
        ),
      ],
    );
  }

  void _showMobileMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.black12, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            _mobileItem(Icons.search, 'Tìm bác sĩ', activeKey == 'find_care', onTapFindCare, context),
            _mobileItem(Icons.star_outline, 'Chuyên gia', activeKey == 'specialists', onTapSpecialists, context),
            _mobileItem(Icons.calendar_today, 'Lịch hẹn', activeKey == 'schedule', onTapSchedule, context),
            _mobileItem(Icons.favorite_border, 'Sức khỏe', activeKey == 'my_health', onTapMyHealth, context),
            const Divider(height: 40),
            ListTile(
              leading: Icon(isLoggedIn ? Icons.logout : Icons.login, color: _primary),
              title: Text(isLoggedIn ? 'Đăng xuất' : 'Đăng nhập', style: GoogleFonts.manrope(fontWeight: FontWeight.w800)),
              onTap: () { Navigator.pop(context); onTapAuth(); },
            ),
          ],
        ),
      ),
    );
  }

  Widget _mobileItem(IconData icon, String label, bool active, VoidCallback onTap, BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: active ? _primary : _textSub),
      title: Text(label, style: GoogleFonts.manrope(fontWeight: active ? FontWeight.w900 : FontWeight.w600, color: active ? _primary : _textSub)),
      onTap: () { Navigator.pop(context); onTap(); },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      tileColor: active ? _primary.withOpacity(0.05) : null,
    );
  }
}

class _ModernNavItem extends StatefulWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _ModernNavItem({required this.label, required this.active, required this.onTap});

  @override
  State<_ModernNavItem> createState() => _ModernNavItemState();
}

class _ModernNavItemState extends State<_ModernNavItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final activeColor = const Color(0xFF006A62);
    final baseColor = const Color(0xFF3C4947);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        onTap: widget.onTap,
        hoverColor: Colors.transparent,
        splashColor: Colors.transparent,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.label,
              style: GoogleFonts.manrope(
                fontSize: 14,
                fontWeight: widget.active ? FontWeight.w800 : FontWeight.w600,
                color: widget.active || _isHovered ? activeColor : baseColor,
              ),
            ),
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              height: 3,
              width: widget.active ? 20 : (_isHovered ? 12 : 0),
              decoration: BoxDecoration(
                color: activeColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
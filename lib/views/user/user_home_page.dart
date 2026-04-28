import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../widgets/doctor_image.dart';
import '../widgets/app_top_nav_bar.dart';
import '../widgets/app_footer.dart';
import '../../controllers/session_controller.dart';

class UserHomePage extends StatelessWidget {
  const UserHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isLoggedIn = SessionController.instance.currentUser != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFA),
      body: SafeArea(
        child: Column(
          children: [
            AppTopNavBar(
              isDesktop: width >= 900,
              isLoggedIn: isLoggedIn,
              activeKey: 'find_care',
              onTapFindCare: () {},
              onTapSpecialists: () => Navigator.of(context).pushNamed('/user/doctors'),
              onTapSchedule: () => Navigator.of(context).pushNamed('/user/appointments'),
              onTapMyHealth: () => Navigator.of(context).pushNamed('/user/appointments'),
              onTapAuth: () {
                if (isLoggedIn) {
                  SessionController.instance.logout();
                  Navigator.of(context).pushReplacementNamed('/user/home');
                } else {
                  Navigator.of(context).pushNamed('/');
                }
              },
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1440),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: width < 600 ? 16 : 40,
                        vertical: 32,
                      ),
                      child: Column(
                        children: [
                          _HeroSection(width: width),
                          const SizedBox(height: 80),
                          const _SpecialistsSection(),
                          const SizedBox(height: 80),
                          const _ExperienceCareSection(),
                          const SizedBox(height: 100),
                          const AppFooter(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  final double width;
  const _HeroSection({required this.width});

  @override
  Widget build(BuildContext context) {
    final isDesktop = width > 1000;
    return isDesktop
        ? Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(flex: 6, child: _HeroContent()),
        const SizedBox(width: 60),
        Expanded(flex: 5, child: _HeroVisual()),
      ],
    )
        : Column(
      children: [
        _HeroContent(),
        const SizedBox(height: 48),
        _HeroVisual(),
      ],
    );
  }
}

class _HeroContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF006A62).withOpacity(0.1),
            borderRadius: BorderRadius.circular(99),
          ),
          child: Text(
            'HỆ THỐNG Y TẾ CAO CẤP',
            style: GoogleFonts.manrope(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
              color: const Color(0xFF006A62),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Health,\nCarefully Curated.',
          style: GoogleFonts.epilogue(
            fontSize: 64,
            fontWeight: FontWeight.w900,
            height: 1.0,
            color: const Color(0xFF191C1D),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Trải nghiệm dịch vụ y tế đẳng cấp quốc tế. Kết nối trực tiếp với các chuyên gia đầu ngành trong không gian số cá nhân hóa.',
          style: GoogleFonts.manrope(
            fontSize: 18,
            height: 1.6,
            color: const Color(0xFF3C4947).withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 40),
        _ModernSearchBar(),
      ],
    );
  }
}

class _ModernSearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          const Icon(Icons.search, color: Color(0xFF006A62)),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Tìm chuyên khoa, bác sĩ...',
                hintStyle: GoogleFonts.manrope(color: Colors.grey),
                border: InputBorder.none,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF006A62),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: Text('Tìm kiếm', style: GoogleFonts.manrope(fontWeight: FontWeight.w800, color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _HeroVisual extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 500,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(48),
            image: const DecorationImage(
              image: NetworkImage('https://images.unsplash.com/photo-1631217818202-90ef4a851c9c?q=80&w=2000'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          bottom: 30,
          left: -20,
          child: _GlassCard(
            child: Row(
              children: [
                const CircleAvatar(backgroundColor: Color(0xFFF99A15), child: Icon(Icons.star, color: Colors.white)),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('4.9/5 Rating', style: GoogleFonts.epilogue(fontWeight: FontWeight.w900)),
                    Text('Từ 2,000+ bệnh nhân', style: GoogleFonts.manrope(fontSize: 12)),
                  ],
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;
  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          color: Colors.white.withOpacity(0.8),
          child: child,
        ),
      ),
    );
  }
}

class _SpecialistsSection extends StatelessWidget {
  const _SpecialistsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('CHUYÊN GIA ĐƯỢC ĐỀ XUẤT', style: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.w900, color: const Color(0xFF895100), letterSpacing: 1.5)),
                const SizedBox(height: 8),
                Text('Đội ngũ y bác sĩ ưu tú', style: GoogleFonts.epilogue(fontSize: 32, fontWeight: FontWeight.w900)),
              ],
            ),
            TextButton(
              onPressed: () {},
              child: Text('Xem tất cả →', style: GoogleFonts.manrope(fontWeight: FontWeight.w800, color: const Color(0xFF006A62))),
            )
          ],
        ),
        const SizedBox(height: 40),
        SizedBox(
          height: 400,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: const [
              _ModernDoctorCard(name: 'Dr. Sarah Jenkins', specialty: 'Tim mạch', rating: '4.9', imageIdx: 1),
              SizedBox(width: 24),
              _ModernDoctorCard(name: 'Dr. Marcus Thorne', specialty: 'Thần kinh', rating: '5.0', imageIdx: 2),
              SizedBox(width: 24),
              _ModernDoctorCard(name: 'Dr. Elena Rodriguez', specialty: 'Nhi khoa', rating: '4.8', imageIdx: 3),
            ],
          ),
        ),
      ],
    );
  }
}

class _ModernDoctorCard extends StatelessWidget {
  final String name, specialty, rating;
  final int imageIdx;
  const _ModernDoctorCard({required this.name, required this.specialty, required this.rating, required this.imageIdx});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        children: [
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                image: DecorationImage(
                  image: NetworkImage('http://googleusercontent.com/profile/picture/$imageIdx'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: GoogleFonts.epilogue(fontWeight: FontWeight.w900, fontSize: 18)),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(specialty, style: GoogleFonts.manrope(color: const Color(0xFF006A62), fontWeight: FontWeight.w700)),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Color(0xFFF99A15), size: 16),
                        Text(rating, style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    )
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _ExperienceCareSection extends StatelessWidget {
  const _ExperienceCareSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(48),
      decoration: BoxDecoration(
        color: const Color(0xFF1B3A4B),
        borderRadius: BorderRadius.circular(48),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Y tế số không rào cản.',
                  style: GoogleFonts.epilogue(color: Colors.white, fontSize: 40, fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 32),
                _FeatureBullet(icon: Icons.flash_on, title: 'Đặt lịch tức thì', desc: 'Xác nhận lịch hẹn chỉ trong 60 giây.'),
                const SizedBox(height: 24),
                _FeatureBullet(icon: Icons.videocam, title: 'Tư vấn Hybrid', desc: 'Linh hoạt giữa Online và trực tiếp tại phòng khám.'),
              ],
            ),
          ),
          const SizedBox(width: 48),
          Expanded(
            child: Container(
              height: 300,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
              ),
              child: const Center(child: Icon(Icons.play_circle_fill, size: 80, color: Colors.white)),
            ),
          )
        ],
      ),
    );
  }
}

class _FeatureBullet extends StatelessWidget {
  final IconData icon;
  final String title, desc;
  const _FeatureBullet({required this.icon, required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: const Color(0xFF2EC4B6).withOpacity(0.2), borderRadius: BorderRadius.circular(16)),
          child: Icon(icon, color: const Color(0xFF2EC4B6)),
        ),
        const SizedBox(width: 20),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.manrope(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18)),
              Text(desc, style: GoogleFonts.manrope(color: Colors.white60)),
            ],
          ),
        )
      ],
    );
  }
}
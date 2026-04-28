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
      backgroundColor: const Color(0xFFF8FAFC),
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
                physics: const BouncingScrollPhysics(),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: width < 600 ? 20 : 40,
                        vertical: 40,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _HeroSection(width: width),
                          const SizedBox(height: 80),
                          _SpecialistsSection(width: width),
                          const SizedBox(height: 80),
                          _FeaturesBentoGrid(width: width),
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
    final isMobile = width < 900;
    return Column(
      crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        if (isMobile) const _HeroImageMobile(),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0D9488).withAlpha(20),
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      'HỆ THỐNG Y TẾ CURATED',
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0D9488),
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Chăm sóc sức khỏe\ntheo cách tinh hoa.',
                    textAlign: isMobile ? TextAlign.center : TextAlign.start,
                    style: GoogleFonts.epilogue(
                      fontSize: width < 600 ? 42 : 64,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF0F172A),
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Kết nối trực tiếp với các chuyên gia đầu ngành. Trải nghiệm quy trình đặt lịch minh bạch, không chờ đợi.',
                    textAlign: isMobile ? TextAlign.center : TextAlign.start,
                    style: GoogleFonts.manrope(
                      fontSize: 18,
                      color: const Color(0xFF475569),
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 40),
                  _MainSearchBar(isMobile: isMobile),
                ],
              ),
            ),
            if (!isMobile)
              const Expanded(
                flex: 2,
                child: Padding(
                  padding: EdgeInsets.only(left: 60),
                  child: _HeroImageDesktop(),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _MainSearchBar extends StatelessWidget {
  final bool isMobile;
  const _MainSearchBar({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
      ),
      child: isMobile
          ? Column(
        children: [
          _buildSearchField(Icons.search, 'Tên bác sĩ hoặc chuyên khoa'),
          const Divider(),
          _buildSearchField(Icons.location_on_outlined, 'Vị trí'),
          const SizedBox(height: 8),
          _buildSearchButton(true),
        ],
      )
          : Row(
        children: [
          Expanded(child: _buildSearchField(Icons.search, 'Tên bác sĩ hoặc chuyên khoa')),
          Container(width: 1, height: 30, color: Colors.grey[200]),
          Expanded(child: _buildSearchField(Icons.location_on_outlined, 'Vị trí')),
          _buildSearchButton(false),
        ],
      ),
    );
  }

  Widget _buildSearchField(IconData icon, String hint) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF0D9488), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: hint,
                border: InputBorder.none,
                hintStyle: GoogleFonts.manrope(color: Colors.grey[400], fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchButton(bool fullWidth) {
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF0F172A),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 0,
      ),
      child: Text(
        'Tìm kiếm',
        style: GoogleFonts.manrope(fontWeight: FontWeight.w800),
      ),
    );
  }
}

class _HeroImageDesktop extends StatelessWidget {
  const _HeroImageDesktop();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 500,
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(40),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: const DoctorImage(
              pathOrUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuALzjGvI7RG-nVb5i62uMGRIwFkn1VaqIEJ8dKwOcBzjlE7JUMqqfVK3jB3wP_6m-OTymNgCeFebtLzZVBBTkhje88MfyZpwpcMWD3qRFtUouC4n04EA6-xdx_OcLODpP-vTLmT1IBVjaZQFDLbB-1t8I1jWtSznl57ZAN2te6dDUhf-uaogBTbThrBf76asK89gxPyYU8WKwT0cfmdpfBJ7jbuW-y3jSfnNCCMja3qm9C3IxCyCDl31BCMqkygDCGhWeX7Pr2pwbA',
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            bottom: 40,
            left: -30,
            child: _InfoCard(
              icon: Icons.star_rounded,
              title: '4.9/5.0',
              subtitle: 'Đánh giá trung bình',
              color: const Color(0xFFF59E0B),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroImageMobile extends StatelessWidget {
  const _HeroImageMobile();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 32),
      height: 300,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(32),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: const DoctorImage(
          pathOrUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuALzjGvI7RG-nVb5i62uMGRIwFkn1VaqIEJ8dKwOcBzjlE7JUMqqfVK3jB3wP_6m-OTymNgCeFebtLzZVBBTkhje88MfyZpwpcMWD3qRFtUouC4n04EA6-xdx_OcLODpP-vTLmT1IBVjaZQFDLbB-1t8I1jWtSznl57ZAN2te6dDUhf-uaogBTbThrBf76asK89gxPyYU8WKwT0cfmdpfBJ7jbuW-y3jSfnNCCMja3qm9C3IxCyCDl31BCMqkygDCGhWeX7Pr2pwbA',
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final Color color;

  const _InfoCard({required this.icon, required this.title, required this.subtitle, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 20)],
      ),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: color.withAlpha(30), child: Icon(icon, color: color)),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.epilogue(fontWeight: FontWeight.w900, fontSize: 18)),
              Text(subtitle, style: GoogleFonts.manrope(color: Colors.grey[600], fontSize: 12)),
            ],
          )
        ],
      ),
    );
  }
}

class _SpecialistsSection extends StatelessWidget {
  final double width;
  const _SpecialistsSection({required this.width});

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
                Text('CHUYÊN GIA NỔI BẬT', style: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.w800, color: const Color(0xFFF59E0B), letterSpacing: 1.5)),
                const SizedBox(height: 8),
                Text('Đội ngũ bác sĩ hàng đầu', style: GoogleFonts.epilogue(fontSize: 32, fontWeight: FontWeight.w900, color: const Color(0xFF0F172A))),
              ],
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pushNamed('/user/doctors'),
              child: Text('Xem tất cả →', style: GoogleFonts.manrope(fontWeight: FontWeight.w800, color: const Color(0xFF0D9488))),
            ),
          ],
        ),
        const SizedBox(height: 40),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: width < 600 ? 1 : width < 1000 ? 2 : 3,
          mainAxisSpacing: 24,
          crossAxisSpacing: 24,
          childAspectRatio: 0.85,
          children: const [
            _DoctorCard(name: 'BS. Sarah Jenkins', role: 'Tim mạch', image: '1'),
            _DoctorCard(name: 'BS. Marcus Thorne', role: 'Thần kinh', image: '2'),
            _DoctorCard(name: 'BS. Elena Rodriguez', role: 'Nhi khoa', image: '3'),
          ],
        ),
      ],
    );
  }
}

class _DoctorCard extends StatelessWidget {
  final String name, role, image;
  const _DoctorCard({required this.name, required this.role, required this.image});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: DoctorImage(
                pathOrUrl: 'http://googleusercontent.com/profile/picture/$image',
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(name, style: GoogleFonts.epilogue(fontSize: 18, fontWeight: FontWeight.w800)),
          Text(role, style: GoogleFonts.manrope(color: const Color(0xFF0D9488), fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _FeaturesBentoGrid extends StatelessWidget {
  final double width;
  const _FeaturesBentoGrid({required this.width});

  @override
  Widget build(BuildContext context) {
    final isMobile = width < 900;
    return Column(
      children: [
        Text(
          'Tại sao chọn Curated Clinic?',
          style: GoogleFonts.epilogue(fontSize: 32, fontWeight: FontWeight.w900, color: const Color(0xFF0F172A)),
        ),
        const SizedBox(height: 48),
        isMobile
            ? Column(
          children: [
            _FeatureItem(icon: Icons.bolt, title: 'Đặt lịch tức thì', desc: 'Xác nhận lịch hẹn chỉ trong 60 giây.', color: const Color(0xFF0D9488)),
            const SizedBox(height: 16),
            _FeatureItem(icon: Icons.video_camera_front, title: 'Tư vấn từ xa', desc: 'Gặp bác sĩ mọi lúc mọi nơi qua video.', color: const Color(0xFFF59E0B)),
          ],
        )
            : Row(
          children: [
            Expanded(child: _FeatureItem(icon: Icons.bolt, title: 'Đặt lịch tức thì', desc: 'Xác nhận lịch hẹn chỉ trong 60 giây.', color: const Color(0xFF0D9488))),
            const SizedBox(width: 24),
            Expanded(child: _FeatureItem(icon: Icons.video_camera_front, title: 'Tư vấn từ xa', desc: 'Gặp bác sĩ mọi lúc mọi nơi qua video.', color: const Color(0xFFF59E0B))),
            const SizedBox(width: 24),
            Expanded(child: _FeatureItem(icon: Icons.folder_special, title: 'Hồ sơ bảo mật', desc: 'Lưu trữ bệnh án an toàn tuyệt đối.', color: const Color(0xFF0F172A))),
          ],
        ),
      ],
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title, desc;
  final Color color;

  const _FeatureItem({required this.icon, required this.title, required this.desc, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: color.withAlpha(10),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 24),
          Text(title, style: GoogleFonts.epilogue(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          Text(desc, style: GoogleFonts.manrope(color: const Color(0xFF475569), fontSize: 15, height: 1.5)),
        ],
      ),
    );
  }
}
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../controllers/doctor_controller.dart';
import '../../controllers/session_controller.dart';
import '../../models/doctor.dart';
import '../widgets/app_footer.dart';
import '../widgets/app_top_nav_bar.dart';
import '../widgets/doctor_image.dart';

class CuratedClinicHomePage extends StatefulWidget {
  const CuratedClinicHomePage({super.key});

  @override
  State<CuratedClinicHomePage> createState() => _CuratedClinicHomePageState();
}

class _CuratedClinicHomePageState extends State<CuratedClinicHomePage> {
  late final Future<List<Doctor>> _doctorsFuture;
  final _scrollController = ScrollController();
  final _doctorSearchController = TextEditingController();
  final _specialistsKey = GlobalKey();

  static const Color kPrimary = Color(0xFF0D9488);
  static const Color kBackground = Color(0xFFF8FAFC);
  static const Color kTextDark = Color(0xFF0F172A);

  @override
  void initState() {
    super.initState();
    _doctorsFuture = DoctorController.instance.getAllDoctors();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _doctorSearchController.dispose();
    super.dispose();
  }

  Future<void> _scrollTo(GlobalKey key) async {
    final ctx = key.currentContext;
    if (ctx == null) return;
    await Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= 900;
    final user = SessionController.instance.currentUser;

    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(
        child: Column(
          children: [
            AppTopNavBar(
              isDesktop: isDesktop,
              isLoggedIn: user != null,
              activeKey: 'find_care',
              onTapFindCare: () => Navigator.of(context).pushReplacementNamed('/user/doctors'),
              onTapSpecialists: () => _scrollTo(_specialistsKey),
              onTapSchedule: () => Navigator.of(context).pushNamed('/user/appointments'),
              onTapMyHealth: () => Navigator.of(context).pushNamed('/user/appointments'),
              onTapAuth: () {
                if (user == null) {
                  Navigator.of(context).pushNamed('/');
                } else {
                  SessionController.instance.logout();
                  Navigator.of(context).pushReplacementNamed('/user/home');
                }
              },
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: width < 600 ? 20 : 40, vertical: 40),
                      child: Column(
                        children: [
                          _HeroSection(
                            isDesktop: isDesktop,
                            searchController: _doctorSearchController,
                            onSearch: () {
                              final q = _doctorSearchController.text.trim();
                              Navigator.of(context).pushNamed('/user/doctors', arguments: q);
                            },
                          ),
                          const SizedBox(height: 100),
                          _buildSectionTitle('Chuyên gia nổi bật', 'Gợi ý hàng đầu cho sức khỏe của bạn'),
                          const SizedBox(height: 32),
                          FutureBuilder<List<Doctor>>(
                            key: _specialistsKey,
                            future: _doctorsFuture,
                            builder: (context, snap) {
                              if (!snap.hasData) return const Center(child: CircularProgressIndicator(color: kPrimary));
                              return _SpecialistsGrid(doctors: snap.data!, isLoggedIn: user != null);
                            },
                          ),
                          const SizedBox(height: 100),
                          const _ExperienceSection(),
                          const SizedBox(height: 80),
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

  Widget _buildSectionTitle(String title, String subtitle) {
    return Column(
      children: [
        Text(
          title,
          style: GoogleFonts.epilogue(fontSize: 32, fontWeight: FontWeight.w800, color: kTextDark),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: GoogleFonts.manrope(fontSize: 16, color: Colors.grey[600], fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

class _HeroSection extends StatelessWidget {
  final bool isDesktop;
  final TextEditingController searchController;
  final VoidCallback onSearch;

  const _HeroSection({required this.isDesktop, required this.searchController, required this.onSearch});

  @override
  Widget build(BuildContext context) {
    return isDesktop
        ? Row(
      children: [
        Expanded(flex: 6, child: _buildHeroText()),
        const SizedBox(width: 40),
        Expanded(flex: 4, child: _buildHeroImage()),
      ],
    )
        : Column(
      children: [
        _buildHeroText(),
        const SizedBox(height: 40),
        _buildHeroImage(),
      ],
    );
  }

  Widget _buildHeroText() {
    return Column(
      crossAxisAlignment: isDesktop ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        RichText(
          textAlign: isDesktop ? TextAlign.left : TextAlign.center,
          text: TextSpan(
            style: GoogleFonts.epilogue(fontSize: isDesktop ? 64 : 42, fontWeight: FontWeight.w900, height: 1.1, color: Colors.black),
            children: [
              const TextSpan(text: 'Sức khỏe,\n'),
              TextSpan(text: 'Chọn lọc tinh tế.', style: GoogleFonts.epilogue(color: const Color(0xFF0D9488))),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Kết nối với các chuyên gia y tế hàng đầu Việt Nam qua nền tảng công nghệ hiện đại, minh bạch và tận tâm.',
          textAlign: isDesktop ? TextAlign.left : TextAlign.center,
          style: GoogleFonts.manrope(fontSize: 18, color: Colors.grey[600], height: 1.6),
        ),
        const SizedBox(height: 40),
        _SearchBar(controller: searchController, onSearch: onSearch),
      ],
    );
  }

  Widget _buildHeroImage() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 320,
          height: 320,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF0D9488).withAlpha(20),
          ),
        ),
        Transform.rotate(
          angle: 0.05,
          child: Container(
            width: 280,
            height: 380,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40),
              boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 40, offset: const Offset(0, 20))],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: const DoctorImage(pathOrUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuALzjGvI7RG-nVb5i62uMGRIwFkn1VaqIEJ8dKwOcBzjlE7JUMqqfVK3jB3wP_6m-OTymNgCeFebtLzZVBBTkhje88MfyZpwpcMWD3qRFtUouC4n04EA6-xdx_OcLODpP-vTLmT1IBVjaZQFDLbB-1t8I1jWtSznl57ZAN2te6dDUhf-uaogBTbThrBf76asK89gxPyYU8WKwT0cfmdpfBJ7jbuW-y3jSfnNCCMja3qm9C3IxCyCDl31BCMqkygDCGhWeX7Pr2pwbA', fit: BoxFit.cover),
            ),
          ),
        ),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSearch;

  const _SearchBar({required this.controller, required this.onSearch});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 30, offset: const Offset(0, 15))],
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          const Icon(Icons.search_rounded, color: Color(0xFF0D9488)),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Tìm bác sĩ, chuyên khoa...',
                hintStyle: GoogleFonts.manrope(color: Colors.grey[400]),
                border: InputBorder.none,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: onSearch,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D9488),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: Text('Tìm kiếm', style: GoogleFonts.manrope(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _SpecialistsGrid extends StatelessWidget {
  final List<Doctor> doctors;
  final bool isLoggedIn;
  const _SpecialistsGrid({required this.doctors, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final cols = width >= 1000 ? 3 : width >= 600 ? 2 : 1;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: doctors.take(6).length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cols,
        crossAxisSpacing: 24,
        mainAxisSpacing: 24,
        childAspectRatio: 0.8,
      ),
      itemBuilder: (context, i) {
        final d = doctors[i];
        return _DoctorCard(
          doctor: d,
          onTap: () {
            if (!isLoggedIn) {
              Navigator.of(context).pushNamed('/');
            } else {
              Navigator.of(context).pushNamed('/user/doctor', arguments: d);
            }
          },
        );
      },
    );
  }
}

class _DoctorCard extends StatefulWidget {
  final Doctor doctor;
  final VoidCallback onTap;
  const _DoctorCard({required this.doctor, required this.onTap});

  @override
  State<_DoctorCard> createState() => _DoctorCardState();
}

class _DoctorCardState extends State<_DoctorCard> {
  bool _isHover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHover = true),
      onExit: (_) => setState(() => _isHover = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: _isHover ? const Color(0xFF0D9488) : const Color(0xFFF1F5F9), width: 2),
            boxShadow: [
              BoxShadow(
                color: _isHover ? const Color(0xFF0D9488).withAlpha(10) : Colors.black.withAlpha(5),
                blurRadius: 30,
                offset: const Offset(0, 15),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: DoctorImage(pathOrUrl: widget.doctor.image, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.doctor.name,
                style: GoogleFonts.epilogue(fontSize: 20, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A)),
              ),
              const SizedBox(height: 4),
              Text(
                widget.doctor.specialty,
                style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF0D9488)),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${widget.doctor.experience} năm kinh nghiệm',
                    style: GoogleFonts.manrope(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.w600),
                  ),
                  const Icon(Icons.arrow_forward_rounded, color: Color(0xFF0D9488), size: 20),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExperienceSection extends StatelessWidget {
  const _ExperienceSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(48),
      ),
      child: Column(
        children: [
          Text(
            'Trải nghiệm chăm sóc khác biệt',
            textAlign: TextAlign.center,
            style: GoogleFonts.epilogue(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white),
          ),
          const SizedBox(height: 48),
          LayoutBuilder(builder: (context, c) {
            final isDesktop = c.maxWidth > 800;
            return isDesktop
                ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _buildFeatures(),
            )
                : Column(
              children: _buildFeatures().map((f) => Padding(padding: const EdgeInsets.only(bottom: 32), child: f)).toList(),
            );
          }),
        ],
      ),
    );
  }

  List<Widget> _buildFeatures() {
    return [
      _FeatureItem(icon: Icons.bolt_rounded, title: 'Đặt lịch tức thì', desc: 'Xác nhận lịch hẹn trong 60s'),
      _FeatureItem(icon: Icons.video_camera_front_rounded, title: 'Tư vấn trực tuyến', desc: 'Kết nối bác sĩ mọi lúc'),
      _FeatureItem(icon: Icons.security_rounded, title: 'Bảo mật tuyệt đối', desc: 'Dữ liệu y tế được mã hóa'),
    ];
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;
  const _FeatureItem({required this.icon, required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white.withAlpha(20), shape: BoxShape.circle),
          child: Icon(icon, color: const Color(0xFF0D9488), size: 32),
        ),
        const SizedBox(height: 16),
        Text(title, style: GoogleFonts.epilogue(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
        const SizedBox(height: 4),
        Text(desc, style: GoogleFonts.manrope(fontSize: 14, color: Colors.grey[400])),
      ],
    );
  }
}
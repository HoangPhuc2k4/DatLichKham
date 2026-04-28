import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../controllers/session_controller.dart';
import '../../models/doctor.dart';
import '../widgets/app_footer.dart';
import '../widgets/app_top_nav_bar.dart';
import '../widgets/doctor_image.dart';

class DoctorDetailPage extends StatefulWidget {
  const DoctorDetailPage({super.key});

  @override
  State<DoctorDetailPage> createState() => _DoctorDetailPageState();
}

class _DoctorDetailPageState extends State<DoctorDetailPage> {
  late Doctor doctor;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is Doctor) {
      doctor = arg;
    } else {
      doctor = Doctor(id: 0, name: 'Bác sĩ', specialty: '', experience: 0, description: '', image: '');
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= 1100;
    final isLoggedIn = SessionController.instance.currentUser != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFA),
      body: SafeArea(
        child: Column(
          children: [
            AppTopNavBar(
              isDesktop: width >= 900,
              isLoggedIn: isLoggedIn,
              activeKey: 'specialists',
              onTapFindCare: () => Navigator.of(context).pushReplacementNamed('/user/doctors'),
              onTapSpecialists: () => Navigator.of(context).pushReplacementNamed('/user/doctors'),
              onTapSchedule: () => _handleNav('/user/appointments'),
              onTapMyHealth: () => _handleNav('/user/appointments'),
              onTapAuth: () {
                if (!isLoggedIn) {
                  Navigator.of(context).pushNamed('/');
                } else {
                  SessionController.instance.logout();
                  Navigator.of(context).pushReplacementNamed('/user/home');
                }
              },
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: width < 600 ? 16 : 40,
                  vertical: 32,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: Column(
                      children: [
                        _HeroHeader(doctor: doctor, isDesktop: isDesktop),
                        const SizedBox(height: 64),
                        _DetailContent(doctor: doctor, isDesktop: isDesktop),
                        const SizedBox(height: 80),
                        const AppFooter(),
                      ],
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

  void _handleNav(String route) {
    if (SessionController.instance.currentUser == null) {
      Navigator.of(context).pushNamed('/');
    } else {
      Navigator.of(context).pushNamed(route);
    }
  }
}

class _HeroHeader extends StatelessWidget {
  final Doctor doctor;
  final bool isDesktop;
  const _HeroHeader({required this.doctor, required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    return isDesktop
        ? Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(flex: 6, child: _HeroInfo(doctor: doctor)),
        const SizedBox(width: 60),
        Expanded(flex: 5, child: _HeroImageFrame(doctor: doctor)),
      ],
    )
        : Column(
      children: [
        _HeroImageFrame(doctor: doctor),
        const SizedBox(height: 40),
        _HeroInfo(doctor: doctor),
      ],
    );
  }
}

class _HeroInfo extends StatelessWidget {
  final Doctor doctor;
  const _HeroInfo({required this.doctor});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final headlineSize = width > 1200 ? 72.0 : 48.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF2EC4B6).withOpacity(0.1),
            borderRadius: BorderRadius.circular(99),
          ),
          child: Text(
            'CHUYÊN GIA ĐẦU NGÀNH',
            style: GoogleFonts.manrope(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
              color: const Color(0xFF006A62),
            ),
          ),
        ),
        const SizedBox(height: 24),
        RichText(
          text: TextSpan(
            style: GoogleFonts.epilogue(
              fontSize: headlineSize,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF191C1D),
              height: 1.1,
            ),
            children: [
              TextSpan(text: 'Bác sĩ\n${doctor.name}\n'),
              TextSpan(
                text: doctor.specialty,
                style: TextStyle(
                  color: const Color(0xFF006A62),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
        _StatRow(doctor: doctor),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  final Doctor doctor;
  const _StatRow({required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatBox(value: '${doctor.experience}+', label: 'Năm kinh nghiệm'),
        _Divider(),
        _StatBox(value: '4.9', label: 'Đánh giá', hasStar: true),
        _Divider(),
        _StatBox(value: '98%', label: 'Hài lòng'),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  final String value;
  final String label;
  final bool hasStar;
  const _StatBox({required this.value, required this.label, this.hasStar = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(value, style: GoogleFonts.epilogue(fontSize: 28, fontWeight: FontWeight.w900)),
            if (hasStar) const Icon(Icons.star, color: Color(0xFFF99A15), size: 20),
          ],
        ),
        Text(label, style: GoogleFonts.manrope(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(margin: const EdgeInsets.symmetric(horizontal: 24), height: 40, width: 1, color: Colors.grey.withOpacity(0.2));
}

class _HeroImageFrame extends StatelessWidget {
  final Doctor doctor;
  const _HeroImageFrame({required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 500,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 40, offset: const Offset(0, 20))],
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: DoctorImage(pathOrUrl: doctor.image, fit: BoxFit.cover),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  color: Colors.white.withOpacity(0.8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.verified_user, color: Color(0xFF006A62)),
                      const SizedBox(height: 8),
                      Text('Chứng nhận bởi\nCurated Clinic', style: GoogleFonts.manrope(fontWeight: FontWeight.w800, fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _DetailContent extends StatelessWidget {
  final Doctor doctor;
  final bool isDesktop;
  const _DetailContent({required this.doctor, required this.isDesktop});

  @override
  Widget build(BuildContext context) {
    return isDesktop
        ? Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 7, child: _InfoBento(doctor: doctor)),
        const SizedBox(width: 32),
        Expanded(flex: 4, child: _BookingPanel(doctor: doctor)),
      ],
    )
        : Column(
      children: [
        _BookingPanel(doctor: doctor),
        const SizedBox(height: 32),
        _InfoBento(doctor: doctor),
      ],
    );
  }
}

class _InfoBento extends StatelessWidget {
  final Doctor doctor;
  const _InfoBento({required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Giới thiệu chuyên môn', style: GoogleFonts.epilogue(fontSize: 28, fontWeight: FontWeight.w900)),
        const SizedBox(height: 24),
        Text(
          doctor.description.isEmpty ? 'Thông tin bác sĩ đang được cập nhật...' : doctor.description,
          style: GoogleFonts.manrope(fontSize: 16, height: 1.8, color: const Color(0xFF3C4947)),
        ),
        const SizedBox(height: 40),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
          childAspectRatio: 1.5,
          children: [
            _SmallBento(icon: Icons.biotech, title: 'Lĩnh vực', items: [doctor.specialty]),
            _SmallBento(icon: Icons.school, title: 'Học vấn', items: const ['Đại học Y Dược', 'Thạc sĩ Chuyên khoa']),
          ],
        )
      ],
    );
  }
}

class _SmallBento extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<String> items;
  const _SmallBento({required this.icon, required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: const Color(0xFFF2F4F4), borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF006A62)),
          const SizedBox(height: 12),
          Text(title, style: GoogleFonts.epilogue(fontWeight: FontWeight.w900, fontSize: 18)),
          const SizedBox(height: 8),
          ...items.map((e) => Text(e, style: GoogleFonts.manrope(fontSize: 13, color: Colors.blueGrey))),
        ],
      ),
    );
  }
}

class _BookingPanel extends StatelessWidget {
  final Doctor doctor;
  const _BookingPanel({required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 40, offset: const Offset(0, 20))],
        border: Border.all(color: const Color(0xFF006A62).withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Phí tư vấn', style: GoogleFonts.manrope(fontWeight: FontWeight.w700, color: Colors.grey)),
          const SizedBox(height: 4),
          Text('150.000đ', style: GoogleFonts.epilogue(fontSize: 32, fontWeight: FontWeight.w900)),
          const Divider(height: 40),
          _BookingBenefit(icon: Icons.flash_on, text: 'Đặt lịch nhanh trong 60s'),
          const SizedBox(height: 12),
          _BookingBenefit(icon: Icons.video_call, text: 'Hỗ trợ tư vấn Online/Offline'),
          const SizedBox(height: 40),
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: () {
                final user = SessionController.instance.currentUser;
                if (user == null) {
                  Navigator.of(context).pushNamed('/');
                } else {
                  Navigator.of(context).pushNamed('/user/booking', arguments: doctor);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF006A62),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: Text('Đặt lịch ngay', style: GoogleFonts.manrope(fontWeight: FontWeight.w900, fontSize: 16, color: Colors.white)),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text('Hệ thống bảo mật 100%', style: GoogleFonts.manrope(fontSize: 12, color: Colors.grey)),
          )
        ],
      ),
    );
  }
}

class _BookingBenefit extends StatelessWidget {
  final IconData icon;
  final String text;
  const _BookingBenefit({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF2EC4B6)),
        const SizedBox(width: 12),
        Text(text, style: GoogleFonts.manrope(fontWeight: FontWeight.w600, fontSize: 14)),
      ],
    );
  }
}
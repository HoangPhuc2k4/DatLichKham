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
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            AppTopNavBar(
              isDesktop: width >= 900,
              isLoggedIn: isLoggedIn,
              activeKey: 'specialists',
              onTapFindCare: () => Navigator.of(context).pushReplacementNamed('/user/doctors'),
              onTapSpecialists: () => Navigator.of(context).pushReplacementNamed('/user/doctors'),
              onTapSchedule: () => Navigator.of(context).pushNamed('/user/appointments'),
              onTapMyHealth: () => Navigator.of(context).pushNamed('/user/appointments'),
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
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: width < 600 ? 20 : 40,
                  vertical: 32,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: Column(
                      children: [
                        _buildHeroSection(isDesktop, width),
                        const SizedBox(height: 48),
                        _buildMainContent(isDesktop),
                        const SizedBox(height: 60),
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

  Widget _buildHeroSection(bool isDesktop, double width) {
    return isDesktop
        ? Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 6, child: _HeroInfo(doctor: doctor)),
        const SizedBox(width: 48),
        Expanded(flex: 4, child: _HeroImage(doctor: doctor)),
      ],
    )
        : Column(
      children: [
        _HeroImage(doctor: doctor),
        const SizedBox(height: 32),
        _HeroInfo(doctor: doctor),
      ],
    );
  }

  Widget _buildMainContent(bool isDesktop) {
    return isDesktop
        ? Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 6, child: _DoctorBio(doctor: doctor)),
        const SizedBox(width: 48),
        Expanded(flex: 4, child: _BookingSidePanel(doctor: doctor)),
      ],
    )
        : Column(
      children: [
        _DoctorBio(doctor: doctor),
        const SizedBox(height: 32),
        _BookingSidePanel(doctor: doctor),
      ],
    );
  }
}

class _HeroInfo extends StatelessWidget {
  final Doctor doctor;
  const _HeroInfo({required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF0D9488).withAlpha(20),
            borderRadius: BorderRadius.circular(99),
          ),
          child: Text(
            'CHUYÊN GIA Y TẾ HÀNG ĐẦU',
            style: GoogleFonts.manrope(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0D9488),
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          doctor.name,
          style: GoogleFonts.epilogue(
            fontSize: 48,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF0F172A),
            height: 1.1,
          ),
        ),
        Text(
          doctor.specialty,
          style: GoogleFonts.epilogue(
            fontSize: 48,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF0D9488),
            height: 1.1,
          ),
        ),
        const SizedBox(height: 32),
        Row(
          children: [
            _StatTile(label: 'Kinh nghiệm', value: '${doctor.experience}+ năm'),
            _VerticalDivider(),
            _StatTile(label: 'Đánh giá', value: '4.9/5.0'),
            _VerticalDivider(),
            _StatTile(label: 'Hài lòng', value: '99%'),
          ],
        ),
      ],
    );
  }
}

class _HeroImage extends StatelessWidget {
  final Doctor doctor;
  const _HeroImage({required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 450,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 40,
            offset: const Offset(0, 20),
          )
        ],
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(40),
            child: DoctorImage(pathOrUrl: doctor.image, fit: BoxFit.cover),
          ),
          Positioned(
            bottom: 24,
            left: 24,
            right: 24,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.white.withAlpha(180),
                  child: Row(
                    children: [
                      const Icon(Icons.verified_rounded, color: Color(0xFF0D9488)),
                      const SizedBox(width: 12),
                      Text(
                        'Thông tin đã xác thực',
                        style: GoogleFonts.manrope(
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DoctorBio extends StatelessWidget {
  final Doctor doctor;
  const _DoctorBio({required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: 'Về bác sĩ'),
        const SizedBox(height: 16),
        Text(
          doctor.description.isNotEmpty
              ? doctor.description
              : 'Bác sĩ chuyên khoa giàu kinh nghiệm, tận tâm với nghề và luôn đặt sức khỏe của bệnh nhân lên hàng đầu. Chuyên tư vấn và điều trị các bệnh lý phức tạp với phương pháp hiện đại nhất.',
          style: GoogleFonts.manrope(
            fontSize: 16,
            height: 1.8,
            color: const Color(0xFF475569),
          ),
        ),
        const SizedBox(height: 32),
        _SectionTitle(title: 'Chuyên môn đào tạo'),
        const SizedBox(height: 16),
        _BentoGrid(),
      ],
    );
  }
}

class _BookingSidePanel extends StatelessWidget {
  final Doctor doctor;
  const _BookingSidePanel({required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 30,
            offset: const Offset(0, 15),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thông tin đặt lịch',
            style: GoogleFonts.epilogue(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 24),
          _BookingInfoRow(icon: Icons.location_on_outlined, text: 'Phòng khám đa khoa Curated'),
          const SizedBox(height: 16),
          _BookingInfoRow(icon: Icons.access_time_rounded, text: 'Thứ 2 - Thứ 7: 08:00 - 17:00'),
          const SizedBox(height: 24),
          const Divider(color: Color(0xFFF1F5F9)),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Phí khám dự kiến', style: GoogleFonts.manrope(fontWeight: FontWeight.w600, color: const Color(0xFF64748B))),
              Text('150.000đ', style: GoogleFonts.epilogue(fontSize: 20, fontWeight: FontWeight.w800, color: const Color(0xFF0D9488))),
            ],
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 56,
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
                backgroundColor: const Color(0xFFF59E0B),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
              child: Text(
                'Đặt lịch ngay',
                style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Các Widget hỗ trợ nhỏ
class _StatTile extends StatelessWidget {
  final String label, value;
  const _StatTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: GoogleFonts.epilogue(fontSize: 20, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A))),
        Text(label, style: GoogleFonts.manrope(fontSize: 12, color: const Color(0xFF64748B), fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      width: 1,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      color: const Color(0xFFE2E8F0),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.epilogue(fontSize: 24, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A)),
    );
  }
}

class _BookingInfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _BookingInfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF0D9488)),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.manrope(fontWeight: FontWeight.w600, color: const Color(0xFF475569)),
          ),
        ),
      ],
    );
  }
}

class _BentoGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _BentoItem(
            color: const Color(0xFFF1F5F9),
            title: 'Học vấn',
            subtitle: 'Đại học Y Dược TP.HCM',
            icon: Icons.school_outlined,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _BentoItem(
            color: const Color(0xFF0D9488).withAlpha(15),
            title: 'Ngoại ngữ',
            subtitle: 'Tiếng Anh, Tiếng Việt',
            icon: Icons.translate_rounded,
          ),
        ),
      ],
    );
  }
}

class _BentoItem extends StatelessWidget {
  final Color color;
  final String title, subtitle;
  final IconData icon;
  const _BentoItem({required this.color, required this.title, required this.subtitle, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(24)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF0D9488)),
          const SizedBox(height: 16),
          Text(title, style: GoogleFonts.manrope(fontWeight: FontWeight.w800, fontSize: 14, color: const Color(0xFF0F172A))),
          Text(subtitle, style: GoogleFonts.manrope(fontSize: 13, color: const Color(0xFF64748B))),
        ],
      ),
    );
  }
}
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
  // Đặt lịch được thực hiện ở trang riêng: `/user/booking`

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is Doctor) {
      doctor = arg;
    } else {
      doctor = Doctor(
        id: 0,
        name: 'Bác sĩ',
        specialty: '',
        experience: 0,
        description: '',
        image: '',
      );
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
              onTapFindCare: () =>
                  Navigator.of(context).pushReplacementNamed('/user/doctors'),
              onTapSpecialists: () =>
                  Navigator.of(context).pushReplacementNamed('/user/doctors'),
              onTapSchedule: () {
                final user = SessionController.instance.currentUser;
                if (user?.id == null) {
                  Navigator.of(context).pushNamed('/');
                  return;
                }
                Navigator.of(context).pushNamed('/user/appointments');
              },
              onTapMyHealth: () {
                final user = SessionController.instance.currentUser;
                if (user?.id == null) {
                  Navigator.of(context).pushNamed('/');
                  return;
                }
                Navigator.of(context).pushNamed('/user/appointments');
              },
              onTapAuth: () {
                if (!isLoggedIn) {
                  Navigator.of(context).pushNamed('/');
                  return;
                }
                SessionController.instance.logout();
                Navigator.of(context).pushReplacementNamed('/user/home');
              },
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: width < 600 ? 16 : 24,
                  vertical: width < 600 ? 16 : 28,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1440),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _HeroHeader(doctor: doctor),
                        const SizedBox(height: 34),
                        LayoutBuilder(
                          builder: (context, c) {
                            final isTwoCol = isDesktop && c.maxWidth >= 1100;
                            final content = _AboutAndBento(doctor: doctor);
                            final panel = _SpecializationsPanel(
                              doctor: doctor,
                              onContinue: () {
                                final user =
                                    SessionController.instance.currentUser;
                                if (user?.id == null) {
                                  Navigator.of(context).pushNamed('/');
                                  return;
                                }
                                Navigator.of(context).pushNamed(
                                  '/user/booking',
                                  arguments: doctor,
                                );
                              },
                            );

                            if (!isTwoCol) {
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  content,
                                  const SizedBox(height: 18),
                                  panel,
                                ],
                              );
                            }

                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(flex: 7, child: content),
                                const SizedBox(width: 24),
                                Expanded(flex: 5, child: panel),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 48),
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
}

class _HeroHeader extends StatelessWidget {
  final Doctor doctor;
  const _HeroHeader({required this.doctor});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= 1100;
    // Giảm mạnh trên mobile để tránh tràn/đè layout.
    final headlineSize = isDesktop ? 72.0 : width >= 600 ? 52.0 : 34.0;

    return Padding(
      padding: EdgeInsets.only(top: width < 600 ? 8 : 16),
      child: isDesktop
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  flex: 7,
                  child: _HeroLeft(
                    doctor: doctor,
                    headlineSize: headlineSize,
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  flex: 5,
                  child: _HeroRight(doctor: doctor),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HeroRight(doctor: doctor),
                const SizedBox(height: 18),
                _HeroLeft(
                  doctor: doctor,
                  headlineSize: headlineSize,
                ),
              ],
            ),
    );
  }
}

class _HeroLeft extends StatelessWidget {
  final Doctor doctor;
  final double headlineSize;
  const _HeroLeft({required this.doctor, required this.headlineSize});

  static const Color secondaryContainer = Color(0xFFC5E4FA);
  static const Color onSecondaryContainer = Color(0xFF496679);
  static const Color primary = Color(0xFF006A62);
  static const Color tertiaryContainer = Color(0xFFF99A15);
  static const Color onSurfaceVariant = Color(0xFF3C4947);
  static const Color outlineVariant = Color(0xFFBBCAC6);

  @override
  Widget build(BuildContext context) {
    final name = doctor.name.isEmpty ? 'Bác sĩ' : doctor.name;
    final specialty = doctor.specialty.isEmpty ? 'Chuyên khoa' : doctor.specialty;
    final intro = doctor.description.isNotEmpty
        ? doctor.description
        : 'Bác sĩ $specialty với kinh nghiệm lâm sàng và phong cách tư vấn rõ ràng, tận tâm.';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: secondaryContainer,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.verified, size: 16, color: onSecondaryContainer),
              const SizedBox(width: 8),
              Text(
                'CHUYÊN GIA',
                style: GoogleFonts.manrope(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.4,
                  color: onSecondaryContainer,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: '$name\n',
                style: GoogleFonts.epilogue(
                  fontSize: headlineSize,
                  fontWeight: FontWeight.w900,
                  height: 1.02,
                  letterSpacing: -1.2,
                  color: const Color(0xFF191C1D),
                ),
              ),
              TextSpan(
                text: specialty,
                style: GoogleFonts.epilogue(
                  fontSize: headlineSize,
                  fontWeight: FontWeight.w900,
                  height: 1.02,
                  letterSpacing: -1.2,
                  color: primary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Text(
            intro,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.manrope(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              height: 1.5,
              color: onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(height: 22),
        Wrap(
          spacing: 28,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _Stat(
              value: '${doctor.experience}+' ,
              label: 'Năm kinh nghiệm',
              color: const Color(0xFF895100),
            ),
            Container(
              width: 1,
              height: 42,
              color: outlineVariant.withValues(alpha: 0.35),
            ),
            _Stat(
              value: '4.9',
              label: 'Đánh giá',
              color: tertiaryContainer,
              trailing: const Icon(Icons.star, size: 18, color: tertiaryContainer),
            ),
            Container(
              width: 1,
              height: 42,
              color: outlineVariant.withValues(alpha: 0.35),
            ),
            _Stat(
              value: '98%',
              label: 'Tỷ lệ hài lòng',
              color: primary,
            ),
          ],
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final Widget? trailing;

  const _Stat({
    required this.value,
    required this.label,
    required this.color,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              value,
              style: GoogleFonts.epilogue(
                fontSize: 30,
                fontWeight: FontWeight.w900,
                color: color,
                height: 1,
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 6),
              trailing!,
            ]
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.manrope(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF3C4947).withValues(alpha: 0.85),
          ),
        )
      ],
    );
  }
}

class _HeroRight extends StatelessWidget {
  final Doctor doctor;
  const _HeroRight({required this.doctor});

  static const Color primary = Color(0xFF006A62);
  static const Color tertiaryContainer = Color(0xFFF99A15);

  @override
  Widget build(BuildContext context) {
    final img = doctor.image;
    return SizedBox(
      height: 520,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Transform.rotate(
              angle: -0.05,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      primary.withValues(alpha: 0.14),
                      tertiaryContainer.withValues(alpha: 0.10),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(48),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(48),
              child: DoctorImage(pathOrUrl: img, fit: BoxFit.cover),
            ),
          ),
          Positioned(
            bottom: -16,
            left: -6,
            child: _GlassBadge(
              icon: Icons.favorite,
              title: 'Chuyên môn',
              body: doctor.specialty.isEmpty ? 'Chăm sóc sức khỏe' : doctor.specialty,
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassBadge extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;

  const _GlassBadge({
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: 220,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Colors.white.withValues(alpha: 0.45)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 22,
                offset: const Offset(0, 14),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: const Color(0xFF006A62)),
              const SizedBox(height: 10),
              Text(
                '$title\n$body',
                style: GoogleFonts.epilogue(
                  fontWeight: FontWeight.w900,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AboutAndBento extends StatelessWidget {
  final Doctor doctor;
  const _AboutAndBento({required this.doctor});

  static const Color primary = Color(0xFF006A62);
  static const Color onSurfaceVariant = Color(0xFF3C4947);

  @override
  Widget build(BuildContext context) {
    final about = doctor.description.isNotEmpty
        ? doctor.description
        : 'Bác sĩ có kinh nghiệm lâm sàng, tư vấn theo hướng “tổng thể”, tập trung vào phát hiện sớm và kế hoạch chăm sóc cá nhân hóa.';

    final specialties = doctor.specialty.isNotEmpty
        ? <String>[doctor.specialty, 'Tư vấn tổng quát', 'Chăm sóc dự phòng']
        : <String>['Tư vấn tổng quát', 'Chăm sóc dự phòng', 'Theo dõi sức khỏe'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 32,
              height: 4,
              decoration: BoxDecoration(
                color: primary,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Giới thiệu bác sĩ',
              style: GoogleFonts.epilogue(
                fontSize: 28,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Text(
          about,
          style: GoogleFonts.manrope(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            height: 1.7,
            color: onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 26),
        LayoutBuilder(
          builder: (context, c) {
            final twoCol = c.maxWidth >= 700;
            final left = _BentoCard(
              bg: const Color(0xFFF2F4F4),
              icon: Icons.description,
              iconColor: primary,
              title: 'Chuyên môn',
              items: specialties,
            );
            final right = _BentoCard(
              bg: const Color(0xFFE6E8E9),
              icon: Icons.school,
              iconColor: const Color(0xFF895100),
              title: 'Học vấn',
              items: const [
                'Đào tạo chuyên khoa',
                'Kinh nghiệm lâm sàng',
                'Tư vấn theo phác đồ',
              ],
            );
            if (!twoCol) {
              return Column(
                children: [
                  left,
                  const SizedBox(height: 14),
                  right,
                ],
              );
            }
            return Row(
              children: [
                Expanded(child: left),
                const SizedBox(width: 14),
                Expanded(child: right),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _BentoCard extends StatelessWidget {
  final Color bg;
  final IconData icon;
  final Color iconColor;
  final String title;
  final List<String> items;

  const _BentoCard({
    required this.bg,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.epilogue(
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 10),
          for (final it in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                it,
                style: GoogleFonts.manrope(
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF3C4947),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SpecializationsPanel extends StatelessWidget {
  final Doctor doctor;
  final VoidCallback onContinue;

  const _SpecializationsPanel({
    required this.doctor,
    required this.onContinue,
  });

  static const Color surfaceLow = Color(0xFFF2F4F4);
  static const Color outlineVariant = Color(0xFFBBCAC6);

  @override
  Widget build(BuildContext context) {
    final specs = doctor.specializations.isNotEmpty
        ? doctor.specializations
        : (doctor.specialty.isNotEmpty
            ? <String>[doctor.specialty]
            : <String>['Khám tổng quát']);

    return ClipRRect(
      borderRadius: BorderRadius.circular(40),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(26),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(color: Colors.white.withValues(alpha: 0.40)),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF191C1D).withValues(alpha: 0.06),
                blurRadius: 40,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Chuyên môn khám bệnh',
                style: GoogleFonts.epilogue(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'LĨNH VỰC',
                style: GoogleFonts.manrope(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                  color: const Color(0xFF3C4947).withValues(alpha: 0.75),
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final s in specs.take(10))
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: surfaceLow,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: outlineVariant.withValues(alpha: 0.20),
                        ),
                      ),
                      child: Text(
                        s,
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF191C1D),
                        ),
                      ),
                    )
                ],
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.only(top: 16),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: outlineVariant.withValues(alpha: 0.20)),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Phí khám',
                      style: GoogleFonts.manrope(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF3C4947).withValues(alpha: 0.75),
                      ),
                    ),
                    Text(
                      '140.000đ',
                      style: GoogleFonts.epilogue(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF191C1D),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              GestureDetector(
                onTap: onContinue,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [Color(0xFFF99A15), Color(0xFFFF9F1C)],
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFF99A15).withValues(alpha: 0.28),
                        blurRadius: 22,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Tiếp tục',
                        style: GoogleFonts.epilogue(
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Bạn chưa bị trừ tiền. Hệ thống có thể tạm giữ hạn mức để xác nhận đặt lịch.',
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF3C4947).withValues(alpha: 0.60),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


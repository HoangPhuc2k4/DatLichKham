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

class _CuratedClinicHomePageState extends State<CuratedClinicHomePage>
    with SingleTickerProviderStateMixin {
  late final Future<List<Doctor>> _doctorsFuture;
  final _scrollController = ScrollController();
  final _doctorSearchController = TextEditingController();
  final _specialistsKey = GlobalKey();
  final _experienceKey = GlobalKey();
  static const Color background = Color(0xFFF8FAFA);

  @override
  void initState() {
    super.initState();
    _doctorsFuture = _loadDoctors();
  }

  Future<List<Doctor>> _loadDoctors() async {
    return DoctorController.instance.getAllDoctors();
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
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
      alignment: 0.06,
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 900;
    final user = SessionController.instance.currentUser;
    final horizontalPad = width < 600 ? 16.0 : 24.0;

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            AppTopNavBar(
              isDesktop: isDesktop,
              isLoggedIn: user != null,
              activeKey: 'find_care',
              onTapFindCare: () =>
                  Navigator.of(context).pushReplacementNamed('/user/doctors'),
              onTapSpecialists: () =>
                  Navigator.of(context).pushReplacementNamed('/user/doctors'),
              onTapSchedule: () {
                final u = SessionController.instance.currentUser;
                if (u?.id == null) {
                  Navigator.of(context).pushNamed('/');
                  return;
                }
                Navigator.of(context).pushNamed('/user/appointments');
              },
              onTapMyHealth: () {
                final u = SessionController.instance.currentUser;
                if (u?.id == null) {
                  Navigator.of(context).pushNamed('/');
                  return;
                }
                Navigator.of(context).pushNamed('/user/appointments');
              },
              onTapAuth: () {
                final isLoggedIn =
                    SessionController.instance.currentUser != null;
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
                controller: _scrollController,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPad),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1440),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 32),
                        _HeroSection(
                          isDesktop: isDesktop,
                          onBookTap: () => _scrollTo(_specialistsKey),
                          doctorSearchController: _doctorSearchController,
                          onSearchTap: () {
                            final q = _doctorSearchController.text.trim();
                            Navigator.of(context)
                                .pushNamed('/user/doctors', arguments: q);
                          },
                        ),
                        const SizedBox(height: 64),
                        FutureBuilder<List<Doctor>>(
                          future: _doctorsFuture,
                          builder: (context, snap) {
                            if (!snap.hasData) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 36),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
                            final isLoggedIn =
                                SessionController.instance.currentUser != null;
                            return KeyedSubtree(
                              key: _specialistsKey,
                              child: _SpecialistsSection(
                                doctors: snap.data!,
                                isLoggedIn: isLoggedIn,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 48),
                        KeyedSubtree(
                          key: _experienceKey,
                          child: _ExperienceCareSection(),
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

// Menu đã được tách ra widget dùng chung: `AppTopNavBar` (lib/views/widgets/app_top_nav_bar.dart)

class _HeroSection extends StatelessWidget {
  final bool isDesktop;
  final VoidCallback onBookTap;
  final TextEditingController doctorSearchController;
  final VoidCallback onSearchTap;

  const _HeroSection({
    required this.isDesktop,
    required this.onBookTap,
    required this.doctorSearchController,
    required this.onSearchTap,
  });

  static const String heroDoctor =
      'https://lh3.googleusercontent.com/aida-public/AB6AXuALzjGvI7RG-nVb5i62uMGRIwFkn1VaqIEJ8dKwOcBzjlE7JUMqqfVK3jB3wP_6m-OTymNgCeFebtLzZVBBTkhje88MfyZpwpcMWD3qRFtUouC4n04EA6-xdx_OcLODpP-vTLmT1IBVjaZQFDLbB-1t8I1jWtSznl57ZAN2te6dDUhf-uaogBTbThrBf76asK89gxPyYU8WKwT0cfmdpfBJ7jbuW-y3jSfnNCCMja3qm9C3IxCyCDl31BCMqkygDCGhWeX7Pr2pwbA';

  @override
  Widget build(BuildContext context) {
    return isDesktop
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 8,
                child: _HeroLeft(
                  onBookTap: onBookTap,
                  doctorSearchController: doctorSearchController,
                  onSearchTap: onSearchTap,
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: 4,
                child: _HeroRight(),
              ),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HeroLeft(
                onBookTap: onBookTap,
                doctorSearchController: doctorSearchController,
                onSearchTap: onSearchTap,
              ),
              const SizedBox(height: 24),
              _HeroRight(),
            ],
          );
  }
}

class _HeroLeft extends StatelessWidget {
  final VoidCallback onBookTap;
  final TextEditingController doctorSearchController;
  final VoidCallback onSearchTap;

  const _HeroLeft({
    required this.onBookTap,
    required this.doctorSearchController,
    required this.onSearchTap,
  });
  static const Color onSurfaceVariant = Color(0xFF3C4947);

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < 600;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _HeroHeadline(isMobile: isMobile),
        const SizedBox(height: 18),
        Text(
          'Bỏ qua phòng chờ. Kết nối với bác sĩ hàng đầu qua trải nghiệm được thiết kế cho sức khỏe của bạn — chủ động, cá nhân hóa và cao cấp.',
          style: GoogleFonts.manrope(
            fontSize: 18,
            color: onSurfaceVariant,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 18),
        _SearchBar(
          doctorController: doctorSearchController,
          onSearchTap: onSearchTap,
        ),
      ],
    );
  }
}

class _HeroHeadline extends StatelessWidget {
  final bool isMobile;
  const _HeroHeadline({required this.isMobile});

  static const Color primary = Color(0xFF006A62);
  static const Color primaryContainer = Color(0xFF2EC4B6);

  @override
  Widget build(BuildContext context) {
    final size = isMobile ? 44.0 : 72.0;
    final gradient = const LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [primary, primaryContainer],
    );

    return LayoutBuilder(
      builder: (context, c) {
        final shader = gradient.createShader(
          Rect.fromLTWH(0, 0, c.maxWidth == 0 ? 600 : c.maxWidth, size),
        );
        return RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Sức khỏe,\n',
                style: GoogleFonts.epilogue(
                  fontSize: size,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.2,
                  height: 1.05,
                  color: const Color(0xFF191C1D),
                ),
              ),
              TextSpan(
                text: 'Chọn lọc tinh tế.',
                style: GoogleFonts.epilogue(
                  fontSize: size,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.2,
                  height: 1.05,
                  fontStyle: FontStyle.italic,
                  foreground: Paint()..shader = shader,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController doctorController;
  final VoidCallback onSearchTap;

  const _SearchBar({required this.doctorController, required this.onSearchTap});
  static const Color outlineVariant = Color(0xFFBBCAC6);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final wide = c.maxWidth > 760;
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.90),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: outlineVariant.withValues(alpha: 0.12)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 30,
              offset: const Offset(0, 18),
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: wide
                ? Row(
                    children: [
                      Expanded(
                        child: _SearchField(
                          icon: Icons.search,
                          hint: 'Chuyên khoa, tên bác sĩ hoặc phòng khám',
                          controller: doctorController,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SearchField(
                          icon: Icons.location_on_outlined,
                          hint: 'Khu vực',
                          enabled: false,
                        ),
                      ),
                      const SizedBox(width: 12),
                      _BookBtn(onTap: onSearchTap),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _SearchField(
                        icon: Icons.search,
                        hint: 'Chuyên khoa, tên bác sĩ hoặc phòng khám',
                        controller: doctorController,
                      ),
                      const SizedBox(height: 12),
                      _SearchField(
                        icon: Icons.location_on_outlined,
                        hint: 'Khu vực',
                        enabled: false,
                      ),
                      const SizedBox(height: 12),
                      _BookBtn(expanded: true, onTap: onSearchTap),
                    ],
                  ),
          ),
        ),
      );
    });
  }
}

class _SearchField extends StatelessWidget {
  final IconData icon;
  final String hint;
  final TextEditingController? controller;
  final bool enabled;

  const _SearchField({
    required this.icon,
    required this.hint,
    this.controller,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F4),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF006A62)),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              enabled: enabled,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hint,
                hintStyle: GoogleFonts.manrope(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BookBtn extends StatelessWidget {
  final bool expanded;
  final VoidCallback onTap;

  const _BookBtn({this.expanded = false, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final child = InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 14),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Color(0xFF006A62), Color(0xFF2EC4B6)],
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2EC4B6).withValues(alpha: 0.25),
              blurRadius: 24,
              offset: const Offset(0, 14),
            )
          ],
        ),
        child: Text(
          'Tìm',
          style: GoogleFonts.manrope(
            fontWeight: FontWeight.w900,
            color: Colors.white,
          ),
        ),
      ),
    );

    if (expanded) {
      return SizedBox(
        width: double.infinity,
        child: child,
      );
    }
    return child;
  }
}

class _HeroRight extends StatelessWidget {
  const _HeroRight();

  static const Color tertiaryContainer = Color(0xFFF99A15);
  static const Color secondaryContainer = Color(0xFFC5E4FA);
  static const Color onSurfaceVariant = Color(0xFF3C4947);

  @override
  Widget build(BuildContext context) {
    // Stack cần ràng buộc kích thước để tránh lỗi "size.isFinite".
    return SizedBox(
      height: 320,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
        Positioned.fill(
          child: Transform.rotate(
            angle: -0.28,
            child: Container(
              decoration: BoxDecoration(
                color: secondaryContainer.withValues(alpha: 0.30),
                borderRadius: BorderRadius.circular(64),
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(52),
              child: ColorFiltered(
                colorFilter: const ColorFilter.mode(
                  Color(0xFFB0B0B0),
                  BlendMode.saturation,
                ),
                child: DoctorImage(pathOrUrl: _HeroSection.heroDoctor, fit: BoxFit.cover),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -22,
          left: 0,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.90),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.white.withValues(alpha: 0.40)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.14),
                  blurRadius: 34,
                  offset: const Offset(0, 18),
                )
              ],
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: secondaryContainer.withValues(alpha: 0.80),
                  child: const Icon(Icons.verified, size: 18, color: tertiaryContainer),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '500+',
                      style: GoogleFonts.epilogue(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      'BÁC SĨ HÀNG ĐẦU',
                      style: GoogleFonts.manrope(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.6,
                        color: onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        ],
      ),
    );
  }
}

class _SpecialistsSection extends StatelessWidget {
  final List<Doctor> doctors;
  final bool isLoggedIn;

  const _SpecialistsSection({required this.doctors, required this.isLoggedIn});

  static const Color tertiaryContainer = Color(0xFFF99A15);
  static const Color primary = Color(0xFF006A62);

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
                Text(
                  'Gợi ý cho bạn',
                  style: GoogleFonts.manrope(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    color: tertiaryContainer,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Bác sĩ hàng đầu',
                  style: GoogleFonts.epilogue(
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                  ),
                ),
              ],
            ),
            InkWell(
              onTap: () => Navigator.of(context).pushNamed('/user/doctors'),
              child: Text(
                'Xem tất cả  >',
                style: GoogleFonts.manrope(
                  fontWeight: FontWeight.w900,
                  color: primary,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        LayoutBuilder(builder: (context, c) {
          final cols = c.maxWidth >= 1100
              ? 3
              : c.maxWidth >= 700
                  ? 2
                  : 1;
          final shown = doctors.take(6).toList();
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: cols,
              mainAxisSpacing: 22,
              crossAxisSpacing: 22,
              childAspectRatio: 0.72,
            ),
            itemCount: shown.length,
            itemBuilder: (context, i) {
              final d = shown[i];
              return _DoctorCard(
                doctor: d,
                onTap: () {
                  if (!isLoggedIn) {
                    Navigator.of(context).pushNamed('/');
                    return;
                  }
                  Navigator.of(context).pushNamed('/user/doctor', arguments: d);
                },
              );
            },
          );
        }),
      ],
    );
  }
}

class _DoctorCard extends StatefulWidget {
  final Doctor doctor;
  final VoidCallback onTap;

  const _DoctorCard({
    required this.doctor,
    required this.onTap,
  });

  @override
  State<_DoctorCard> createState() => _DoctorCardState();
}

class _DoctorCardState extends State<_DoctorCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final highlight = widget.doctor.experience >= 10;
    final bg = highlight ? const Color(0xFFFFFFFF) : const Color(0xFFE6E8E9);

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      child: AnimatedScale(
        scale: _hover ? 1.02 : 1.0,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(40),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(26),
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: AnimatedScale(
                      scale: _hover ? 1.05 : 1.0,
                      duration: const Duration(milliseconds: 700),
                      curve: Curves.easeOutCubic,
                      child: DoctorImage(pathOrUrl: widget.doctor.image, fit: BoxFit.cover),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.doctor.name,
                                  style: GoogleFonts.epilogue(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    height: 1.1,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  widget.doctor.specialty,
                                  style: GoogleFonts.manrope(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF3C4947),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.arrow_forward,
                              color: Color(0xFF2EC4B6),
                            ),
                          ),
                        ],
                      ),
                      if (highlight) ...[
                        const SizedBox(height: 18),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFC5E4FA),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Text(
                            'Dày dặn kinh nghiệm',
                            style: GoogleFonts.manrope(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFF2C4A5C),
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 18),
                      Text(
                        '${widget.doctor.experience} năm kinh nghiệm',
                        style: GoogleFonts.manrope(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF3C4947).withValues(alpha: 0.65),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ExperienceCareSection extends StatelessWidget {
  const _ExperienceCareSection();

  static const Color surfaceContainer = Color(0xFFECEEEE);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      decoration: BoxDecoration(
        color: surfaceContainer,
        borderRadius: BorderRadius.circular(48),
      ),
      child: LayoutBuilder(builder: (context, c) {
        final isDesktop = c.maxWidth >= 900;
        return isDesktop
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 5, child: _ExperienceLeft()),
                  const SizedBox(width: 24),
                  Expanded(flex: 6, child: _BookingTimeline()),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ExperienceLeft(),
                  const SizedBox(height: 24),
                  _BookingTimeline(),
                ],
              );
      }),
    );
  }
}

class _ExperienceLeft extends StatelessWidget {
  const _ExperienceLeft();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Trải nghiệm chăm sóc\nmượt mà,\nkhông rườm rà.',
          style: GoogleFonts.epilogue(
            fontSize: 28,
            fontWeight: FontWeight.w900,
            height: 1.08,
          ),
        ),
        const SizedBox(height: 22),
        _Bullet(
          icon: Icons.bolt,
          title: 'Đặt lịch tức thì',
          description:
              'Không cần gọi điện. Xác nhận lịch hẹn trong khoảng 60 giây.',
        ),
        const SizedBox(height: 14),
        _Bullet(
          icon: Icons.video_chat_outlined,
          title: 'Khám linh hoạt',
          description:
              'Chọn tư vấn trực tuyến hoặc khám trực tiếp tại phòng khám.',
        ),
        const SizedBox(height: 14),
        _Bullet(
          icon: Icons.folder_shared_outlined,
          title: 'Hồ sơ sức khỏe thông minh',
          description:
              'Lưu trữ lịch sử khám, xét nghiệm và đơn thuốc ở một nơi gọn gàng.',
        ),
      ],
    );
  }
}

class _Bullet extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _Bullet({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: const Color(0xFF006A62), size: 22),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.manrope(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                description,
                style: GoogleFonts.manrope(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF3C4947),
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BookingTimeline extends StatelessWidget {
  const _BookingTimeline();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.60),
        borderRadius: BorderRadius.circular(34),
        border: Border.all(color: Colors.white.withValues(alpha: 0.40)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 34,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(34),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Phiên đặt lịch',
                    style: GoogleFonts.epilogue(
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                  Text(
                    '24/10/2024',
                    style: GoogleFonts.manrope(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF3C4947).withValues(alpha: 0.50),
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _TimeCard(
                time: '09:00 AM',
                title: 'Khám tổng quát',
                dimmed: true,
                leftColor: null,
                action: const Icon(Icons.lock_outline, size: 18),
              ),
              const SizedBox(height: 10),
              _TimeCard(
                time: '11:30 AM',
                title: 'Tư vấn nha khoa',
                subtitle: 'Dr. Amanda Lee',
                accent: true,
                leftColor: const Color(0xFFF99A15),
                action: const Icon(Icons.check_circle, size: 18),
              ),
              const SizedBox(height: 10),
              _TimeCard(
                time: '02:15 PM',
                title: 'Nhi khoa',
                action: Text(
                  'CHỌN',
                  style: GoogleFonts.manrope(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                    color: const Color(0xFF3C4947).withValues(alpha: 0.85),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimeCard extends StatelessWidget {
  final String time;
  final String title;
  final String? subtitle;
  final bool dimmed;
  final bool accent;
  final Color? leftColor;
  final Widget action;

  const _TimeCard({
    required this.time,
    required this.title,
    this.subtitle,
    this.dimmed = false,
    this.accent = false,
    this.leftColor,
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    final baseBg = accent
        ? const Color(0xFFFFF6EC)
        : dimmed
            ? const Color(0xFFF2F4F4)
            : Colors.white;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: baseBg,
        borderRadius: BorderRadius.circular(18),
        border: accent
            ? Border(
                left: BorderSide(
                  color: leftColor ?? const Color(0xFFF99A15),
                  width: 6,
                ),
              )
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                time,
                style: GoogleFonts.manrope(
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                  color: accent
                      ? const Color(0xFFF99A15)
                      : const Color(0xFF3C4947).withValues(alpha: 0.90),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 2,
                height: 26,
                color: const Color(0xFFBBcac6).withValues(alpha: 0.45),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.manrope(
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: GoogleFonts.manrope(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF3C4947).withValues(alpha: 0.65),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          accent
              ? CircleAvatar(
                  radius: 16,
                  backgroundColor: const Color(0xFF2EC4B6),
                  child: const Icon(Icons.check_circle, size: 18, color: Colors.white),
                )
              : action,
        ],
      ),
    );
  }
}

// Footer đã được tách ra widget dùng chung: `AppFooter` (lib/views/widgets/app_footer.dart)


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
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= 900;
    final user = SessionController.instance.currentUser;
    final horizontalPad = width < 600 ? 16.0 : 40.0;

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            AppTopNavBar(
              isDesktop: isDesktop,
              isLoggedIn: user != null,
              activeKey: 'find_care',
              onTapFindCare: () => Navigator.of(context).pushReplacementNamed('/user/doctors'),
              onTapSpecialists: () => _scrollTo(_specialistsKey),
              onTapSchedule: () {
                if (user == null) {
                  Navigator.of(context).pushNamed('/');
                } else {
                  Navigator.of(context).pushNamed('/user/appointments');
                }
              },
              onTapMyHealth: () {
                if (user == null) {
                  Navigator.of(context).pushNamed('/');
                } else {
                  Navigator.of(context).pushNamed('/user/appointments');
                }
              },
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
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPad),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1200),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 48),
                          _HeroSection(
                            isDesktop: isDesktop,
                            onBookTap: () => _scrollTo(_specialistsKey),
                            doctorSearchController: _doctorSearchController,
                            onSearchTap: () {
                              final q = _doctorSearchController.text.trim();
                              Navigator.of(context).pushNamed('/user/doctors', arguments: q);
                            },
                          ),
                          const SizedBox(height: 80),
                          FutureBuilder<List<Doctor>>(
                            future: _doctorsFuture,
                            builder: (context, snap) {
                              if (!snap.hasData) {
                                return const Center(child: CircularProgressIndicator());
                              }
                              return KeyedSubtree(
                                key: _specialistsKey,
                                child: _SpecialistsSection(
                                  doctors: snap.data!,
                                  isLoggedIn: user != null,
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 80),
                          KeyedSubtree(
                            key: _experienceKey,
                            child: const _ExperienceCareSection(),
                          ),
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
}

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

  @override
  Widget build(BuildContext context) {
    return isDesktop
        ? Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 7,
          child: _HeroLeft(
            doctorSearchController: doctorSearchController,
            onSearchTap: onSearchTap,
          ),
        ),
        const SizedBox(width: 40),
        const Expanded(flex: 5, child: _HeroRight()),
      ],
    )
        : Column(
      children: [
        _HeroLeft(doctorSearchController: doctorSearchController, onSearchTap: onSearchTap),
        const SizedBox(height: 40),
        const _HeroRight(),
      ],
    );
  }
}

class _HeroLeft extends StatelessWidget {
  final TextEditingController doctorSearchController;
  final VoidCallback onSearchTap;
  const _HeroLeft({required this.doctorSearchController, required this.onSearchTap});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < 600;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _HeroHeadline(isMobile: isMobile),
        const SizedBox(height: 24),
        Text(
          'Bỏ qua phòng chờ. Kết nối với bác sĩ hàng đầu qua trải nghiệm được thiết kế cho sức khỏe của bạn — chủ động và cá nhân hóa.',
          style: GoogleFonts.manrope(fontSize: 18, color: const Color(0xFF3C4947), height: 1.6),
        ),
        const SizedBox(height: 32),
        _SearchBar(doctorController: doctorSearchController, onSearchTap: onSearchTap),
      ],
    );
  }
}

class _HeroHeadline extends StatelessWidget {
  final bool isMobile;
  const _HeroHeadline({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final double size = isMobile ? 48 : 72;
    return RichText(
      text: TextSpan(
        style: GoogleFonts.epilogue(fontSize: size, fontWeight: FontWeight.w900, color: const Color(0xFF191C1D), height: 1.1),
        children: [
          const TextSpan(text: 'Sức khỏe,\n'),
          TextSpan(
            text: 'Chọn lọc tinh tế.',
            style: TextStyle(
              fontStyle: FontStyle.italic,
              foreground: Paint()
                ..shader = const LinearGradient(
                  colors: [Color(0xFF006A62), Color(0xFF2EC4B6)],
                ).createShader(const Rect.fromLTWH(0, 0, 500, 70)),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController doctorController;
  final VoidCallback onSearchTap;
  const _SearchBar({required this.doctorController, required this.onSearchTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 40, offset: const Offset(0, 20))],
      ),
      child: Row(
        children: [
          const SizedBox(width: 12),
          const Icon(Icons.search, color: Color(0xFF006A62)),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: doctorController,
              decoration: InputDecoration(
                hintText: 'Tên bác sĩ hoặc chuyên khoa...',
                hintStyle: GoogleFonts.manrope(color: Colors.grey),
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: onSearchTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF006A62),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: Text('Tìm kiếm', style: GoogleFonts.manrope(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }
}

class _HeroRight extends StatelessWidget {
  const _HeroRight();
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 300,
          height: 300,
          decoration: const BoxDecoration(color: Color(0xFFC5E4FA), shape: BoxShape.circle),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(300),
          child: SizedBox(
            width: 280,
            height: 280,
            child: ColorFiltered(
              colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.saturation),
              child: DoctorImage(pathOrUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuALzjGvI7RG-nVb5i62uMGRIwFkn1VaqIEJ8dKwOcBzjlE7JUMqqfVK3jB3wP_6m-OTymNgCeFebtLzZVBBTkhje88MfyZpwpcMWD3qRFtUouC4n04EA6-xdx_OcLODpP-vTLmT1IBVjaZQFDLbB-1t8I1jWtSznl57ZAN2te6dDUhf-uaogBTbThrBf76asK89gxPyYU8WKwT0cfmdpfBJ7jbuW-y3jSfnNCCMja3qm9C3IxCyCDl31BCMqkygDCGhWeX7Pr2pwbA', fit: BoxFit.cover),
            ),
          ),
        ),
        Positioned(
          bottom: 20,
          right: 0,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20)],
            ),
            child: Row(
              children: [
                const Icon(Icons.verified, color: Color(0xFFF99A15)),
                const SizedBox(width: 8),
                Text('500+ Bác sĩ đầu ngành', style: GoogleFonts.manrope(fontWeight: FontWeight.w800, fontSize: 12)),
              ],
            ),
          ),
        )
      ],
    );
  }
}

class _SpecialistsSection extends StatelessWidget {
  final List<Doctor> doctors;
  final bool isLoggedIn;
  const _SpecialistsSection({required this.doctors, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    final shown = doctors.take(6).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Bác sĩ tiêu biểu', style: GoogleFonts.epilogue(fontSize: 32, fontWeight: FontWeight.w900)),
            TextButton(
              onPressed: () => Navigator.of(context).pushNamed('/user/doctors'),
              child: Text('Xem tất cả', style: GoogleFonts.manrope(color: const Color(0xFF006A62), fontWeight: FontWeight.w800)),
            ),
          ],
        ),
        const SizedBox(height: 32),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 24,
            crossAxisSpacing: 24,
            childAspectRatio: 0.75,
          ),
          itemCount: shown.length,
          itemBuilder: (context, i) => _DoctorCard(
            doctor: shown[i],
            onTap: () {
              if (!isLoggedIn) {
                Navigator.of(context).pushNamed('/');
              } else {
                Navigator.of(context).pushNamed('/user/doctor', arguments: shown[i]);
              }
            },
          ),
        ),
      ],
    );
  }
}

class _DoctorCard extends StatelessWidget {
  final Doctor doctor;
  final VoidCallback onTap;
  const _DoctorCard({required this.doctor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 20)]),
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                child: DoctorImage(pathOrUrl: doctor.image, fit: BoxFit.cover),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(doctor.name, style: GoogleFonts.epilogue(fontSize: 18, fontWeight: FontWeight.w900)),
                  Text(doctor.specialty, style: GoogleFonts.manrope(color: Colors.grey, fontWeight: FontWeight.w600)),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _ExperienceCareSection extends StatelessWidget {
  const _ExperienceCareSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(color: const Color(0xFFECEEEE), borderRadius: BorderRadius.circular(48)),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Trải nghiệm mượt mà,\nkhông rườm rà.', style: GoogleFonts.epilogue(fontSize: 32, fontWeight: FontWeight.w900, height: 1.2)),
                const SizedBox(height: 32),
                _Bullet(icon: Icons.bolt, title: 'Đặt lịch tức thì', desc: 'Xác nhận lịch hẹn chỉ trong 60 giây.'),
                const SizedBox(height: 16),
                _Bullet(icon: Icons.video_call, title: 'Tư vấn từ xa', desc: 'Kết nối với bác sĩ mọi lúc mọi nơi.'),
              ],
            ),
          ),
          const SizedBox(width: 40),
          const Expanded(flex: 5, child: _BookingTimeline()),
        ],
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;
  const _Bullet({required this.icon, required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: Icon(icon, color: const Color(0xFF006A62)),
        ),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: GoogleFonts.manrope(fontWeight: FontWeight.w900, fontSize: 16)),
            Text(desc, style: GoogleFonts.manrope(color: Colors.blueGrey)),
          ],
        )
      ],
    );
  }
}

class _BookingTimeline extends StatelessWidget {
  const _BookingTimeline();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 30)]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tiến trình đặt lịch', style: GoogleFonts.epilogue(fontWeight: FontWeight.w900, fontSize: 20)),
          const SizedBox(height: 24),
          _TimelineStep(index: 1, title: 'Chọn bác sĩ', active: true),
          _TimelineStep(index: 2, title: 'Chọn khung giờ', active: true),
          _TimelineStep(index: 3, title: 'Hoàn tất', active: false, isLast: true),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: const Color(0xFF006A62), borderRadius: BorderRadius.circular(16)),
            child: const Row(
              children: [
                Icon(Icons.calendar_month, color: Colors.white),
                SizedBox(width: 12),
                Text('Lịch hẹn: Thứ 6, 24/04', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _TimelineStep extends StatelessWidget {
  final int index;
  final String title;
  final bool active;
  final bool isLast;
  const _TimelineStep({required this.index, required this.title, required this.active, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          children: [
            CircleAvatar(radius: 12, backgroundColor: active ? const Color(0xFF006A62) : Colors.grey[200], child: Text('$index', style: TextStyle(color: active ? Colors.white : Colors.grey, fontSize: 10))),
            if (!isLast) Container(width: 2, height: 20, color: Colors.grey[200]),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(title, style: GoogleFonts.manrope(fontWeight: active ? FontWeight.w800 : FontWeight.w500))),
      ],
    );
  }
}
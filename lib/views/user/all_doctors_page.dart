import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../controllers/doctor_controller.dart';
import '../../controllers/session_controller.dart';
import '../../models/doctor.dart';
import '../widgets/app_footer.dart';
import '../widgets/app_top_nav_bar.dart';
import '../widgets/doctor_image.dart';

class AllDoctorsPage extends StatefulWidget {
  const AllDoctorsPage({super.key});

  @override
  State<AllDoctorsPage> createState() => _AllDoctorsPageState();
}

class _AllDoctorsPageState extends State<AllDoctorsPage> {
  late Future<List<Doctor>> _future;
  String _query = '';
  bool _argApplied = false;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _future = DoctorController.instance.getAllDoctors();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_argApplied) {
      final arg = ModalRoute.of(context)?.settings.arguments;
      if (arg is String && arg.trim().isNotEmpty) {
        _query = arg.trim();
        _searchController.text = _query;
      }
      _argApplied = true;
    }
    final width = MediaQuery.sizeOf(context).width;
    final isLoggedIn = SessionController.instance.currentUser != null;
    final cols = width >= 1200 ? 4 : width >= 900 ? 3 : width >= 650 ? 2 : 1;
    final titleSize = width >= 900 ? 44.0 : width >= 600 ? 38.0 : 30.0;

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
              onTapSchedule: () =>
                  Navigator.of(context).pushReplacementNamed('/user/appointments'),
              onTapMyHealth: () =>
                  Navigator.of(context).pushReplacementNamed('/user/appointments'),
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
                        Text(
                          'Danh sách bác sĩ',
                          style: GoogleFonts.epilogue(
                            fontSize: titleSize,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Tìm bác sĩ theo tên hoặc chuyên khoa. Bấm vào bác sĩ để xem chi tiết và đặt lịch.',
                          style: GoogleFonts.manrope(
                            fontWeight: FontWeight.w600,
                            color:
                                const Color(0xFF3C4947).withValues(alpha: 0.75),
                          ),
                        ),
                        const SizedBox(height: 18),
                        _SearchField(
                          controller: _searchController,
                          onChanged: (v) => setState(() => _query = v.trim()),
                        ),
                        const SizedBox(height: 18),
                        FutureBuilder<List<Doctor>>(
                          future: _future,
                          builder: (context, snap) {
                            if (!snap.hasData) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 40),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
                            final all = snap.data!;
                            final q = _query.toLowerCase();
                            final filtered = q.isEmpty
                                ? all
                                : all.where((d) {
                                    final hay = [
                                      d.name,
                                      d.specialty,
                                      ...d.specializations,
                                    ].join(' ').toLowerCase();
                                    return hay.contains(q);
                                  }).toList();

                            if (filtered.isEmpty) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 28),
                                child: Text(
                                  'Không tìm thấy bác sĩ phù hợp.',
                                  style: GoogleFonts.manrope(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              );
                            }

                            return GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: cols,
                                crossAxisSpacing: 18,
                                mainAxisSpacing: 18,
                                childAspectRatio: cols == 1 ? 2.6 : 0.88,
                              ),
                              itemCount: filtered.length,
                              itemBuilder: (context, i) {
                                final d = filtered[i];
                                return _DoctorTile(
                                  doctor: d,
                                  onTap: () {
                                    if (!isLoggedIn) {
                                      Navigator.of(context).pushNamed('/');
                                      return;
                                    }
                                    Navigator.of(context).pushNamed(
                                      '/user/doctor',
                                      arguments: d,
                                    );
                                  },
                                );
                              },
                            );
                          },
                        ),
                        const SizedBox(height: 28),
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

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  const _SearchField({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: const Color(0xFFBBCAC6).withValues(alpha: 0.18),
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.search, color: Color(0xFF006A62)),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: controller,
                  onChanged: onChanged,
                  decoration: InputDecoration(
                    hintText: 'Tìm theo tên / chuyên khoa / chuyên môn…',
                    hintStyle: GoogleFonts.manrope(
                      fontWeight: FontWeight.w600,
                      color:
                          const Color(0xFF3C4947).withValues(alpha: 0.45),
                    ),
                    border: InputBorder.none,
                    isDense: true,
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

class _DoctorTile extends StatelessWidget {
  final Doctor doctor;
  final VoidCallback onTap;
  const _DoctorTile({required this.doctor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final specs = doctor.specializations.take(3).toList();
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: const Color(0xFFBBCAC6).withValues(alpha: 0.18),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF191C1D).withValues(alpha: 0.06),
              blurRadius: 30,
              offset: const Offset(0, 18),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: DoctorImage(pathOrUrl: doctor.image, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              doctor.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.epilogue(
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              doctor.specialty,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.manrope(
                fontWeight: FontWeight.w700,
                color: const Color(0xFF006A62),
              ),
            ),
            if (specs.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final s in specs)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2F4F4),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        s,
                        style: GoogleFonts.manrope(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF3C4947),
                        ),
                      ),
                    )
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}


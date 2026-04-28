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

  // Color constants đồng bộ với hệ thống mới
  static const Color kPrimary = Color(0xFF0D9488);
  static const Color kBackground = Color(0xFFF8FAFC);
  static const Color kTextDark = Color(0xFF0F172A);
  static const Color kTextLight = Color(0xFF64748B);

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

    // Responsive grid logic
    final cols = width >= 1200 ? 4 : width >= 900 ? 3 : width >= 600 ? 2 : 1;
    final titleSize = width >= 900 ? 40.0 : 28.0;

    return Scaffold(
      backgroundColor: kBackground,
      body: SafeArea(
        child: Column(
          children: [
            AppTopNavBar(
              isDesktop: width >= 900,
              isLoggedIn: isLoggedIn,
              activeKey: 'specialists',
              onTapFindCare: () => Navigator.of(context).pushReplacementNamed('/user/doctors'),
              onTapSpecialists: () => Navigator.of(context).pushReplacementNamed('/user/doctors'),
              onTapSchedule: () => Navigator.of(context).pushReplacementNamed('/user/appointments'),
              onTapMyHealth: () => Navigator.of(context).pushReplacementNamed('/user/appointments'),
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
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(
                  horizontal: width < 600 ? 20 : 40,
                  vertical: 32,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Đội ngũ chuyên gia',
                                    style: GoogleFonts.epilogue(
                                      fontSize: titleSize,
                                      fontWeight: FontWeight.w800,
                                      color: kTextDark,
                                      letterSpacing: -1,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Tìm kiếm bác sĩ theo tên hoặc chuyên khoa để nhận tư vấn tốt nhất.',
                                    style: GoogleFonts.manrope(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w500,
                                      color: kTextLight,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // Enhanced Search Field
                        _SearchField(
                          controller: _searchController,
                          onChanged: (v) => setState(() => _query = v.trim()),
                        ),
                        const SizedBox(height: 40),

                        // List Section
                        FutureBuilder<List<Doctor>>(
                          future: _future,
                          builder: (context, snap) {
                            if (snap.connectionState == ConnectionState.waiting) {
                              return const SizedBox(
                                height: 300,
                                child: Center(child: CircularProgressIndicator(color: kPrimary)),
                              );
                            }

                            final all = snap.data ?? [];
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
                              return _buildEmptyState();
                            }

                            return GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: cols,
                                crossAxisSpacing: 24,
                                mainAxisSpacing: 24,
                                childAspectRatio: cols == 1 ? 2.8 : 0.78,
                              ),
                              itemCount: filtered.length,
                              itemBuilder: (context, i) {
                                return _DoctorTile(
                                  doctor: filtered[i],
                                  onTap: () {
                                    if (!isLoggedIn) {
                                      Navigator.of(context).pushNamed('/');
                                      return;
                                    }
                                    Navigator.of(context).pushNamed(
                                      '/user/doctor',
                                      arguments: filtered[i],
                                    );
                                  },
                                );
                              },
                            );
                          },
                        ),
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

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Icon(Icons.search_off_rounded, size: 64, color: kTextLight.withAlpha(100)),
          const SizedBox(height: 16),
          Text(
            'Không tìm thấy bác sĩ phù hợp',
            style: GoogleFonts.manrope(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: kTextDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Hãy thử thay đổi từ khóa tìm kiếm của bạn.',
            style: GoogleFonts.manrope(color: kTextLight),
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  const _SearchField({required this.controller, required this.onChanged});

  @override
  State<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends State<_SearchField> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (focus) => setState(() => _isFocused = focus),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _isFocused ? const Color(0xFF0D9488) : Colors.white,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: _isFocused
                  ? const Color(0xFF0D9488).withAlpha(15)
                  : Colors.black.withAlpha(8),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        child: Row(
          children: [
            const Icon(Icons.search_rounded, color: Color(0xFF0D9488), size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: widget.controller,
                onChanged: widget.onChanged,
                style: GoogleFonts.manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF0F172A),
                ),
                decoration: InputDecoration(
                  hintText: 'Tên bác sĩ, chuyên khoa, chuyên môn...',
                  hintStyle: GoogleFonts.manrope(
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF94A3B8),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            if (widget.controller.text.isNotEmpty)
              IconButton(
                onPressed: () {
                  widget.controller.clear();
                  widget.onChanged('');
                },
                icon: const Icon(Icons.close_rounded, size: 20, color: Color(0xFF94A3B8)),
              ),
          ],
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
    final specs = doctor.specializations.take(2).toList();

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(8),
                blurRadius: 24,
                offset: const Offset(0, 12),
              )
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Doctor Image with Overlay Icon
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        color: const Color(0xFFF1F5F9),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: DoctorImage(pathOrUrl: doctor.image, fit: BoxFit.cover),
                      ),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.favorite_border_rounded, size: 18, color: Color(0xFFF43F5E)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Name & Specialty
              Text(
                doctor.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.epilogue(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                doctor.specialty.toUpperCase(),
                style: GoogleFonts.manrope(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                  color: const Color(0xFF0D9488),
                ),
              ),

              // Specialization Tags
              if (specs.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (final s in specs)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          s,
                          style: GoogleFonts.manrope(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF475569),
                          ),
                        ),
                      ),
                    if (doctor.specializations.length > 2)
                      Text(
                        '+${doctor.specializations.length - 2}',
                        style: GoogleFonts.manrope(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                  ],
                ),
              ],

              const SizedBox(height: 16),
              // Appointment Button Placeholder (Look-alike)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D9488).withAlpha(15),
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Đặt lịch hẹn',
                  style: GoogleFonts.manrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0D9488),
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
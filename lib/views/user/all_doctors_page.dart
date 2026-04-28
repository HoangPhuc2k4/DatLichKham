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

  static const Color primaryMedical = Color(0xFF006A62);
  static const Color backgroundLight = Color(0xFFF8FAFA);

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
    // Xử lý arguments từ Navigator
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

    // Grid Logic
    final crossAxisCount = width >= 1100 ? 4 : width >= 800 ? 3 : width >= 600 ? 2 : 1;

    return Scaffold(
      backgroundColor: backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            AppTopNavBar(
              isDesktop: width >= 900,
              isLoggedIn: isLoggedIn,
              activeKey: 'specialists',
              onTapFindCare: () => Navigator.of(context).pushReplacementNamed('/user/doctors'),
              onTapSpecialists: () {},
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
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: width < 600 ? 20 : 40,
                        vertical: 40,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(),
                          const SizedBox(height: 32),
                          _buildSearchSection(),
                          const SizedBox(height: 40),
                          _buildGridArea(crossAxisCount, isLoggedIn),
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

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: primaryMedical.withOpacity(0.1),
            borderRadius: BorderRadius.circular(99),
          ),
          child: Text(
            'CHUYÊN GIA Y TẾ',
            style: GoogleFonts.manrope(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: primaryMedical,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Đội ngũ Bác sĩ',
          style: GoogleFonts.epilogue(
            fontSize: 40,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF191C1D),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Kết nối với những chuyên gia hàng đầu để nhận được sự chăm sóc tận tâm và phác đồ điều trị tối ưu nhất.',
          style: GoogleFonts.manrope(
            fontSize: 16,
            height: 1.6,
            color: const Color(0xFF3C4947).withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (v) => setState(() => _query = v.trim().toLowerCase()),
        style: GoogleFonts.manrope(fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          hintText: 'Tìm theo tên, chuyên khoa hoặc học hàm...',
          hintStyle: GoogleFonts.manrope(color: Colors.grey, fontWeight: FontWeight.w500),
          prefixIcon: const Icon(Icons.search_rounded, color: primaryMedical),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(20),
        ),
      ),
    );
  }

  Widget _buildGridArea(int cols, bool isLoggedIn) {
    return FutureBuilder<List<Doctor>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: primaryMedical));
        }

        final list = snapshot.data ?? [];
        final filtered = list.where((d) {
          final s = _query;
          return d.name.toLowerCase().contains(s) ||
              d.specialty.toLowerCase().contains(s);
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
            mainAxisExtent: 380, // Chiều cao cố định cho card
          ),
          itemCount: filtered.length,
          itemBuilder: (context, index) => _DoctorBentoCard(
            doctor: filtered[index],
            onTap: () => Navigator.of(context).pushNamed(
              '/user/doctor-detail',
              arguments: filtered[index].id,
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 40),
          Icon(Icons.person_search_outlined, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'Không tìm thấy bác sĩ phù hợp',
            style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class _DoctorBentoCard extends StatefulWidget {
  final Doctor doctor;
  final VoidCallback onTap;

  const _DoctorBentoCard({required this.doctor, required this.onTap});

  @override
  State<_DoctorBentoCard> createState() => _DoctorBentoCardState();
}

class _DoctorBentoCardState extends State<_DoctorBentoCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedScale(
        scale: _hovered ? 1.02 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(_hovered ? 0.08 : 0.03),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ảnh bác sĩ
                Expanded(
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(10),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: DoctorImage(
                        pathOrUrl: widget.doctor.image,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
                // Thông tin
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.doctor.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.epilogue(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF191C1D),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.doctor.specialty,
                        style: GoogleFonts.manrope(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF006A62),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildBadge(Icons.star_rounded, '4.9', const Color(0xFFF99A15)),
                          _buildBadge(Icons.access_time_rounded, 'Có sẵn', Colors.blue),
                        ],
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

  Widget _buildBadge(IconData icon, String label, Color color) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: GoogleFonts.manrope(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF3C4947),
          ),
        ),
      ],
    );
  }
}
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../controllers/appointment_controller.dart';
import '../../controllers/session_controller.dart';
import '../../models/appointment.dart';
import '../../models/appointment_details.dart';
import '../../models/doctor.dart';
import '../widgets/app_footer.dart';
import '../widgets/app_top_nav_bar.dart';
import '../widgets/app_confirm_dialog.dart';

class MyAppointmentsPage extends StatefulWidget {
  const MyAppointmentsPage({super.key});

  @override
  State<MyAppointmentsPage> createState() => _MyAppointmentsPageState();
}

class _MyAppointmentsPageState extends State<MyAppointmentsPage> {
  bool loading = true;
  List<AppointmentDetails> items = [];
  bool historyMode = false;
  int page = 1;
  static const int pageSize = 4;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = SessionController.instance.currentUser;
    if (user?.id == null) {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/');
      return;
    }
    setState(() => loading = true);
    items = await AppointmentController.instance.getAppointmentsByUserDetails(user!.id!);
    setState(() {
      loading = false;
      page = 1;
    });
  }

  Future<void> _cancel(Appointment a) async {
    final ok = await showAppConfirmDialog(
      context,
      title: 'Hủy lịch khám?',
      message: 'Bạn chắc chắn muốn hủy lịch khám này? Slot sẽ được mở lại để đặt lịch.',
      confirmText: 'XÁC NHẬN HỦY',
      cancelText: 'GIỮ LẠI',
    );
    if (!ok) return;
    try {
      await AppointmentController.instance.cancelAppointment(a);
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= 1100;

    // Lọc và sắp xếp
    final confirmed = items.where((d) => d.appointment.status == 'confirmed').toList();
    final other = items.where((d) => d.appointment.status != 'confirmed').toList();

    final displayItems = historyMode ? items : (confirmed.isNotEmpty ? confirmed : items);
    final focal = displayItems.isNotEmpty ? displayItems.first : null;
    final rest = displayItems.length > 1 ? displayItems.sublist(1) : <AppointmentDetails>[];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            AppTopNavBar(
              isDesktop: width >= 900,
              isLoggedIn: true,
              activeKey: 'my_health',
              onTapFindCare: () => Navigator.of(context).pushReplacementNamed('/user/doctors'),
              onTapSpecialists: () => Navigator.of(context).pushReplacementNamed('/user/doctors'),
              onTapSchedule: () {},
              onTapMyHealth: () {},
              onTapAuth: () {
                SessionController.instance.logout();
                Navigator.of(context).pushReplacementNamed('/user/home');
              },
            ),
            Expanded(
              child: loading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF0D9488)))
                  : SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: width < 600 ? 20 : 40, vertical: 32),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 32),
                        if (items.isEmpty)
                          _buildEmptyState()
                        else
                          _buildBentoGrid(isDesktop, focal, rest),
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

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('QUẢN LÝ SỨC KHỎE', style: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.w800, color: const Color(0xFF0D9488), letterSpacing: 1.5)),
            const SizedBox(height: 8),
            Text('Lịch khám của bạn', style: GoogleFonts.epilogue(fontSize: 32, fontWeight: FontWeight.w900, color: const Color(0xFF0F172A))),
          ],
        ),
        ElevatedButton.icon(
          onPressed: () => Navigator.of(context).pushNamed('/user/home'),
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Đặt lịch mới'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0D9488),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
        ),
      ],
    );
  }

  Widget _buildBentoGrid(bool isDesktop, AppointmentDetails? focal, List<AppointmentDetails> rest) {
    return Column(
      children: [
        if (focal != null)
          _FocalAppointmentCard(
            d: focal,
            onCancel: () => _cancel(focal.appointment),
          ),
        const SizedBox(height: 24),
        if (rest.isNotEmpty)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: rest.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isDesktop ? 2 : 1,
              mainAxisExtent: 180,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
            ),
            itemBuilder: (context, i) => _SmallAppointmentCard(d: rest[i]),
          ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 60),
          Icon(Icons.calendar_today_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 24),
          Text('Chưa có lịch hẹn nào', style: GoogleFonts.epilogue(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text('Bắt đầu chăm sóc sức khỏe của bạn ngay hôm nay.', style: GoogleFonts.manrope(color: Colors.grey[600])),
        ],
      ),
    );
  }
}

class _FocalAppointmentCard extends StatelessWidget {
  final AppointmentDetails d;
  final VoidCallback onCancel;

  const _FocalAppointmentCard({required this.d, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    final isConfirmed = d.appointment.status == 'confirmed';

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF0F172A), Color(0xFF1E293B)]),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 40, offset: const Offset(0, 20))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StatusTag(status: d.appointment.status),
                const SizedBox(height: 20),
                Text(d.doctorName, style: GoogleFonts.epilogue(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.white)),
                Text(d.specialty, style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w600, color: const Color(0xFF0D9488))),
                const SizedBox(height: 24),
                Row(
                  children: [
                    _InfoItem(icon: Icons.calendar_month, text: d.date, isDark: true),
                    const SizedBox(width: 24),
                    _InfoItem(icon: Icons.access_time_filled, text: d.startTime, isDark: true),
                  ],
                ),
              ],
            ),
          ),
          if (isConfirmed)
            Column(
              children: [
                ElevatedButton(
                  onPressed: onCancel,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withAlpha(30),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Hủy lịch'),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _SmallAppointmentCard extends StatelessWidget {
  final AppointmentDetails d;
  const _SmallAppointmentCard({required this.d});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _StatusTag(status: d.appointment.status),
              const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFF94A3B8)),
            ],
          ),
          const Spacer(),
          Text(d.doctorName, style: GoogleFonts.epilogue(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          Row(
            children: [
              _InfoItem(icon: Icons.calendar_today, text: d.date),
              const SizedBox(width: 16),
              _InfoItem(icon: Icons.access_time, text: d.startTime),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusTag extends StatelessWidget {
  final String status;
  const _StatusTag({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String text;
    switch (status) {
      case 'confirmed':
        color = const Color(0xFF0D9488);
        text = 'ĐÃ XÁC NHẬN';
        break;
      case 'pending':
        color = const Color(0xFFF59E0B);
        text = 'ĐANG CHỜ';
        break;
      default:
        color = const Color(0xFF94A3B8);
        text = 'ĐÃ HỦY';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color.withAlpha(30), borderRadius: BorderRadius.circular(6)),
      child: Text(text, style: GoogleFonts.manrope(fontSize: 10, fontWeight: FontWeight.w800, color: color)),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isDark;
  const _InfoItem({required this.icon, required this.text, this.isDark = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: isDark ? const Color(0xFF0D9488) : const Color(0xFF64748B)),
        const SizedBox(width: 8),
        Text(text, style: GoogleFonts.manrope(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF475569))),
      ],
    );
  }
}
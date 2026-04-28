import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../controllers/appointment_controller.dart';
import '../../controllers/schedule_controller.dart';
import '../../controllers/session_controller.dart';
import '../../models/appointment.dart';
import '../../models/doctor.dart';
import '../../models/schedule.dart';
import '../widgets/app_footer.dart';
import '../widgets/app_top_nav_bar.dart';
import '../widgets/doctor_image.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({super.key});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  Doctor? doctor;
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month, 1);
  DateTime _selectedDate = DateTime.now();
  List<Schedule> _slots = [];
  Schedule? _selectedSlot;
  bool _loadingSlots = true;

  final _symptomController = TextEditingController();

  static const Color kPrimary = Color(0xFF0D9488);
  static const Color kSecondary = Color(0xFFF1F5F9);
  static const Color kAccent = Color(0xFFF59E0B);
  static const Color kTextDark = Color(0xFF0F172A);
  static const Color kTextLight = Color(0xFF64748B);

  @override
  void dispose() {
    _symptomController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is Doctor) {
      doctor = arg;
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day);
      _month = DateTime(_selectedDate.year, _selectedDate.month, 1);
      _loadSlots();
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      Navigator.of(context).pushReplacementNamed('/user/home');
    });
  }

  String _dateKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  String _monthLabel(DateTime m) {
    const months = ['Tháng 1', 'Tháng 2', 'Tháng 3', 'Tháng 4', 'Tháng 5', 'Tháng 6', 'Tháng 7', 'Tháng 8', 'Tháng 9', 'Tháng 10', 'Tháng 11', 'Tháng 12'];
    return '${months[m.month - 1]} ${m.year}';
  }

  Future<void> _loadSlots() async {
    if (doctor?.id == null) return;
    setState(() => _loadingSlots = true);
    _slots = await ScheduleController.instance.getSchedulesByDoctorAndDate(
      doctorId: doctor!.id!,
      date: _dateKey(_selectedDate),
    );
    _selectedSlot = null;
    setState(() => _loadingSlots = false);
  }

  Future<void> _confirmBooking() async {
    if (doctor?.id == null) return;
    final user = SessionController.instance.currentUser;
    if (user?.id == null) {
      Navigator.of(context).pushNamed('/');
      return;
    }
    if (_selectedSlot == null) {
      _showSnack('Vui lòng chọn một khung giờ để tiếp tục.');
      return;
    }

    try {
      await AppointmentController.instance.createAppointment(
        Appointment(
          userId: user!.id!,
          doctorId: doctor!.id!,
          scheduleId: _selectedSlot!.id!,
          symptom: _symptomController.text.trim(),
          status: 'pending',
          createdAt: DateTime.now().toIso8601String(),
        ),
      );
      if (!mounted) return;
      _showSnack('Đặt lịch thành công! Đang chuyển hướng...');
      Navigator.of(context).pushReplacementNamed('/user/appointments');
    } catch (e) {
      _showSnack('Lỗi: $e');
    }
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.manrope(fontWeight: FontWeight.w600)),
        behavior: SnackBarBehavior.floating,
        backgroundColor: kTextDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (doctor == null) return const Scaffold(body: Center(child: CircularProgressIndicator(color: kPrimary)));

    final width = MediaQuery.sizeOf(context).width;
    final isLoggedIn = SessionController.instance.currentUser != null;
    final isLargeScreen = width >= 1100;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            AppTopNavBar(
              isDesktop: width >= 900,
              isLoggedIn: isLoggedIn,
              activeKey: 'schedule',
              onTapFindCare: () => Navigator.of(context).pushReplacementNamed('/user/doctors'),
              onTapSpecialists: () => Navigator.of(context).pushReplacementNamed('/user/doctors'),
              onTapSchedule: () {},
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
                    child: isLargeScreen
                        ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 4, child: _buildInfoColumn()),
                        const SizedBox(width: 40),
                        Expanded(flex: 6, child: _buildBookingColumn()),
                      ],
                    )
                        : Column(
                      children: [
                        _buildInfoColumn(),
                        const SizedBox(height: 32),
                        _buildBookingColumn(),
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

  Widget _buildInfoColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: 'Bác sĩ phụ trách'),
        const SizedBox(height: 16),
        _DoctorSummaryCard(doctor: doctor!),
        const SizedBox(height: 32),
        _SectionHeader(title: 'Triệu chứng của bạn'),
        const SizedBox(height: 8),
        Text(
          'Mô tả ngắn gọn tình trạng sức khỏe hiện tại.',
          style: GoogleFonts.manrope(color: kTextLight, fontSize: 14),
        ),
        const SizedBox(height: 16),
        _SymptomBox(controller: _symptomController),
        const SizedBox(height: 24),
        _FeeSummaryCard(),
      ],
    );
  }

  Widget _buildBookingColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: 'Chọn thời gian khám'),
        const SizedBox(height: 16),
        _CalendarCard(
          monthLabel: _monthLabel(_month),
          month: _month,
          selected: _selectedDate,
          onPrev: () => setState(() => _month = DateTime(_month.year, _month.month - 1, 1)),
          onNext: () => setState(() => _month = DateTime(_month.year, _month.month + 1, 1)),
          onSelect: (d) {
            setState(() => _selectedDate = d);
            _loadSlots();
          },
        ),
        const SizedBox(height: 32),
        _SectionHeader(title: 'Giờ trống trong ngày'),
        const SizedBox(height: 16),
        _SlotsGrid(
          loading: _loadingSlots,
          slots: _slots,
          selected: _selectedSlot,
          onSelect: (s) => setState(() => _selectedSlot = s),
        ),
        const SizedBox(height: 40),
        _ConfirmButton(onTap: _confirmBooking),
        const SizedBox(height: 20),
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_outline, size: 14, color: kPrimary),
              const SizedBox(width: 6),
              Text(
                'Dữ liệu y tế của bạn được bảo mật tuyệt đối.',
                style: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.w600, color: kPrimary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
        const AppFooter(),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 4, height: 16, decoration: BoxDecoration(color: const Color(0xFF0D9488), borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 8),
        Text(
          title.toUpperCase(),
          style: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.2, color: const Color(0xFF64748B)),
        ),
      ],
    );
  }
}

class _DoctorSummaryCard extends StatelessWidget {
  final Doctor doctor;
  const _DoctorSummaryCard({required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(width: 80, height: 80, child: DoctorImage(pathOrUrl: doctor.image, fit: BoxFit.cover)),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(doctor.name, style: GoogleFonts.epilogue(fontSize: 18, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A))),
                const SizedBox(height: 4),
                Text(doctor.specialty.isEmpty ? 'Bác sĩ chuyên khoa' : doctor.specialty, style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w600, color: const Color(0xFF0D9488))),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, size: 18, color: Color(0xFFF59E0B)),
                    const SizedBox(width: 4),
                    Text('4.9', style: GoogleFonts.manrope(fontSize: 13, fontWeight: FontWeight.w700, color: const Color(0xFF0F172A))),
                    const SizedBox(width: 4),
                    Text('(120+ đánh giá)', style: GoogleFonts.manrope(fontSize: 12, color: const Color(0xFF64748B))),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SymptomBox extends StatelessWidget {
  final TextEditingController controller;
  const _SymptomBox({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: controller,
        maxLines: 4,
        style: GoogleFonts.manrope(fontSize: 15, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: 'Nhập triệu chứng tại đây (ví dụ: sốt, đau họng...)',
          hintStyle: GoogleFonts.manrope(color: const Color(0xFF94A3B8), fontSize: 14),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}

class _FeeSummaryCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF0D9488).withAlpha(10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF0D9488).withAlpha(20)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Phí tư vấn dự kiến', style: GoogleFonts.manrope(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF64748B))),
              const SizedBox(height: 4),
              Text('150.000đ', style: GoogleFonts.epilogue(fontSize: 20, fontWeight: FontWeight.w800, color: const Color(0xFF0D9488))),
            ],
          ),
          const Icon(Icons.info_outline_rounded, color: Color(0xFF0D9488), size: 24),
        ],
      ),
    );
  }
}

class _CalendarCard extends StatelessWidget {
  final String monthLabel;
  final DateTime month;
  final DateTime selected;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final ValueChanged<DateTime> onSelect;

  const _CalendarCard({required this.monthLabel, required this.month, required this.selected, required this.onPrev, required this.onNext, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final first = DateTime(month.year, month.month, 1);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final leading = (first.weekday - 1) % 7;
    final today = DateTime.now();
    final minDate = DateTime(today.year, today.month, today.day);

    const headers = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(5), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(onPressed: onPrev, icon: const Icon(Icons.chevron_left, color: Color(0xFF0F172A))),
              Text(monthLabel, style: GoogleFonts.epilogue(fontSize: 17, fontWeight: FontWeight.w800, color: const Color(0xFF0F172A))),
              IconButton(onPressed: onNext, icon: const Icon(Icons.chevron_right, color: Color(0xFF0F172A))),
            ],
          ),
          const SizedBox(height: 20),
          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: headers.map((h) => Center(child: Text(h, style: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF94A3B8))))).toList(),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7),
            itemCount: leading + daysInMonth,
            itemBuilder: (context, i) {
              if (i < leading) return const SizedBox();
              final dayNum = i - leading + 1;
              final d = DateTime(month.year, month.month, dayNum);
              final isSelected = d.year == selected.year && d.month == selected.month && d.day == selected.day;
              final isDisabled = d.isBefore(minDate);

              return GestureDetector(
                onTap: isDisabled ? null : () => onSelect(d),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF0D9488) : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$dayNum',
                    style: GoogleFonts.manrope(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: isDisabled ? const Color(0xFFCBD5E1) : (isSelected ? Colors.white : const Color(0xFF1E293B)),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SlotsGrid extends StatelessWidget {
  final bool loading;
  final List<Schedule> slots;
  final Schedule? selected;
  final ValueChanged<Schedule> onSelect;

  const _SlotsGrid({required this.loading, required this.slots, required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator(color: Color(0xFF0D9488))));
    if (slots.isEmpty) return Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(16)), child: Center(child: Text('Không có khung giờ trống trong ngày này.', style: GoogleFonts.manrope(color: const Color(0xFF64748B)))));

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 2.2),
      itemCount: slots.length,
      itemBuilder: (context, i) {
        final s = slots[i];
        final isSelected = selected?.id == s.id;
        final isBooked = s.isBooked;

        return GestureDetector(
          onTap: isBooked ? null : () => onSelect(s),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF0D9488) : (isBooked ? const Color(0xFFF1F5F9) : Colors.white),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isSelected ? const Color(0xFF0D9488) : const Color(0xFFE2E8F0)),
            ),
            alignment: Alignment.center,
            child: Text(
              s.startTime,
              style: GoogleFonts.manrope(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isBooked ? const Color(0xFFCBD5E1) : (isSelected ? Colors.white : const Color(0xFF1E293B)),
                decoration: isBooked ? TextDecoration.lineThrough : null,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ConfirmButton extends StatelessWidget {
  final VoidCallback onTap;
  const _ConfirmButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFD97706)]),
        boxShadow: [BoxShadow(color: const Color(0xFFF59E0B).withAlpha(80), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Xác nhận đặt lịch ngay', style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_rounded, color: Colors.white),
          ],
        ),
      ),
    );
  }
}
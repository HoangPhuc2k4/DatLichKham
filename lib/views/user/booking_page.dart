import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Import đúng các đường dẫn controller/model trong dự án của bạn
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
  DateTime _selectedDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  List<Schedule> _slots = [];
  Schedule? _selectedSlot;
  bool _loadingSlots = true;

  final _symptomController = TextEditingController();

  static const Color medicalTeal = Color(0xFF006A62);
  static const Color accentOrange = Color(0xFFF99A15);

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
      _loadSlots();
    }
  }

  Future<void> _loadSlots() async {
    if (doctor?.id == null) return;
    setState(() => _loadingSlots = true);

    // Gọi API lấy danh sách khung giờ
    try {
      final results = await ScheduleController.instance.getSchedulesByDoctorAndDate(
        doctorId: doctor!.id!,
        date: _dateKey(_selectedDate),
      );
      setState(() {
        _slots = results;
        _selectedSlot = null;
        _loadingSlots = false;
      });
    } catch (e) {
      setState(() => _loadingSlots = false);
      _showToast("Không thể tải lịch khám.");
    }
  }

  String _dateKey(DateTime d) =>
      "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

  Future<void> _confirmBooking() async {
    final user = SessionController.instance.currentUser;
    if (user == null) {
      _showToast("Vui lòng đăng nhập để đặt lịch.");
      Navigator.pushNamed(context, '/');
      return;
    }

    if (_selectedSlot == null) {
      _showToast("Vui lòng chọn một khung giờ khám.");
      return;
    }

    try {
      await AppointmentController.instance.createAppointment(
        Appointment(
          userId: user.id!,
          doctorId: doctor!.id!,
          scheduleId: _selectedSlot!.id!,
          symptom: _symptomController.text.trim(),
          status: 'pending',
          createdAt: DateTime.now().toIso8601String(),
        ),
      );

      if (!mounted) return;
      _showSuccessDialog();
    } catch (e) {
      _showToast("Lỗi đặt lịch: $e");
    }
  }

  void _showToast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.manrope(fontWeight: FontWeight.w600)),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text('Thành công!', style: GoogleFonts.epilogue(fontWeight: FontWeight.w900)),
        content: Text('Lịch hẹn của bạn đã được gửi đi và chờ bác sĩ xác nhận.', style: GoogleFonts.manrope()),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/user/appointments');
            },
            child: Text('XEM LỊCH HẸN', style: GoogleFonts.manrope(fontWeight: FontWeight.w800, color: medicalTeal)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final d = doctor;
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= 1100;
    final isLoggedIn = SessionController.instance.currentUser != null;

    if (d == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFA),
      body: Column(
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
              if (isLoggedIn) {
                SessionController.instance.logout();
                Navigator.of(context).pushReplacementNamed('/user/home');
              } else {
                Navigator.pushNamed(context, '/');
              }
            },
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: width < 600 ? 16 : 40, vertical: 32),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: isDesktop
                      ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(flex: 5, child: _buildInfoSide(d)),
                      const SizedBox(width: 48),
                      Expanded(flex: 7, child: _buildSelectionSide()),
                    ],
                  )
                      : Column(
                    children: [
                      _buildInfoSide(d),
                      const SizedBox(height: 40),
                      _buildSelectionSide(),
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

  Widget _buildInfoSide(Doctor d) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(label: 'Bác sĩ phụ trách'),
        const SizedBox(height: 16),
        _DoctorSummaryCard(doctor: d),
        const SizedBox(height: 32),
        const _SectionTitle(label: 'Thông tin triệu chứng'),
        const SizedBox(height: 16),
        _SymptomBox(controller: _symptomController),
        const SizedBox(height: 24),
        _FeeCard(),
      ],
    );
  }

  Widget _buildSelectionSide() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(label: 'Chọn thời gian khám'),
        const SizedBox(height: 16),
        _CalendarCard(
          month: _month,
          selected: _selectedDate,
          onMonthChange: (m) => setState(() => _month = m),
          onDateSelect: (d) {
            setState(() => _selectedDate = d);
            _loadSlots();
          },
        ),
        const SizedBox(height: 32),
        const _SectionTitle(label: 'Khung giờ trống'),
        const SizedBox(height: 16),
        _SlotsGrid(
          loading: _loadingSlots,
          slots: _slots,
          selected: _selectedSlot,
          onSelect: (s) => setState(() => _selectedSlot = s),
        ),
        const SizedBox(height: 48),
        _ConfirmButton(onTap: _confirmBooking),
        const SizedBox(height: 80),
        const AppFooter(),
      ],
    );
  }
}

// --- CÁC SUB-WIDGETS PHỤ TRỢ ---

class _SectionTitle extends StatelessWidget {
  final String label;
  const _SectionTitle({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4, height: 16,
          decoration: BoxDecoration(color: const Color(0xFF006A62), borderRadius: BorderRadius.circular(2)),
        ),
        const SizedBox(width: 10),
        Text(
          label.toUpperCase(),
          style: GoogleFonts.epilogue(fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: const Color(0xFF3C4947)),
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
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              width: 80, height: 80,
              child: DoctorImage(pathOrUrl: doctor.image, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(doctor.name, style: GoogleFonts.epilogue(fontSize: 18, fontWeight: FontWeight.w900)),
                Text(doctor.specialty, style: GoogleFonts.manrope(fontWeight: FontWeight.w700, color: const Color(0xFF006A62))),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star_rounded, size: 18, color: Color(0xFFF99A15)),
                    const SizedBox(width: 4),
                    Text('5.0', style: GoogleFonts.manrope(fontSize: 13, fontWeight: FontWeight.w800)),
                  ],
                )
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
        border: Border.all(color: Colors.black.withOpacity(0.05)),
      ),
      child: TextField(
        controller: controller,
        minLines: 5, maxLines: 8,
        style: GoogleFonts.manrope(fontWeight: FontWeight.w600, fontSize: 14),
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.all(20),
          hintText: 'Nhập triệu chứng của bạn tại đây...',
          border: InputBorder.none,
        ),
      ),
    );
  }
}

class _FeeCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: const Color(0xFF006A62).withOpacity(0.05), borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Phí tư vấn tạm tính', style: GoogleFonts.manrope(fontWeight: FontWeight.w700)),
          Text('145.000đ', style: GoogleFonts.epilogue(fontSize: 18, fontWeight: FontWeight.w900, color: const Color(0xFF006A62))),
        ],
      ),
    );
  }
}

class _CalendarCard extends StatelessWidget {
  final DateTime month;
  final DateTime selected;
  final ValueChanged<DateTime> onMonthChange;
  final ValueChanged<DateTime> onDateSelect;

  const _CalendarCard({required this.month, required this.selected, required this.onMonthChange, required this.onDateSelect});

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final firstWeekday = DateTime(month.year, month.month, 1).weekday;
    final leadingSpaces = (firstWeekday - 1) % 7;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _NavBtn(icon: Icons.chevron_left, onTap: () => onMonthChange(DateTime(month.year, month.month - 1))),
              Text('Tháng ${month.month}, ${month.year}', style: GoogleFonts.epilogue(fontSize: 17, fontWeight: FontWeight.w900)),
              _NavBtn(icon: Icons.chevron_right, onTap: () => onMonthChange(DateTime(month.year, month.month + 1))),
            ],
          ),
          const SizedBox(height: 24),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, mainAxisExtent: 40),
            itemCount: 7 + leadingSpaces + daysInMonth,
            itemBuilder: (context, i) {
              if (i < 7) {
                return Center(child: Text(['T2','T3','T4','T5','T6','T7','CN'][i], style: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.grey)));
              }
              final day = i - 7 - leadingSpaces + 1;
              if (day <= 0) return const SizedBox();
              final date = DateTime(month.year, month.month, day);
              final isSelected = date.year == selected.year && date.month == selected.month && date.day == selected.day;
              final isPast = date.isBefore(DateTime.now().subtract(const Duration(days: 1)));

              return GestureDetector(
                onTap: isPast ? null : () => onDateSelect(date),
                child: Container(
                  decoration: BoxDecoration(color: isSelected ? const Color(0xFF006A62) : Colors.transparent, borderRadius: BorderRadius.circular(10)),
                  alignment: Alignment.center,
                  child: Text('$day', style: GoogleFonts.manrope(fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600, color: isSelected ? Colors.white : (isPast ? Colors.grey[300] : Colors.black))),
                ),
              );
            },
          )
        ],
      ),
    );
  }
}

class _NavBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _NavBtn({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return IconButton(onPressed: onTap, icon: Icon(icon, color: const Color(0xFF006A62)), style: IconButton.styleFrom(backgroundColor: const Color(0xFFF2F4F4)));
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
    if (loading) return const Center(child: CircularProgressIndicator());
    final available = slots.where((s) => !s.isBooked).toList();
    if (available.isEmpty) return const Center(child: Text("Hết lịch trống."));

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, mainAxisExtent: 48, crossAxisSpacing: 10, mainAxisSpacing: 10),
      itemCount: available.length,
      itemBuilder: (context, i) {
        final s = available[i];
        final active = selected?.id == s.id;
        return GestureDetector(
          onTap: () => onSelect(s),
          child: Container(
            decoration: BoxDecoration(color: active ? const Color(0xFF006A62) : Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: active ? Colors.transparent : Colors.black12)),
            alignment: Alignment.center,
            child: Text(s.startTime, style: GoogleFonts.epilogue(fontWeight: FontWeight.w800, color: active ? Colors.white : Colors.black)),
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
    return SizedBox(
      width: double.infinity, height: 56,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF99A15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
        child: Text('XÁC NHẬN ĐẶT LỊCH', style: GoogleFonts.epilogue(fontWeight: FontWeight.w900, color: Colors.white)),
      ),
    );
  }
}
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
      _selectedDate = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
      );
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
    const months = [
      'Tháng 1',
      'Tháng 2',
      'Tháng 3',
      'Tháng 4',
      'Tháng 5',
      'Tháng 6',
      'Tháng 7',
      'Tháng 8',
      'Tháng 9',
      'Tháng 10',
      'Tháng 11',
      'Tháng 12',
    ];
    return '${months[m.month - 1]} ${m.year}';
  }

  Future<void> _loadSlots() async {
    final d = doctor;
    if (d?.id == null) return;
    setState(() => _loadingSlots = true);
    _slots = await ScheduleController.instance.getSchedulesByDoctorAndDate(
      doctorId: d!.id!,
      date: _dateKey(_selectedDate),
    );
    _selectedSlot = null;
    setState(() => _loadingSlots = false);
  }

  Future<void> _confirmBooking() async {
    final d = doctor;
    if (d?.id == null) return;

    final user = SessionController.instance.currentUser;
    if (user?.id == null) {
      Navigator.of(context).pushNamed('/');
      return;
    }

    final slot = _selectedSlot;
    if (slot == null || slot.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn 1 khung giờ.')),
      );
      return;
    }

    try {
      await AppointmentController.instance.createAppointment(
        Appointment(
          userId: user!.id!,
          doctorId: d!.id!,
          scheduleId: slot.id!,
          symptom: _symptomController.text.trim(),
          status: 'pending',
          createdAt: DateTime.now().toIso8601String(),
        ),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đặt lịch thành công.')),
      );
      Navigator.of(context).pushReplacementNamed('/user/appointments');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không đặt được lịch: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = doctor;
    final width = MediaQuery.sizeOf(context).width;
    final isLoggedIn = SessionController.instance.currentUser != null;
    final twoCol = width >= 1100;

    if (d == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFA),
      body: SafeArea(
        child: Column(
          children: [
            AppTopNavBar(
              isDesktop: width >= 900,
              isLoggedIn: isLoggedIn,
              activeKey: 'schedule',
              onTapFindCare: () =>
                  Navigator.of(context).pushReplacementNamed('/user/doctors'),
              onTapSpecialists: () =>
                  Navigator.of(context).pushReplacementNamed('/user/doctors'),
              onTapSchedule: () {},
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
                  vertical: width < 600 ? 16 : 24,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1440),
                    child: twoCol
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(flex: 5, child: _LeftColumn(d: d)),
                              const SizedBox(width: 24),
                              Expanded(flex: 7, child: _RightColumn()),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _LeftColumn(d: d),
                              const SizedBox(height: 18),
                              _RightColumn(),
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

  Widget _RightColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionTitle(label: 'Chọn ngày', keyLabel: 'SELECT_A_DATE'),
        const SizedBox(height: 12),
        _CalendarCard(
          monthLabel: _monthLabel(_month),
          month: _month,
          selected: _selectedDate,
          onPrev: () async {
            setState(() {
              _month = DateTime(_month.year, _month.month - 1, 1);
            });
          },
          onNext: () async {
            setState(() {
              _month = DateTime(_month.year, _month.month + 1, 1);
            });
          },
          onSelect: (d) async {
            setState(() => _selectedDate = d);
            await _loadSlots();
          },
        ),
        const SizedBox(height: 22),
        _SectionTitle(label: 'Khung giờ trống', keyLabel: 'AVAILABLE_SLOTS'),
        const SizedBox(height: 12),
        _SlotsGrid(
          loading: _loadingSlots,
          slots: _slots,
          selected: _selectedSlot,
          onSelect: (s) => setState(() => _selectedSlot = s),
        ),
        const SizedBox(height: 18),
        _ConfirmButton(onTap: _confirmBooking),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.verified_user, size: 18, color: Color(0xFF2EC4B6)),
            const SizedBox(width: 8),
            Text(
              'Thông tin được bảo vệ và mã hoá.',
              style: GoogleFonts.manrope(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF3C4947).withValues(alpha: 0.75),
              ),
            ),
          ],
        ),
        const SizedBox(height: 28),
        const AppFooter(),
      ],
    );
  }

  Widget _LeftColumn({required Doctor d}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionTitle(label: 'Bác sĩ của bạn', keyLabel: 'YOUR_SPECIALIST'),
        const SizedBox(height: 12),
        _DoctorSummaryCard(doctor: d),
        const SizedBox(height: 22),
        Text(
          'Mô tả triệu chứng',
          style: GoogleFonts.epilogue(
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Cung cấp thêm thông tin để bác sĩ chuẩn bị tốt hơn cho buổi khám.',
          style: GoogleFonts.manrope(
            fontWeight: FontWeight.w600,
            color: const Color(0xFF3C4947).withValues(alpha: 0.75),
          ),
        ),
        const SizedBox(height: 12),
        _SymptomBox(controller: _symptomController),
        const SizedBox(height: 18),
        _FeeCard(),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String label;
  final String keyLabel;
  const _SectionTitle({required this.label, required this.keyLabel});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 2,
          color: const Color(0xFF006A62),
        ),
        const SizedBox(width: 10),
        Text(
          label.toUpperCase(),
          style: GoogleFonts.epilogue(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 2,
            color: const Color(0xFF3C4947).withValues(alpha: 0.75),
          ),
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: SizedBox(
                  width: 72,
                  height: 72,
                  child: DoctorImage(pathOrUrl: doctor.image, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctor.name,
                      style: GoogleFonts.epilogue(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      doctor.specialty.isEmpty ? 'Chuyên khoa' : doctor.specialty,
                      style: GoogleFonts.manrope(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF3C4947),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        for (int i = 0; i < 5; i++)
                          const Padding(
                            padding: EdgeInsets.only(right: 2),
                            child: Icon(Icons.star, size: 14, color: Color(0xFF895100)),
                          ),
                        const SizedBox(width: 6),
                        Text(
                          '5.0 (428 đánh giá)',
                          style: GoogleFonts.manrope(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF3C4947).withValues(alpha: 0.75),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SymptomBox extends StatelessWidget {
  final TextEditingController controller;
  const _SymptomBox({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF2F4F4),
            borderRadius: BorderRadius.circular(28),
          ),
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 34),
          child: TextField(
            controller: controller,
            minLines: 6,
            maxLines: 8,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText:
                  'Ví dụ: Đau đầu kéo dài, bắt đầu từ 3 ngày trước...',
              hintStyle: GoogleFonts.manrope(
                fontWeight: FontWeight.w600,
                color: const Color(0xFF3C4947).withValues(alpha: 0.35),
              ),
            ),
            style: GoogleFonts.manrope(fontWeight: FontWeight.w600),
          ),
        ),
        Positioned(
          right: 14,
          bottom: 12,
          child: Text(
            'BẢO MẬT',
            style: GoogleFonts.manrope(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
              color: const Color(0xFF3C4947).withValues(alpha: 0.25),
            ),
          ),
        ),
      ],
    );
  }
}

class _FeeCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFFE1E3E3).withValues(alpha: 0.30),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.55)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Phí khám',
                style: GoogleFonts.manrope(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF3C4947).withValues(alpha: 0.80),
                ),
              ),
              Text(
                '145.000đ',
                style: GoogleFonts.epilogue(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Khi xác nhận, bạn đồng ý chính sách huỷ trước 24 giờ. Hệ thống có thể tạm giữ hạn mức để xác thực.',
            style: GoogleFonts.manrope(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              height: 1.45,
              color: const Color(0xFF3C4947).withValues(alpha: 0.75),
            ),
          ),
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

  const _CalendarCard({
    required this.monthLabel,
    required this.month,
    required this.selected,
    required this.onPrev,
    required this.onNext,
    required this.onSelect,
  });

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final first = DateTime(month.year, month.month, 1);
    final nextMonth = DateTime(month.year, month.month + 1, 1);
    final daysInMonth = nextMonth.difference(first).inDays;
    // week starts Mon
    final leading = (first.weekday - 1) % 7;
    final totalCells = ((leading + daysInMonth) / 7).ceil() * 7;
    final today = DateTime.now();
    final minDate = DateTime(today.year, today.month, today.day);

    const headers = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F4),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _CircleIconBtn(icon: Icons.chevron_left, onTap: onPrev),
              Text(
                monthLabel,
                style: GoogleFonts.epilogue(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              _CircleIconBtn(icon: Icons.chevron_right, onTap: onNext),
            ],
          ),
          const SizedBox(height: 18),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisExtent: 42,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: totalCells + 7,
            itemBuilder: (context, i) {
              if (i < 7) {
                return Center(
                  child: Text(
                    headers[i],
                    style: GoogleFonts.manrope(
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                      color: const Color(0xFF3C4947).withValues(alpha: 0.35),
                    ),
                  ),
                );
              }
              final idx = i - 7;
              final dayNum = idx - leading + 1;
              if (dayNum < 1 || dayNum > daysInMonth) {
                return const SizedBox.shrink();
              }
              final d = DateTime(month.year, month.month, dayNum);
              final disabled = d.isBefore(minDate);
              final active = _sameDay(d, selected);

              Color bg = Colors.transparent;
              Color fg = const Color(0xFF191C1D);
              List<BoxShadow> shadow = const [];
              if (active) {
                bg = const Color(0xFF006A62);
                fg = Colors.white;
                shadow = [
                  BoxShadow(
                    color: const Color(0xFF006A62).withValues(alpha: 0.18),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ];
              } else if (disabled) {
                fg = const Color(0xFF3C4947).withValues(alpha: 0.25);
              }

              return Opacity(
                opacity: disabled ? 0.55 : 1,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: disabled ? null : () => onSelect(d),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: bg,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: shadow,
                      ),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$dayNum',
                            style: GoogleFonts.manrope(
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: fg,
                            ),
                          ),
                          if (active) ...[
                            const SizedBox(height: 4),
                            Container(
                              width: 4,
                              height: 4,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ],
                      ),
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

class _CircleIconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleIconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Icon(icon, color: const Color(0xFF006A62)),
      ),
    );
  }
}

class _SlotsGrid extends StatelessWidget {
  final bool loading;
  final List<Schedule> slots;
  final Schedule? selected;
  final ValueChanged<Schedule> onSelect;

  const _SlotsGrid({
    required this.loading,
    required this.slots,
    required this.selected,
    required this.onSelect,
  });

  String _period(String start) {
    final parts = start.split(':');
    final h = int.tryParse(parts.first) ?? 0;
    if (h < 11) return 'Sáng';
    if (h < 14) return 'Trưa';
    if (h < 18) return 'Chiều';
    return 'Tối';
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const LinearProgressIndicator();
    final available = slots.where((s) => !s.isBooked).toList();
    final disabled = slots.where((s) => s.isBooked).toList();
    final merged = [...available, ...disabled];

    if (merged.isEmpty) {
      return Text(
        'Không có khung giờ cho ngày này.',
        style: GoogleFonts.manrope(fontWeight: FontWeight.w600),
      );
    }

    final width = MediaQuery.sizeOf(context).width;
    final cols = width >= 1100 ? 4 : width >= 700 ? 3 : 2;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cols,
        mainAxisExtent: 96,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemCount: merged.length,
      itemBuilder: (context, i) {
        final s = merged[i];
        final isActive = selected?.id != null && selected?.id == s.id;
        final isDisabled = s.isBooked;
        return _SlotCard(
          period: _period(s.startTime),
          time: s.startTime,
          active: isActive,
          disabled: isDisabled,
          onTap: isDisabled ? null : () => onSelect(s),
        );
      },
    );
  }
}

class _SlotCard extends StatelessWidget {
  final String period;
  final String time;
  final bool active;
  final bool disabled;
  final VoidCallback? onTap;

  const _SlotCard({
    required this.period,
    required this.time,
    required this.active,
    required this.disabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final border = active
        ? Border.all(color: const Color(0xFF006A62), width: 2)
        : Border.all(color: Colors.transparent, width: 1);
    final bg = Colors.white;
    final fg = disabled
        ? const Color(0xFF3C4947).withValues(alpha: 0.35)
        : active
            ? const Color(0xFF006A62)
            : const Color(0xFF191C1D);

    return Opacity(
      opacity: disabled ? 0.45 : 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(18),
            border: border,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                period.toUpperCase(),
                style: GoogleFonts.manrope(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.4,
                  color: active
                      ? const Color(0xFF006A62)
                      : const Color(0xFF3C4947).withValues(alpha: 0.55),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                time,
                style: GoogleFonts.epilogue(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: fg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConfirmButton extends StatelessWidget {
  final VoidCallback onTap;
  const _ConfirmButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Color(0xFFF99A15), Color(0xFFFF9F1C)],
          ),
          borderRadius: BorderRadius.circular(999),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFF99A15).withValues(alpha: 0.30),
              blurRadius: 26,
              offset: const Offset(0, 16),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Xác nhận đặt lịch',
              style: GoogleFonts.epilogue(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 18),
          ],
        ),
      ),
    );
  }
}


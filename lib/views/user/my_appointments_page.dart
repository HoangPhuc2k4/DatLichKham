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
  static const int pageSize = 6;

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
    items = await AppointmentController.instance
        .getAppointmentsByUserDetails(user!.id!);
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
      confirmText: 'HỦY LỊCH',
      cancelText: 'GIỮ LẠI',
    );
    if (!ok) return;
    try {
      await AppointmentController.instance.cancelAppointment(a);
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không hủy được: $e')),
      );
    }
  }

  Doctor _toDoctor(AppointmentDetails d) {
    return Doctor(
      id: d.appointment.doctorId,
      name: d.doctorName,
      specialty: d.specialty,
      experience: 0,
      description: '',
      image: '',
    );
  }

  Future<void> _goBookNew() async {
    Navigator.of(context).pushReplacementNamed('/user/home');
  }

  Future<void> _goReschedule(AppointmentDetails d) async {
    // Luồng đơn giản: chuyển sang trang booking với cùng doctor
    Navigator.of(context).pushNamed(
      '/user/booking',
      arguments: _toDoctor(d),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isLoggedIn = SessionController.instance.currentUser != null;

    int cmp(AppointmentDetails a, AppointmentDetails b) {
      final ad = a.date.compareTo(b.date);
      if (ad != 0) return ad;
      return a.startTime.compareTo(b.startTime);
    }

    final confirmed =
        items.where((d) => d.appointment.status == 'confirmed').toList()..sort(cmp);
    final pending =
        items.where((d) => d.appointment.status == 'pending').toList()..sort(cmp);
    final cancelled =
        items.where((d) => d.appointment.status == 'cancelled').toList()..sort(cmp);

    final visible = historyMode ? [...confirmed, ...cancelled] : items;

    AppointmentDetails? focal;
    if (!historyMode) {
      focal = confirmed.isNotEmpty ? confirmed.first : pending.isNotEmpty ? pending.first : null;
    } else {
      focal = confirmed.isNotEmpty ? confirmed.first : cancelled.isNotEmpty ? cancelled.first : null;
    }

    final rest = [
      ...visible.where((d) => focal == null ? true : d != focal),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFA),
      body: SafeArea(
        child: Column(
          children: [
            AppTopNavBar(
              isDesktop: width >= 900,
              isLoggedIn: isLoggedIn,
              activeKey: 'my_health',
              onTapFindCare: () => Navigator.of(context).pushReplacementNamed('/user/doctors'),
              onTapSpecialists: () => Navigator.of(context).pushReplacementNamed('/user/doctors'),
              onTapSchedule: () => Navigator.of(context).pushReplacementNamed('/user/appointments'),
              onTapMyHealth: () {},
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
              child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
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
                              _Header(
                                historyMode: historyMode,
                                onToggleHistory: () => setState(() {
                                  historyMode = !historyMode;
                                  page = 1;
                                }),
                                onBookNew: _goBookNew,
                              ),
                              const SizedBox(height: 22),
                              if (items.isEmpty)
                                _EmptyState(onBookNew: _goBookNew)
                              else
                                _BentoGrid(
                                  width: width,
                                  focal: focal,
                                  confirmedCount: confirmed.length,
                                  pendingCount: pending.length,
                                  cancelledCount: cancelled.length,
                                  onCancel: _cancel,
                                  onReschedule: _goReschedule,
                                  rest: rest,
                                  page: page,
                                  pageSize: pageSize,
                                  onPageChange: (p) => setState(() => page = p),
                                ),
                              const SizedBox(height: 48),
                              _HelpSection(),
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

class _Header extends StatelessWidget {
  final bool historyMode;
  final VoidCallback onToggleHistory;
  final VoidCallback onBookNew;

  const _Header({
    required this.historyMode,
    required this.onToggleHistory,
    required this.onBookNew,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final isWide = c.maxWidth >= 760;
        final titleSize = c.maxWidth >= 900 ? 48.0 : c.maxWidth >= 600 ? 40.0 : 30.0;
        final left = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'TRUNG TÂM CHĂM SÓC CÁ NHÂN',
              style: GoogleFonts.manrope(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 2.2,
                color: const Color(0xFF895100),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Lịch khám của tôi',
              style: GoogleFonts.epilogue(
                fontSize: titleSize,
                fontWeight: FontWeight.w900,
                letterSpacing: -1.2,
                height: 1,
              ),
            ),
            const SizedBox(height: 10),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Text(
                'Xem, quản lý và theo dõi các lịch hẹn khám sắp tới của bạn.',
                style: GoogleFonts.manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  height: 1.5,
                  color: const Color(0xFF3C4947).withValues(alpha: 0.75),
                ),
              ),
            ),
          ],
        );

        final historyBtn = TextButton(
          onPressed: onToggleHistory,
          style: TextButton.styleFrom(
            backgroundColor: const Color(0xFFE1E3E3),
            foregroundColor: const Color(0xFF496679),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: Text(
            historyMode ? 'Đang xem: Lịch sử' : 'Xem lịch sử',
            style: GoogleFonts.epilogue(fontWeight: FontWeight.w900),
          ),
        );

        final bookNewBtn = TextButton(
          onPressed: onBookNew,
          style: TextButton.styleFrom(
            backgroundColor: const Color(0xFF006A62),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: Text(
            'Đặt lịch mới',
            style: GoogleFonts.epilogue(fontWeight: FontWeight.w900),
          ),
        );

        if (!isWide) {
          // Trên màn hình nhỏ: xếp dọc để tránh Wrap/Row bị rơi vào constraint vô hạn.
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              left,
              const SizedBox(height: 14),
              SizedBox(width: double.infinity, child: historyBtn),
              const SizedBox(height: 10),
              SizedBox(width: double.infinity, child: bookNewBtn),
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: left),
            const SizedBox(width: 16),
            Wrap(
              spacing: 12,
              runSpacing: 10,
              alignment: WrapAlignment.end,
              children: [
                historyBtn,
                bookNewBtn,
              ],
            ),
          ],
        );
      },
    );
  }
}

class _BentoGrid extends StatelessWidget {
  final double width;
  final AppointmentDetails? focal;
  final int confirmedCount;
  final int pendingCount;
  final int cancelledCount;
  final List<AppointmentDetails> rest;
  final Future<void> Function(Appointment a) onCancel;
  final Future<void> Function(AppointmentDetails d) onReschedule;
  final int page;
  final int pageSize;
  final ValueChanged<int> onPageChange;

  const _BentoGrid({
    required this.width,
    required this.focal,
    required this.confirmedCount,
    required this.pendingCount,
    required this.cancelledCount,
    required this.rest,
    required this.onCancel,
    required this.onReschedule,
    required this.page,
    required this.pageSize,
    required this.onPageChange,
  });

  @override
  Widget build(BuildContext context) {
    final twoCol = width >= 900;
    final rightCards = Column(
      children: const [
        _HealthProgressCard(),
        SizedBox(height: 14),
        _NextStepCard(),
      ],
    );

    final pending = rest.where((d) => d.appointment.status == 'pending').toList();
    final cancelled = rest.where((d) => d.appointment.status == 'cancelled').toList();
    final others = rest.where((d) => d.appointment.status == 'confirmed').toList();

    final blocks = <Widget>[];
    if (pending.isNotEmpty) blocks.add(_PendingCard(d: pending.first, onCancel: onCancel, onModify: onReschedule));
    if (cancelled.isNotEmpty) blocks.add(_CancelledCard(d: cancelled.first, onRebook: onReschedule));
    if (pending.length > 1) {
      for (final d in pending.skip(1)) {
        blocks.add(_PendingCard(d: d, onCancel: onCancel, onModify: onReschedule));
      }
    }
    if (cancelled.length > 1) {
      for (final d in cancelled.skip(1)) {
        blocks.add(_CancelledCard(d: d, onRebook: onReschedule));
      }
    }
    for (final d in others) {
      blocks.add(_SmallConfirmedCard(d: d, onCancel: onCancel, onReschedule: onReschedule));
    }

    final totalPages = (blocks.length / pageSize).ceil().clamp(1, 9999);
    final safePage = page.clamp(1, totalPages);
    final pageBlocks = blocks.skip((safePage - 1) * pageSize).take(pageSize).toList();

    return Column(
      children: [
        if (twoCol)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 8,
                child: focal == null
                    ? const SizedBox.shrink()
                    : _FocalCard(d: focal!, onCancel: onCancel, onReschedule: onReschedule),
              ),
              const SizedBox(width: 16),
              Expanded(flex: 4, child: rightCards),
            ],
          )
        else ...[
          if (focal != null) _FocalCard(d: focal!, onCancel: onCancel, onReschedule: onReschedule),
          const SizedBox(height: 14),
          rightCards,
        ],
        const SizedBox(height: 16),
        if (pageBlocks.isNotEmpty)
          LayoutBuilder(
            builder: (context, c) {
              final col2 = c.maxWidth >= 760;
              if (!col2) {
                return Column(
                  children: [
                    for (int i = 0; i < pageBlocks.length; i++) ...[
                      pageBlocks[i],
                      if (i != pageBlocks.length - 1) const SizedBox(height: 14),
                    ]
                  ],
                );
              }
              final w = (c.maxWidth - 14) / 2;
              return Wrap(
                spacing: 14,
                runSpacing: 14,
                children: [
                  for (final b in pageBlocks) SizedBox(width: w, child: b),
                ],
              );
            },
          ),
        if (totalPages > 1) ...[
          const SizedBox(height: 16),
          _Pager(
            page: safePage,
            totalPages: totalPages,
            onPageChange: onPageChange,
          ),
        ],
      ],
    );
  }
}

class _Pager extends StatelessWidget {
  final int page;
  final int totalPages;
  final ValueChanged<int> onPageChange;

  const _Pager({
    required this.page,
    required this.totalPages,
    required this.onPageChange,
  });

  @override
  Widget build(BuildContext context) {
    final pages = <int>[];
    for (int i = 1; i <= totalPages; i++) {
      pages.add(i);
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          tooltip: 'Trang trước',
          onPressed: page <= 1 ? null : () => onPageChange(page - 1),
          icon: const Icon(Icons.chevron_left),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final p in pages)
              InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => onPageChange(p),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: p == page ? const Color(0xFF006A62) : Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFBBCAC6).withValues(alpha: 0.18)),
                  ),
                  child: Text(
                    '$p',
                    style: GoogleFonts.manrope(
                      fontWeight: FontWeight.w900,
                      color: p == page ? Colors.white : const Color(0xFF3C4947),
                    ),
                  ),
                ),
              ),
          ],
        ),
        IconButton(
          tooltip: 'Trang sau',
          onPressed: page >= totalPages ? null : () => onPageChange(page + 1),
          icon: const Icon(Icons.chevron_right),
        ),
      ],
    );
  }
}

class _FocalCard extends StatelessWidget {
  final AppointmentDetails d;
  final Future<void> Function(Appointment a) onCancel;
  final Future<void> Function(AppointmentDetails d) onReschedule;

  const _FocalCard({
    required this.d,
    required this.onCancel,
    required this.onReschedule,
  });

  @override
  Widget build(BuildContext context) {
    final a = d.appointment;
    final status = a.status;
    final badge = _StatusBadge(status: status);
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: const Color(0xFFBBCAC6).withValues(alpha: 0.18)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF191C1D).withValues(alpha: 0.06),
              blurRadius: 40,
              offset: const Offset(0, 20),
            )
          ],
        ),
        child: Stack(
          children: [
            Align(alignment: Alignment.topRight, child: badge),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DoctorAvatarLarge(name: d.doctorName),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        d.doctorName,
                        style: GoogleFonts.epilogue(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        d.specialty,
                        style: GoogleFonts.manrope(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF2EC4B6),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Wrap(
                        spacing: 18,
                        runSpacing: 12,
                        children: [
                          _MetaPill(
                            icon: Icons.calendar_today,
                            label: 'Ngày',
                            value: d.date,
                          ),
                          _MetaPill(
                            icon: Icons.schedule,
                            label: 'Giờ',
                            value: d.startTime,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          TextButton.icon(
                            onPressed: status == 'cancelled' ? null : () => onCancel(a),
                            icon: const Icon(Icons.cancel, size: 18, color: Colors.red),
                            label: Text(
                              'Hủy lịch',
                              style: GoogleFonts.manrope(
                                fontWeight: FontWeight.w900,
                                color: Colors.red,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          TextButton(
                            onPressed: () => onReschedule(d),
                            child: Text(
                              'Đổi lịch',
                              style: GoogleFonts.manrope(
                                fontWeight: FontWeight.w900,
                                color: const Color(0xFF3C4947).withValues(alpha: 0.8),
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _MetaPill({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFF2F4F4),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Icon(icon, size: 18, color: const Color(0xFF3C4947).withValues(alpha: 0.7)),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: GoogleFonts.manrope(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.4,
                color: const Color(0xFF3C4947).withValues(alpha: 0.55),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: GoogleFonts.manrope(fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ],
    );
  }
}

class _DoctorAvatarLarge extends StatelessWidget {
  final String name;
  const _DoctorAvatarLarge({required this.name});

  @override
  Widget build(BuildContext context) {
    final initials = name.isNotEmpty ? name.trim().split(' ').take(2).map((s) => s.isNotEmpty ? s[0] : '').join() : 'BS';
    return Container(
      width: 120,
      height: 140,
      decoration: BoxDecoration(
        color: const Color(0xFF1B3A4B).withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(18),
      ),
      alignment: Alignment.center,
      child: Text(
        initials.toUpperCase(),
        style: GoogleFonts.epilogue(
          fontSize: 32,
          fontWeight: FontWeight.w900,
          color: const Color(0xFF1B3A4B),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    String t;
    Color bg;
    Color fg;
    switch (status) {
      case 'confirmed':
        t = 'Đã xác nhận';
        bg = const Color(0xFF006A62).withValues(alpha: 0.10);
        fg = const Color(0xFF006A62);
        break;
      case 'cancelled':
        t = 'Đã hủy';
        bg = Colors.black.withValues(alpha: 0.06);
        fg = const Color(0xFF3C4947);
        break;
      default:
        t = 'Đang chờ';
        bg = const Color(0xFFF99A15).withValues(alpha: 0.12);
        fg = const Color(0xFF895100);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        t,
        style: GoogleFonts.epilogue(
          fontSize: 11,
          fontWeight: FontWeight.w900,
          color: fg,
        ),
      ),
    );
  }
}

class _HealthProgressCard extends StatelessWidget {
  const _HealthProgressCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF1B3A4B),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF191C1D).withValues(alpha: 0.06),
            blurRadius: 40,
            offset: const Offset(0, 20),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.health_and_safety, size: 36, color: const Color(0xFF2EC4B6)),
          const SizedBox(height: 12),
          Text(
            'Tiến độ\nsức khỏe',
            style: GoogleFonts.epilogue(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '85%',
                style: GoogleFonts.epilogue(
                  fontSize: 38,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              Text(
                'Đang theo dõi mục tiêu',
                style: GoogleFonts.manrope(
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NextStepCard extends StatelessWidget {
  const _NextStepCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFFF99A15).withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFF99A15).withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bước tiếp theo',
            style: GoogleFonts.epilogue(
              fontWeight: FontWeight.w900,
              color: const Color(0xFF633900),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Hoàn thành phiếu đánh giá sức khỏe trước buổi khám.',
            style: GoogleFonts.manrope(
              fontWeight: FontWeight.w600,
              color: const Color(0xFF633900).withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFFF99A15),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: Text(
                'Điền biểu mẫu',
                style: GoogleFonts.epilogue(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PendingCard extends StatelessWidget {
  final AppointmentDetails d;
  final Future<void> Function(Appointment a) onCancel;
  final Future<void> Function(AppointmentDetails d) onModify;
  const _PendingCard({required this.d, required this.onCancel, required this.onModify});

  @override
  Widget build(BuildContext context) {
    final a = d.appointment;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF191C1D).withValues(alpha: 0.06),
            blurRadius: 34,
            offset: const Offset(0, 18),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: const Color(0xFF2EC4B6).withValues(alpha: 0.12),
                    child: Text(
                      d.doctorName.isNotEmpty ? d.doctorName[0].toUpperCase() : 'B',
                      style: GoogleFonts.epilogue(fontWeight: FontWeight.w900, color: const Color(0xFF006A62)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(d.doctorName, style: GoogleFonts.epilogue(fontWeight: FontWeight.w900)),
                      Text(d.specialty, style: GoogleFonts.manrope(color: const Color(0xFF3C4947).withValues(alpha: 0.7))),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF99A15).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text('ĐANG CHỜ', style: GoogleFonts.epilogue(fontSize: 11, fontWeight: FontWeight.w900, color: const Color(0xFFF99A15))),
              )
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F4F4),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('LỊCH YÊU CẦU', style: GoogleFonts.manrope(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2, color: const Color(0xFF3C4947).withValues(alpha: 0.55))),
                    const SizedBox(height: 6),
                    Text('${d.date} • ${d.startTime}', style: GoogleFonts.manrope(fontWeight: FontWeight.w900)),
                  ],
                ),
                const Icon(Icons.event_repeat, color: Color(0xFF3C4947)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () => onCancel(a),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.red.withValues(alpha: 0.06),
                    foregroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text('Hủy', style: GoogleFonts.epilogue(fontWeight: FontWeight.w900)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextButton(
                  onPressed: () => onModify(d),
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFFE1E3E3),
                    foregroundColor: const Color(0xFF191C1D),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: Text('Sửa', style: GoogleFonts.epilogue(fontWeight: FontWeight.w900)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CancelledCard extends StatelessWidget {
  final AppointmentDetails d;
  final Future<void> Function(AppointmentDetails d) onRebook;
  const _CancelledCard({required this.d, required this.onRebook});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.75,
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F4F4),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: const Color(0xFFBBCAC6).withValues(alpha: 0.20)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.black.withValues(alpha: 0.06),
                      child: Text(
                        d.doctorName.isNotEmpty ? d.doctorName[0].toUpperCase() : 'B',
                        style: GoogleFonts.epilogue(fontWeight: FontWeight.w900, color: const Color(0xFF3C4947)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(d.doctorName, style: GoogleFonts.epilogue(fontWeight: FontWeight.w900)),
                        Text(d.specialty, style: GoogleFonts.manrope(color: const Color(0xFF3C4947).withValues(alpha: 0.7))),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text('ĐÃ HỦY', style: GoogleFonts.epilogue(fontSize: 11, fontWeight: FontWeight.w900, color: const Color(0xFF3C4947))),
                )
              ],
            ),
            const SizedBox(height: 16),
            Text('NGÀY GỐC', style: GoogleFonts.manrope(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2, color: const Color(0xFF3C4947).withValues(alpha: 0.55))),
            const SizedBox(height: 6),
            Text('${d.date} • ${d.startTime}', style: GoogleFonts.manrope(fontWeight: FontWeight.w900, decoration: TextDecoration.lineThrough)),
            const SizedBox(height: 8),
            Text('• Đã hủy bởi người dùng', style: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.red.shade700)),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => onRebook(d),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF006A62), width: 2),
                  foregroundColor: const Color(0xFF006A62),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text('Đặt lại', style: GoogleFonts.epilogue(fontWeight: FontWeight.w900)),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _SmallConfirmedCard extends StatelessWidget {
  final AppointmentDetails d;
  final Future<void> Function(Appointment a) onCancel;
  final Future<void> Function(AppointmentDetails d) onReschedule;
  const _SmallConfirmedCard({required this.d, required this.onCancel, required this.onReschedule});

  @override
  Widget build(BuildContext context) {
    final a = d.appointment;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFBBCAC6).withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(d.doctorName, style: GoogleFonts.epilogue(fontWeight: FontWeight.w900)),
              _StatusBadge(status: 'confirmed'),
            ],
          ),
          const SizedBox(height: 8),
          Text(d.specialty, style: GoogleFonts.manrope(color: const Color(0xFF3C4947).withValues(alpha: 0.7))),
          const SizedBox(height: 12),
          Text('${d.date} • ${d.startTime}', style: GoogleFonts.manrope(fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          Row(
            children: [
              TextButton(
                onPressed: () => onCancel(a),
                child: Text('Hủy', style: GoogleFonts.manrope(fontWeight: FontWeight.w900, color: Colors.red)),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () => onReschedule(d),
                child: Text('Đổi lịch', style: GoogleFonts.manrope(fontWeight: FontWeight.w900)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HelpSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xFFE6E8E9),
        borderRadius: BorderRadius.circular(40),
      ),
      child: Column(
        children: [
          Text(
            'Bạn chưa tìm thấy lịch cần xem?',
            style: GoogleFonts.epilogue(
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            'Bộ phận hỗ trợ 24/7 sẵn sàng giúp bạn quản lý lịch hẹn hoặc tìm bác sĩ phù hợp.',
            style: GoogleFonts.manrope(
              fontWeight: FontWeight.w600,
              color: const Color(0xFF3C4947).withValues(alpha: 0.75),
              height: 1.45,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 18,
            runSpacing: 10,
            children: [
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.chat, color: Color(0xFF006A62)),
                label: Text('Chat hỗ trợ', style: GoogleFonts.manrope(fontWeight: FontWeight.w900, color: const Color(0xFF006A62))),
              ),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.call, color: Color(0xFF006A62)),
                label: Text('Gọi hỗ trợ', style: GoogleFonts.manrope(fontWeight: FontWeight.w900, color: const Color(0xFF006A62))),
              ),
            ],
          )
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onBookNew;
  const _EmptyState({required this.onBookNew});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color(0xFFBBCAC6).withValues(alpha: 0.18)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bạn chưa có lịch khám nào.',
            style: GoogleFonts.epilogue(fontSize: 20, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            'Hãy đặt lịch mới để bắt đầu.',
            style: GoogleFonts.manrope(
              fontWeight: FontWeight.w600,
              color: const Color(0xFF3C4947).withValues(alpha: 0.75),
            ),
          ),
          const SizedBox(height: 14),
          TextButton(
            onPressed: onBookNew,
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFF006A62),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            child: Text('Đặt lịch mới', style: GoogleFonts.epilogue(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }
}


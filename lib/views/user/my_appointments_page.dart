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
  static const int pageSize = 4; // Tăng trải nghiệm người dùng bằng cách giảm số lượng item mỗi trang

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
    try {
      items = await AppointmentController.instance.getAppointmentsByUserDetails(user!.id!);
    } catch (e) {
      debugPrint("Error loading appointments: $e");
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
          page = 1;
        });
      }
    }
  }

  Future<void> _cancel(Appointment a) async {
    final ok = await showAppConfirmDialog(
      context,
      title: 'Hủy lịch khám?',
      message: 'Bạn chắc chắn muốn hủy lịch khám này? Slot sẽ được mở lại để người khác đặt lịch.',
      confirmText: 'HỦY LỊCH',
      cancelText: 'GIỮ LẠI',
    );
    if (!ok) return;
    try {
      await AppointmentController.instance.cancelAppointment(a);
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Không hủy được: $e')));
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

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final isLoggedIn = SessionController.instance.currentUser != null;

    // Phân loại và sắp xếp lịch hẹn
    final upcoming = items.where((d) => d.appointment.status == 'confirmed' || d.appointment.status == 'pending').toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    final history = items.where((d) => d.appointment.status == 'cancelled' || d.appointment.status == 'completed').toList()
      ..sort((a, b) => b.date.compareTo(a.date)); // Lịch sử xem cái gần nhất trước

    final displayList = historyMode ? history : upcoming;

    // Thẻ tiêu điểm (Focal Card)
    AppointmentDetails? focal = displayList.isNotEmpty ? displayList.first : null;
    final rest = displayList.skip(focal == null ? 0 : 1).toList();

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
                SessionController.instance.logout();
                Navigator.of(context).pushReplacementNamed('/user/home');
              },
            ),
            Expanded(
              child: loading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF006A62)))
                  : SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: width < 600 ? 16 : 40,
                  vertical: 32,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Header(
                          historyMode: historyMode,
                          onToggleHistory: () => setState(() {
                            historyMode = !historyMode;
                            page = 1;
                          }),
                          onBookNew: () => Navigator.of(context).pushNamed('/user/doctors'),
                        ),
                        const SizedBox(height: 40),
                        if (displayList.isEmpty)
                          _EmptyState(historyMode: historyMode)
                        else
                          _BentoGrid(
                            width: width,
                            focal: focal,
                            rest: rest,
                            onCancel: _cancel,
                            onReschedule: (d) => Navigator.of(context).pushNamed('/user/booking', arguments: _toDoctor(d)),
                            page: page,
                            pageSize: pageSize,
                            onPageChange: (p) => setState(() => page = p),
                          ),
                        const SizedBox(height: 60),
                        const _HelpSection(),
                        const SizedBox(height: 40),
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

  const _Header({required this.historyMode, required this.onToggleHistory, required this.onBookNew});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'QUẢN LÝ SỨC KHỎE',
                style: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: const Color(0xFF006A62)),
              ),
              const SizedBox(height: 12),
              Text(
                historyMode ? 'Lịch sử khám' : 'Lịch hẹn sắp tới',
                style: GoogleFonts.epilogue(fontSize: 40, fontWeight: FontWeight.w900, height: 1.1),
              ),
            ],
          ),
        ),
        Row(
          children: [
            _HeaderButton(
              onPressed: onToggleHistory,
              label: historyMode ? 'Xem lịch sắp tới' : 'Xem lịch sử',
              isPrimary: false,
            ),
            const SizedBox(width: 12),
            _HeaderButton(
              onPressed: onBookNew,
              label: 'Đặt lịch mới',
              isPrimary: true,
            ),
          ],
        ),
      ],
    );
  }
}

class _HeaderButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String label;
  final bool isPrimary;
  const _HeaderButton({required this.onPressed, required this.label, required this.isPrimary});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: isPrimary ? const Color(0xFF006A62) : Colors.white,
        foregroundColor: isPrimary ? Colors.white : const Color(0xFF006A62),
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: isPrimary ? BorderSide.none : const BorderSide(color: Color(0xFF006A62), width: 1.5),
        ),
      ),
      child: Text(label, style: GoogleFonts.manrope(fontWeight: FontWeight.w800)),
    );
  }
}

class _BentoGrid extends StatelessWidget {
  final double width;
  final AppointmentDetails? focal;
  final List<AppointmentDetails> rest;
  final Future<void> Function(Appointment a) onCancel;
  final Function(AppointmentDetails d) onReschedule;
  final int page;
  final int pageSize;
  final ValueChanged<int> onPageChange;

  const _BentoGrid({
    required this.width,
    required this.focal,
    required this.rest,
    required this.onCancel,
    required this.onReschedule,
    required this.page,
    required this.pageSize,
    required this.onPageChange,
  });

  @override
  Widget build(BuildContext context) {
    final isDesktop = width >= 950;
    final totalPages = (rest.length / pageSize).ceil().clamp(1, 99);
    final pagedItems = rest.skip((page - 1) * pageSize).take(pageSize).toList();

    return Column(
      children: [
        if (isDesktop)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 7, child: _FocalCard(d: focal!, onCancel: onCancel, onReschedule: onReschedule)),
              const SizedBox(width: 24),
              const Expanded(flex: 4, child: _HealthSummarySidebar()),
            ],
          )
        else ...[
          _FocalCard(d: focal!, onCancel: onCancel, onReschedule: onReschedule),
          const SizedBox(height: 24),
          const _HealthSummarySidebar(),
        ],
        const SizedBox(height: 32),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: width < 700 ? 1 : (width < 1100 ? 2 : 2),
            mainAxisSpacing: 20,
            crossAxisSpacing: 20,
            mainAxisExtent: 220,
          ),
          itemCount: pagedItems.length,
          itemBuilder: (context, index) => _SmallCard(
            d: pagedItems[index],
            onCancel: onCancel,
            onReschedule: onReschedule,
          ),
        ),
        if (totalPages > 1) _Pagination(currentPage: page, total: totalPages, onPageChange: onPageChange),
      ],
    );
  }
}

class _FocalCard extends StatelessWidget {
  final AppointmentDetails d;
  final Future<void> Function(Appointment a) onCancel;
  final Function(AppointmentDetails d) onReschedule;

  const _FocalCard({required this.d, required this.onCancel, required this.onReschedule});

  @override
  Widget build(BuildContext context) {
    final isCancelled = d.appointment.status == 'cancelled';
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 40, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _StatusChip(status: d.appointment.status),
              const Spacer(),
              Text('Mã lịch: #${d.appointment.id}', style: GoogleFonts.manrope(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              CircleAvatar(radius: 40, backgroundColor: const Color(0xFFC5E4FA), child: Text(d.doctorName[0], style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold))),
              const SizedBox(width: 24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(d.doctorName, style: GoogleFonts.epilogue(fontSize: 28, fontWeight: FontWeight.w900)),
                    Text(d.specialty, style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w700, color: const Color(0xFF006A62))),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: const Color(0xFFF8FAFA), borderRadius: BorderRadius.circular(20)),
            child: Row(
              children: [
                _DateTimeInfo(icon: Icons.calendar_today, label: 'Ngày khám', value: d.date),
                const SizedBox(width: 40),
                _DateTimeInfo(icon: Icons.access_time, label: 'Giờ khám', value: d.startTime),
              ],
            ),
          ),
          if (!isCancelled) ...[
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => onReschedule(d),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFECEEEE), foregroundColor: Colors.black, elevation: 0, padding: const EdgeInsets.symmetric(vertical: 20), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                    child: const Text('Đổi lịch hẹn', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => onCancel(d.appointment),
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFE8E8), foregroundColor: Colors.red, elevation: 0, padding: const EdgeInsets.symmetric(vertical: 20), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                    child: const Text('Hủy lịch', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            )
          ]
        ],
      ),
    );
  }
}

class _SmallCard extends StatelessWidget {
  final AppointmentDetails d;
  final Future<void> Function(Appointment a) onCancel;
  final Function(AppointmentDetails d) onReschedule;

  const _SmallCard({required this.d, required this.onCancel, required this.onReschedule});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), border: Border.all(color: const Color(0xFFECEEEE))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StatusChip(status: d.appointment.status, small: true),
          const SizedBox(height: 16),
          Text(d.doctorName, style: GoogleFonts.epilogue(fontSize: 18, fontWeight: FontWeight.w900)),
          Text(d.specialty, style: GoogleFonts.manrope(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.bold)),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${d.date} • ${d.startTime}', style: GoogleFonts.manrope(fontWeight: FontWeight.w900, fontSize: 13)),
              if (d.appointment.status != 'cancelled')
                IconButton(onPressed: () => onCancel(d.appointment), icon: const Icon(Icons.cancel_outlined, color: Colors.red, size: 20)),
            ],
          )
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  final bool small;
  const _StatusChip({required this.status, this.small = false});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    String label;

    switch (status) {
      case 'confirmed':
        bg = const Color(0xFFE6F4F1); fg = const Color(0xFF006A62); label = 'Đã xác nhận';
        break;
      case 'pending':
        bg = const Color(0xFFFFF4E5); fg = const Color(0xFFB07000); label = 'Đang chờ';
        break;
      case 'cancelled':
        bg = const Color(0xFFFFE8E8); fg = Colors.red; label = 'Đã hủy';
        break;
      default:
        bg = Colors.grey[100]!; fg = Colors.grey[700]!; label = 'Hoàn thành';
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: small ? 10 : 16, vertical: small ? 6 : 10),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(99)),
      child: Text(label.toUpperCase(), style: GoogleFonts.manrope(fontSize: small ? 10 : 12, fontWeight: FontWeight.w900, letterSpacing: 1)),
    );
  }
}

class _DateTimeInfo extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _DateTimeInfo({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)), child: Icon(icon, size: 20, color: const Color(0xFF006A62))),
        const SizedBox(width: 16),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: GoogleFonts.manrope(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
          Text(value, style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w900)),
        ]),
      ],
    );
  }
}

class _HealthSummarySidebar extends StatelessWidget {
  const _HealthSummarySidebar();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SidebarCard(title: 'Tiến trình sức khỏe', value: '85%', color: const Color(0xFF1B3A4B), icon: Icons.auto_graph),
        const SizedBox(height: 20),
        _SidebarCard(title: 'Buổi khám đã xong', value: '12', color: const Color(0xFF006A62), icon: Icons.done_all),
      ],
    );
  }
}

class _SidebarCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;
  const _SidebarCard({required this.title, required this.value, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(24)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: GoogleFonts.manrope(color: Colors.white70, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(value, style: GoogleFonts.epilogue(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900)),
          ]),
          Icon(icon, color: Colors.white24, size: 48),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool historyMode;
  const _EmptyState({required this.historyMode});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 60),
          Icon(Icons.event_note_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 24),
          Text(historyMode ? 'Bạn chưa có lịch sử khám' : 'Bạn chưa có lịch hẹn nào', style: GoogleFonts.epilogue(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.grey)),
        ],
      ),
    );
  }
}

class _Pagination extends StatelessWidget {
  final int currentPage;
  final int total;
  final ValueChanged<int> onPageChange;
  const _Pagination({required this.currentPage, required this.total, required this.onPageChange});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(total, (index) {
          final p = index + 1;
          final isActive = p == currentPage;
          return GestureDetector(
            onTap: () => onPageChange(p),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 6),
              width: isActive ? 40 : 32,
              height: 32,
              decoration: BoxDecoration(color: isActive ? const Color(0xFF006A62) : Colors.transparent, borderRadius: BorderRadius.circular(8), border: Border.all(color: isActive ? Colors.transparent : const Color(0xFFECEEEE))),
              alignment: Alignment.center,
              child: Text('$p', style: TextStyle(color: isActive ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
            ),
          );
        }),
      ),
    );
  }
}

class _HelpSection extends StatelessWidget {
  const _HelpSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(color: const Color(0xFFECEEEE), borderRadius: BorderRadius.circular(32)),
      child: Row(
        children: [
          const Icon(Icons.help_outline, size: 40, color: Color(0xFF006A62)),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Bạn cần hỗ trợ với lịch hẹn?', style: GoogleFonts.epilogue(fontSize: 18, fontWeight: FontWeight.w900)),
                Text('Đội ngũ chăm sóc khách hàng của chúng tôi luôn sẵn sàng 24/7.', style: GoogleFonts.manrope(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 0, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('Liên hệ hỗ trợ'),
          )
        ],
      ),
    );
  }
}
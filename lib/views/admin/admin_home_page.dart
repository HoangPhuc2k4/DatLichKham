import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../controllers/appointment_controller.dart';
import '../../controllers/doctor_controller.dart';
import '../../controllers/session_controller.dart';
import '../../database/db_helper.dart';
import '../../models/appointment_details.dart';
import '../../models/doctor.dart';
import '../../models/schedule.dart';
import '../../controllers/schedule_controller.dart';
import '../widgets/app_confirm_dialog.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = SessionController.instance.currentUser;
    if (user == null || user.role != 'admin') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed('/');
      });
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin - Tổng quan'),
      ),
      body: const _AdminDashboardBody(),
    );
  }
}

class _AdminDashboardBody extends StatefulWidget {
  const _AdminDashboardBody();

  @override
  State<_AdminDashboardBody> createState() => _AdminDashboardBodyState();
}

class _AdminDashboardBodyState extends State<_AdminDashboardBody> {
  Future<_Counts> _loadCounts() async {
    final db = DbHelper.instance.db;
    final users = await (db.select(db.users)).get();
    final doctors = await (db.select(db.doctors)).get();
    final appts = await (db.select(db.appointments)).get();
    return _Counts(
      users: users.length,
      doctors: doctors.length,
      appointments: appts.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 980;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FutureBuilder<_Counts>(
                future: _loadCounts(),
                builder: (context, snap) {
                  if (!snap.hasData) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: LinearProgressIndicator(),
                    );
                  }
                  final c = snap.data!;
                  return Wrap(
                    spacing: 14,
                    runSpacing: 14,
                    children: [
                      _StatCard(label: 'Bệnh nhân', value: '${c.users}'),
                      _StatCard(label: 'Bác sĩ', value: '${c.doctors}'),
                      _StatCard(label: 'Lịch khám', value: '${c.appointments}'),
                    ],
                  );
                },
              ),
              const SizedBox(height: 18),
              Expanded(
                child: isWide
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Expanded(child: _DoctorManagementCard()),
                          SizedBox(width: 14),
                          Expanded(child: _ScheduleManagementCard()),
                          SizedBox(width: 14),
                          Expanded(child: _AppointmentManagementCard()),
                        ],
                      )
                    : ListView(
                        children: const [
                          _DoctorManagementCard(),
                          SizedBox(height: 14),
                          _ScheduleManagementCard(),
                          SizedBox(height: 14),
                          _AppointmentManagementCard(),
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

class _Counts {
  final int users;
  final int doctors;
  final int appointments;
  _Counts({
    required this.users,
    required this.doctors,
    required this.appointments,
  });
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  const _StatCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFBBCAC6).withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.manrope(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF3C4947),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.epilogue(
              fontSize: 30,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _DoctorManagementCard extends StatefulWidget {
  const _DoctorManagementCard();

  @override
  State<_DoctorManagementCard> createState() => _DoctorManagementCardState();
}

class _DoctorManagementCardState extends State<_DoctorManagementCard> {
  late Future<List<Doctor>> _future;

  @override
  void initState() {
    super.initState();
    _future = DoctorController.instance.getAllDoctors();
  }

  Future<void> _reload() async {
    setState(() => _future = DoctorController.instance.getAllDoctors());
  }

  Future<void> _openForm([Doctor? d]) async {
    final res = await showDialog<Doctor>(
      context: context,
      builder: (context) => _DoctorDialog(initial: d),
    );
    if (res != null) {
      await DoctorController.instance.upsertDoctor(res);
      await _reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    return _Panel(
      title: 'Bác sĩ',
      subtitle: 'Thêm / sửa / xóa',
      trailing: IconButton(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add),
      ),
      child: FutureBuilder<List<Doctor>>(
        future: _future,
        builder: (context, snap) {
          if (!snap.hasData) return const LinearProgressIndicator();
          final items = snap.data!;
          return ListView.separated(
            shrinkWrap: true,
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final d = items[i];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: d.image.isNotEmpty ? NetworkImage(d.image) : null,
                  backgroundColor: Colors.black12,
                ),
                title: Text(d.name),
                subtitle: Text('${d.specialty} • ${d.experience} năm'),
                onTap: () => _openForm(d),
                trailing: IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () async {
                    if (d.id == null) return;
                    final ok = await showAppConfirmDialog(
                      context,
                      title: 'Xóa bác sĩ?',
                      message: 'Bạn chắc chắn muốn xóa "${d.name}"?',
                    );
                    if (!ok) return;
                    await DoctorController.instance.deleteDoctor(d.id!);
                    await _reload();
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _DoctorDialog extends StatefulWidget {
  final Doctor? initial;
  const _DoctorDialog({this.initial});

  @override
  State<_DoctorDialog> createState() => _DoctorDialogState();
}

class _DoctorDialogState extends State<_DoctorDialog> {
  late final TextEditingController name;
  late final TextEditingController specialty;
  late final TextEditingController exp;
  late final TextEditingController desc;
  late final TextEditingController image;

  @override
  void initState() {
    super.initState();
    name = TextEditingController(text: widget.initial?.name ?? '');
    specialty = TextEditingController(text: widget.initial?.specialty ?? '');
    exp = TextEditingController(text: '${widget.initial?.experience ?? 0}');
    desc = TextEditingController(text: widget.initial?.description ?? '');
    image = TextEditingController(text: widget.initial?.image ?? '');
  }

  @override
  void dispose() {
    name.dispose();
    specialty.dispose();
    exp.dispose();
    desc.dispose();
    image.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initial == null ? 'Thêm bác sĩ' : 'Sửa bác sĩ'),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(controller: name, decoration: const InputDecoration(labelText: 'Tên')),
              TextField(controller: specialty, decoration: const InputDecoration(labelText: 'Chuyên khoa')),
              TextField(controller: exp, decoration: const InputDecoration(labelText: 'Kinh nghiệm (năm)'), keyboardType: TextInputType.number),
              TextField(controller: image, decoration: const InputDecoration(labelText: 'Ảnh (URL)')),
              TextField(controller: desc, decoration: const InputDecoration(labelText: 'Mô tả'), maxLines: 3),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
        FilledButton(
          onPressed: () {
            final parsed = int.tryParse(exp.text.trim()) ?? 0;
            Navigator.pop(
              context,
              Doctor(
                id: widget.initial?.id,
                name: name.text.trim(),
                specialty: specialty.text.trim(),
                experience: parsed,
                description: desc.text.trim(),
                image: image.text.trim(),
              ),
            );
          },
          child: const Text('Lưu'),
        ),
      ],
    );
  }
}

class _ScheduleManagementCard extends StatefulWidget {
  const _ScheduleManagementCard();

  @override
  State<_ScheduleManagementCard> createState() => _ScheduleManagementCardState();
}

class _ScheduleManagementCardState extends State<_ScheduleManagementCard> {
  Doctor? selectedDoctor;
  DateTime selectedDate = DateTime.now();
  List<Schedule> schedules = [];
  bool loading = false;

  String _dateKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<void> _load() async {
    if (selectedDoctor?.id == null) return;
    setState(() => loading = true);
    schedules = await ScheduleController.instance.getSchedulesByDoctorAndDate(
      doctorId: selectedDoctor!.id!,
      date: _dateKey(selectedDate),
    );
    setState(() => loading = false);
  }

  Future<void> _createSlot() async {
    if (selectedDoctor?.id == null) return;
    final res = await showDialog<_SlotInput>(
      context: context,
      builder: (context) => const _SlotDialog(),
    );
    if (res == null) return;
    await ScheduleController.instance.createSchedule(
      Schedule(
        doctorId: selectedDoctor!.id!,
        date: _dateKey(selectedDate),
        startTime: res.start,
        endTime: res.end,
        isBooked: false,
      ),
    );
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return _Panel(
      title: 'Lịch làm việc',
      subtitle: 'Tạo slot theo bác sĩ & ngày',
      trailing: IconButton(
        onPressed: _createSlot,
        icon: const Icon(Icons.add),
      ),
      child: Column(
        children: [
          FutureBuilder<List<Doctor>>(
            future: DoctorController.instance.getAllDoctors(),
            builder: (context, snap) {
              if (!snap.hasData) return const LinearProgressIndicator();
              final items = snap.data!;
              selectedDoctor ??= items.isNotEmpty ? items.first : null;
              return Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<Doctor>(
                      initialValue: selectedDoctor,
                      items: items
                          .map(
                            (d) => DropdownMenuItem(
                              value: d,
                              child: Text(d.name),
                            ),
                          )
                          .toList(),
                      onChanged: (d) async {
                        setState(() => selectedDoctor = d);
                        await _load();
                      },
                      decoration: const InputDecoration(labelText: 'Bác sĩ'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        firstDate: DateTime.now().subtract(const Duration(days: 1)),
                        lastDate: DateTime.now().add(const Duration(days: 30)),
                        initialDate: selectedDate,
                      );
                      if (picked == null) return;
                      setState(() => selectedDate = picked);
                      await _load();
                    },
                    child: Text(_dateKey(selectedDate)),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: _load,
                    icon: const Icon(Icons.refresh),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 12),
          Expanded(
            child: loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.separated(
                    itemCount: schedules.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final s = schedules[i];
                      return ListTile(
                        title: Text('${s.startTime} - ${s.endTime}'),
                        subtitle: Text(s.isBooked ? 'Đã đặt' : 'Trống'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () async {
                            if (s.id == null) return;
                            await ScheduleController.instance.deleteSchedule(s.id!);
                            await _load();
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _SlotInput {
  final String start;
  final String end;
  _SlotInput(this.start, this.end);
}

class _SlotDialog extends StatefulWidget {
  const _SlotDialog();

  @override
  State<_SlotDialog> createState() => _SlotDialogState();
}

class _SlotDialogState extends State<_SlotDialog> {
  final start = TextEditingController(text: '09:00');
  final end = TextEditingController(text: '09:30');

  @override
  void dispose() {
    start.dispose();
    end.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Tạo slot'),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: start, decoration: const InputDecoration(labelText: 'Start (HH:mm)')),
            TextField(controller: end, decoration: const InputDecoration(labelText: 'End (HH:mm)')),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
        FilledButton(
          onPressed: () => Navigator.pop(context, _SlotInput(start.text.trim(), end.text.trim())),
          child: const Text('Tạo'),
        ),
      ],
    );
  }
}

class _AppointmentManagementCard extends StatefulWidget {
  const _AppointmentManagementCard();

  @override
  State<_AppointmentManagementCard> createState() =>
      _AppointmentManagementCardState();
}

class _AppointmentManagementCardState extends State<_AppointmentManagementCard> {
  late Future<List<AppointmentDetails>> _future;

  @override
  void initState() {
    super.initState();
    _future = AppointmentController.instance.getAllAppointmentsDetails();
  }

  Future<void> _reload() async {
    setState(() => _future = AppointmentController.instance.getAllAppointmentsDetails());
  }

  @override
  Widget build(BuildContext context) {
    return _Panel(
      title: 'Lịch đặt khám',
      subtitle: 'Xác nhận / hủy',
      trailing: IconButton(
        onPressed: _reload,
        icon: const Icon(Icons.refresh),
      ),
      child: FutureBuilder<List<AppointmentDetails>>(
        future: _future,
        builder: (context, snap) {
          if (!snap.hasData) return const LinearProgressIndicator();
          final items = snap.data!;
          return ListView.separated(
            shrinkWrap: true,
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, i) {
              final details = items[i];
              final a = details.appointment;
              return ListTile(
                title: Text('${details.doctorName} • ${details.date} ${details.startTime}-${details.endTime}'),
                subtitle: Text('user:${a.userId} • status: ${a.status}'),
                trailing: Wrap(
                  spacing: 8,
                  children: [
                    TextButton(
                      onPressed: a.status == 'confirmed'
                          ? null
                          : () async {
                              if (a.id == null) return;
                              await AppointmentController.instance
                                  .confirmAppointment(a.id!);
                              await _reload();
                            },
                      child: const Text('Confirm'),
                    ),
                    TextButton(
                      onPressed: a.status == 'cancelled'
                          ? null
                          : () async {
                              final ok = await showAppConfirmDialog(
                                context,
                                title: 'Hủy lịch hẹn?',
                                message: 'Bạn chắc chắn muốn hủy lịch hẹn này?',
                                confirmText: 'HỦY LỊCH',
                                cancelText: 'GIỮ LẠI',
                              );
                              if (!ok) return;
                              await AppointmentController.instance
                                  .cancelAppointment(a);
                              await _reload();
                            },
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget trailing;
  final Widget child;

  const _Panel({
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFBBCAC6).withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.epilogue(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.manrope(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF3C4947),
                      ),
                    ),
                  ],
                ),
              ),
              trailing,
            ],
          ),
          const SizedBox(height: 12),
          Expanded(child: child),
        ],
      ),
    );
  }
}


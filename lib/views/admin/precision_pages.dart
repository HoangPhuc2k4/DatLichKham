import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';
import 'package:drift/drift.dart' as drift;
import 'dart:convert';

import '../../controllers/appointment_controller.dart';
import '../../controllers/doctor_controller.dart';
import '../../controllers/schedule_controller.dart';
import '../../database/app_database.dart';
import '../../database/db_helper.dart';
import '../../models/appointment_details.dart';
import '../../models/doctor.dart';
import '../../models/schedule.dart';
import 'precision_admin_shell.dart';
import '../widgets/app_confirm_dialog.dart';
import '../widgets/doctor_image.dart';

class PrecisionDashboardPage extends StatefulWidget {
  const PrecisionDashboardPage({super.key});

  @override
  State<PrecisionDashboardPage> createState() => _PrecisionDashboardPageState();
}

class _PrecisionDashboardPageState extends State<PrecisionDashboardPage> {
  int rangeDays = 7;

  Future<_DashboardData> _loadDashboard() async {
    final db = DbHelper.instance.db;

    final users = await (db.select(db.users)..where((u) => u.role.equals('user'))).get();
    final doctors = await (db.select(db.doctors)).get();
    final appts = await (db.select(db.appointments)).get();
    final pending = appts.where((a) => a.status == 'pending').length;
    final confirmed = appts.where((a) => a.status == 'confirmed').length;
    final cancelled = appts.where((a) => a.status == 'cancelled').length;

    final efficiency = (confirmed + cancelled) == 0 ? 0.0 : (confirmed / (confirmed + cancelled)) * 100.0;

    // Occupancy hôm nay = booked schedules / total schedules hôm nay
    final now = DateTime.now();
    final todayKey =
        '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final todaySlots = await (db.select(db.schedules)..where((s) => s.date.equals(todayKey))).get();
    final bookedToday = todaySlots.where((s) => s.isBooked).length;
    final occupancy = todaySlots.isEmpty ? 0.0 : (bookedToday / todaySlots.length) * 100.0;

    // Trend series theo createdAt trong rangeDays
    final end = DateTime(now.year, now.month, now.day);
    final start = end.subtract(Duration(days: rangeDays - 1));
    final buckets = <DateTime, int>{};
    for (int i = 0; i < rangeDays; i++) {
      final d = start.add(Duration(days: i));
      buckets[DateTime(d.year, d.month, d.day)] = 0;
    }
    for (final a in appts) {
      DateTime? t;
      try {
        t = DateTime.parse(a.createdAt);
      } catch (_) {
        t = null;
      }
      if (t == null) continue;
      final day = DateTime(t.year, t.month, t.day);
      if (day.isBefore(start) || day.isAfter(end)) continue;
      buckets[day] = (buckets[day] ?? 0) + 1;
    }
    final series = buckets.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    final recent = await AppointmentController.instance.getAllAppointmentsDetails();

    // ER wait time "thật" (suy luận): trung bình phút chờ của pending (tính từ createdAt đến hiện tại) clamp 0..99
    final pendingAppts = appts.where((a) => a.status == 'pending').toList();
    double avgWait = 0;
    if (pendingAppts.isNotEmpty) {
      int sum = 0;
      int n = 0;
      for (final a in pendingAppts) {
        try {
          final t = DateTime.parse(a.createdAt);
          sum += now.difference(t).inMinutes.clamp(0, 600);
          n++;
        } catch (_) {}
      }
      avgWait = n == 0 ? 0 : (sum / n);
    }

    final alerts = <_Alert>[];
    if (pending >= 10) {
      alerts.add(
        const _Alert(
          level: _AlertLevel.warning,
          title: 'Tồn đọng lịch chờ xác nhận',
          body: 'Số lịch hẹn pending đang cao hơn mức khuyến nghị.',
        ),
      );
    }
    if (occupancy >= 85) {
      alerts.add(
        const _Alert(
          level: _AlertLevel.info,
          title: 'Tải lịch hôm nay cao',
          body: 'Tỷ lệ slot đã đặt hôm nay vượt 85%.',
        ),
      );
    }
    if (alerts.isEmpty) {
      alerts.add(
        const _Alert(
          level: _AlertLevel.info,
          title: 'Hệ thống ổn định',
          body: 'Không phát hiện cảnh báo quan trọng trong thời điểm hiện tại.',
        ),
      );
    }

    return _DashboardData(
      totalPatients: users.length,
      clinicalStaff: doctors.length,
      scheduledVisits: appts.length,
      pendingTriage: pending,
      efficiencyRating: efficiency,
      occupancyPercent: occupancy,
      avgWaitMinutes: avgWait,
      series: series.map((e) => _Point(date: e.key, value: e.value)).toList(growable: false),
      recent: recent.take(10).toList(growable: false),
      alerts: alerts,
      lastSync: DateTime.now(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PrecisionAdminShell(
      route: PrecisionAdminRoute.dashboard,
      title: 'Tổng quan',
      child: FutureBuilder<_DashboardData>(
        future: _loadDashboard(),
        builder: (context, snap) {
          if (!snap.hasData) return const LinearProgressIndicator();
          final d = snap.data!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tổng quan',
                style: GoogleFonts.spaceGrotesk(fontSize: 40, fontWeight: FontWeight.w800, letterSpacing: -1),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text('Trạng thái hệ thống:', style: GoogleFonts.manrope(fontSize: 11, color: Colors.black45)),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF006A62).withValues(alpha: 0.12),
                      border: Border.all(color: const Color(0xFF006A62).withValues(alpha: 0.25)),
                      borderRadius: BorderRadius.zero,
                    ),
                    child: Text(
                      'ĐANG HOẠT ĐỘNG',
                      style: GoogleFonts.manrope(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                        color: const Color(0xFF006A62),
                      ),
                    ),
                  ),
                  Text('|', style: GoogleFonts.manrope(fontSize: 11, color: Colors.black26)),
                  Text(
                    'Cập nhật lúc: ${_fmtTime(d.lastSync)}',
                    style: GoogleFonts.manrope(fontSize: 11, color: Colors.black45),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              LayoutBuilder(
                builder: (context, c) {
                  final isWide = c.maxWidth >= 1000;
                  final kpi = Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      _Kpi(
                        label: 'TOTAL PATIENTS',
                        value: '${d.totalPatients}',
                        borderColor: const Color(0xFF012435),
                        foot: '+${_pctVsLastMonth(d.series)}% vs tháng trước',
                        icon: Icons.person,
                        footColor: const Color(0xFF006A62),
                      ),
                      _Kpi(
                        label: 'CLINICAL STAFF',
                        value: '${d.clinicalStaff}',
                        borderColor: const Color(0xFF006A62),
                        foot: 'Active ${_availability(d.occupancyPercent)}% availability',
                        icon: Icons.medical_services_outlined,
                        footColor: const Color(0xFF006A62),
                      ),
                      _Kpi(
                        label: 'SCHEDULED VISITS',
                        value: '${d.scheduledVisits}',
                        borderColor: const Color(0xFF006A62),
                        foot: '${d.pendingTriage} Pending triage',
                        icon: Icons.calendar_today_outlined,
                        footColor: const Color(0xFFFFB86B),
                      ),
                      _Kpi(
                        label: 'EFFICIENCY RATING',
                        value: '${d.efficiencyRating.toStringAsFixed(1)}%',
                        borderColor: const Color(0xFF012435),
                        foot: 'Tỷ lệ lịch confirmed / (confirmed+cancelled)',
                        icon: Icons.analytics_outlined,
                        footColor: const Color(0xFF006A62),
                        spark: d.series.map((p) => p.value.toDouble()).toList(growable: false),
                      ),
                    ],
                  );

                  final mainGrid = isWide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 2,
                              child: _ChartCard(
                                rangeDays: rangeDays,
                                onRangeChange: (v) => setState(() => rangeDays = v),
                                points: d.series,
                              ),
                            ),
                            const SizedBox(width: 18),
                            Expanded(
                              child: _VitalsCard(
                                occupancyPercent: d.occupancyPercent,
                                avgWaitMinutes: d.avgWaitMinutes,
                                alerts: d.alerts,
                              ),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            _ChartCard(
                              rangeDays: rangeDays,
                              onRangeChange: (v) => setState(() => rangeDays = v),
                              points: d.series,
                            ),
                            const SizedBox(height: 18),
                            _VitalsCard(
                              occupancyPercent: d.occupancyPercent,
                              avgWaitMinutes: d.avgWaitMinutes,
                              alerts: d.alerts,
                            ),
                          ],
                        );

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      kpi,
                      const SizedBox(height: 18),
                      mainGrid,
                      const SizedBox(height: 18),
                      _RecentAdmissionsCard(items: d.recent),
                    ],
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

String _fmtTime(DateTime d) {
  final hh = d.hour.toString().padLeft(2, '0');
  final mm = d.minute.toString().padLeft(2, '0');
  final ss = d.second.toString().padLeft(2, '0');
  return '$hh:$mm:$ss';
}

int _availability(double occupancyPercent) {
  final v = (100 - (occupancyPercent / 6)).clamp(0, 100);
  return v.round();
}

int _pctVsLastMonth(List<_Point> points) {
  // Không có bảng theo tháng, dùng xấp xỉ: so sánh nửa đầu vs nửa sau series
  if (points.length < 6) return 0;
  final mid = points.length ~/ 2;
  final a = points.take(mid).fold<int>(0, (s, p) => s + p.value);
  final b = points.skip(mid).fold<int>(0, (s, p) => s + p.value);
  if (a == 0) return b == 0 ? 0 : 100;
  return (((b - a) / a) * 100).round();
}

class _DashboardData {
  final int totalPatients;
  final int clinicalStaff;
  final int scheduledVisits;
  final int pendingTriage;
  final double efficiencyRating;
  final double occupancyPercent;
  final double avgWaitMinutes;
  final List<_Point> series;
  final List<AppointmentDetails> recent;
  final List<_Alert> alerts;
  final DateTime lastSync;

  _DashboardData({
    required this.totalPatients,
    required this.clinicalStaff,
    required this.scheduledVisits,
    required this.pendingTriage,
    required this.efficiencyRating,
    required this.occupancyPercent,
    required this.avgWaitMinutes,
    required this.series,
    required this.recent,
    required this.alerts,
    required this.lastSync,
  });
}

class _Point {
  final DateTime date;
  final int value;
  const _Point({required this.date, required this.value});
}

enum _AlertLevel { warning, info }

class _Alert {
  final _AlertLevel level;
  final String title;
  final String body;
  const _Alert({required this.level, required this.title, required this.body});
}

class _ChartCard extends StatelessWidget {
  final int rangeDays;
  final void Function(int) onRangeChange;
  final List<_Point> points;

  const _ChartCard({
    required this.rangeDays,
    required this.onRangeChange,
    required this.points,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE1E3E4)),
        borderRadius: BorderRadius.zero,
        boxShadow: const [
          BoxShadow(color: Color(0x0F1B3A4B), blurRadius: 40, offset: Offset(0, 16)),
        ],
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
                      'APPOINTMENTS OVER TIME',
                      style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 0.4),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tổng số lịch hẹn theo thời gian (dữ liệu thật từ Drift)',
                      style: GoogleFonts.manrope(fontSize: 12, color: Colors.black45),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _RangeBtn(label: '7D', active: rangeDays == 7, onTap: () => onRangeChange(7)),
              const SizedBox(width: 8),
              _RangeBtn(label: '30D', active: rangeDays == 30, onTap: () => onRangeChange(30)),
              const SizedBox(width: 8),
              _RangeBtn(label: '90D', active: rangeDays == 90, onTap: () => onRangeChange(90)),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 260,
            child: CustomPaint(
              painter: _LineChartPainter(values: points.map((e) => e.value.toDouble()).toList()),
              child: const SizedBox.expand(),
            ),
          ),
          const SizedBox(height: 10),
          _XAxis(points: points),
        ],
      ),
    );
  }
}

class _RangeBtn extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _RangeBtn({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF012435) : Colors.transparent,
          border: Border.all(color: active ? const Color(0xFF012435) : const Color(0xFFE1E3E4)),
          borderRadius: BorderRadius.zero,
        ),
        child: Text(
          label,
          style: GoogleFonts.manrope(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
            color: active ? Colors.white : Colors.black54,
          ),
        ),
      ),
    );
  }
}

class _XAxis extends StatelessWidget {
  final List<_Point> points;
  const _XAxis({required this.points});

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) return const SizedBox.shrink();
    final n = points.length;
    final step = (n / 7).ceil().clamp(1, n);
    final labels = <String>[];
    for (int i = 0; i < n; i += step) {
      final d = points[i].date;
      labels.add('${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}');
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: labels
          .map(
            (t) => Text(
              t,
              style: GoogleFonts.manrope(fontSize: 10, color: Colors.black38, fontWeight: FontWeight.w700),
            ),
          )
          .toList(),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<double> values;
  _LineChartPainter({required this.values});

  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = Colors.white;
    canvas.drawRect(Offset.zero & size, bg);

    final gridPaint = Paint()
      ..color = const Color(0xFFF0F1F2)
      ..strokeWidth = 1;
    for (int i = 1; i <= 4; i++) {
      final y = size.height * (i / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    if (values.isEmpty) return;
    final maxV = values.reduce((a, b) => a > b ? a : b);
    final minV = values.reduce((a, b) => a < b ? a : b);
    final range = (maxV - minV).abs() < 1e-6 ? 1.0 : (maxV - minV);

    final pts = <Offset>[];
    for (int i = 0; i < values.length; i++) {
      final x = values.length == 1 ? 0.0 : (i / (values.length - 1)) * size.width;
      final v = values[i];
      final y = size.height - ((v - minV) / range) * (size.height * 0.78) - size.height * 0.06;
      pts.add(Offset(x, y));
    }

    final areaPath = Path()..moveTo(pts.first.dx, size.height);
    for (final p in pts) {
      areaPath.lineTo(p.dx, p.dy);
    }
    areaPath.lineTo(pts.last.dx, size.height);
    areaPath.close();
    final areaPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF006A62).withValues(alpha: 0.12),
          const Color(0xFF006A62).withValues(alpha: 0.0),
        ],
      ).createShader(Offset.zero & size);
    canvas.drawPath(areaPath, areaPaint);

    final linePaint = Paint()
      ..color = const Color(0xFF006A62)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
    final linePath = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (int i = 1; i < pts.length; i++) {
      linePath.lineTo(pts[i].dx, pts[i].dy);
    }
    canvas.drawPath(linePath, linePaint);

    if (pts.length >= 4) {
      final dotPaint = Paint()..color = const Color(0xFF012435);
      canvas.drawCircle(pts[pts.length ~/ 3], 4, dotPaint);
      canvas.drawCircle(pts[(pts.length * 2) ~/ 3], 4, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) => oldDelegate.values != values;
}

class _VitalsCard extends StatelessWidget {
  final double occupancyPercent;
  final double avgWaitMinutes;
  final List<_Alert> alerts;

  const _VitalsCard({
    required this.occupancyPercent,
    required this.avgWaitMinutes,
    required this.alerts,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: const BoxDecoration(
        color: Color(0xFF012435),
        borderRadius: BorderRadius.zero,
        boxShadow: [
          BoxShadow(color: Color(0x0F1B3A4B), blurRadius: 40, offset: Offset(0, 16)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'REAL-TIME VITALS',
            style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 0.6, color: Colors.white),
          ),
          const SizedBox(height: 14),
          _VitalBar(
            label: 'ICU OCCUPANCY',
            valueText: '${occupancyPercent.toStringAsFixed(0)}%',
            percent: occupancyPercent / 100.0,
            color: const Color(0xFF006A62),
          ),
          const SizedBox(height: 12),
          _VitalBar(
            label: 'ER WAIT TIME',
            valueText: '${avgWaitMinutes.toStringAsFixed(0)} MIN',
            percent: (avgWaitMinutes / 60.0).clamp(0, 1),
            color: const Color(0xFFFFB86B),
          ),
          const SizedBox(height: 16),
          Container(height: 1, color: Colors.white.withValues(alpha: 0.1)),
          const SizedBox(height: 12),
          Text(
            'CRITICAL ALERTS',
            style: GoogleFonts.manrope(fontSize: 10, color: Colors.white.withValues(alpha: 0.55), fontWeight: FontWeight.w800, letterSpacing: 1.4),
          ),
          const SizedBox(height: 10),
          ...alerts.take(2).map((a) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _AlertTile(alert: a),
              )),
        ],
      ),
    );
  }
}

class _VitalBar extends StatelessWidget {
  final String label;
  final String valueText;
  final double percent;
  final Color color;
  const _VitalBar({required this.label, required this.valueText, required this.percent, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        borderRadius: BorderRadius.zero,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.manrope(
                    fontSize: 10,
                    color: Colors.white.withValues(alpha: 0.55),
                    letterSpacing: 1.4,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(valueText, style: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.w900, color: color)),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 4,
            color: Colors.white.withValues(alpha: 0.12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: percent.clamp(0, 1),
                child: Container(color: color),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AlertTile extends StatelessWidget {
  final _Alert alert;
  const _AlertTile({required this.alert});

  @override
  Widget build(BuildContext context) {
    final isWarn = alert.level == _AlertLevel.warning;
    final bg = isWarn ? const Color(0x334A2B00) : Colors.white.withValues(alpha: 0.06);
    final ic = isWarn ? Icons.warning_amber_rounded : Icons.info_outline;
    final icColor = isWarn ? const Color(0xFFFFB86B) : const Color(0xFF006A62);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        borderRadius: BorderRadius.zero,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(ic, color: icColor, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(alert.title, style: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.w900, color: Colors.white)),
                const SizedBox(height: 4),
                Text(alert.body, style: GoogleFonts.manrope(fontSize: 10, color: Colors.white.withValues(alpha: 0.6))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentAdmissionsCard extends StatelessWidget {
  final List<AppointmentDetails> items;
  const _RecentAdmissionsCard({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE1E3E4)),
        borderRadius: BorderRadius.zero,
        boxShadow: const [
          BoxShadow(color: Color(0x0F1B3A4B), blurRadius: 40, offset: Offset(0, 16)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'RECENT PATIENT ADMISSIONS',
                    style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: 0.6),
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    Navigator.of(context).pushReplacementNamed('/admin/appointments');
                  },
                  icon: const Icon(Icons.arrow_forward, size: 16, color: Color(0xFF006A62)),
                  label: Text(
                    'VIEW REGISTRY',
                    style: GoogleFonts.manrope(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.3, color: const Color(0xFF006A62)),
                  ),
                ),
              ],
            ),
          ),
          Container(height: 1, color: const Color(0xFFE7E8E9)),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(const Color(0xFFE1E3E4).withValues(alpha: 0.35)),
              columns: [
                _dtCol('PATIENT ID'),
                _dtCol('LEGAL NAME'),
                _dtCol('DEPARTMENT'),
                _dtCol('ADMISSION TIME'),
                _dtCol('STATUS'),
              ],
              rows: items.asMap().entries.map((e) {
                final i = e.key;
                final d = e.value;
                final a = d.appointment;
                final alt = i.isOdd;
                final createdAt = _safeParse(a.createdAt);
                final timeLabel = createdAt == null ? '--:--' : _fmtTime(createdAt);
                final status = a.status;
                return DataRow(
                  color: WidgetStateProperty.all(alt ? const Color(0xFFF3F4F5) : Colors.white),
                  cells: [
                    DataCell(Text('#PAT-${(a.userId).toString().padLeft(5, '0')}', style: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.w800))),
                    DataCell(Text(d.userName.isNotEmpty ? d.userName : 'USER #${a.userId}', style: GoogleFonts.manrope(fontSize: 13, fontWeight: FontWeight.w800))),
                    DataCell(Text(d.specialty, style: GoogleFonts.manrope(fontSize: 13, color: Colors.black54))),
                    DataCell(Text(timeLabel, style: GoogleFonts.manrope(fontSize: 12, color: Colors.black45))),
                    DataCell(_StatusPill(status: status)),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

DataColumn _dtCol(String t) {
  return DataColumn(
    label: Text(
      t,
      style: GoogleFonts.manrope(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.2, color: Colors.black54),
    ),
  );
}

DateTime? _safeParse(String s) {
  try {
    return DateTime.parse(s);
  } catch (_) {
    return null;
  }
}

class PrecisionDoctorManagementPage extends StatefulWidget {
  const PrecisionDoctorManagementPage({super.key});

  @override
  State<PrecisionDoctorManagementPage> createState() => _PrecisionDoctorManagementPageState();
}

class _PrecisionDoctorManagementPageState extends State<PrecisionDoctorManagementPage> {
  late Future<List<Doctor>> _future;

  @override
  void initState() {
    super.initState();
    _future = DoctorController.instance.getAllDoctors();
  }

  Future<void> _reload() async {
    setState(() {
      _future = DoctorController.instance.getAllDoctors();
    });
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
    return PrecisionAdminShell(
      route: PrecisionAdminRoute.doctors,
      title: 'Quản lý bác sĩ',
      headerRight: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF006A62),
          foregroundColor: Colors.white,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        ),
        onPressed: () => _openForm(),
        icon: const Icon(Icons.person_add_alt_1, size: 18),
        label: Text(
          'THÊM BÁC SĨ',
          style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w800, letterSpacing: 1),
        ),
      ),
      child: FutureBuilder<List<Doctor>>(
        future: _future,
        builder: (context, snap) {
          if (!snap.hasData) return const LinearProgressIndicator();
          final items = snap.data!;
          return _Table(
            headers: const ['BÁC SĨ', 'CHUYÊN KHOA', 'CHUYÊN MÔN', 'KN (NĂM)', 'THAO TÁC'],
            rows: items.map((d) {
              return _RowData(
                cells: [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: SizedBox(
                          width: 40,
                          height: 40,
                          child: DoctorImage(pathOrUrl: d.image, fit: BoxFit.cover),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Text(d.name, style: GoogleFonts.manrope(fontWeight: FontWeight.w800))),
                    ],
                  ),
                  Text(d.specialty),
                  Text(
                    d.specializations.isEmpty ? '-' : d.specializations.take(2).join(', '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text('${d.experience}'),
                  Row(
                    children: [
                      IconButton(onPressed: () => _openForm(d), icon: const Icon(Icons.edit_outlined, size: 18)),
                      IconButton(
                        onPressed: () async {
                          if (d.id == null) return;
                          final ok = await showAppConfirmDialog(
                            context,
                            title: 'Xóa bác sĩ?',
                            message: 'Bạn chắc chắn muốn xóa "${d.name}"? Dữ liệu liên quan có thể bị ảnh hưởng.',
                          );
                          if (!ok) return;
                          await DoctorController.instance.deleteDoctor(d.id!);
                          await _reload();
                        },
                        icon: const Icon(Icons.delete_outline, size: 18),
                      ),
                    ],
                  ),
                ],
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class PrecisionScheduleManagementPage extends StatefulWidget {
  const PrecisionScheduleManagementPage({super.key});

  @override
  State<PrecisionScheduleManagementPage> createState() => _PrecisionScheduleManagementPageState();
}

class _PrecisionScheduleManagementPageState extends State<PrecisionScheduleManagementPage> {
  Doctor? selectedDoctor;
  DateTime selectedDate = DateTime.now();
  static const _shifts = <_Shift>[
    _Shift('Ca Sáng 1', '08:00', '10:00'),
    _Shift('Ca Sáng 2', '10:00', '12:00'),
    _Shift('Ca Chiều 1', '13:30', '15:30'),
    _Shift('Ca Chiều 2', '15:30', '17:30'),
  ];
  final Map<String, bool> _shiftSelected = {
    for (final s in _shifts) '${s.start}-${s.end}': false,
  };
  final resources = <String>['OR-1', 'ICU-B'];
  bool monthMode = false; // false = week, true = month
  bool loading = false;
  late Future<void> _init;
  List<Doctor> _doctors = [];
  final Map<String, List<Schedule>> _week = {}; // key: doctorId|date -> schedules
  final Map<String, _DayCount> _monthCounts = {}; // key: yyyy-MM-dd -> counts

  String _dateKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  void initState() {
    super.initState();
    _init = _bootstrap();
  }

  Future<void> _bootstrap() async {
    final docs = await DoctorController.instance.getAllDoctors();
    _doctors = docs;
    // Nếu được điều hướng từ Doctor Management, lấy doctor truyền qua arguments
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final arg = ModalRoute.of(context)?.settings.arguments;
      if (arg is Doctor && arg.id != null) {
        setState(() => selectedDoctor = arg);
      } else {
        setState(() => selectedDoctor ??= _doctors.isNotEmpty ? _doctors.first : null);
      }
      await _loadGrid();
    });
  }

  List<DateTime> _columns() {
    final base = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    final days = 4; // thiết kế dùng 4 cột Mon-Thu
    return List.generate(days, (i) => base.add(Duration(days: i)));
  }

  Future<void> _loadGrid() async {
    if (_doctors.isEmpty) return;
    setState(() => loading = true);
    final db = DbHelper.instance.db;

    if (!monthMode) {
      final cols = _columns();
      final dateKeys = cols.map(_dateKey).toList(growable: false);
      final doctorIds = _doctors.map((d) => d.id ?? -1).toList(growable: false);
      final rows = await (db.select(db.schedules)
            ..where((s) => s.date.isIn(dateKeys))
            ..where((s) => s.doctorId.isIn(doctorIds)))
          .get();
      _week.clear();
      for (final r in rows) {
        final k = '${r.doctorId}|${r.date}';
        final item = Schedule(
          id: r.id,
          doctorId: r.doctorId,
          date: r.date,
          startTime: r.startTime,
          endTime: r.endTime,
          isBooked: r.isBooked,
        );
        (_week[k] ??= <Schedule>[]).add(item);
      }
    } else {
      _monthCounts.clear();
      final d = selectedDoctor;
      if (d?.id != null) {
        final first = DateTime(selectedDate.year, selectedDate.month, 1);
        final next = DateTime(selectedDate.year, selectedDate.month + 1, 1);
        final daysInMonth = next.subtract(const Duration(days: 1)).day;
        final keys = List.generate(daysInMonth, (i) => _dateKey(first.add(Duration(days: i))));
        final rows = await (db.select(db.schedules)
              ..where((s) => s.doctorId.equals(d!.id!))
              ..where((s) => s.date.isIn(keys)))
            .get();
        for (final k in keys) {
          _monthCounts[k] = const _DayCount(total: 0, booked: 0);
        }
        for (final r in rows) {
          final prev = _monthCounts[r.date] ?? const _DayCount(total: 0, booked: 0);
          _monthCounts[r.date] = _DayCount(
            total: prev.total + 1,
            booked: prev.booked + (r.isBooked ? 1 : 0),
          );
        }
      }
    }
    setState(() => loading = false);
  }

  Future<void> _commitSchedule() async {
    if (selectedDoctor?.id == null) return;
    final doctorId = selectedDoctor!.id!;
    final date = _dateKey(selectedDate);
    final desired = <String, _Shift>{};
    for (final s in _shifts) {
      final key = '${s.start}-${s.end}';
      if (_shiftSelected[key] == true) desired[key] = s;
    }

    final db = DbHelper.instance.db;
    await db.transaction(() async {
      final existing = await (db.select(db.schedules)
            ..where((x) => x.doctorId.equals(doctorId))
            ..where((x) => x.date.equals(date)))
          .get();
      final existingByKey = <String, dynamic>{
        for (final r in existing) '${r.startTime}-${r.endTime}': r,
      };

      // insert missing
      for (final entry in desired.entries) {
        final k = entry.key;
        if (existingByKey.containsKey(k)) continue;
        final s = entry.value;
        await db.into(db.schedules).insert(
              SchedulesCompanion.insert(
                doctorId: doctorId,
                date: date,
                startTime: s.start,
                endTime: s.end,
                isBooked: const drift.Value(false),
              ),
            );
      }

      // delete removed (only if not booked)
      for (final r in existing) {
        final k = '${r.startTime}-${r.endTime}';
        if (desired.containsKey(k)) continue;
        if (r.isBooked) continue;
        await (db.delete(db.schedules)..where((x) => x.id.equals(r.id))).go();
      }
    });

    // reload selected day shifts
    await _loadSelectedDayShifts();
    await _loadGrid();
  }

  Future<void> _loadSelectedDayShifts() async {
    final d = selectedDoctor;
    if (d?.id == null) return;
    final date = _dateKey(selectedDate);
    final slots = await ScheduleController.instance.getSchedulesByDoctorAndDate(
      doctorId: d!.id!,
      date: date,
    );
    final set = slots.map((s) => '${s.startTime}-${s.endTime}').toSet();
    setState(() {
      for (final s in _shifts) {
        final k = '${s.start}-${s.end}';
        _shiftSelected[k] = set.contains(k);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PrecisionAdminShell(
      route: PrecisionAdminRoute.schedules,
      title: 'Xếp lịch',
      child: FutureBuilder<void>(
        future: _init,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) return const LinearProgressIndicator();
          final cols = _columns();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Triển khai: Khu B-4 | Khoa phẫu thuật'.toUpperCase(),
                style: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.2, color: Colors.black45),
              ),
              const SizedBox(height: 16),
              if (loading) const LinearProgressIndicator(),
              LayoutBuilder(
                builder: (context, c) {
                  final twoCol = c.maxWidth >= 980;
                  final left = Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: const [
                            BoxShadow(color: Color(0x0F1B3A4B), blurRadius: 40, offset: Offset(0, 16)),
                          ],
                          border: Border.all(color: const Color(0xFFE1E3E4)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.edit_calendar, color: Color(0xFF006A62)),
                                const SizedBox(width: 8),
                                Text('PHÂN BỔ MỚI', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Text('CHỌN BÁC SĨ', style: GoogleFonts.manrope(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.6, color: Colors.black54)),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<Doctor>(
                              initialValue: selectedDoctor,
                              items: _doctors.map((d) => DropdownMenuItem(value: d, child: Text('${d.name} (${d.specialty})'))).toList(),
                              onChanged: (d) => setState(() => selectedDoctor = d),
                              decoration: const InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.zero), isDense: true),
                            ),
                            const SizedBox(height: 14),
                            Text('NGÀY ÁP DỤNG', style: GoogleFonts.manrope(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.6, color: Colors.black54)),
                            const SizedBox(height: 8),
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14)),
                              onPressed: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  firstDate: DateTime.now().subtract(const Duration(days: 30)),
                                  lastDate: DateTime.now().add(const Duration(days: 365)),
                                  initialDate: selectedDate,
                                );
                                if (picked == null) return;
                                setState(() => selectedDate = picked);
                                await _loadGrid();
                              },
                              child: Row(
                                children: [
                                  Expanded(child: Text(_dateKey(selectedDate), style: GoogleFonts.manrope(fontWeight: FontWeight.w800))),
                                  const Icon(Icons.calendar_today_outlined, size: 18),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text('CHỌN CA LÀM VIỆC', style: GoogleFonts.manrope(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.6, color: Colors.black54)),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 10,
                              runSpacing: 10,
                              children: [
                                for (final s in _shifts)
                                  _ShiftChip(
                                    label: s.label,
                                    time: '${s.start} - ${s.end}',
                                    selected: _shiftSelected['${s.start}-${s.end}'] == true,
                                    onTap: () {
                                      final k = '${s.start}-${s.end}';
                                      setState(() => _shiftSelected[k] = !(_shiftSelected[k] ?? false));
                                    },
                                  ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Text('PHÂN BỔ TÀI NGUYÊN', style: GoogleFonts.manrope(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.6, color: Colors.black54)),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                for (final r in resources)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    color: const Color(0xFF70F8E8).withValues(alpha: 0.6),
                                    child: Text(r, style: GoogleFonts.manrope(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.2, color: const Color(0xFF005049))),
                                  ),
                                InkWell(
                                  onTap: () {},
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    color: const Color(0xFFE7E8E9),
                                    child: Text('+ THÊM KHU', style: GoogleFonts.manrope(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.2, color: Colors.black54)),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF006A62),
                                  foregroundColor: Colors.white,
                                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                                onPressed: _commitSchedule,
                                child: Text('LƯU LỊCH', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900, letterSpacing: 1.4)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: const BoxDecoration(
                          color: Color(0xFF012435),
                          boxShadow: [BoxShadow(color: Color(0x0F1B3A4B), blurRadius: 40, offset: Offset(0, 16))],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(child: Text('HIỆU SUẤT HỆ THỐNG', style: GoogleFonts.spaceGrotesk(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 0.6))),
                                const Icon(Icons.analytics_outlined, color: Color(0xFF70F8E8)),
                              ],
                            ),
                            const SizedBox(height: 14),
                            _UtilBar(label: 'Tải nhân sự', value: 0.84, color: const Color(0xFF006A62)),
                            const SizedBox(height: 12),
                            _UtilBar(label: 'Băng thông khẩn cấp', value: 0.12, color: const Color(0xFFE48B00)),
                          ],
                        ),
                      ),
                    ],
                  );

                  final right = Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: const [BoxShadow(color: Color(0x0F1B3A4B), blurRadius: 40, offset: Offset(0, 16))],
                      border: Border.all(color: const Color(0xFFE1E3E4)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(18),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'LƯỚI LỊCH HIỆN TẠI',
                                  style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900, letterSpacing: 0.6),
                                ),
                              ),
                              _ToggleBtn(label: 'TUẦN', active: !monthMode, onTap: () => setState(() => monthMode = false)),
                              const SizedBox(width: 8),
                              _ToggleBtn(
                                label: 'THÁNG',
                                active: monthMode,
                                onTap: () async {
                                  setState(() => monthMode = true);
                                  await _loadGrid();
                                },
                              ),
                            ],
                          ),
                        ),
                        Container(height: 1, color: const Color(0xFFE7E8E9)),
                        if (!monthMode)
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              headingRowColor: WidgetStateProperty.all(const Color(0xFFE1E3E4).withValues(alpha: 0.35)),
                              columns: [
                                const DataColumn(label: _Th('PROVIDER')),
                                for (final d in cols) DataColumn(label: _Th(_colLabel(d))),
                              ],
                              rows: _doctors.take(8).map((doc) {
                                return DataRow(
                                  cells: [
                                    DataCell(_ProviderCell(doc: doc)),
                                    for (final day in cols)
                                      DataCell(
                                        _WeekCell(
                                          schedules: (_week['${doc.id}|${_dateKey(day)}'] ?? const <Schedule>[]),
                                        ),
                                      ),
                                  ],
                                );
                              }).toList(),
                            ),
                          )
                        else
                          _MonthCalendar(
                            month: DateTime(selectedDate.year, selectedDate.month),
                            selected: selectedDate,
                            counts: _monthCounts,
                            onPick: (d) async {
                              setState(() => selectedDate = d);
                              await _loadSelectedDayShifts();
                              await _loadGrid();
                            },
                          ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _LegendDot(color: const Color(0xFF006A62), label: 'STANDARD DUTY'),
                              const SizedBox(width: 22),
                              _LegendDot(color: const Color(0xFFE48B00), label: 'ON CALL / CRITICAL'),
                              const SizedBox(width: 22),
                              Row(
                                children: [
                                  Icon(Icons.block, size: 16, color: Colors.black38),
                                  const SizedBox(width: 6),
                                  Text('LEAVE / RESTRICTED', style: GoogleFonts.manrope(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.2, color: Colors.black54)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );

                  if (!twoCol) {
                    return Column(
                      children: [
                        left,
                        const SizedBox(height: 16),
                        right,
                      ],
                    );
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(width: 420, child: left),
                      const SizedBox(width: 18),
                      Expanded(child: right),
                    ],
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

String _colLabel(DateTime d) {
  const w = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
  final wd = w[d.weekday - 1];
  return '$wd ${d.day}';
}

class _ToggleBtn extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _ToggleBtn({required this.label, required this.active, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF012435) : const Color(0xFFF3F4F5),
          borderRadius: BorderRadius.zero,
        ),
        child: Text(
          label,
          style: GoogleFonts.manrope(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.4,
            color: active ? Colors.white : const Color(0xFF012435),
          ),
        ),
      ),
    );
  }
}

class _ProviderCell extends StatelessWidget {
  final Doctor doc;
  const _ProviderCell({required this.doc});
  @override
  Widget build(BuildContext context) {
    final initials = _initials(doc.name);
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          color: const Color(0xFF1B3A4B),
          child: Text(initials, style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900, color: const Color(0xFF85A4B8))),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(doc.name.toUpperCase(), style: GoogleFonts.spaceGrotesk(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.3)),
            Text(doc.specialty.toUpperCase(), style: GoogleFonts.manrope(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.6, color: Colors.black45)),
          ],
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 8, height: 8, color: color),
        const SizedBox(width: 8),
        Text(label, style: GoogleFonts.manrope(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.2, color: Colors.black54)),
      ],
    );
  }
}

class _UtilBar extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  const _UtilBar({required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(label.toUpperCase(), style: GoogleFonts.manrope(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.6, color: Colors.white.withValues(alpha: 0.75)))),
            Text('${(value * 100).round()}%', style: GoogleFonts.manrope(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.6, color: Colors.white.withValues(alpha: 0.75))),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          height: 4,
          color: Colors.white.withValues(alpha: 0.10),
          child: Align(
            alignment: Alignment.centerLeft,
            child: FractionallySizedBox(widthFactor: value.clamp(0, 1), child: Container(color: color)),
          ),
        ),
      ],
    );
  }
}

class _Shift {
  final String label;
  final String start;
  final String end;
  const _Shift(this.label, this.start, this.end);
}

class _DayCount {
  final int total;
  final int booked;
  const _DayCount({required this.total, required this.booked});
}

class _ShiftChip extends StatelessWidget {
  final String label;
  final String time;
  final bool selected;
  final VoidCallback onTap;
  const _ShiftChip({
    required this.label,
    required this.time,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = selected ? const Color(0xFF006A62).withValues(alpha: 0.10) : const Color(0xFFF3F4F5);
    final border = selected ? const Color(0xFF006A62) : const Color(0xFFE1E3E4);
    final fg = selected ? const Color(0xFF006A62) : Colors.black54;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(color: bg, border: Border.all(color: border), borderRadius: BorderRadius.zero),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label.toUpperCase(), style: GoogleFonts.manrope(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.2, color: fg)),
            const SizedBox(height: 4),
            Text(time, style: GoogleFonts.manrope(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.black87)),
          ],
        ),
      ),
    );
  }
}

class _WeekCell extends StatelessWidget {
  final List<Schedule> schedules;
  const _WeekCell({required this.schedules});

  @override
  Widget build(BuildContext context) {
    if (schedules.isEmpty) {
      return Center(child: Icon(Icons.block, color: Colors.black26));
    }
    // ưu tiên hiển thị 1 block giống thiết kế, còn lại show "+n"
    final first = schedules.first;
    final accent = first.isBooked ? const Color(0xFF006A62) : const Color(0xFFE48B00);
    final title = first.isBooked ? '${first.startTime} - ${first.endTime}' : 'ON CALL';
    final sub = first.isBooked ? 'Clinic' : 'Remote';
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: accent.withValues(alpha: 0.06), border: Border(left: BorderSide(color: accent, width: 2))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.manrope(fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1.1, color: accent)),
                const SizedBox(height: 4),
                Text(sub, style: GoogleFonts.manrope(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.black54)),
              ],
            ),
          ),
        ),
        if (schedules.length > 1) ...[
          const SizedBox(width: 8),
          Text('+${schedules.length - 1}', style: GoogleFonts.manrope(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.black45)),
        ],
      ],
    );
  }
}

class _MonthCalendar extends StatelessWidget {
  final DateTime month; // first day-of-month
  final DateTime selected;
  final Map<String, _DayCount> counts;
  final ValueChanged<DateTime> onPick;

  const _MonthCalendar({
    required this.month,
    required this.selected,
    required this.counts,
    required this.onPick,
  });

  String _key(DateTime d) => '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final first = DateTime(month.year, month.month, 1);
    final next = DateTime(month.year, month.month + 1, 1);
    final daysInMonth = next.subtract(const Duration(days: 1)).day;
    final startWeekday = first.weekday; // 1..7
    final cells = <DateTime?>[];
    for (int i = 1; i < startWeekday; i++) {
      cells.add(null);
    }
    for (int d = 1; d <= daysInMonth; d++) {
      cells.add(DateTime(month.year, month.month, d));
    }
    while (cells.length % 7 != 0) {
      cells.add(null);
    }

    return Padding(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'THÁNG ${month.month}/${month.year}',
            style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w900, letterSpacing: 0.6),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: cells.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, mainAxisSpacing: 8, crossAxisSpacing: 8),
            itemBuilder: (context, i) {
              final d = cells[i];
              if (d == null) return const SizedBox.shrink();
              final k = _key(d);
              final c = counts[k] ?? const _DayCount(total: 0, booked: 0);
              final isSel = d.year == selected.year && d.month == selected.month && d.day == selected.day;
              return InkWell(
                onTap: () => onPick(d),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSel ? const Color(0xFF012435) : const Color(0xFFF3F4F5),
                    border: Border.all(color: isSel ? const Color(0xFF012435) : const Color(0xFFE1E3E4)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${d.day}', style: GoogleFonts.manrope(fontWeight: FontWeight.w900, color: isSel ? Colors.white : const Color(0xFF012435))),
                      const Spacer(),
                      Text(
                        '${c.booked}/${c.total} ca',
                        style: GoogleFonts.manrope(fontSize: 10, fontWeight: FontWeight.w900, color: isSel ? Colors.white70 : Colors.black45),
                      ),
                    ],
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

class PrecisionAppointmentManagementPage extends StatefulWidget {
  const PrecisionAppointmentManagementPage({super.key});

  @override
  State<PrecisionAppointmentManagementPage> createState() => _PrecisionAppointmentManagementPageState();
}

class _PrecisionAppointmentManagementPageState extends State<PrecisionAppointmentManagementPage> {
  String filter = 'all';
  String query = '';
  int page = 1;
  static const int _pageSize = 10;
  late Future<List<AppointmentDetails>> _future;

  @override
  void initState() {
    super.initState();
    _future = AppointmentController.instance.getAllAppointmentsDetails();
  }

  Future<void> _reload() async {
    setState(() {
      _future = AppointmentController.instance.getAllAppointmentsDetails();
    });
  }

  Future<_ApptStats> _loadStats() async {
    final db = DbHelper.instance.db;
    final appts = await (db.select(db.appointments)).get();
    final now = DateTime.now();
    final todayKey =
        '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    final todaySlots = await (db.select(db.schedules)..where((s) => s.date.equals(todayKey))).get();
    final bookedToday = todaySlots.where((s) => s.isBooked).length;
    final capacity = todaySlots.isEmpty ? 0.0 : (bookedToday / todaySlots.length);

    final confirmed = appts.where((a) => a.status == 'confirmed').length;
    final pending = appts.where((a) => a.status == 'pending').length;

    // Clinicians active: distinct doctorId trong các appointment hôm nay (theo createdAt)
    final activeDoctorIds = <int>{};
    for (final a in appts) {
      try {
        final t = DateTime.parse(a.createdAt);
        if (t.year == now.year && t.month == now.month && t.day == now.day) {
          activeDoctorIds.add(a.doctorId);
        }
      } catch (_) {}
    }

    return _ApptStats(
      capacityPercent: (capacity * 100).clamp(0, 100).toDouble(),
      confirmed: confirmed,
      pending: pending,
      cliniciansActive: activeDoctorIds.length,
    );
  }

  Future<void> _viewDetails(AppointmentDetails d) async {
    final a = d.appointment;
    await showDialog<void>(
      context: context,
      builder: (context) {
        return Dialog(
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Hồ sơ lịch hẹn',
                          style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: -0.2),
                        ),
                      ),
                      IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _detailRow('Bệnh nhân', d.userName.isNotEmpty ? d.userName : 'USER #${a.userId}'),
                  _detailRow('Bác sĩ', d.doctorName),
                  _detailRow('Khoa', d.specialty),
                  _detailRow('Slot', '${d.startTime} - ${d.endTime}'),
                  _detailRow('Ngày', d.date),
                  _detailRow('Trạng thái', a.status),
                  const SizedBox(height: 10),
                  Text('Triệu chứng', style: GoogleFonts.manrope(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F5),
                      border: Border.all(color: const Color(0xFFE1E3E4)),
                      borderRadius: BorderRadius.zero,
                    ),
                    child: Text(a.symptom, style: GoogleFonts.manrope()),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Đóng')),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _detailRow(String k, String v) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(k.toUpperCase(), style: GoogleFonts.manrope(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.4, color: Colors.black45)),
          ),
          Expanded(child: Text(v, style: GoogleFonts.manrope(fontWeight: FontWeight.w800))),
        ],
      ),
    );
  }

  bool _matchesQuery(AppointmentDetails d) {
    if (query.trim().isEmpty) return true;
    final q = query.trim().toLowerCase();
    return d.userName.toLowerCase().contains(q) ||
        d.doctorName.toLowerCase().contains(q) ||
        d.specialty.toLowerCase().contains(q) ||
        d.date.toLowerCase().contains(q) ||
        d.startTime.toLowerCase().contains(q);
  }

  @override
  Widget build(BuildContext context) {
    return PrecisionAdminShell(
      route: PrecisionAdminRoute.appointments,
      title: 'Quản lý lịch khám',
      child: FutureBuilder<List<AppointmentDetails>>(
        future: _future,
        builder: (context, snap) {
          if (!snap.hasData) return const LinearProgressIndicator();
          final all = snap.data!;
          final items = all
              .where((d) => filter == 'all' ? true : d.appointment.status == filter)
              .where(_matchesQuery)
              .toList();

          final totalPages = (items.length / _pageSize).ceil().clamp(1, 9999);
          if (page > totalPages) page = totalPages;
          final start = (page - 1) * _pageSize;
          final end = (start + _pageSize).clamp(0, items.length);
          final pageItems = items.sublist(start, end);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Theo dõi và quản lý lịch khám theo thời gian thực.',
                style: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 0.8, color: Colors.black45),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  SizedBox(
                    width: 360,
                    child: TextField(
                      onChanged: (v) => setState(() {
                        query = v;
                        page = 1;
                      }),
                      decoration: InputDecoration(
                        hintText: 'TÌM KIẾM (bệnh nhân / bác sĩ / ngày / giờ)...',
                        border: const OutlineInputBorder(borderRadius: BorderRadius.zero),
                        isDense: true,
                        prefixIcon: const Icon(Icons.search),
                      ),
                    ),
                  ),
                  _FilterBtn(label: 'TẤT CẢ', active: filter == 'all', onTap: () => setState(() { filter = 'all'; page = 1; })),
                  _FilterBtn(label: 'ĐÃ XÁC NHẬN', active: filter == 'confirmed', onTap: () => setState(() { filter = 'confirmed'; page = 1; })),
                  _FilterBtn(label: 'CHỜ XÁC NHẬN', active: filter == 'pending', onTap: () => setState(() { filter = 'pending'; page = 1; })),
                  _FilterBtn(label: 'ĐÃ HỦY', active: filter == 'cancelled', onTap: () => setState(() { filter = 'cancelled'; page = 1; })),
                  IconButton(onPressed: _reload, icon: const Icon(Icons.refresh)),
                ],
              ),
              const SizedBox(height: 16),
              FutureBuilder<_ApptStats>(
                future: _loadStats(),
                builder: (context, s) {
                  if (!s.hasData) return const LinearProgressIndicator();
                  final st = s.data!;
                  return LayoutBuilder(
                    builder: (context, c) {
                      final w = c.maxWidth;
                      final tileW = w >= 1000 ? (w - 18) / 4 : 260.0;
                      return Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          _MiniStat(
                            width: tileW,
                            label: 'Công suất ngày',
                            value: '${st.capacityPercent.toStringAsFixed(0)}%',
                            icon: Icons.speed,
                            accent: const Color(0xFF012435),
                            variant: _MiniStatVariant.plain,
                          ),
                          _MiniStat(
                            width: tileW,
                            label: 'Đã xác nhận',
                            value: '${st.confirmed}',
                            icon: Icons.verified,
                            accent: const Color(0xFF006A62),
                            variant: _MiniStatVariant.secondary,
                          ),
                          _MiniStat(
                            width: tileW,
                            label: 'Chờ xác nhận',
                            value: '${st.pending}',
                            icon: Icons.pending_actions,
                            accent: const Color(0xFFFFB86B),
                            variant: _MiniStatVariant.tertiary,
                          ),
                          _MiniStat(
                            width: tileW,
                            label: 'Clinicians Active',
                            value: '${st.cliniciansActive}',
                            icon: Icons.badge,
                            accent: const Color(0xFF012435),
                            variant: _MiniStatVariant.plain,
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
              _ApptTable(
                items: pageItems,
                zebraStartOdd: false,
                onView: _viewDetails,
                onConfirm: (d) async {
                  final a = d.appointment;
                  if (a.id == null || a.status == 'confirmed') return;
                  try {
                    await AppointmentController.instance.confirmAppointment(a.id!);
                    await _reload();
                  } catch (e) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Không xác nhận được: $e')),
                    );
                  }
                },
                onCancel: (d) async {
                  final a = d.appointment;
                  if (a.status == 'cancelled') return;
                  final ok = await showAppConfirmDialog(
                    context,
                    title: 'Hủy lịch hẹn?',
                    message: 'Bạn chắc chắn muốn hủy lịch hẹn của "${d.userName.isNotEmpty ? d.userName : 'USER #${a.userId}'}" với ${d.doctorName} (${d.date} ${d.startTime})?',
                    confirmText: 'HỦY LỊCH',
                    cancelText: 'GIỮ LẠI',
                  );
                  if (!ok) return;
                  try {
                    await AppointmentController.instance.cancelAppointment(a);
                    await _reload();
                  } catch (e) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Không hủy được: $e')),
                    );
                  }
                },
                onDelete: (d) async {
                  final a = d.appointment;
                  if (a.id == null) return;
                  final ok = await showAppConfirmDialog(
                    context,
                    title: 'Xóa lịch sử?',
                    message: 'Bạn chắc chắn muốn xóa lịch hẹn này khỏi lịch sử? Hành động này không thể hoàn tác.',
                    confirmText: 'XÓA',
                    cancelText: 'HỦY',
                  );
                  if (!ok) return;
                  try {
                    await AppointmentController.instance.deleteAppointment(a.id!);
                    await _reload();
                  } catch (e) {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Không xóa được: $e')),
                    );
                  }
                },
              ),
              const SizedBox(height: 10),
              _Pager(
                page: page,
                totalPages: totalPages,
                totalRecords: items.length,
                from: items.isEmpty ? 0 : start + 1,
                to: end,
                onPrev: page <= 1 ? null : () => setState(() => page--),
                onNext: page >= totalPages ? null : () => setState(() => page++),
                onGo: (p) => setState(() => page = p),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ApptStats {
  final double capacityPercent;
  final int confirmed;
  final int pending;
  final int cliniciansActive;
  _ApptStats({
    required this.capacityPercent,
    required this.confirmed,
    required this.pending,
    required this.cliniciansActive,
  });
}

enum _MiniStatVariant { plain, secondary, tertiary }

class _MiniStat extends StatelessWidget {
  final double width;
  final String label;
  final String value;
  final IconData icon;
  final Color accent;
  final _MiniStatVariant variant;

  const _MiniStat({
    required this.width,
    required this.label,
    required this.value,
    required this.icon,
    required this.accent,
    required this.variant,
  });

  @override
  Widget build(BuildContext context) {
    final border = variant == _MiniStatVariant.secondary
        ? const Border(bottom: BorderSide(color: Color(0xFF006A62), width: 2))
        : variant == _MiniStatVariant.tertiary
            ? const Border(bottom: BorderSide(color: Color(0xFFFFB86B), width: 2))
            : null;

    return Container(
      width: width,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        border: border,
        boxShadow: const [
          BoxShadow(color: Color(0x0F1B3A4B), blurRadius: 40, offset: Offset(0, 16)),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: 0,
            bottom: 0,
            child: Opacity(opacity: 0.10, child: Icon(icon, size: 56, color: accent)),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: GoogleFonts.manrope(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2, color: Colors.black38),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: variant == _MiniStatVariant.secondary
                      ? const Color(0xFF006A62)
                      : variant == _MiniStatVariant.tertiary
                          ? const Color(0xFF683D00)
                          : const Color(0xFF012435),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ApptTable extends StatelessWidget {
  final List<AppointmentDetails> items;
  final bool zebraStartOdd;
  final void Function(AppointmentDetails) onView;
  final void Function(AppointmentDetails) onConfirm;
  final void Function(AppointmentDetails) onCancel;
  final void Function(AppointmentDetails) onDelete;

  const _ApptTable({
    required this.items,
    required this.zebraStartOdd,
    required this.onView,
    required this.onConfirm,
    required this.onCancel,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: const [
          BoxShadow(color: Color(0x0F1B3A4B), blurRadius: 40, offset: Offset(0, 16)),
        ],
        border: Border.all(color: const Color(0xFFE1E3E4)),
      ),
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: WidgetStateProperty.all(const Color(0xFFE1E3E4).withValues(alpha: 0.35)),
              columns: const [
                DataColumn(label: _Th('PATIENT PROFILE')),
                DataColumn(label: _Th('ASSIGNED CLINICIAN')),
                DataColumn(label: _Th('TEMPORAL SLOT')),
                DataColumn(label: _Th('INTEGRITY STATUS')),
                DataColumn(label: _Th('SYSTEM ACTIONS', right: true), numeric: true),
              ],
              rows: items.asMap().entries.map((e) {
                final i = e.key;
                final d = e.value;
                final a = d.appointment;
                final alt = (zebraStartOdd ? i.isEven : i.isOdd);

                final initials = _initials(d.userName.isNotEmpty ? d.userName : 'U${a.userId}');
                final patientId = '#PX-${a.userId.toString().padLeft(5, '0')}';

                final timeLabel = _time12h(d.startTime);
                final dateLabel = _datePretty(d.date);

                final canAct = a.status != 'cancelled';
                final confirmVisible = a.status == 'pending';

                return DataRow(
                  color: WidgetStateProperty.all(alt ? const Color(0xFFF3F4F5) : Colors.white),
                  cells: [
                    DataCell(
                      Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: alt ? const Color(0xFFE1E3E4) : const Color(0xFF1B3A4B),
                              borderRadius: BorderRadius.zero,
                            ),
                            child: Text(
                              initials,
                              style: GoogleFonts.spaceGrotesk(
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                color: alt ? const Color(0xFF012435) : const Color(0xFF85A4B8),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                d.userName.isNotEmpty ? d.userName : 'USER #${a.userId}',
                                style: GoogleFonts.manrope(fontWeight: FontWeight.w900),
                              ),
                              Text(
                                'ID: $patientId',
                                style: GoogleFonts.manrope(fontSize: 10, color: Colors.black38, fontWeight: FontWeight.w800, letterSpacing: 0.4),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                    DataCell(
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(d.doctorName, style: GoogleFonts.manrope(fontWeight: FontWeight.w800)),
                          Text(d.specialty.toUpperCase(), style: GoogleFonts.manrope(fontSize: 10, color: const Color(0xFF006A62), fontWeight: FontWeight.w900, letterSpacing: 0.6)),
                        ],
                      ),
                    ),
                    DataCell(
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(timeLabel, style: GoogleFonts.manrope(fontWeight: FontWeight.w800)),
                          Text(dateLabel, style: GoogleFonts.manrope(fontSize: 10, color: Colors.black38, fontWeight: FontWeight.w800, letterSpacing: 0.6)),
                        ],
                      ),
                    ),
                    DataCell(_IntegrityPill(status: a.status)),
                    DataCell(
                      Align(
                        alignment: Alignment.centerRight,
                        child: confirmVisible
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  _ActionBtn(label: 'XÁC NHẬN', color: const Color(0xFF006A62), onTap: () => onConfirm(d)),
                                  const SizedBox(width: 8),
                                  _ActionBtn(label: 'HỦY', color: const Color(0xFF341C00), onTap: () => onCancel(d)),
                                ],
                              )
                            : Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed: () => onView(d),
                                    icon: const Icon(Icons.visibility_outlined),
                                    tooltip: 'View Details',
                                  ),
                                  if (canAct)
                                    IconButton(
                                      onPressed: () => onCancel(d),
                                      icon: const Icon(Icons.cancel_outlined),
                                      tooltip: 'Void Entry',
                                    )
                                  else
                                    IconButton(
                                      onPressed: () => onDelete(d),
                                      icon: const Icon(Icons.close),
                                      tooltip: 'Delete history',
                                    ),
                                ],
                              ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _Th extends StatelessWidget {
  final String t;
  final bool right;
  const _Th(this.t, {this.right = false});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: right ? 160 : null,
      child: Text(
        t,
        textAlign: right ? TextAlign.right : TextAlign.left,
        style: GoogleFonts.manrope(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.6, color: const Color(0xFF012435)),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionBtn({required this.label, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        elevation: 0,
      ),
      child: Text(
        label,
        style: GoogleFonts.manrope(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.6),
      ),
    );
  }
}

class _IntegrityPill extends StatelessWidget {
  final String status;
  const _IntegrityPill({required this.status});
  @override
  Widget build(BuildContext context) {
    Color fg;
    Color bg;
    bool pulse = false;
    if (status == 'confirmed') {
      fg = const Color(0xFF006A62);
      bg = fg.withValues(alpha: 0.10);
    } else if (status == 'pending') {
      fg = const Color(0xFF683D00);
      bg = fg.withValues(alpha: 0.10);
      pulse = true;
    } else {
      fg = const Color(0xFFBA1A1A);
      bg = fg.withValues(alpha: 0.10);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(color: bg, border: Border.all(color: fg.withValues(alpha: 0.22)), borderRadius: BorderRadius.zero),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: fg, borderRadius: BorderRadius.circular(99)),
          ),
          if (pulse) ...[
            const SizedBox(width: 0),
          ],
          const SizedBox(width: 8),
          Text(status.toUpperCase(), style: GoogleFonts.manrope(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.4, color: fg)),
        ],
      ),
    );
  }
}

class _Pager extends StatelessWidget {
  final int page;
  final int totalPages;
  final int totalRecords;
  final int from;
  final int to;
  final VoidCallback? onPrev;
  final VoidCallback? onNext;
  final void Function(int) onGo;

  const _Pager({
    required this.page,
    required this.totalPages,
    required this.totalRecords,
    required this.from,
    required this.to,
    required this.onPrev,
    required this.onNext,
    required this.onGo,
  });

  @override
  Widget build(BuildContext context) {
    final buttons = <int>[
      page,
      if (page + 1 <= totalPages) page + 1,
      if (page + 2 <= totalPages) page + 2,
    ];
    final visible = buttons.toSet().toList()..sort();
    return Row(
      children: [
        Text(
          'Showing $from-$to of $totalRecords records'.toUpperCase(),
          style: GoogleFonts.manrope(fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 1.2, color: Colors.black38),
        ),
        const Spacer(),
        _NavSquare(icon: Icons.chevron_left, active: onPrev != null, onTap: onPrev),
        const SizedBox(width: 6),
        ...visible.map((p) => Padding(
              padding: const EdgeInsets.only(right: 6),
              child: _PageSquare(page: p, active: p == page, onTap: () => onGo(p)),
            )),
        _NavSquare(icon: Icons.chevron_right, active: onNext != null, onTap: onNext),
      ],
    );
  }
}

class _NavSquare extends StatelessWidget {
  final IconData icon;
  final bool active;
  final VoidCallback? onTap;
  const _NavSquare({required this.icon, required this.active, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFC2C7CC).withValues(alpha: 0.55)),
          borderRadius: BorderRadius.zero,
        ),
        child: Icon(icon, size: 18, color: active ? const Color(0xFF012435) : Colors.black26),
      ),
    );
  }
}

class _PageSquare extends StatelessWidget {
  final int page;
  final bool active;
  final VoidCallback onTap;
  const _PageSquare({required this.page, required this.active, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? const Color(0xFF012435) : Colors.white,
          border: Border.all(color: const Color(0xFFC2C7CC).withValues(alpha: 0.55)),
          borderRadius: BorderRadius.zero,
        ),
        child: Text(
          '$page',
          style: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.w900, color: active ? Colors.white : const Color(0xFF012435)),
        ),
      ),
    );
  }
}

String _initials(String name) {
  final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
  if (parts.isEmpty) return 'U';
  final a = parts.first.characters.first.toUpperCase();
  final b = parts.length >= 2 ? parts.last.characters.first.toUpperCase() : '';
  return '$a$b';
}

String _time12h(String hhmm) {
  final m = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(hhmm.trim());
  if (m == null) return hhmm;
  int h = int.tryParse(m.group(1)!) ?? 0;
  final mm = m.group(2)!;
  final am = h < 12;
  final h12 = h % 12 == 0 ? 12 : h % 12;
  return '${h12.toString().padLeft(2, '0')}:$mm ${am ? 'AM' : 'PM'}';
}

String _datePretty(String yyyyMmDd) {
  try {
    final d = DateTime.parse(yyyyMmDd);
    const months = ['JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG','SEP','OCT','NOV','DEC'];
    return '${months[d.month - 1]} ${d.day.toString().padLeft(2, '0')}, ${d.year}';
  } catch (_) {
    return yyyyMmDd;
  }
}

class _Kpi extends StatelessWidget {
  final String label;
  final String value;
  final Color borderColor;
  final String? foot;
  final Color? footColor;
  final IconData? icon;
  final List<double>? spark;

  const _Kpi({
    required this.label,
    required this.value,
    required this.borderColor,
    this.foot,
    this.footColor,
    this.icon,
    this.spark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(left: BorderSide(color: borderColor, width: 4)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1B3A4B).withValues(alpha: 0.06),
            blurRadius: 40,
            offset: const Offset(0, 16),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.manrope(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                    color: Colors.black.withValues(alpha: 0.45),
                  ),
                ),
              ),
              if (icon != null)
                Icon(icon, size: 18, color: const Color(0xFF012435).withValues(alpha: 0.35)),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 34,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF012435),
            ),
          ),
          if (spark != null && (spark?.isNotEmpty ?? false)) ...[
            const SizedBox(height: 10),
            SizedBox(height: 38, child: CustomPaint(painter: _SparkPainter(values: spark!), child: const SizedBox.expand())),
          ],
          if (foot != null) ...[
            const SizedBox(height: 10),
            Text(
              foot!,
              style: GoogleFonts.manrope(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: (footColor ?? const Color(0xFF006A62)).withValues(alpha: 0.95),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SparkPainter extends CustomPainter {
  final List<double> values;
  _SparkPainter({required this.values});

  @override
  void paint(Canvas canvas, Size size) {
    final bg = Paint()..color = const Color(0xFFF3F4F5);
    canvas.drawRect(Offset.zero & size, bg);

    if (values.isEmpty) return;
    final maxV = values.reduce((a, b) => a > b ? a : b);
    final minV = values.reduce((a, b) => a < b ? a : b);
    final range = (maxV - minV).abs() < 1e-6 ? 1.0 : (maxV - minV);

    final bars = 7;
    final step = (values.length / bars).ceil().clamp(1, values.length);
    final sampled = <double>[];
    for (int i = 0; i < values.length; i += step) {
      sampled.add(values[i]);
      if (sampled.length >= bars) break;
    }
    while (sampled.length < bars) {
      sampled.add(sampled.isEmpty ? 0 : sampled.last);
    }

    final w = size.width / (bars * 1.2);
    final gap = w * 0.2;
    final base = size.height;
    for (int i = 0; i < bars; i++) {
      final v = sampled[i];
      final h = ((v - minV) / range) * (size.height * 0.9) + 2;
      final x = i * (w + gap);
      final r = Rect.fromLTWH(x, base - h, w, h);
      final p = Paint()..color = const Color(0xFF006A62).withValues(alpha: 0.18 + (i / (bars * 8)));
      canvas.drawRect(r, p);
    }
  }

  @override
  bool shouldRepaint(covariant _SparkPainter oldDelegate) => oldDelegate.values != values;
}

class _FilterBtn extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _FilterBtn({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        backgroundColor: active ? const Color(0xFF012435) : Colors.transparent,
        foregroundColor: active ? Colors.white : Colors.black.withValues(alpha: 0.55),
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      child: Text(
        label,
        style: GoogleFonts.manrope(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 2,
        ),
      ),
    );
  }
}

class _Table extends StatelessWidget {
  final List<String> headers;
  final List<_RowData> rows;

  const _Table({required this.headers, required this.rows});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1B3A4B).withValues(alpha: 0.06),
            blurRadius: 40,
            offset: const Offset(0, 16),
          )
        ],
      ),
      child: Column(
        children: [
          Container(
            color: const Color(0xFFEDEEEF),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: headers
                  .map(
                    (h) => Expanded(
                      child: Text(
                        h,
                        style: GoogleFonts.manrope(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.8,
                          color: Colors.black.withValues(alpha: 0.55),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          ...rows.map((r) => _TableRow(cells: r.cells)).toList(),
        ],
      ),
    );
  }
}

class _RowData {
  final List<Widget> cells;
  _RowData({required this.cells});
}

class _TableRow extends StatelessWidget {
  final List<Widget> cells;
  const _TableRow({required this.cells});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: const Color(0xFFC2C7CC).withValues(alpha: 0.30)),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: cells.map((c) => Expanded(child: c)).toList(),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String status;
  const _StatusPill({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    switch (status) {
      case 'confirmed':
        bg = const Color(0xFF006A62).withValues(alpha: 0.12);
        fg = const Color(0xFF006A62);
        break;
      case 'cancelled':
        bg = Colors.red.withValues(alpha: 0.10);
        fg = Colors.red.shade700;
        break;
      case 'booked':
        bg = const Color(0xFFF99A15).withValues(alpha: 0.15);
        fg = const Color(0xFF683D00);
        break;
      case 'open':
        bg = const Color(0xFF70F8E8).withValues(alpha: 0.18);
        fg = const Color(0xFF005049);
        break;
      default:
        bg = const Color(0xFFF99A15).withValues(alpha: 0.12);
        fg = const Color(0xFF683D00);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: fg.withValues(alpha: 0.15)),
      ),
      child: Text(
        status.toUpperCase(),
        style: GoogleFonts.manrope(
          fontSize: 10,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.6,
          color: fg,
        ),
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
  late final TextEditingController specs;
  late final TextEditingController exp;
  late final TextEditingController desc;
  late final TextEditingController image;
  String pickedImage = '';

  @override
  void initState() {
    super.initState();
    name = TextEditingController(text: widget.initial?.name ?? '');
    specialty = TextEditingController(text: widget.initial?.specialty ?? '');
    specs = TextEditingController(text: (widget.initial?.specializations ?? const []).join(', '));
    exp = TextEditingController(text: '${widget.initial?.experience ?? 0}');
    desc = TextEditingController(text: widget.initial?.description ?? '');
    image = TextEditingController(text: widget.initial?.image ?? '');
    pickedImage = image.text.trim();
  }

  @override
  void dispose() {
    name.dispose();
    specialty.dispose();
    specs.dispose();
    exp.dispose();
    desc.dispose();
    image.dispose();
    super.dispose();
  }

  List<String> _parseSpecs(String raw) {
    return raw
        .split(RegExp(r'[,\n|]+'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList(growable: false);
  }

  Future<void> _pickImageFromDevice() async {
    final res = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );
    final file = res?.files.single;
    final bytes = file?.bytes;
    if (bytes != null) {
      // Web-friendly: lưu data-uri trực tiếp vào DB (DoctorImage hỗ trợ)
      final ext = (file?.extension ?? 'png').toLowerCase();
      final mime = ext == 'jpg' || ext == 'jpeg' ? 'image/jpeg' : 'image/png';
      final b64 = base64Encode(bytes);
      final dataUri = 'data:$mime;base64,$b64';
      setState(() {
        pickedImage = dataUri;
        image.text = dataUri;
      });
      return;
    }

    // Desktop/mobile fallback: lưu path nếu có
    final path = file?.path;
    if (path == null || path.trim().isEmpty) return;
    setState(() {
      pickedImage = path.trim();
      image.text = path.trim();
    });
  }

  @override
  Widget build(BuildContext context) {
    const defaults = <String>[
      // Ảnh từ thiết kế cũ (đảm bảo hiển thị)
      'https://lh3.googleusercontent.com/aida-public/AB6AXuACxIl2BQtqmStUjBo1hH3_ZU3isctPoPOlKOtOI0Vmj1iIwbV7oYx2_ZLLVYo6VLVHcuqslIP1HIV6l46lyxMQpe1ebenVOh4q1CKXpFYjtYMPlA1ein57VpPeEShPP9T8apABS8pG2y1RuNKsECAXb90G3DhXViRCQgRopuJiooAjQPzAYCh_PBgtVBz7hFvxcjqNniBYko4-uO1wFPA5bVitNaRV4fVznlu05D_kTmw_wgnJfCcBPLOSubGjw4evVUCrpmBLEnc',
      'https://lh3.googleusercontent.com/aida-public/AB6AXuAI3EhnM7K8H2AzHeJvtzCYy6yeXxtUcXaIXr54pRPmeWBN4OZya6Iuq4qduY7GQHg4HWm6JayE4Vg8hlfe2QZxe3W5N3lY2cte3M6Zs5x9lBV2XBtpGAVOsbgUgVim2AuomfXQXzubII7aS-LQhLeHLr4r2X-fFI82P1m5pCNgxEOo4eURzcDMzzY9IxhDUSrJNh-_c4hawTJBWAhRdk5e0slitcfZfu4RELeuyc7zDOh-lrnpZrJikP2XDMvlChhb0xWLCrg5lLc',
      'https://lh3.googleusercontent.com/aida-public/AB6AXuAoYJVAa1lW6LB6w8uSaep9p3Dt_infnhy8lENKMdjX1h2tRwwPiHteodgBsI6-FysNuST7MGayhprCPZR-97UBABdu1dI7nCJL4kOvPQcbP_RVUnNeb3uy5MYaqjgLcfe99OO_YvzUXfGoQ6CvgSfZ_9ngNLB5Vz1rV0dZYSf4cI86Df6OcBdlAVxom_ocECUlnL0VhI1OhwPRHdflV3xkZl6WWRb9ZnCYbLDdxHQtWNt9K3muBKHFx676VEFjjEZNt_g27oXeEO8',
    ];

    return Dialog(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 860),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.initial == null ? 'Thêm bác sĩ' : 'Chỉnh sửa bác sĩ',
                      style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w900),
                    ),
                  ),
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                ],
              ),
              const SizedBox(height: 12),
              LayoutBuilder(
                builder: (context, c) {
                  final isWide = c.maxWidth >= 760;
                  final left = Column(
                    children: [
                      TextField(
                        controller: name,
                        decoration: const InputDecoration(
                          labelText: 'Họ tên bác sĩ',
                          border: OutlineInputBorder(borderRadius: BorderRadius.zero),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: specialty,
                        decoration: const InputDecoration(
                          labelText: 'Chuyên khoa',
                          border: OutlineInputBorder(borderRadius: BorderRadius.zero),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: specs,
                        decoration: const InputDecoration(
                          labelText: 'Chuyên môn khám bệnh (cách nhau bởi dấu phẩy)',
                          border: OutlineInputBorder(borderRadius: BorderRadius.zero),
                        ),
                        maxLines: 2,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: exp,
                        decoration: const InputDecoration(
                          labelText: 'Kinh nghiệm (năm)',
                          border: OutlineInputBorder(borderRadius: BorderRadius.zero),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: desc,
                        decoration: const InputDecoration(
                          labelText: 'Mô tả',
                          border: OutlineInputBorder(borderRadius: BorderRadius.zero),
                        ),
                        maxLines: 3,
                      ),
                    ],
                  );

                  final right = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Ảnh hiển thị', style: GoogleFonts.manrope(fontWeight: FontWeight.w900)),
                      const SizedBox(height: 10),
                      Container(
                        height: 220,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFE1E3E4)),
                          color: const Color(0xFFF3F4F5),
                        ),
                        child: _DoctorImagePreview(path: pickedImage),
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        initialValue: defaults.contains(pickedImage) ? pickedImage : defaults.first,
                        items: defaults
                            .toList()
                            .asMap()
                            .entries
                            .map((e) => DropdownMenuItem(value: e.value, child: Text('Ảnh ${e.key + 1}')))
                            .toList(),
                        onChanged: (v) {
                          if (v == null) return;
                          setState(() {
                            pickedImage = v;
                            image.text = v;
                          });
                        },
                        decoration: const InputDecoration(
                          labelText: 'Chọn ảnh mặc định',
                          border: OutlineInputBorder(borderRadius: BorderRadius.zero),
                        ),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                        ),
                        onPressed: _pickImageFromDevice,
                        icon: const Icon(Icons.upload_file),
                        label: Text(
                          'CHỌN ẢNH TỪ MÁY',
                          style: GoogleFonts.manrope(fontWeight: FontWeight.w900, letterSpacing: 1.2, fontSize: 11),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: image,
                        decoration: const InputDecoration(
                          labelText: 'Đường dẫn tương đối (assets/...)',
                          border: OutlineInputBorder(borderRadius: BorderRadius.zero),
                        ),
                        onChanged: (v) => setState(() => pickedImage = v.trim()),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Nếu để trống sẽ dùng ảnh mặc định.',
                        style: GoogleFonts.manrope(fontSize: 11, color: Colors.black45),
                      ),
                    ],
                  );

                  if (!isWide) {
                    return Column(
                      children: [
                        left,
                        const SizedBox(height: 14),
                        right,
                      ],
                    );
                  }
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: left),
                      const SizedBox(width: 14),
                      SizedBox(width: 340, child: right),
                    ],
                  );
                },
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
                  const SizedBox(width: 10),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                      backgroundColor: const Color(0xFF006A62),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    ),
                    onPressed: () {
                      final parsed = int.tryParse(exp.text.trim()) ?? 0;
                      final img = image.text.trim().isEmpty ? defaults.first : image.text.trim();
                      Navigator.pop(
                        context,
                        Doctor(
                          id: widget.initial?.id,
                          name: name.text.trim(),
                          specialty: specialty.text.trim(),
                          specializations: _parseSpecs(specs.text),
                          experience: parsed,
                          description: desc.text.trim(),
                          image: img,
                        ),
                      );
                    },
                    child: Text(
                      'LƯU THAY ĐỔI',
                      style: GoogleFonts.manrope(fontWeight: FontWeight.w900, letterSpacing: 1.2, fontSize: 11),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DoctorImagePreview extends StatelessWidget {
  final String path;
  const _DoctorImagePreview({required this.path});

  @override
  Widget build(BuildContext context) {
    final p = path.trim();
    if (p.isEmpty) {
      return const Center(child: Icon(Icons.person, size: 64, color: Color(0xFF72787C)));
    }
    if (p.toLowerCase().endsWith('.svg')) {
      return Center(
        child: Text(
          p.split('/').last,
          style: GoogleFonts.manrope(fontWeight: FontWeight.w900, color: const Color(0xFF012435)),
        ),
      );
    }
    if (p.startsWith('http://') || p.startsWith('https://')) {
      return Image.network(p, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Center(child: Icon(Icons.broken_image)));
    }
    return Image.asset(p, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Center(child: Icon(Icons.broken_image)));
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
      title: const Text('Create slot'),
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
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: () => Navigator.pop(context, _SlotInput(start.text.trim(), end.text.trim())),
          child: const Text('Create'),
        ),
      ],
    );
  }
}


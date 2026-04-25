import 'package:drift/drift.dart';

import 'connection/connection.dart';

part 'app_database.g.dart';

@DataClassName('DbUser')
class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get email => text().unique()();
  TextColumn get password => text()();
  TextColumn get phone => text().withDefault(const Constant(''))();
  TextColumn get role => text().withDefault(const Constant('user'))();
}

@DataClassName('DbDoctor')
class Doctors extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get specialty => text()();
  /// Danh sách "chuyên môn khám bệnh" dạng chuỗi, ngăn cách bởi `|`.
  TextColumn get specializations => text().withDefault(const Constant(''))();
  IntColumn get experience => integer().withDefault(const Constant(0))();
  TextColumn get description => text().withDefault(const Constant(''))();
  TextColumn get image => text().withDefault(const Constant(''))();
}

@DataClassName('DbSchedule')
class Schedules extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get doctorId => integer().references(Doctors, #id)();
  TextColumn get date => text()(); // yyyy-MM-dd
  TextColumn get startTime => text()(); // HH:mm
  TextColumn get endTime => text()(); // HH:mm
  BoolColumn get isBooked => boolean().withDefault(const Constant(false))();
}

@DataClassName('DbAppointment')
class Appointments extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get userId => integer().references(Users, #id)();
  IntColumn get doctorId => integer().references(Doctors, #id)();
  IntColumn get scheduleId => integer().references(Schedules, #id)();
  TextColumn get symptom => text().withDefault(const Constant(''))();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  TextColumn get createdAt => text()(); // ISO8601
}

@DriftDatabase(tables: [Users, Doctors, Schedules, Appointments])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(openAppConnection());

  static final AppDatabase instance = AppDatabase();

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await _seedIfEmpty();
          await _seedMoreIfNeeded();
          await _ensureDoctorImages();
          await _normalizeSchedulesToShifts();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.addColumn(doctors, doctors.specializations);
          }
          if (from < 3) {
            await _seedMoreIfNeeded();
          }
          if (from < 4) {
            await _ensureDoctorImages();
          }
          if (from < 5) {
            await _normalizeSchedulesToShifts();
          }
        },
      );

  static const _shiftPairs = <List<String>>[
    ['08:00', '10:00'],
    ['10:00', '12:00'],
    ['13:30', '15:30'],
    ['15:30', '17:30'],
  ];

  String _shiftKey(String start, String end) => '$start-$end';

  String _bucketToShiftKey(String startTime) {
    // map giờ bất kỳ về 4 ca gần nhất để chuẩn hoá dữ liệu cũ
    // 00:00-09:59 -> 08:00-10:00
    // 10:00-12:59 -> 10:00-12:00
    // 13:00-15:29 -> 13:30-15:30
    // còn lại -> 15:30-17:30
    final m = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(startTime.trim());
    if (m == null) return _shiftKey(_shiftPairs.first[0], _shiftPairs.first[1]);
    final h = int.tryParse(m.group(1)!) ?? 0;
    final mm = int.tryParse(m.group(2)!) ?? 0;
    final minutes = h * 60 + mm;
    if (minutes < 10 * 60) return _shiftKey(_shiftPairs[0][0], _shiftPairs[0][1]);
    if (minutes < 13 * 60) return _shiftKey(_shiftPairs[1][0], _shiftPairs[1][1]);
    if (minutes < (15 * 60 + 30)) return _shiftKey(_shiftPairs[2][0], _shiftPairs[2][1]);
    return _shiftKey(_shiftPairs[3][0], _shiftPairs[3][1]);
  }

  Future<void> _normalizeSchedulesToShifts() async {
    // Chuẩn hoá schedule hiện có về đúng 4 ca/ngày/bác sĩ.
    // QUAN TRỌNG: không được xoá schedule đã booked vì appointment đang tham chiếu scheduleId.
    await transaction(() async {
      final all = await (select(schedules)).get();
      final byDoctorDate = <String, List<DbSchedule>>{};
      for (final s in all) {
        final k = '${s.doctorId}|${s.date}';
        (byDoctorDate[k] ??= []).add(s);
      }

      for (final entry in byDoctorDate.entries) {
        final list = entry.value;
        if (list.isEmpty) continue;

        final doctorId = list.first.doctorId;
        final date = list.first.date;

        final desired = {for (final p in _shiftPairs) _shiftKey(p[0], p[1]): p};

        // track shift occupancy
        final existingByShift = <String, DbSchedule>{};
        for (final s in list) {
          final k = _bucketToShiftKey(s.startTime);
          // ưu tiên giữ schedule booked (để không hỏng appointment)
          if (!existingByShift.containsKey(k) || (s.isBooked && !(existingByShift[k]!.isBooked))) {
            existingByShift[k] = s;
          }
        }

        // update các schedule booked về đúng khung ca (nếu chưa đúng)
        for (final kv in existingByShift.entries) {
          final shiftKey = kv.key;
          final row = kv.value;
          final pair = desired[shiftKey];
          if (pair == null) continue;
          if (row.startTime == pair[0] && row.endTime == pair[1]) continue;
          // tránh collision: nếu đã có schedule khác đúng giờ ca thì không update
          final collision = list.any((x) => x.id != row.id && x.startTime == pair[0] && x.endTime == pair[1]);
          if (collision) continue;
          await (update(schedules)..where((x) => x.id.equals(row.id))).write(
            SchedulesCompanion(
              startTime: Value(pair[0]),
              endTime: Value(pair[1]),
            ),
          );
        }

        // xoá các schedule không-booked không thuộc 4 ca (hoặc trùng) để gọn DB
        for (final s in list) {
          if (s.isBooked) continue;
          final k = _bucketToShiftKey(s.startTime);
          final pair = desired[k];
          if (pair == null) {
            await (delete(schedules)..where((x) => x.id.equals(s.id))).go();
            continue;
          }
          final isExactShift = s.startTime == pair[0] && s.endTime == pair[1];
          if (!isExactShift) {
            await (delete(schedules)..where((x) => x.id.equals(s.id))).go();
            continue;
          }
          // nếu trùng exact shift (nhiều row cùng ca), giữ 1 row
          final duplicates = list.where((x) => !x.isBooked && x.startTime == pair[0] && x.endTime == pair[1]).toList();
          if (duplicates.length > 1 && duplicates.first.id != s.id) {
            await (delete(schedules)..where((x) => x.id.equals(s.id))).go();
          }
        }

        // đảm bảo đủ 4 ca (nếu thiếu thì insert ca open)
        final after = await (select(schedules)
              ..where((x) => x.doctorId.equals(doctorId))
              ..where((x) => x.date.equals(date)))
            .get();
        final have = after.map((x) => _shiftKey(x.startTime, x.endTime)).toSet();
        for (final p in _shiftPairs) {
          final k = _shiftKey(p[0], p[1]);
          if (have.contains(k)) continue;
          await into(schedules).insert(
            SchedulesCompanion.insert(
              doctorId: doctorId,
              date: date,
              startTime: p[0],
              endTime: p[1],
              isBooked: const Value(false),
            ),
          );
        }
      }
    });
  }

  Future<void> _ensureDoctorImages() async {
    // Đảm bảo luôn có ảnh hiển thị (tránh dữ liệu cũ trống/URL lỗi).
    const u1 =
        'https://lh3.googleusercontent.com/aida-public/AB6AXuACxIl2BQtqmStUjBo1hH3_ZU3isctPoPOlKOtOI0Vmj1iIwbV7oYx2_ZLLVYo6VLVHcuqslIP1HIV6l46lyxMQpe1ebenVOh4q1CKXpFYjtYMPlA1ein57VpPeEShPP9T8apABS8pG2y1RuNKsECAXb90G3DhXViRCQgRopuJiooAjQPzAYCh_PBgtVBz7hFvxcjqNniBYko4-uO1wFPA5bVitNaRV4fVznlu05D_kTmw_wgnJfCcBPLOSubGjw4evVUCrpmBLEnc';
    const u2 =
        'https://lh3.googleusercontent.com/aida-public/AB6AXuAI3EhnM7K8H2AzHeJvtzCYy6yeXxtUcXaIXr54pRPmeWBN4OZya6Iuq4qduY7GQHg4HWm6JayE4Vg8hlfe2QZxe3W5N3lY2cte3M6Zs5x9lBV2XBtpGAVOsbgUgVim2AuomfXQXzubII7aS-LQhLeHLr4r2X-fFI82P1m5pCNgxEOo4eURzcDMzzY9IxhDUSrJNh-_c4hawTJBWAhRdk5e0slitcfZfu4RELeuyc7zDOh-lrnpZrJikP2XDMvlChhb0xWLCrg5lLc';
    const u3 =
        'https://lh3.googleusercontent.com/aida-public/AB6AXuAoYJVAa1lW6LB6w8uSaep9p3Dt_infnhy8lENKMdjX1h2tRwwPiHteodgBsI6-FysNuST7MGayhprCPZR-97UBABdu1dI7nCJL4kOvPQcbP_RVUnNeb3uy5MYaqjgLcfe99OO_YvzUXfGoQ6CvgSfZ_9ngNLB5Vz1rV0dZYSf4cI86Df6OcBdlAVxom_ocECUlnL0VhI1OhwPRHdflV3xkZl6WWRb9ZnCYbLDdxHQtWNt9K3muBKHFx676VEFjjEZNt_g27oXeEO8';
    await customStatement(
      "UPDATE doctors SET image = '$u1' "
      "WHERE image IS NULL OR TRIM(image) = ''",
    );
    // Nếu image đang trỏ tới svg assets cũ -> map về ảnh cũ theo thiết kế
    await customStatement(
      "UPDATE doctors SET image = '$u1' WHERE image = 'assets/doctors/default_1.svg';",
    );
    await customStatement(
      "UPDATE doctors SET image = '$u2' WHERE image = 'assets/doctors/default_2.svg';",
    );
    await customStatement(
      "UPDATE doctors SET image = '$u3' WHERE image = 'assets/doctors/default_3.svg';",
    );
  }

  Future<void> _seedMoreIfNeeded() async {
    // Tránh seed lặp: nếu đã có nhiều user/appointment thì bỏ qua
    final userCount = await (select(users)).get().then((v) => v.length);
    final apptCount = await (select(appointments)).get().then((v) => v.length);
    if (userCount >= 25 && apptCount >= 20) return;

    // tạo thêm users (role user)
    final existingEmails = (await select(users).get()).map((u) => u.email).toSet();
    final names = <String>[
      'Nguyễn Văn An',
      'Trần Thị Bích',
      'Lê Minh Châu',
      'Phạm Quốc Dũng',
      'Võ Thanh Hà',
      'Đặng Gia Huy',
      'Hoàng Mỹ Linh',
      'Bùi Anh Khoa',
      'Đỗ Thảo Nhi',
      'Phan Minh Tâm',
      'Ngô Thu Trang',
      'Dương Hải Đăng',
      'Vũ Ngọc Mai',
      'Tạ Quang Vinh',
      'Lý Bảo Ngọc',
      'Mai Đức Long',
      'Nguyễn Khánh Vy',
      'Trần Quốc Khải',
      'Lê Thùy Dương',
      'Phạm Nhật Minh',
    ];

    final userIds = <int>[];
    for (int i = 0; i < names.length; i++) {
      final email = 'user${i + 1}@gmail.com';
      if (existingEmails.contains(email)) continue;
      final id = await into(users).insert(
        UsersCompanion.insert(
          name: names[i],
          email: email,
          password: '123456',
          phone: const Value(''),
          role: const Value('user'),
        ),
      );
      userIds.add(id);
    }

    // lấy danh sách doctorIds hiện có
    final ds = await select(doctors).get();
    final doctorIds = ds.map((d) => d.id).toList();
    if (doctorIds.isEmpty) return;

    // tạo lịch (schedules) cho 90 ngày gần nhất, mỗi ngày 4 ca/doctor
    final now = DateTime.now();
    for (int daysBack = 0; daysBack < 90; daysBack++) {
      final day = DateTime(now.year, now.month, now.day).subtract(Duration(days: daysBack));
      final date = '${day.year.toString().padLeft(4, '0')}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
      for (final doctorId in doctorIds.take(10)) {
        for (final p in _shiftPairs) {
          final existed = await (select(schedules)
                ..where((s) =>
                    s.doctorId.equals(doctorId) &
                    s.date.equals(date) &
                    s.startTime.equals(p[0]) &
                    s.endTime.equals(p[1]))
                ..limit(1))
              .getSingleOrNull();
          if (existed != null) continue;
          await into(schedules).insert(
            SchedulesCompanion.insert(
              doctorId: doctorId,
              date: date,
              startTime: p[0],
              endTime: p[1],
              isBooked: const Value(false),
            ),
          );
        }
      }
    }

    // tạo nhiều appointment mẫu rải theo 7/30/90 ngày (dùng schedule đã tạo)
    final allSlots = await (select(schedules)
          ..orderBy([(s) => OrderingTerm.desc(s.date)]))
        .get();
    final useUserIds = [
      ...(await (select(users)..where((u) => u.role.equals('user'))).get()).map((u) => u.id),
    ];
    if (useUserIds.isEmpty || allSlots.isEmpty) return;

    int created = 0;
    for (final s in allSlots.take(120)) {
      if (created >= 80) break;
      // chỉ tạo cho slot chưa booked
      if (s.isBooked) continue;

      final userId = useUserIds[created % useUserIds.length];
      final doctorId = s.doctorId;
      final status = created % 5 == 0
          ? 'cancelled'
          : created % 3 == 0
              ? 'confirmed'
              : 'pending';
      final createdAt = DateTime.parse('${s.date}T${s.startTime}:00.000')
          .add(Duration(minutes: created % 17))
          .toIso8601String();

      final apptId = await into(appointments).insert(
        AppointmentsCompanion.insert(
          userId: userId,
          doctorId: doctorId,
          scheduleId: s.id,
          symptom: Value(created % 2 == 0 ? 'Đau đầu' : 'Mệt mỏi'),
          status: Value(status),
          createdAt: createdAt,
        ),
      );

      if (status != 'cancelled') {
        await (update(schedules)..where((x) => x.id.equals(s.id))).write(
          const SchedulesCompanion(isBooked: Value(true)),
        );
      }
      // silence unused
      // ignore: unused_local_variable
      final _ = apptId;
      created++;
    }
  }

  Future<void> _seedIfEmpty() async {
    final existing = await (select(users)..limit(1)).get();
    if (existing.isNotEmpty) return;

    // Admin theo readme
    final adminId = await into(users).insert(
      UsersCompanion.insert(
        name: 'Admin',
        email: 'admin@gmail.com',
        password: '123456',
        phone: const Value(''),
        role: const Value('admin'),
      ),
    );

    // 1 user mẫu
    final userId = await into(users).insert(
      UsersCompanion.insert(
        name: 'Demo User',
        email: 'user@gmail.com',
        password: '123456',
        phone: const Value(''),
        role: const Value('user'),
      ),
    );

    // Doctors demo (dùng ảnh remote cho web demo)
    final doctor1Id = await into(doctors).insert(
      DoctorsCompanion.insert(
        name: 'Dr. Sarah Jenkins',
        specialty: 'Cardiology',
        specializations: const Value('Tim mạch tổng quát|Tăng huyết áp|Rối loạn nhịp tim|Tư vấn lối sống'),
        experience: const Value(8),
        description: const Value('Lead Cardiologist with a patient-first approach.'),
        image: const Value('assets/doctors/default_1.svg'),
      ),
    );
    final doctor2Id = await into(doctors).insert(
      DoctorsCompanion.insert(
        name: 'Dr. Marcus Thorne',
        specialty: 'Neurology',
        specializations: const Value('Thần kinh|Đau đầu/migraine|Rối loạn giấc ngủ|Tư vấn phục hồi chức năng'),
        experience: const Value(12),
        description: const Value('Neurology specialist focused on modern diagnostics.'),
        image: const Value('assets/doctors/default_2.svg'),
      ),
    );
    final doctor3Id = await into(doctors).insert(
      DoctorsCompanion.insert(
        name: 'Dr. Elena Rodriguez',
        specialty: 'Pediatrics',
        specializations: const Value('Nhi khoa|Tiêm chủng|Dinh dưỡng trẻ em|Theo dõi phát triển'),
        experience: const Value(6),
        description: const Value('Pediatric wellness and preventive care.'),
        image: const Value('assets/doctors/default_3.svg'),
      ),
    );

    // Thêm nhiều bác sĩ mẫu
    final more = <Map<String, Object>>[
      {
        'name': 'Dr. An Nguyen',
        'specialty': 'Dermatology',
        'specializations': 'Da liễu|Mụn|Dị ứng da|Tư vấn chăm sóc da',
        'experience': 9,
        'description': 'Chuyên gia da liễu, tập trung điều trị mụn và chăm sóc da an toàn.',
        'image': 'assets/doctors/default_1.svg',
      },
      {
        'name': 'Dr. Minh Tran',
        'specialty': 'Internal Medicine',
        'specializations': 'Nội tổng quát|Tiểu đường|Mỡ máu|Tư vấn sức khỏe định kỳ',
        'experience': 11,
        'description': 'Bác sĩ nội tổng quát, theo dõi bệnh mạn tính và tư vấn lối sống.',
        'image': 'assets/doctors/default_2.svg',
      },
      {
        'name': 'Dr. Ha Le',
        'specialty': 'ENT',
        'specializations': 'Tai mũi họng|Viêm xoang|Viêm họng|Tầm soát thính lực',
        'experience': 7,
        'description': 'Chẩn đoán và điều trị bệnh lý tai mũi họng, ưu tiên phác đồ nhẹ nhàng.',
        'image': 'assets/doctors/default_3.svg',
      },
      {
        'name': 'Dr. Khoa Pham',
        'specialty': 'Orthopedics',
        'specializations': 'Cơ xương khớp|Đau lưng|Thoái hóa khớp|Vật lý trị liệu',
        'experience': 13,
        'description': 'Bác sĩ cơ xương khớp, điều trị đau lưng và chấn thương thể thao.',
        'image': 'assets/doctors/default_1.svg',
      },
      {
        'name': 'Dr. Linh Vo',
        'specialty': 'Nutrition',
        'specializations': 'Dinh dưỡng|Giảm cân|Tăng cơ|Dinh dưỡng bệnh lý',
        'experience': 5,
        'description': 'Tư vấn dinh dưỡng cá nhân hoá, thực đơn dễ áp dụng.',
        'image': 'assets/doctors/default_2.svg',
      },
    ];

    final moreDoctorIds = <int>[];
    for (final m in more) {
      final id = await into(doctors).insert(
        DoctorsCompanion.insert(
          name: m['name'] as String,
          specialty: m['specialty'] as String,
          specializations: Value(m['specializations'] as String),
          experience: Value(m['experience'] as int),
          description: Value(m['description'] as String),
          image: Value(m['image'] as String),
        ),
      );
      moreDoctorIds.add(id);
    }

    // Schedules demo: hôm nay + 6 ngày tới
    final now = DateTime.now();
    final dates = List.generate(7, (i) {
      final d = DateTime(now.year, now.month, now.day).add(Duration(days: i));
      return '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    });

    Future<void> addSlots(int doctorId) async {
      for (final date in dates) {
        for (final t in _shiftPairs) {
          await into(schedules).insert(
            SchedulesCompanion.insert(
              doctorId: doctorId,
              date: date,
              startTime: t[0],
              endTime: t[1],
              isBooked: const Value(false),
            ),
          );
        }
      }
    }

    await addSlots(doctor1Id);
    await addSlots(doctor2Id);
    await addSlots(doctor3Id);
    for (final id in moreDoctorIds) {
      await addSlots(id);
    }

    // Appointment demo: 1 lịch pending cho user mẫu để admin thấy ngay
    final firstSlot = await (select(schedules)
          ..where((s) => s.doctorId.equals(doctor1Id) & s.date.equals(dates.first))
          ..limit(1))
        .getSingle();

    final createdAt = DateTime.now().toIso8601String();
    final apptId = await into(appointments).insert(
      AppointmentsCompanion.insert(
        userId: userId,
        doctorId: doctor1Id,
        scheduleId: firstSlot.id,
        symptom: const Value('Headache'),
        status: const Value('pending'),
        createdAt: createdAt,
      ),
    );

    // mark booked
    await (update(schedules)..where((s) => s.id.equals(firstSlot.id))).write(
      const SchedulesCompanion(isBooked: Value(true)),
    );

    // silence unused warnings in seed (kept for possible future use)
    // ignore: unused_local_variable
    final _ = [adminId, apptId];
  }
}


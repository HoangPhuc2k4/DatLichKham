import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'views/auth/login_page.dart';
import 'views/admin/precision_pages.dart';
import 'views/user/curated_clinic_home_page.dart';
import 'views/user/my_appointments_page.dart';
import 'views/user/doctor_detail_page.dart';
import 'views/user/booking_page.dart';
import 'views/user/all_doctors_page.dart';

void main() {
  runApp(const DatLichKhamApp());
}

class DatLichKhamApp extends StatelessWidget {
  const DatLichKhamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Đặt lịch khám',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2EC4B6),
        ),
        useMaterial3: true,
      ),
      initialRoute: '/user/home',
      routes: {
        '/': (context) => const LoginPage(),
        '/user/home': (context) => const CuratedClinicHomePage(),
        '/user/appointments': (context) => const MyAppointmentsPage(),
        '/user/doctor': (context) => const DoctorDetailPage(),
        '/user/booking': (context) => const BookingPage(),
        '/user/doctors': (context) => const AllDoctorsPage(),
        '/admin/home': (context) => const PrecisionDashboardPage(),
        '/admin/dashboard': (context) => const PrecisionDashboardPage(),
        '/admin/doctors': (context) => const PrecisionDoctorManagementPage(),
        '/admin/schedules': (context) => const PrecisionScheduleManagementPage(),
        '/admin/appointments': (context) => const PrecisionAppointmentManagementPage(),
      },
      builder: (context, child) {
        if (kIsWeb) {
          return child ?? const SizedBox.shrink();
        }
        return child ?? const SizedBox.shrink();
      },
    );
  }
}


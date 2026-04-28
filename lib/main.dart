import 'dart:ui'; // Sửa lỗi PointerDeviceKind
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Import các trang dựa trên cấu trúc thư mục thực tế của bạn
import 'views/auth/login_page.dart';
import 'views/admin/precision_pages.dart';
import 'views/user/curated_clinic_home_page.dart';
import 'views/user/my_appointments_page.dart';
import 'views/user/doctor_detail_page.dart';
import 'views/user/booking_page.dart';
import 'views/user/all_doctors_page.dart';
import 'views/user/user_home_page.dart'; // Đảm bảo file này tồn tại trong thư mục user

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DatLichKhamApp());
}

class DatLichKhamApp extends StatelessWidget {
  const DatLichKhamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Curated Clinic',
      debugShowCheckedModeBanner: false,

      // --- CẤU HÌNH THEME HỆ THỐNG ---
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0D9488), // Teal chủ đạo
          primary: const Color(0xFF0D9488),
          secondary: const Color(0xFF0F172A), // Slate
          surface: Colors.white,
          background: const Color(0xFFF8FAFC),
        ),
        // Áp dụng font Manrope cho toàn bộ ứng dụng
        textTheme: GoogleFonts.manropeTextTheme(
          Theme.of(context).textTheme,
        ),
      ),

      // --- QUẢN LÝ ĐỊNH TUYẾN ---
      initialRoute: '/user/home',
      routes: {
        // Auth
        '/': (context) => const LoginPage(),

        // User Pages
        '/user/home': (context) => const CuratedClinicHomePage(),
        '/user/old_home': (context) => const UserHomePage(), // Nếu bạn vẫn giữ file user_home_page.dart
        '/user/appointments': (context) => const MyAppointmentsPage(),
        '/user/doctor': (context) => const DoctorDetailPage(),
        '/user/booking': (context) => const BookingPage(),
        '/user/doctors': (context) => const AllDoctorsPage(),

        // Admin Pages
        '/admin/home': (context) => const PrecisionDashboardPage(),
        '/admin/dashboard': (context) => const PrecisionDashboardPage(),
        '/admin/doctors': (context) => const PrecisionDoctorManagementPage(),
        '/admin/schedules': (context) => const PrecisionScheduleManagementPage(),
        '/admin/appointments': (context) => const PrecisionAppointmentManagementPage(),
      },

      // --- XỬ LÝ LỖI ĐIỀU HƯỚNG ---
      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (context) => const CuratedClinicHomePage(),
      ),

      // --- CẤU HÌNH CUỘN TRANG (SỬA LỖI TRÊN WEB) ---
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse, // Cho phép dùng chuột kéo cuộn như mobile
        },
      ),
    );
  }
}
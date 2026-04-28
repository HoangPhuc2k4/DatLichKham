import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

  static const Color primaryTeal = Color(0xFF006A62);
  static const Color accentMint = Color(0xFF2EC4B6);
  static const Color backgroundLight = Color(0xFFF8FAFA);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Curated Clinic',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryTeal,
          primary: primaryTeal,
          secondary: accentMint,
          surface: backgroundLight,
          onSurface: const Color(0xFF191C1D),
        ),

        // Cấu hình Font chữ
        textTheme: GoogleFonts.manropeTextTheme().copyWith(
          displayLarge: GoogleFonts.epilogue(fontWeight: FontWeight.w900, color: const Color(0xFF191C1D)),
          displayMedium: GoogleFonts.epilogue(fontWeight: FontWeight.w800, color: const Color(0xFF191C1D)),
          headlineMedium: GoogleFonts.epilogue(fontWeight: FontWeight.w800, color: const Color(0xFF191C1D)),
          titleLarge: GoogleFonts.epilogue(fontWeight: FontWeight.w700, color: const Color(0xFF191C1D)),
        ),

        // Cấu hình Input (TextField)
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.black.withOpacity(0.05)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: primaryTeal, width: 1.5),
          ),
          hintStyle: GoogleFonts.manrope(color: Colors.grey, fontWeight: FontWeight.w500),
        ),

        // Cấu hình Button
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryTeal,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            textStyle: GoogleFonts.manrope(fontWeight: FontWeight.w800, fontSize: 15),
          ),
        ),

        // --- ĐÃ SỬA LỖI TẠI ĐÂY ---
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        // -------------------------
      ),

      initialRoute: '/user/home',
      routes: {
        '/': (context) => const LoginPage(),
        '/user/home': (context) => const CuratedClinicHomePage(),
        '/user/appointments': (context) => const MyAppointmentsPage(),
        '/user/doctor': (context) => const DoctorDetailPage(),
        '/user/booking': (context) => const BookingPage(),
        '/user/doctors': (context) => const AllDoctorsPage(),

        // Admin Routes
        '/admin/home': (context) => const PrecisionDashboardPage(),
        '/admin/dashboard': (context) => const PrecisionDashboardPage(),
        '/admin/doctors': (context) => const PrecisionDoctorManagementPage(),
        '/admin/schedules': (context) => const PrecisionScheduleManagementPage(),
        '/admin/appointments': (context) => const PrecisionAppointmentManagementPage(),
      },

      builder: (context, child) {
        return ScrollConfiguration(
          behavior: const ScrollBehavior().copyWith(
            scrollbars: true,
            dragDevices: {
              PointerDeviceKind.touch,
              PointerDeviceKind.mouse,
              PointerDeviceKind.trackpad,
            },
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
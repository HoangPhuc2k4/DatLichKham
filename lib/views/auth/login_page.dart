import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/session_controller.dart';
import '../../models/user.dart';
import '../widgets/primary_button.dart'; // Sử dụng widget nút đã refactor

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static const Color primaryMedical = Color(0xFF006A62); // Teal đậm chuẩn Premium
  static const Color accentMedical = Color(0xFF2EC4B6);
  static const Color bgLight = Color(0xFFF8FAFA);

  int _tabIndex = 0;
  bool _isLoading = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _toast('Vui lòng nhập đầy đủ thông tin.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (_tabIndex == 1) {
        final name = _nameController.text.trim();
        final confirm = _confirmPasswordController.text;
        if (name.isEmpty || password != confirm) {
          _toast('Thông tin đăng ký không hợp lệ.');
          setState(() => _isLoading = false);
          return;
        }

        final created = await AuthController.instance.register(
          User(name: name, email: email, password: password, phone: '', role: 'user'),
        );
        SessionController.instance.setUser(created);
        Navigator.of(context).pushReplacementNamed('/user/home');
      } else {
        final user = await AuthController.instance.login(email, password);
        if (user == null) {
          _toast('Email hoặc mật khẩu không chính xác.');
        } else {
          SessionController.instance.setUser(user);
          Navigator.of(context).pushReplacementNamed(
              user.role == 'admin' ? '/admin/home' : '/user/home');
        }
      }
    } catch (e) {
      _toast('Lỗi hệ thống: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.manrope(fontWeight: FontWeight.w600)),
        behavior: SnackBarBehavior.floating,
        backgroundColor: primaryMedical,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      body: Stack(
        children: [
          // Background Blobs
          Positioned(
            top: -100,
            right: -50,
            child: _buildBlob(accentMedical.withOpacity(0.1), 350),
          ),
          Positioned(
            bottom: -80,
            left: -50,
            child: _buildBlob(primaryMedical.withOpacity(0.08), 300),
          ),

          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 440),
                child: Column(
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 40),
                    _buildMainCard(),
                    const SizedBox(height: 32),
                    _buildFooter(),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlob(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: primaryMedical,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.auto_awesome, color: Colors.white, size: 32),
        ),
        const SizedBox(height: 20),
        Text(
          'Curated Clinic',
          style: GoogleFonts.epilogue(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF191C1D),
            letterSpacing: -1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Tiêu chuẩn mới cho y tế cá nhân hóa',
          style: GoogleFonts.manrope(
            fontSize: 14,
            color: Colors.blueGrey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildMainCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 40,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          // Custom Toggle
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: bgLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                _buildTabBtn(0, 'Đăng nhập'),
                _buildTabBtn(1, 'Đăng ký'),
              ],
            ),
          ),
          const SizedBox(height: 32),

          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Column(
              key: ValueKey(_tabIndex),
              children: [
                if (_tabIndex == 1) ...[
                  _buildField(_nameController, 'Họ và tên', Icons.person_outline),
                  const SizedBox(height: 16),
                ],
                _buildField(_emailController, 'Email', Icons.mail_outline),
                const SizedBox(height: 16),
                _buildField(_passwordController, 'Mật khẩu', Icons.lock_outline, isObscure: true),
                if (_tabIndex == 1) ...[
                  const SizedBox(height: 16),
                  _buildField(_confirmPasswordController, 'Xác nhận mật khẩu', Icons.verified_user_outlined, isObscure: true),
                ],
              ],
            ),
          ),

          const SizedBox(height: 32),
          PrimaryButton(
            label: _tabIndex == 0 ? 'Tiếp tục' : 'Tạo tài khoản',
            isLoading: _isLoading,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }

  Widget _buildTabBtn(int index, String label) {
    final active = _tabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _tabIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: active ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)] : [],
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.manrope(
                fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                color: active ? primaryMedical : Colors.blueGrey[300],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(TextEditingController controller, String hint, IconData icon, {bool isObscure = false}) {
    return TextField(
      controller: controller,
      obscureText: isObscure,
      style: GoogleFonts.manrope(fontWeight: FontWeight.w600, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, size: 20, color: primaryMedical),
        filled: true,
        fillColor: bgLight,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
      ),
    );
  }

  Widget _buildFooter() {
    return Text(
      'Quên mật khẩu? Liên hệ quản trị viên',
      style: GoogleFonts.manrope(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: primaryMedical.withOpacity(0.7),
      ),
    );
  }
}
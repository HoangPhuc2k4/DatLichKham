import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/session_controller.dart';
import '../../models/user.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // Bảng màu hiện đại cho Medical App
  static const Color kPrimary = Color(0xFF0D9488); // Teal 600
  static const Color kSecondary = Color(0xFF14B8A6); // Teal 500
  static const Color kAccent = Color(0xFFF59E0B); // Amber 500
  static const Color kBackground = Color(0xFFF8FAFC); // Slate 50
  static const Color kTextDark = Color(0xFF0F172A); // Slate 900
  static const Color kTextLight = Color(0xFF64748B); // Slate 500

  int _tabIndex = 0;

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
      _toast('Vui lòng nhập email và mật khẩu.');
      return;
    }

    try {
      if (_tabIndex == 1) {
        final name = _nameController.text.trim();
        final confirm = _confirmPasswordController.text;
        if (name.isEmpty) {
          _toast('Vui lòng nhập họ tên.');
          return;
        }
        if (password != confirm) {
          _toast('Mật khẩu xác nhận không khớp.');
          return;
        }

        final created = await AuthController.instance.register(
          User(
            name: name,
            email: email,
            password: password,
            phone: '',
            role: 'user',
          ),
        );
        SessionController.instance.setUser(created);
        Navigator.of(context).pushReplacementNamed('/user/home');
        return;
      }

      final user = await AuthController.instance.login(email, password);
      if (user == null) {
        _toast('Sai email hoặc mật khẩu.');
        return;
      }
      SessionController.instance.setUser(user);

      if (user.role == 'admin') {
        Navigator.of(context).pushReplacementNamed('/admin/home');
      } else {
        Navigator.of(context).pushReplacementNamed('/user/home');
      }
    } catch (e) {
      if (e is StateError && e.message == 'EMAIL_EXISTS') {
        _toast('Email đã tồn tại. Vui lòng dùng email khác hoặc đăng nhập.');
        return;
      }
      _toast('Có lỗi xảy ra: $e');
    }
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.manrope(fontWeight: FontWeight.w600)),
        backgroundColor: kTextDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(20),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final width = size.width;
    final showDecorCards = width >= 1200;

    return Scaffold(
      backgroundColor: kBackground,
      body: Stack(
        children: [
          // Background Blobs với màu sắc mềm mại hơn
          Positioned(
            top: -100,
            left: -50,
            child: _artBlob(
              color: kPrimary.withAlpha(20),
              size: width < 600 ? 300 : 500,
            ),
          ),
          Positioned(
            right: -100,
            bottom: -50,
            child: _artBlob(
              color: kAccent.withAlpha(15),
              size: width < 600 ? 250 : 450,
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Form đăng nhập chính
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 480),
                      child: _AuthColumn(
                        tabIndex: _tabIndex,
                        onTabChanged: (i) => setState(() => _tabIndex = i),
                        emailController: _emailController,
                        passwordController: _passwordController,
                        nameController: _nameController,
                        confirmPasswordController: _confirmPasswordController,
                        onSubmit: _submit,
                      ),
                    ),

                    // Side Cards cho màn hình lớn
                    if (showDecorCards) ...[
                      const SizedBox(width: 80),
                      const SizedBox(
                        width: 320,
                        child: _SideInfoColumn(),
                      ),
                    ]
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthColumn extends StatelessWidget {
  final int tabIndex;
  final ValueChanged<int> onTabChanged;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController nameController;
  final TextEditingController confirmPasswordController;
  final VoidCallback onSubmit;

  const _AuthColumn({
    required this.tabIndex,
    required this.onTabChanged,
    required this.emailController,
    required this.passwordController,
    required this.nameController,
    required this.confirmPasswordController,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Brand Header
        Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(13),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    )
                  ]
              ),
              child: const Icon(Icons.auto_awesome, color: Color(0xFF0D9488), size: 32),
            ),
            const SizedBox(height: 24),
            Text(
              'Curated Clinic',
              style: GoogleFonts.epilogue(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Trải nghiệm tiêu chuẩn chăm sóc sức khỏe mới',
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                fontSize: 15,
                color: const Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 40),

        // Form Card
        ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(230),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(color: Colors.white, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(13),
                    blurRadius: 50,
                    offset: const Offset(0, 25),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _TabToggle(tabIndex: tabIndex, onChanged: onTabChanged),
                  const SizedBox(height: 32),
                  _AuthForm(
                    isSignUp: tabIndex == 1,
                    emailController: emailController,
                    passwordController: passwordController,
                    nameController: nameController,
                    confirmPasswordController: confirmPasswordController,
                    onSubmit: onSubmit,
                  ),
                  const SizedBox(height: 32),
                  const _SocialDivider(),
                  const SizedBox(height: 24),
                  const _SocialButtonsRow(),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 32),
        const _FooterLinks(),
      ],
    );
  }
}

class _TabToggle extends StatelessWidget {
  final int tabIndex;
  final ValueChanged<int> onChanged;

  const _TabToggle({required this.tabIndex, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          _tabItem(0, 'Đăng nhập'),
          _tabItem(1, 'Đăng ký'),
        ],
      ),
    );
  }

  Widget _tabItem(int index, String label) {
    bool active = tabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: active ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: active
                ? [
              BoxShadow(
                color: Colors.black.withAlpha(13),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ]
                : [],
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GoogleFonts.manrope(
              fontSize: 14,
              fontWeight: active ? FontWeight.w700 : FontWeight.w600,
              color: active ? const Color(0xFF0D9488) : const Color(0xFF64748B),
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthForm extends StatefulWidget {
  final bool isSignUp;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController nameController;
  final TextEditingController confirmPasswordController;
  final VoidCallback onSubmit;

  const _AuthForm({
    required this.isSignUp,
    required this.emailController,
    required this.passwordController,
    required this.nameController,
    required this.confirmPasswordController,
    required this.onSubmit,
  });

  @override
  State<_AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<_AuthForm> {
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.isSignUp) ...[
          _fieldLabel('Họ và tên'),
          _SoftField(
            controller: widget.nameController,
            hintText: 'Nguyễn Văn A',
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 20),
        ],
        _fieldLabel('Email'),
        _SoftField(
          controller: widget.emailController,
          hintText: 'name@clinic.com',
          icon: Icons.mail_outline,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _fieldLabel('Mật khẩu'),
            if (!widget.isSignUp)
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                child: Text('Quên mật khẩu?',
                    style: GoogleFonts.manrope(
                        fontSize: 12, fontWeight: FontWeight.w700, color: const Color(0xFF0D9488))),
              ),
          ],
        ),
        _SoftField(
          controller: widget.passwordController,
          hintText: '••••••••',
          icon: Icons.lock_outline,
          obscureText: _obscurePassword,
          onToggleObscure: () => setState(() => _obscurePassword = !_obscurePassword),
        ),
        if (widget.isSignUp) ...[
          const SizedBox(height: 20),
          _fieldLabel('Xác nhận mật khẩu'),
          _SoftField(
            controller: widget.confirmPasswordController,
            hintText: '••••••••',
            icon: Icons.lock_reset_outlined,
            obscureText: _obscureConfirm,
            onToggleObscure: () => setState(() => _obscureConfirm = !_obscureConfirm),
          ),
        ],
        const SizedBox(height: 32),
        _PrimaryButton(
          label: widget.isSignUp ? 'Tạo tài khoản' : 'Đăng nhập ngay',
          onPressed: widget.onSubmit,
        ),
      ],
    );
  }

  Widget _fieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        text,
        style: GoogleFonts.manrope(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF1E293B),
        ),
      ),
    );
  }
}

class _SoftField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final bool obscureText;
  final VoidCallback? onToggleObscure;
  final TextInputType? keyboardType;

  const _SoftField({
    required this.controller,
    required this.hintText,
    required this.icon,
    this.obscureText = false,
    this.onToggleObscure,
    this.keyboardType,
  });

  @override
  State<_SoftField> createState() => _SoftFieldState();
}

class _SoftFieldState extends State<_SoftField> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (focus) => setState(() => _isFocused = focus),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: _isFocused ? Colors.white : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isFocused ? const Color(0xFF0D9488) : const Color(0xFFE2E8F0),
            width: 1.5,
          ),
          boxShadow: _isFocused
              ? [BoxShadow(color: const Color(0xFF0D9488).withAlpha(10), blurRadius: 8, spreadRadius: 2)]
              : [],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: TextField(
          controller: widget.controller,
          obscureText: widget.obscureText,
          keyboardType: widget.keyboardType,
          style: GoogleFonts.manrope(fontSize: 15, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            icon: Icon(widget.icon, size: 20, color: _isFocused ? const Color(0xFF0D9488) : const Color(0xFF94A3B8)),
            border: InputBorder.none,
            hintText: widget.hintText,
            hintStyle: GoogleFonts.manrope(color: const Color(0xFF94A3B8), fontWeight: FontWeight.w500),
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
            suffixIcon: widget.onToggleObscure != null
                ? IconButton(
              icon: Icon(
                widget.obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                size: 20,
                color: const Color(0xFF94A3B8),
              ),
              onPressed: widget.onToggleObscure,
            )
                : null,
          ),
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _PrimaryButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFF0D9488), Color(0xFF14B8A6)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0D9488).withAlpha(60),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: Text(
          label,
          style: GoogleFonts.manrope(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white),
        ),
      ),
    );
  }
}

class _SocialDivider extends StatelessWidget {
  const _SocialDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'HOẶC TIẾP TỤC VỚI',
            style: GoogleFonts.manrope(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF94A3B8),
              letterSpacing: 1.2,
            ),
          ),
        ),
        const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
      ],
    );
  }
}

class _SocialButtonsRow extends StatelessWidget {
  const _SocialButtonsRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _socialBtn(Icons.g_mobiledata, 'Google'),
        const SizedBox(width: 16),
        _socialBtn(Icons.apple, 'Apple'),
      ],
    );
  }

  Widget _socialBtn(IconData icon, String label) {
    return Expanded(
      child: OutlinedButton(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: const BorderSide(color: Color(0xFFE2E8F0)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24, color: const Color(0xFF1E293B)),
            const SizedBox(width: 8),
            Text(label, style: GoogleFonts.manrope(fontSize: 14, fontWeight: FontWeight.w700, color: const Color(0xFF1E293B))),
          ],
        ),
      ),
    );
  }
}

class _FooterLinks extends StatelessWidget {
  const _FooterLinks();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text.rich(
          TextSpan(
            text: 'Bạn là thành viên mới? ',
            style: GoogleFonts.manrope(fontSize: 14, color: const Color(0xFF64748B)),
            children: [
              TextSpan(
                text: 'Yêu cầu tham gia',
                style: GoogleFonts.manrope(fontWeight: FontWeight.w800, color: const Color(0xFF0D9488)),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _fLink('Bảo mật'),
            _fDot(),
            _fLink('Điều khoản'),
            _fDot(),
            _fLink('Hỗ trợ'),
          ],
        )
      ],
    );
  }

  Widget _fLink(String t) => Text(t, style: GoogleFonts.manrope(fontSize: 12, fontWeight: FontWeight.w600, color: const Color(0xFF94A3B8)));
  Widget _fDot() => Container(margin: const EdgeInsets.symmetric(horizontal: 12), width: 4, height: 4, decoration: const BoxDecoration(color: Color(0xFFCBD5E1), shape: BoxShape.circle));
}

class _SideInfoColumn extends StatelessWidget {
  const _SideInfoColumn();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _infoCard(
          Icons.shield_outlined,
          'An toàn tuyệt đối',
          'Dữ liệu y tế của bạn được mã hóa theo tiêu chuẩn quốc tế.',
          const Color(0xFF0D9488),
        ),
        const SizedBox(height: 20),
        _infoCard(
          Icons.verified_outlined,
          'Bác sĩ chuyên gia',
          'Kết nối trực tiếp với đội ngũ bác sĩ đã qua kiểm duyệt kỹ lưỡng.',
          const Color(0xFFF59E0B),
        ),
      ],
    );
  }

  Widget _infoCard(IconData icon, String title, String desc, Color color) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: Colors.black.withAlpha(10), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: color.withAlpha(25), shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 16),
          Text(title, style: GoogleFonts.epilogue(fontSize: 18, fontWeight: FontWeight.w800, color: const Color(0xFF1E293B))),
          const SizedBox(height: 8),
          Text(desc, style: GoogleFonts.manrope(fontSize: 14, height: 1.5, color: const Color(0xFF64748B), fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

Widget _artBlob({required Color color, required double size}) {
  return Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: color,
      shape: BoxShape.circle,
    ),
  );
}
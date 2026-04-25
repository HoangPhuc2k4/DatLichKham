import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/session_controller.dart';
import '../../models/user.dart';

/// Trang đăng nhập / đăng ký theo thiết kế `login_register_curated_clinic/code.html`.
/// - Sign In: email + password + Forgot
/// - Sign Up: full name + email + password + confirm (khác hẳn Sign In)
/// - Responsive: điện thoại / tablet / laptop (side cards: cạnh phải từ `lg`, dưới form khi nhỏ hơn)
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static const Color primaryContainer = Color(0xFF2EC4B6);
  static const Color tertiaryContainer = Color(0xFFF99A15);
  static const Color secondaryContainer = Color(0xFFC5E4FA);

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
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final showDecorCards = width >= 1280;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFA),
      body: Stack(
        children: [
          Positioned(
            top: -80,
            left: -80,
            child: _artBlob(
              color: primaryContainer.withValues(alpha: 0.12),
              size: width < 600 ? 220 : 320,
            ),
          ),
          Positioned(
            right: -120,
            top: width * 0.15,
            child: Transform.rotate(
              angle: 0.2,
              child: _artBlob(
                color: tertiaryContainer.withValues(alpha: 0.08),
                size: width < 600 ? 260 : 400,
              ),
            ),
          ),
          Positioned(
            left: width * 0.1,
            bottom: -100,
            child: Transform.rotate(
              angle: -0.65,
              child: _artBlob(
                color: secondaryContainer.withValues(alpha: 0.18),
                size: 240,
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final horizontal =
                    width < 600 ? 16.0 : width < 900 ? 24.0 : 32.0;
                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontal,
                    vertical: width < 600 ? 20 : 32,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: 520,
                      ),
                      child: _AuthColumn(
                        tabIndex: _tabIndex,
                        onTabChanged: (i) => setState(() => _tabIndex = i),
                        emailController: _emailController,
                        passwordController: _passwordController,
                        nameController: _nameController,
                        confirmPasswordController: _confirmPasswordController,
                        onSubmit: () => _submit(),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (showDecorCards)
            const Positioned(
              right: 96,
              top: 160,
              child: IgnorePointer(
                child: SizedBox(width: 256, child: _SideInfoColumn()),
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
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Curated Clinic',
          textAlign: TextAlign.center,
          style: GoogleFonts.epilogue(
            fontSize: 36,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.6,
            height: 1.1,
            color: const Color(0xFF191C1D),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'A New Standard in Wellness.',
          textAlign: TextAlign.center,
          style: GoogleFonts.manrope(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF3C4947),
          ),
        ),
        const SizedBox(height: 36),
        ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: const Color(0xFF3C4947).withValues(alpha: 0.05),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF191C1D).withValues(alpha: 0.06),
                    blurRadius: 40,
                    offset: const Offset(0, 20),
                  ),
                ],
              ),
              padding: EdgeInsets.all(
                MediaQuery.sizeOf(context).width >= 600 ? 40 : 28,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _TabToggle(
                    tabIndex: tabIndex,
                    onChanged: onTabChanged,
                  ),
                  const SizedBox(height: 28),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 280),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    transitionBuilder: (child, anim) {
                      return FadeTransition(
                        opacity: anim,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.03, 0),
                            end: Offset.zero,
                          ).animate(anim),
                          child: child,
                        ),
                      );
                    },
                    child: _AuthForm(
                      key: ValueKey(tabIndex),
                      isSignUp: tabIndex == 1,
                      emailController: emailController,
                      passwordController: passwordController,
                      nameController: nameController,
                      confirmPasswordController: confirmPasswordController,
                      onSubmit: onSubmit,
                    ),
                  ),
                  const SizedBox(height: 28),
                  const _SocialDivider(),
                  const SizedBox(height: 20),
                  const _SocialButtonsRow(),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 28),
        const _FooterLinks(),
      ],
    );
  }
}

/// Pill toggle giống HTML: nền xám, tab active nền trắng + shadow, có trượt nhẹ.
class _TabToggle extends StatelessWidget {
  final int tabIndex;
  final ValueChanged<int> onChanged;

  const _TabToggle({
    required this.tabIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        final innerW = w - 12;
        final segmentW = innerW / 2;
        return Container(
          height: 48,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFFF2F4F4),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeOutCubic,
                left: tabIndex == 0 ? 0 : segmentW,
                top: 0,
                bottom: 0,
                width: segmentW,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () => onChanged(0),
                        child: Center(
                          child: Text(
                            'Đăng nhập',
                            style: GoogleFonts.manrope(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: tabIndex == 0
                                  ? const Color(0xFF004C46)
                                  : const Color(0xFF3C4947),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(10),
                        onTap: () => onChanged(1),
                        child: Center(
                          child: Text(
                            'Đăng ký',
                            style: GoogleFonts.manrope(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: tabIndex == 1
                                  ? const Color(0xFF004C46)
                                  : const Color(0xFF3C4947),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
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
    super.key,
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
    if (widget.isSignUp) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _label('Họ và tên'),
          const SizedBox(height: 8),
          _SoftField(
            controller: widget.nameController,
            hintText: 'Nguyễn Văn A',
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 20),
          _label('Email'),
          const SizedBox(height: 8),
          _SoftField(
            controller: widget.emailController,
            hintText: 'name@clinic.com',
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 20),
          _label('Mật khẩu'),
          const SizedBox(height: 8),
          _SoftField(
            controller: widget.passwordController,
            hintText: '••••••••',
            obscureText: _obscurePassword,
            onToggleObscure: () =>
                setState(() => _obscurePassword = !_obscurePassword),
          ),
          const SizedBox(height: 20),
          _label('Nhập lại mật khẩu'),
          const SizedBox(height: 8),
          _SoftField(
            controller: widget.confirmPasswordController,
            hintText: '••••••••',
            obscureText: _obscureConfirm,
            onToggleObscure: () =>
                setState(() => _obscureConfirm = !_obscureConfirm),
          ),
          const SizedBox(height: 24),
          _PrimaryGradientButton(
            label: 'Tạo tài khoản',
            onPressed: widget.onSubmit,
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _label('Email'),
        const SizedBox(height: 8),
        _SoftField(
          controller: widget.emailController,
          hintText: 'name@clinic.com',
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _labelInline('Mật khẩu'),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'Quên mật khẩu?',
                style: GoogleFonts.manrope(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                  color: const Color(0xFF006A62),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _SoftField(
          controller: widget.passwordController,
          hintText: '••••••••',
          obscureText: _obscurePassword,
          onToggleObscure: () =>
              setState(() => _obscurePassword = !_obscurePassword),
        ),
        const SizedBox(height: 24),
        _PrimaryGradientButton(
          label: 'Vào ứng dụng',
          onPressed: widget.onSubmit,
        ),
      ],
    );
  }

  Widget _label(String text) {
    return Text(
      text.toUpperCase(),
      style: GoogleFonts.manrope(
        fontSize: 10,
        fontWeight: FontWeight.w800,
        letterSpacing: 2,
        color: const Color(0xFF3C4947),
      ),
    );
  }

  Widget _labelInline(String text) {
    return Text(
      text.toUpperCase(),
      style: GoogleFonts.manrope(
        fontSize: 10,
        fontWeight: FontWeight.w800,
        letterSpacing: 2,
        color: const Color(0xFF3C4947),
      ),
    );
  }
}

class _SoftField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;
  final bool obscureText;
  final VoidCallback? onToggleObscure;
  final TextCapitalization textCapitalization;

  const _SoftField({
    required this.controller,
    required this.hintText,
    this.keyboardType,
    this.obscureText = false,
    this.onToggleObscure,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  Widget build(BuildContext context) {
    final showEye = onToggleObscure != null;
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F4),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              obscureText: obscureText,
              keyboardType: keyboardType,
              textCapitalization: textCapitalization,
              style: GoogleFonts.manrope(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF191C1D),
              ),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 18),
                hintText: hintText,
                hintStyle: GoogleFonts.manrope(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF6C7A77).withValues(alpha: 0.55),
                ),
              ),
            ),
          ),
          if (showEye)
            IconButton(
              onPressed: onToggleObscure,
              icon: Icon(
                obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                size: 22,
                color: const Color(0xFF6C7A77),
              ),
            ),
        ],
      ),
    );
  }
}

class _PrimaryGradientButton extends StatefulWidget {
  final String label;
  final VoidCallback onPressed;

  const _PrimaryGradientButton({
    required this.label,
    required this.onPressed,
  });

  @override
  State<_PrimaryGradientButton> createState() =>
      _PrimaryGradientButtonState();
}

class _PrimaryGradientButtonState extends State<_PrimaryGradientButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onPressed,
      child: AnimatedScale(
        scale: _pressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Container(
          height: 54,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF006A62), Color(0xFF2EC4B6)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF006A62).withValues(alpha: 0.25),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            widget.label,
            style: GoogleFonts.epilogue(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _SocialDivider extends StatelessWidget {
  const _SocialDivider();

  @override
  Widget build(BuildContext context) {
    final outline = const Color(0xFFBBCAC6).withValues(alpha: 0.35);
    return Row(
      children: [
        Expanded(child: Divider(height: 1, color: outline)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            'SOCIAL GATEWAY',
            style: GoogleFonts.manrope(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 2.4,
              color: const Color(0xFF6C7A77),
            ),
          ),
        ),
        Expanded(child: Divider(height: 1, color: outline)),
      ],
    );
  }
}

class _SocialButtonsRow extends StatelessWidget {
  const _SocialButtonsRow();

  @override
  Widget build(BuildContext context) {
    final border = const Color(0xFFBBCAC6).withValues(alpha: 0.35);
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF3C4947),
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: BorderSide(color: border),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () {},
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _googleMark(),
                const SizedBox(width: 10),
                Text(
                  'Google',
                  style: GoogleFonts.manrope(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF3C4947),
              padding: const EdgeInsets.symmetric(vertical: 14),
              side: BorderSide(color: border),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () {},
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.apple, size: 22, color: Color(0xFF191C1D)),
                const SizedBox(width: 8),
                Text(
                  'Apple',
                  style: GoogleFonts.manrope(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Gợi ý logo Google đơn giản (4 màu) giống thiết kế.
  Widget _googleMark() {
    return SizedBox(
      width: 22,
      height: 22,
      child: CustomPaint(
        painter: _GoogleGPainter(),
      ),
    );
  }
}

class _GoogleGPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final r = size.shortestSide / 2;
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()..style = PaintingStyle.stroke..strokeWidth = 2.2;
    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: r - 1),
      -0.4,
      2.2,
      false,
      paint,
    );
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: r - 1),
      2.0,
      1.1,
      false,
      paint,
    );
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: r - 1),
      3.2,
      0.9,
      false,
      paint,
    );
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: r - 1),
      4.2,
      1.4,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FooterLinks extends StatelessWidget {
  const _FooterLinks();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text.rich(
          TextSpan(
            text: 'New to the community? ',
            style: GoogleFonts.manrope(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF3C4947),
            ),
            children: [
              TextSpan(
                text: 'Request an invitation',
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF006A62),
                ),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 20,
          runSpacing: 8,
          children: [
            _footerLink('Privacy'),
            _footerLink('Security'),
            _footerLink('Terms'),
          ],
        ),
      ],
    );
  }

  Widget _footerLink(String t) {
    return Text(
      t,
      style: GoogleFonts.manrope(
        fontSize: 10,
        fontWeight: FontWeight.w800,
        letterSpacing: 2,
        color: const Color(0xFF6C7A77),
      ),
    );
  }
}

class _SideInfoColumn extends StatelessWidget {
  const _SideInfoColumn();

  @override
  Widget build(BuildContext context) {
    final first = _InfoCard(
      icon: Icons.health_and_safety_rounded,
      iconColor: tertiaryContainer,
      bg: tertiaryContainer.withValues(alpha: 0.10),
      border: tertiaryContainer.withValues(alpha: 0.20),
      title: 'Secure Care',
      body:
          'Your data is protected with clinical-grade encryption protocol.',
    );
    final second = _InfoCard(
      icon: Icons.verified_user_rounded,
      iconColor: primary,
      bg: primaryContainer.withValues(alpha: 0.10),
      border: primaryContainer.withValues(alpha: 0.20),
      title: 'Verified Specialists',
      body:
          'Connect only with board-certified healthcare professionals.',
    );

    final cards = [
      first,
      const SizedBox(height: 16),
      Transform.translate(
        offset: const Offset(24, 0),
        child: second,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: cards,
    );
  }

  static const Color primary = Color(0xFF006A62);
  static const Color primaryContainer = Color(0xFF2EC4B6);
  static const Color tertiaryContainer = Color(0xFFF99A15);
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color bg;
  final Color border;
  final String title;
  final String body;

  const _InfoCard({
    required this.icon,
    required this.iconColor,
    required this.bg,
    required this.border,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 28, color: iconColor),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.epilogue(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF191C1D),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            body,
            style: GoogleFonts.manrope(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              height: 1.45,
              color: const Color(0xFF3C4947),
            ),
          ),
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
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(size * 0.55),
        topRight: Radius.circular(size * 0.45),
        bottomLeft: Radius.circular(size * 0.38),
        bottomRight: Radius.circular(size * 0.62),
      ),
    ),
  );
}

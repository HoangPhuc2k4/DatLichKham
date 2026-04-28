import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final Color? backgroundColor;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isLoading = false,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    // Màu mặc định là Teal 700 nếu không được truyền vào
    final primaryColor = backgroundColor ?? const Color(0xFF0D9488);
    final isDisabled = onPressed == null || isLoading;

    return SizedBox(
      height: 52, // Tăng nhẹ chiều cao để trông cao cấp hơn
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isDisabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          disabledBackgroundColor: primaryColor.withOpacity(0.5),
          disabledForegroundColor: Colors.white.withOpacity(0.8),
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24),
        ).copyWith(
          // Hiệu ứng đổ bóng nhẹ khi hover (dành cho Web/Desktop)
          overlayColor: WidgetStateProperty.resolveWith<Color?>(
                (states) {
              if (states.contains(WidgetState.hovered)) {
                return Colors.white.withOpacity(0.08);
              }
              if (states.contains(WidgetState.pressed)) {
                return Colors.black.withOpacity(0.08);
              }
              return null;
            },
          ),
        ),
        child: isLoading
            ? const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 18),
              const SizedBox(width: 10),
            ],
            Text(
              label,
              style: GoogleFonts.manrope(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
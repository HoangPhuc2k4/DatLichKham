import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum AppConfirmTone { danger, neutral }

Future<bool> showAppConfirmDialog(
    BuildContext context, {
      required String title,
      required String message,
      String confirmText = 'XÁC NHẬN',
      String cancelText = 'HỦY',
      AppConfirmTone tone = AppConfirmTone.danger,
    }) async {
  final res = await showGeneralDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierLabel: '',
    barrierColor: Colors.black54, // Làm tối nền để nổi bật Dialog
    transitionDuration: const Duration(milliseconds: 200),
    pageBuilder: (context, anim1, anim2) => _AppConfirmDialog(
      title: title,
      message: message,
      confirmText: confirmText,
      cancelText: cancelText,
      tone: tone,
    ),
    transitionBuilder: (context, anim1, anim2, child) {
      return ScaleTransition(
        scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
        child: FadeTransition(opacity: anim1, child: child),
      );
    },
  );
  return res ?? false;
}

class _AppConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final AppConfirmTone tone;

  const _AppConfirmDialog({
    required this.title,
    required this.message,
    required this.confirmText,
    required this.cancelText,
    required this.tone,
  });

  @override
  Widget build(BuildContext context) {
    // Màu sắc theo tone nhưng theo hệ màu của trang chủ
    final isDanger = tone == AppConfirmTone.danger;
    final accent = isDanger ? const Color(0xFFBA1A1A) : const Color(0xFF006A62);
    final bgAccent = isDanger ? const Color(0xFFFFDAD6) : const Color(0xFFE6F4F1);

    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32), // Bo góc lớn đồng bộ Bento
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Dialog(
              backgroundColor: Colors.white.withOpacity(0.9),
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400), // Dialog nhỏ gọn hơn
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Icon Header nổi bật
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: bgAccent,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isDanger ? Icons.report_problem_rounded : Icons.help_outline_rounded,
                          color: accent,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Typography đồng bộ (Epilogue)
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.epilogue(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF191C1D),
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Message (Manrope)
                      Text(
                        message,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.manrope(
                          fontSize: 15,
                          height: 1.6,
                          color: const Color(0xFF3C4947),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Action Buttons
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Nút Xác nhận (Primary)
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accent,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            onPressed: () => Navigator.pop(context, true),
                            child: Text(
                              confirmText,
                              style: GoogleFonts.manrope(fontWeight: FontWeight.w800, fontSize: 14),
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Nút Hủy (Secondary)
                          TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF3C4947),
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            ),
                            onPressed: () => Navigator.pop(context, false),
                            child: Text(
                              cancelText,
                              style: GoogleFonts.manrope(fontWeight: FontWeight.w800, fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
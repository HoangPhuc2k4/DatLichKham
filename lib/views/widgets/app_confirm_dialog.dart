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
  final res = await showDialog<bool>(
    context: context,
    barrierDismissible: true, // Cho phép bấm ra ngoài để đóng
    builder: (context) => _AppConfirmDialog(
      title: title,
      message: message,
      confirmText: confirmText,
      cancelText: cancelText,
      tone: tone,
    ),
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
    final isDanger = tone == AppConfirmTone.danger;
    final accent = isDanger ? const Color(0xFFBA1A1A) : const Color(0xFF0D9488);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 40,
                offset: const Offset(0, 10),
              )
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header với Icon
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: accent.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isDanger ? Icons.warning_amber_rounded : Icons.help_outline_rounded,
                        color: accent,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        title,
                        style: GoogleFonts.epilogue(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Content
                Text(
                  message,
                  style: GoogleFonts.manrope(
                    fontSize: 15,
                    height: 1.6,
                    color: const Color(0xFF475569),
                  ),
                ),
                const SizedBox(height: 32),

                // Actions
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context, false),
                        child: Text(
                          cancelText,
                          style: GoogleFonts.manrope(
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: accent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context, true),
                        child: Text(
                          confirmText,
                          style: GoogleFonts.manrope(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
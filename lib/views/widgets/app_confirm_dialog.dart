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
    barrierDismissible: false,
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
    final accent = tone == AppConfirmTone.danger ? const Color(0xFFBA1A1A) : const Color(0xFF006A62);
    return Dialog(
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.12),
                      border: Border.all(color: accent.withValues(alpha: 0.25)),
                    ),
                    child: Icon(
                      tone == AppConfirmTone.danger ? Icons.warning_amber_rounded : Icons.help_outline,
                      color: accent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: -0.2),
                    ),
                  ),
                  IconButton(onPressed: () => Navigator.pop(context, false), icon: const Icon(Icons.close)),
                ],
              ),
              const SizedBox(height: 12),
              Container(height: 1, color: const Color(0xFFE1E3E4)),
              const SizedBox(height: 12),
              Text(message, style: GoogleFonts.manrope(fontSize: 13, height: 1.4, color: Colors.black87)),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    style: TextButton.styleFrom(
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                      foregroundColor: Colors.black54,
                    ),
                    onPressed: () => Navigator.pop(context, false),
                    child: Text(cancelText, style: GoogleFonts.manrope(fontWeight: FontWeight.w900, letterSpacing: 1.2, fontSize: 11)),
                  ),
                  const SizedBox(width: 10),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                      backgroundColor: accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                    ),
                    onPressed: () => Navigator.pop(context, true),
                    child: Text(confirmText, style: GoogleFonts.manrope(fontWeight: FontWeight.w900, letterSpacing: 1.2, fontSize: 11)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}


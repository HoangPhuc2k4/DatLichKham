import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  static const Color _bg = Color(0xFFECEEEE);
  static const Color _onSurfaceVariant = Color(0xFF3C4947);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 44),
      decoration: const BoxDecoration(color: _bg),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1440),
        child: LayoutBuilder(
          builder: (context, c) {
            final isWide = c.maxWidth >= 760;
            final links = Wrap(
              alignment: isWide ? WrapAlignment.end : WrapAlignment.start,
              spacing: 24,
              runSpacing: 10,
              children: const [
                _FooterLink('Chính sách riêng tư'),
                _FooterLink('Điều khoản dịch vụ'),
                _FooterLink('Trung tâm trợ giúp'),
                _FooterLink('Liên hệ'),
              ],
            );

            if (!isWide) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _brand(),
                  const SizedBox(height: 18),
                  links,
                ],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _brand()),
                const SizedBox(width: 18),
                links,
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _brand() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Curated Clinic',
          style: GoogleFonts.epilogue(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: const Color(0xFF191C1D),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '© 2026 Curated Clinic. Một tiêu chuẩn mới cho chăm sóc sức khỏe.',
          style: GoogleFonts.manrope(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            height: 1.4,
            color: _onSurfaceVariant.withValues(alpha: 0.75),
          ),
        ),
      ],
    );
  }
}

class _FooterLink extends StatelessWidget {
  final String label;
  const _FooterLink(this.label);

  static const Color _onSurfaceVariant = Color(0xFF3C4947);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Text(
        label,
        style: GoogleFonts.manrope(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: _onSurfaceVariant.withValues(alpha: 0.80),
          decoration: TextDecoration.none,
        ),
      ),
    );
  }
}


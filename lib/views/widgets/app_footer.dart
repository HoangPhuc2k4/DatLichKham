import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  // Cập nhật bảng màu đồng bộ với Home Page và My Appointments
  static const Color _bg = Color(0xFF0F172A); // Slate 900
  static const Color _textPrimary = Colors.white;
  static const Color _textSecondary = Color(0xFF94A3B8); // Slate 400

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
      decoration: const BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: LayoutBuilder(
            builder: (context, c) {
              final isWide = c.maxWidth >= 850;

              if (isWide) {
                return Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 2, child: _buildBrandInfo()),
                        Expanded(child: _buildLinkColumn('Dịch vụ', ['Tìm bác sĩ', 'Chuyên khoa', 'Đặt lịch nhanh', 'Tư vấn video'])),
                        Expanded(child: _buildLinkColumn('Hỗ trợ', ['Trung tâm trợ giúp', 'Câu hỏi thường gặp', 'Liên hệ', 'Tuyển dụng'])),
                        Expanded(child: _buildSocialSection()),
                      ],
                    ),
                    const SizedBox(height: 60),
                    _buildBottomBar(true),
                  ],
                );
              }

              // Giao diện Mobile
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBrandInfo(),
                  const SizedBox(height: 40),
                  _buildLinkColumn('Dịch vụ', ['Tìm bác sĩ', 'Chuyên khoa', 'Đặt lịch nhanh']),
                  const SizedBox(height: 32),
                  _buildLinkColumn('Hỗ trợ', ['Trung tâm trợ giúp', 'Liên hệ']),
                  const SizedBox(height: 40),
                  _buildSocialSection(),
                  const SizedBox(height: 40),
                  const Divider(color: Color(0xFF1E293B)),
                  const SizedBox(height: 24),
                  _buildBottomBar(false),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBrandInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0xFF0D9488),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.health_and_safety, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              'Curated Clinic',
              style: GoogleFonts.epilogue(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: _textPrimary,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: 280,
          child: Text(
            'Tiêu chuẩn mới trong chăm sóc sức khỏe kỹ thuật số. Kết nối bạn với những chuyên gia hàng đầu.',
            style: GoogleFonts.manrope(
              fontSize: 14,
              color: _textSecondary,
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLinkColumn(String title, List<String> links) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title.toUpperCase(),
          style: GoogleFonts.manrope(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: _textPrimary,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 20),
        ...links.map((link) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () {},
            child: Text(
              link,
              style: GoogleFonts.manrope(
                fontSize: 14,
                color: _textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildSocialSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'THEO DÕI CHÚNG TÔI',
          style: GoogleFonts.manrope(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: _textPrimary,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            _socialIcon(Icons.facebook),
            const SizedBox(width: 12),
            _socialIcon(Icons.camera_alt_outlined),
            const SizedBox(width: 12),
            _socialIcon(Icons.alternate_email),
          ],
        ),
      ],
    );
  }

  Widget _socialIcon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF1E293B)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: _textSecondary, size: 20),
    );
  }

  Widget _buildBottomBar(bool isWide) {
    final copyright = Text(
      '© 2026 Curated Clinic. All rights reserved.',
      style: GoogleFonts.manrope(
        fontSize: 13,
        color: _textSecondary.withOpacity(0.6),
      ),
    );

    final legalLinks = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _bottomLink('Chính sách riêng tư'),
        const SizedBox(width: 24),
        _bottomLink('Điều khoản'),
      ],
    );

    if (isWide) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [copyright, legalLinks],
      );
    }
    return Column(
      children: [legalLinks, const SizedBox(height: 16), copyright],
    );
  }

  Widget _bottomLink(String label) {
    return InkWell(
      onTap: () {},
      child: Text(
        label,
        style: GoogleFonts.manrope(
          fontSize: 13,
          color: _textSecondary.withOpacity(0.6),
        ),
      ),
    );
  }
}
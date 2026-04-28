import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  // Hệ màu đồng bộ với Premium Bento
  static const Color _bg = Color(0xFF191C1D);
  static const Color _accentMint = Color(0xFF2EC4B6);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
          horizontal: width < 600 ? 24 : 40,
          vertical: 80
      ),
      decoration: const BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(48)),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: Column(
            children: [
              LayoutBuilder(
                builder: (context, c) {
                  final isWide = c.maxWidth >= 800;

                  if (isWide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 4, child: _brandArea()),
                        const Spacer(),
                        const Expanded(flex: 7, child: _FooterLinksGrid()),
                      ],
                    );
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _brandArea(),
                      const SizedBox(height: 60),
                      const _FooterLinksGrid(),
                    ],
                  );
                },
              ),
              const SizedBox(height: 80),
              const Divider(color: Colors.white10, height: 1),
              const SizedBox(height: 40),
              _bottomBar(width < 600),
            ],
          ),
        ),
      ),
    );
  }

  Widget _brandArea() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _accentMint,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.health_and_safety, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Text(
              'Curated Clinic',
              style: GoogleFonts.epilogue(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(
          'Định nghĩa lại trải nghiệm chăm sóc sức khỏe cá nhân hóa với tiêu chuẩn premium quốc tế.',
          style: GoogleFonts.manrope(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            height: 1.6,
            color: Colors.white.withOpacity(0.5),
          ),
        ),
        const SizedBox(height: 32),
        Row(
          children: [
            // Đã sửa lỗi: Sử dụng các Icon cơ bản để tránh lỗi member not found
            _socialIcon(Icons.facebook),
            const SizedBox(width: 12),
            _socialIcon(Icons.camera_alt),
            const SizedBox(width: 12),
            _socialIcon(Icons.link), // Thay thế linkedin_rounded bị lỗi
          ],
        )
      ],
    );
  }

  Widget _socialIcon(IconData icon) {
    return InkWell(
      onTap: () {},
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white.withOpacity(0.08)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white.withOpacity(0.7), size: 20),
      ),
    );
  }

  Widget _bottomBar(bool isSmall) {
    final content = [
      Text(
        '© 2026 Curated Clinic. All rights reserved.',
        style: GoogleFonts.manrope(
          fontSize: 13,
          color: Colors.white.withOpacity(0.3),
        ),
      ),
      if (isSmall) const SizedBox(height: 20),
      Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.language, color: Colors.white.withOpacity(0.3), size: 16),
          const SizedBox(width: 8),
          Text(
            'Tiếng Việt (VN)',
            style: GoogleFonts.manrope(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.white.withOpacity(0.3),
            ),
          ),
        ],
      )
    ];

    return isSmall
        ? Column(children: content)
        : Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: content);
  }
}

class _FooterLinksGrid extends StatelessWidget {
  const _FooterLinksGrid();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    return Wrap(
      spacing: 40,
      runSpacing: 40,
      alignment: WrapAlignment.spaceBetween,
      children: [
        _buildColumn('Dịch vụ', ['Tìm bác sĩ', 'Chuyên khoa', 'Đặt lịch nhanh', 'Gói khám tổng quát'], width),
        _buildColumn('Hỗ trợ', ['Trung tâm trợ giúp', 'Liên hệ chúng tôi', 'Quy trình khám', 'Câu hỏi thường gặp'], width),
        _buildColumn('Pháp lý', ['Chính sách bảo mật', 'Điều khoản sử dụng', 'Quyền lợi bệnh nhân'], width),
      ],
    );
  }

  Widget _buildColumn(String title, List<String> links, double totalWidth) {
    return SizedBox(
      width: totalWidth < 600 ? (totalWidth - 80) / 2 : 160,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: GoogleFonts.manrope(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.5,
              color: const Color(0xFF2EC4B6),
            ),
          ),
          const SizedBox(height: 24),
          ...links.map((link) => Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: InkWell(
              onTap: () {},
              child: Text(
                link,
                style: GoogleFonts.manrope(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
            ),
          )),
        ],
      ),
    );
  }
}
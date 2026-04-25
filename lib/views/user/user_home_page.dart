import 'package:flutter/material.dart';

import '../widgets/doctor_image.dart';

class UserHomePage extends StatelessWidget {
  const UserHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFA),
      body: SafeArea(
        child: Column(
          children: const [
            _TopNavBar(),
            Expanded(
              child: _HomeBody(),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopNavBar extends StatelessWidget {
  const _TopNavBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Curated Clinic',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          Row(
            children: [
              _navItem('Tìm bác sĩ', isActive: true),
              const SizedBox(width: 16),
              _navItem('Chuyên gia'),
              const SizedBox(width: 16),
              _navItem('Lịch hẹn'),
              const SizedBox(width: 16),
              _navItem('Sức khỏe'),
              const SizedBox(width: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2EC4B6),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed('/');
                },
                child: const Text(
                  'Đăng nhập',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _navItem(String label, {bool isActive = false}) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 13,
        fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
        color: isActive ? const Color(0xFF2EC4B6) : const Color(0xFF3C4947),
      ),
    );
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 900;
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _HeroSection(isWide: isWide),
              const SizedBox(height: 40),
              const _SpecialistsSection(),
              const SizedBox(height: 40),
              const _ExperienceCareSection(),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }
}

class _HeroSection extends StatelessWidget {
  final bool isWide;

  const _HeroSection({required this.isWide});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Health,\nCarefully Curated.',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Skip the waiting room. Connect with world-class specialists '
                'through an experience designed for your well-being. '
                'Proactive, personalized, and premium.',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 16,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              _SearchBar(),
            ],
          ),
        ),
        if (isWide) const SizedBox(width: 24),
        if (isWide)
          Expanded(
            flex: 2,
            child: _DoctorHeroCard(),
          ),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _SearchField(
              icon: Icons.search,
              hint: 'Specialty, doctor name, or clinic',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _SearchField(
              icon: Icons.location_on_outlined,
              hint: 'Location',
            ),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF006A62),
              padding:
                  const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            onPressed: () {},
            child: const Text(
              'Book Appointment',
              style: TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final IconData icon;
  final String hint;

  const _SearchField({required this.icon, required this.hint});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F4),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF006A62)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              hint,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DoctorHeroCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _HoverScale(
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 320,
            decoration: BoxDecoration(
              color: const Color(0xFFC5E4FA).withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(48),
            ),
          ),
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Align(
                alignment: Alignment.center,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: const DoctorImage(
                    pathOrUrl:
                        // lấy trực tiếp từ thiết kế home_page_curated_clinic
                        'https://lh3.googleusercontent.com/aida-public/AB6AXuALzjGvI7RG-nVb5i62uMGRIwFkn1VaqIEJ8dKwOcBzjlE7JUMqqfVK3jB3wP_6m-OTymNgCeFebtLzZVBBTkhje88MfyZpwpcMWD3qRFtUouC4n04EA6-xdx_OcLODpP-vTLmT1IBVjaZQFDLbB-1t8I1jWtSznl57ZAN2te6dDUhf-uaogBTbThrBf76asK89gxPyYU8WKwT0cfmdpfBJ7jbuW-y3jSfnNCCMja3qm9C3IxCyCDl31BCMqkygDCGhWeX7Pr2pwbA',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -20,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: const [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: Color(0xFFF99A15),
                    child: Icon(
                      Icons.verified,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    '500+ Top Specialists',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpecialistsSection extends StatelessWidget {
  const _SpecialistsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            _SectionTitle(
              title: 'World-Class Specialists',
              subtitle: 'Recommended for you',
            ),
            Text(
              'View all →',
              style: TextStyle(
                color: Color(0xFF006A62),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: const [
              _DoctorCard(
                name: 'Dr. Sarah Jenkins',
                role: 'Lead Cardiologist',
                rating: '4.9',
              ),
              SizedBox(width: 16),
              _DoctorCard(
                name: 'Dr. Marcus Thorne',
                role: 'Neurology Specialist',
                rating: '5.0',
                highlight: true,
              ),
              SizedBox(width: 16),
              _DoctorCard(
                name: 'Dr. Elena Rodriguez',
                role: 'Pediatric Wellness',
                rating: '4.8',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionTitle({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          subtitle.toUpperCase(),
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
            color: Color(0xFF895100),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _DoctorCard extends StatelessWidget {
  final String name;
  final String role;
  final String rating;
  final bool highlight;

  const _DoctorCard({
    required this.name,
    required this.role,
    required this.rating,
    this.highlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = switch (name) {
      'Dr. Sarah Jenkins' =>
        'https://lh3.googleusercontent.com/aida-public/AB6AXuACxIl2BQtqmStUjBo1hH3_ZU3isctPoPOlKOtOI0Vmj1iIwbV7oYx2_ZLLVYo6VLVHcuqslIP1HIV6l46lyxMQpe1ebenVOh4q1CKXpFYjtYMPlA1ein57VpPeEShPP9T8apABS8pG2y1RuNKsECAXb90G3DhXViRCQgRopuJiooAjQPzAYCh_PBgtVBz7hFvxcjqNniBYko4-uO1wFPA5bVitNaRV4fVznlu05D_kTmw_wgnJfCcBPLOSubGjw4evVUCrpmBLEnc',
      'Dr. Marcus Thorne' =>
        'https://lh3.googleusercontent.com/aida-public/AB6AXuAI3EhnM7K8H2AzHeJvtzCYy6yeXxtUcXaIXr54pRPmeWBN4OZya6Iuq4qduY7GQHg4HWm6JayE4Vg8hlfe2QZxe3W5N3lY2cte3M6Zs5x9lBV2XBtpGAVOsbgUgVim2AuomfXQXzubII7aS-LQhLeHLr4r2X-fFI82P1m5pCNgxEOo4eURzcDMzzY9IxhDUSrJNh-_c4hawTJBWAhRdk5e0slitcfZfu4RELeuyc7zDOh-lrnpZrJikP2XDMvlChhb0xWLCrg5lLc',
      'Dr. Elena Rodriguez' =>
        'https://lh3.googleusercontent.com/aida-public/AB6AXuAoYJVAa1lW6LB6w8uSaep9p3Dt_infnhy8lENKMdjX1h2tRwwPiHteodgBsI6-FysNuST7MGayhprCPZR-97UBABdu1dI7nCJL4kOvPQcbP_RVUnNeb3uy5MYaqjgLcfe99OO_YvzUXfGoQ6CvgSfZ_9ngNLB5Vz1rV0dZYSf4cI86Df6OcBdlAVxom_ocECUlnL0VhI1OhwPRHdflV3xkZl6WWRb9ZnCYbLDdxHQtWNt9K3muBKHFx676VEFjjEZNt_g27oXeEO8',
      _ => null,
    };

    return _HoverScale(
      child: Container(
        width: 220,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: highlight ? Colors.white : const Color(0xFFECEEEE),
          borderRadius: BorderRadius.circular(28),
          boxShadow: highlight
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  )
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: AspectRatio(
                aspectRatio: 1,
                child: imageUrl != null
                    ? DoctorImage(pathOrUrl: imageUrl, fit: BoxFit.cover)
                    : Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF2EC4B6), Color(0xFF006A62)],
                          ),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        role,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.favorite_border,
                    color: Color(0xFF2EC4B6),
                    size: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    CircleAvatar(radius: 8, backgroundColor: Colors.white),
                    SizedBox(width: 4),
                    CircleAvatar(radius: 8, backgroundColor: Colors.white70),
                    SizedBox(width: 4),
                    CircleAvatar(radius: 8, backgroundColor: Colors.white38),
                  ],
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.star,
                      size: 16,
                      color: Color(0xFFF99A15),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      rating,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HoverScale extends StatefulWidget {
  final Widget child;

  const _HoverScale({required this.child});

  @override
  State<_HoverScale> createState() => _HoverScaleState();
}

class _HoverScaleState extends State<_HoverScale> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedScale(
        scale: _hovered ? 1.03 : 1.0,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

class _ExperienceCareSection extends StatelessWidget {
  const _ExperienceCareSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFECEEEE),
        borderRadius: BorderRadius.circular(40),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Expanded(
            flex: 2,
            child: _ExperienceText(),
          ),
          SizedBox(width: 20),
          Expanded(
            flex: 2,
            child: _BookingTimeline(),
          ),
        ],
      ),
    );
  }
}

class _ExperienceText extends StatelessWidget {
  const _ExperienceText();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Experience Care\nWithout the Friction.',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 18),
        _Bullet(
          icon: Icons.bolt,
          title: 'Instant Booking',
          description:
              'No phone calls required. Confirm your appointment in 60 seconds or less.',
        ),
        const SizedBox(height: 16),
        _Bullet(
          icon: Icons.video_chat,
          title: 'Hybrid Care',
          description:
              'Choose between virtual consultations or premium in-clinic visits.',
        ),
        const SizedBox(height: 16),
        _Bullet(
          icon: Icons.folder_shared,
          title: 'Smart Health Vault',
          description:
              'Access your medical history, labs, and prescriptions in one hub.',
        ),
      ],
    );
  }
}

class _Bullet extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _Bullet({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: const Color(0xFF006A62)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BookingTimeline extends StatelessWidget {
  const _BookingTimeline();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Phiên đặt lịch',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              Text(
                '24/10/2024',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _timelineItem(
            time: '09:00 AM',
            title: 'Khám tổng quát',
            dimmed: true,
          ),
          const SizedBox(height: 10),
          _timelineItem(
            time: '11:30 AM',
            title: 'Tư vấn nha khoa',
            accent: true,
          ),
          const SizedBox(height: 10),
          _timelineItem(
            time: '02:15 PM',
            title: 'Nhi khoa',
          ),
        ],
      ),
    );
  }

  Widget _timelineItem({
    required String time,
    required String title,
    bool dimmed = false,
    bool accent = false,
  }) {
    final baseColor = accent
        ? const Color(0xFFF99A15)
        : const Color(0xFF6C7A77).withValues(alpha: 0.4);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: accent
            ? const Color(0xFFFFF6EC)
            : dimmed
                ? const Color(0xFFF2F4F4)
                : const Color(0xFFF8FAFA),
        borderRadius: BorderRadius.circular(18),
        border: accent
            ? Border(
                left: BorderSide(
                  color: baseColor,
                  width: 4,
                ),
              )
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                time,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: baseColor,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 2,
                height: 28,
                color: baseColor.withValues(alpha: 0.4),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          if (accent)
            const Icon(
              Icons.check_circle,
              color: Color(0xFFF99A15),
            )
          else if (dimmed)
            const Icon(
              Icons.lock_outline,
              color: Colors.grey,
              size: 18,
            )
          else
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {},
              child: const Text(
                'Select',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }
}


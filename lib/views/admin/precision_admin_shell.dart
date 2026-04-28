import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../controllers/session_controller.dart';
import 'widgets/precision_admin_nav.dart';

enum PrecisionAdminRoute { dashboard, doctors, schedules, appointments }

class PrecisionAdminShell extends StatelessWidget {
  final PrecisionAdminRoute route;
  final Widget child;
  final String title;
  final Widget? headerRight;

  const PrecisionAdminShell({
    super.key,
    required this.route,
    required this.child,
    required this.title,
    this.headerRight,
  });

  static const _sidebarW = 256.0;
  static const _bg = Color(0xFFF8F9FA);
  static const _navBg = Color(0xFF012435);

  @override
  Widget build(BuildContext context) {
    final user = SessionController.instance.currentUser;
    if (user == null || user.role != 'admin') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed('/');
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: _bg,
      body: Row(
        children: [
          SizedBox(
            width: _sidebarW,
            child: PrecisionAdminSidebar(active: route),
          ),
          Expanded(
            child: Column(
              children: [
                const PrecisionAdminTopBar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1240),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: Text(
                                    title,
                                    style: GoogleFonts.spaceGrotesk(
                                      fontSize: 40,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.8,
                                      color: _navBg,
                                    ),
                                  ),
                                ),
                                if (headerRight != null) headerRight!,
                              ],
                            ),
                            const SizedBox(height: 18),
                            child,
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

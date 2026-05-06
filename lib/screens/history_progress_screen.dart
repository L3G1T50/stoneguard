import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import 'history_screen.dart';
import 'progress_screen.dart';
import 'settings_screen.dart';

// ─── MERGED HISTORY + PROGRESS SCREEN ────────────────────────────────────────
// Shows Progress charts (default tab) and History entries (second tab).
// Teal-fade gradient header matches the rest of the app (GradientScaffold).

class HistoryProgressScreen extends StatefulWidget {
  const HistoryProgressScreen({super.key});

  @override
  State<HistoryProgressScreen> createState() => _HistoryProgressScreenState();
}

class _HistoryProgressScreenState extends State<HistoryProgressScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this, initialIndex: 0);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Same gradient as GradientScaffold — teal fade on light, dark on dark
    final List<Color> gradientColors = isDark
        ? [
            const Color(0xFF01696F),
            const Color(0xFF025A60),
            AppColors.darkBackground,
            AppColors.darkBackground,
          ]
        : [
            const Color(0xFF01696F),
            const Color(0xFF2A9DA5),
            const Color(0xFFE0F4F5),
            Colors.white,
          ];
    const gradientStops = [0.0, 0.18, 0.42, 0.62];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : Colors.white,
        body: Stack(
          children: [
            // ── Teal gradient background (same as every other tab) ──
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: const Alignment(0, 0.55),
                    colors: gradientColors,
                    stops: gradientStops,
                  ),
                ),
              ),
            ),

            // ── SafeArea with custom header + tabs + content ──
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Header row: title + settings gear ──
                  SizedBox(
                    height: 52,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 56),
                          child: Text(
                            'History & Progress',
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          child: IconButton(
                            icon: const Icon(
                              Icons.settings_outlined,
                              color: Colors.white,
                              size: 22,
                            ),
                            tooltip: 'Settings',
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const SettingsScreen()),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Segmented tab bar ──
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                    child: Container(
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TabBar(
                        controller: _tabController,
                        labelColor: isDark
                            ? AppColors.darkBackground
                            : const Color(0xFF01696F),
                        unselectedLabelColor:
                            Colors.white.withValues(alpha: 0.85),
                        labelStyle: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                        unselectedLabelStyle: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                        indicator: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        indicatorSize: TabBarIndicatorSize.tab,
                        dividerColor: Colors.transparent,
                        tabs: const [
                          Tab(text: 'Charts'),
                          Tab(text: 'Entries'),
                        ],
                      ),
                    ),
                  ),

                  // ── Tab content ──
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: const [
                        _ProgressTab(),
                        _HistoryTab(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Progress (Charts) tab — keeps state alive when switching tabs ─────────────

class _ProgressTab extends StatefulWidget {
  const _ProgressTab();
  @override
  State<_ProgressTab> createState() => _ProgressTabState();
}

class _ProgressTabState extends State<_ProgressTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return const ProgressScreen();
  }
}

// ── History (Entries) tab — renders HistoryScreen directly in the same
//    Navigator/theme context so Theme.of(context) correctly sees dark mode ─────

class _HistoryTab extends StatefulWidget {
  const _HistoryTab();
  @override
  State<_HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<_HistoryTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // Render HistoryScreen directly — no nested Navigator — so it inherits
    // the MaterialApp theme (including dark mode) from the parent context.
    return const HistoryScreen();
  }
}

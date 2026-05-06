import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'history_screen.dart';
import 'progress_screen.dart';
import 'settings_screen.dart';

// ─── MERGED HISTORY + PROGRESS SCREEN ────────────────────────────────────────
// Shows Progress charts (default tab) and History entries (second tab).
// Settings gear in the AppBar navigates to SettingsScreen.

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
    final isDark       = Theme.of(context).brightness == Brightness.dark;
    final appBarBg     = isDark ? AppColors.darkSurface    : const Color(0xFFE8E8EC);
    final titleColor   = isDark ? AppColors.darkTextPrimary : const Color(0xFF2C2C2C);
    final mutedColor   = isDark ? AppColors.darkTextSecond  : const Color(0xFF888888);
    final segmentBg    = isDark ? AppColors.darkBackground  : const Color(0xFFD0D0D8);
    final accentTeal   = AppColors.primary;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: appBarBg,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'History & Progress',
          style: TextStyle(
            color: titleColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.settings_outlined, color: titleColor),
            tooltip: 'Settings',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Container(
              height: 36,
              decoration: BoxDecoration(
                color: segmentBg.withValues(alpha: isDark ? 0.5 : 0.35),
                borderRadius: BorderRadius.circular(20),
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: Colors.white,
                unselectedLabelColor: mutedColor,
                labelStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
                indicator: BoxDecoration(
                  color: accentTeal,
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
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _ProgressTab(),
          _HistoryTab(),
        ],
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

// ── History (Entries) tab — keeps state alive when switching tabs ─────────────

class _HistoryTab extends StatelessWidget {
  const _HistoryTab();
  @override
  Widget build(BuildContext context) {
    return const _EmbeddedHistory();
  }
}

class _EmbeddedHistory extends StatefulWidget {
  const _EmbeddedHistory();
  @override
  State<_EmbeddedHistory> createState() => _EmbeddedHistoryState();
}

class _EmbeddedHistoryState extends State<_EmbeddedHistory>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Navigator(
      onGenerateRoute: (_) => MaterialPageRoute(
        builder: (_) => const HistoryScreen(),
      ),
    );
  }
}

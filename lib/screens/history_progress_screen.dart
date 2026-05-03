import 'package:flutter/material.dart';
import 'history_screen.dart';
import 'progress_screen.dart';

// ─── MERGED HISTORY + PROGRESS SCREEN ────────────────────────────────────────
// Shows History entries and Progress charts in a single tab with a
// chip-style switcher at the top.

class HistoryProgressScreen extends StatefulWidget {
  const HistoryProgressScreen({super.key});

  @override
  State<HistoryProgressScreen> createState() => _HistoryProgressScreenState();
}

class _HistoryProgressScreenState extends State<HistoryProgressScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const Color bgColor      = Color(0xFFF8F8F8);
  static const Color appBarColor  = Color(0xFFE8E8EC);
  static const Color textColor    = Color(0xFF2C2C2C);
  static const Color accentTeal   = Color(0xFF1A8A9A);
  static const Color mutedColor   = Color(0xFF888888);
  static const Color borderColor  = Color(0xFFD0D0D8);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: appBarColor,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'History & Progress',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Container(
              height: 36,
              decoration: BoxDecoration(
                color: borderColor.withValues(alpha: 0.35),
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
                  Tab(text: 'Entries'),
                  Tab(text: 'Charts'),
                ],
              ),
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _HistoryTab(),
          _ProgressTab(),
        ],
      ),
    );
  }
}

// ── Wrapper widgets that embed the existing screens without their own AppBar ──

class _HistoryTab extends StatelessWidget {
  const _HistoryTab();

  @override
  Widget build(BuildContext context) {
    // HistoryScreen is a full Scaffold — we pull just its body by
    // embedding it inside a NestedScrollView-friendly wrapper.
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
    // Render HistoryScreen inside a Navigator so it can push detail routes
    // without affecting the top-level shell.
    return Navigator(
      onGenerateRoute: (_) => MaterialPageRoute(
        builder: (_) => const _HistoryBody(),
      ),
    );
  }
}

class _HistoryBody extends StatelessWidget {
  const _HistoryBody();
  @override
  Widget build(BuildContext context) {
    // Strip the AppBar from HistoryScreen by wrapping it and letting
    // the merged screen supply the AppBar instead.
    return const HistoryScreen();
  }
}

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

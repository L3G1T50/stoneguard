import 'package:flutter/material.dart';
import 'history_screen.dart';
import 'progress_screen.dart';
import 'settings_screen.dart';
import '../widgets/gradient_scaffold.dart';

// ─── MERGED HISTORY + PROGRESS SCREEN ─────────────────────────────────────────────────
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
    // Chip-style tab switcher that sits just below the gradient header
    final tabBar = Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Container(
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: Colors.white.withValues(alpha: 0.30), width: 1),
        ),
        child: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF01696F),
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(
              fontSize: 13, fontWeight: FontWeight.w600),
          unselectedLabelStyle: const TextStyle(
              fontSize: 13, fontWeight: FontWeight.w500),
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
    );

    return GradientScaffold(
      title: 'History & Progress',
      actions: [
        IconButton(
          icon: const Icon(Icons.settings_outlined, color: Colors.white),
          tooltip: 'Settings',
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const SettingsScreen()),
          ),
        ),
      ],
      body: Column(
        children: [
          tabBar,
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
    );
  }
}

// ── Wrapper widgets ───────────────────────────────────────────────────────────────
class _HistoryTab extends StatelessWidget {
  const _HistoryTab();
  @override
  Widget build(BuildContext context) => const _EmbeddedHistory();
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

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import '../utils/sharing.dart';
import '../models/session_model.dart';
import '../utils/parser_engine.dart';
import '../theme.dart';
import '../widgets/accordion_input.dart';
import '../widgets/search_autocomplete.dart';
import '../widgets/schedule_card.dart';
import '../widgets/bottom_nav_bar.dart';

class MainView extends StatefulWidget {
  final String initialSharedText;
  const MainView({Key? key, this.initialSharedText = ''}) : super(key: key);

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  int _currentTab = 0;
  List<BadmintonSession> _sessions = [];
  String _searchQuery = '';
  String _pastedText = '';
  bool _rememberSchedule = false;
  bool _filterIncompleteRoster = false;

  static const String _prefSessionsKey = 'shuttle_sessions';
  static const String _prefPastedTextKey = 'shuttle_pasted_text';
  static const String _prefRememberKey = 'shuttle_remember';

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    _initSharingListener();
    // Handle web share target via initialSharedText passed from main.dart
    if (widget.initialSharedText.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleSharedText(Uri.decodeComponent(widget.initialSharedText));
      });
    }
  }

  StreamSubscription<String>? _textIntentSub;

  void _initSharingListener() {
    // Handle cold-start share (when app launched via share)
    Sharing.getInitialText().then((String? value) {
      if (value != null && value.isNotEmpty) {
        _handleSharedText(value);
      }
    }).catchError((_) {});

    // Handle incoming share while app running
    _textIntentSub = Sharing.getTextStream().listen((String value) {
      if (mounted) _handleSharedText(value);
    }, onError: (_) {});
  }


  @override
  void dispose() {
    _textIntentSub?.cancel();
    super.dispose();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _rememberSchedule = prefs.getBool(_prefRememberKey) ?? false;
      if (_rememberSchedule) {
        _pastedText = prefs.getString(_prefPastedTextKey) ?? '';
        final sessionsJson = prefs.getString(_prefSessionsKey) ?? '';
        if (sessionsJson.isNotEmpty) {
          _sessions = BadmintonSession.decodeList(sessionsJson);
        } else {
          _sessions = ParserEngine.defaultSessions;
        }
      } else {
        _sessions = ParserEngine.defaultSessions;
      }
    });
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefRememberKey, _rememberSchedule);
    if (_rememberSchedule) {
      await prefs.setString(_prefPastedTextKey, _pastedText);
      await prefs.setString(_prefSessionsKey, BadmintonSession.encodeList(_sessions));
    } else {
      await prefs.remove(_prefPastedTextKey);
      await prefs.remove(_prefSessionsKey);
    }
  }

  void _processPastedSchedule(String text, bool remember) {
    setState(() {
      _pastedText = text;
      _rememberSchedule = remember;
      _sessions = ParserEngine.parse(text);
    });
    _savePreferences();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.flash_on, color: Colors.white),
            const SizedBox(width: 8),
            Text(
              'SLAY! Schedule parsed successfully.',
              style: ShuttleTheme.bodyMd.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        backgroundColor: ShuttleTheme.neonPink,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ShuttleTheme.radiusDefault)),
        margin: const EdgeInsets.all(ShuttleTheme.md),
      ),
    );
  }

  void _handleSharedText(String text) async {
    // Clear any previous schedule first
    _clearSchedule();
    // Reuse existing process flow so UI behaves the same as manual processing
    _processPastedSchedule(text, true);
  }

  void _clearSchedule() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefPastedTextKey);
    await prefs.remove(_prefSessionsKey);
    await prefs.setBool(_prefRememberKey, false);

    setState(() {
      _pastedText = '';
      _rememberSchedule = false;
      // Clear parsed sessions so summarized schedule is empty
      _sessions = [];
      // Reset search and filters
      _searchQuery = '';
      _filterIncompleteRoster = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.delete_sweep_outlined, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                'Schedule cleared.',
                style: ShuttleTheme.bodyMd.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          backgroundColor: ShuttleTheme.neonPink,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(ShuttleTheme.radiusDefault)),
          margin: const EdgeInsets.all(ShuttleTheme.md),
        ),
      );
    }
  }

  List<String> _getDistinctPlayers() {
    final Set<String> players = {};
    for (var session in _sessions) {
      players.addAll(session.players);
    }
    return players.toList()..sort();
  }

  List<BadmintonSession> _getFilteredSessions() {
    List<BadmintonSession> filtered = _sessions;

    if (_filterIncompleteRoster) {
      filtered = filtered.where((session) => session.isIncomplete).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((session) {
        return session.players.any((p) => p.toLowerCase().contains(query)) ||
               session.location.toLowerCase().contains(query) ||
               session.court.toLowerCase().contains(query);
      }).toList();
    }

    return filtered;
  }

  Map<String, List<BadmintonSession>> _groupSessionsByMonth(List<BadmintonSession> filtered) {
    final Map<String, List<BadmintonSession>> groups = {};
    for (var session in filtered) {
      final month = session.month.toUpperCase();
      if (!groups.containsKey(month)) {
        groups[month] = [];
      }
      groups[month]!.add(session);
    }
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ShuttleTheme.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64.0),
        child: Container(
          decoration: BoxDecoration(
            color: ShuttleTheme.surfaceContainerLowest,
            border: Border(
              bottom: BorderSide(color: ShuttleTheme.neonPink.withOpacity(0.2), width: 1.2),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: ShuttleTheme.marginMobile),
          alignment: Alignment.center,
          child: SafeArea(
            bottom: false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.sports_tennis,
                      color: ShuttleTheme.neonPink,
                      size: 26,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'ShuttleSummary',
                      style: ShuttleTheme.headlineMd.copyWith(
                        color: ShuttleTheme.onBackground,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(
                    Icons.account_circle_outlined,
                    color: ShuttleTheme.neonTeal,
                    size: 26,
                  ),
                  onPressed: () {
                    _showProfileDialog();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.bug_report_outlined, color: Colors.white),
        label: const Text('Inject Share', style: TextStyle(color: Colors.white)),
        backgroundColor: ShuttleTheme.neonPink,
        onPressed: () {
          final controller = TextEditingController();
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: ShuttleTheme.surfaceContainerLowest,
              title: Text('Inject Shared Text', style: ShuttleTheme.headlineSm),
              content: TextField(
                controller: controller,
                maxLines: 6,
                decoration: const InputDecoration(hintText: 'Paste schedule text here...'),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('CANCEL', style: ShuttleTheme.bodyMd.copyWith(color: ShuttleTheme.neonTeal)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: ShuttleTheme.neonPink),
                  onPressed: () {
                    final text = controller.text.trim();
                    if (text.isNotEmpty) _handleSharedText(text);
                    Navigator.of(context).pop();
                  },
                  child: Text('SEND', style: ShuttleTheme.bodyMd.copyWith(color: Colors.white)),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentTab,
        onTap: (index) {
          setState(() {
            _currentTab = index;
          });
        },
      ),
    );
  }

  Widget _buildBody() {
    switch (_currentTab) {
      case 0:
        return _buildScheduleTab();
      case 1:
        return _buildResultsTab();
      case 2:
        return _buildInfoTab();
      default:
        return _buildScheduleTab();
    }
  }

  Widget _buildScheduleTab() {
    final filtered = _getFilteredSessions();
    final grouped = _groupSessionsByMonth(filtered);
    final allPlayers = _getDistinctPlayers();

    return ListView(
      padding: const EdgeInsets.all(ShuttleTheme.marginMobile),
      children: [
        AccordionInput(
          onProcess: _processPastedSchedule,
          onClear: _clearSchedule,
          initialText: _pastedText,
          initialRemember: _rememberSchedule,
        ),
        const SizedBox(height: ShuttleTheme.md),

        SearchAutocomplete(
          allPlayers: allPlayers,
          initialValue: _searchQuery,
          onSearch: (query) {
            setState(() {
              _searchQuery = query;
            });
          },
        ),
        const SizedBox(height: ShuttleTheme.md),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: ShuttleTheme.xs),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'SUMMARIZED SCHEDULE',
                style: ShuttleTheme.labelCaps.copyWith(color: ShuttleTheme.neonYellow),
              ),
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _filterIncompleteRoster = !_filterIncompleteRoster;
                  });
                },
                icon: Icon(
                  _filterIncompleteRoster ? Icons.filter_alt_off_outlined : Icons.filter_alt_outlined,
                  color: _filterIncompleteRoster ? ShuttleTheme.neonPink : ShuttleTheme.neonTeal,
                  size: 14,
                ),
                label: Text(
                  _filterIncompleteRoster ? 'SHOW ALL' : 'INCOMPLETE ROSTER',
                  style: ShuttleTheme.bodySm.copyWith(
                    color: _filterIncompleteRoster ? ShuttleTheme.neonPink : ShuttleTheme.neonTeal,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: _filterIncompleteRoster ? ShuttleTheme.neonPink : ShuttleTheme.neonTeal.withOpacity(0.5),
                    width: 1.0,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(ShuttleTheme.radiusSmall),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: ShuttleTheme.sm),

        if (filtered.isEmpty)
          Container(
            padding: const EdgeInsets.all(ShuttleTheme.xl),
            decoration: BoxDecoration(
              color: ShuttleTheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(ShuttleTheme.radiusDefault),
              border: Border.all(color: ShuttleTheme.neonPink.withOpacity(0.3)),
            ),
            alignment: Alignment.center,
            child: Column(
              children: [
                const Icon(Icons.search_off_outlined, size: 48, color: ShuttleTheme.neonPink),
                const SizedBox(height: 8),
                Text(
                  'No sessions found matching "$_searchQuery"',
                  style: ShuttleTheme.bodyMd.copyWith(color: ShuttleTheme.onSurfaceVariant),
                ),
              ],
            ),
          )
        else
          ...grouped.entries.map((entry) {
            final monthName = entry.key;
            final sessionsInMonth = entry.value;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: ShuttleTheme.sm),
                  child: Row(
                    children: [
                      Expanded(child: Divider(color: ShuttleTheme.neonPink.withOpacity(0.2), height: 1.2)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: ShuttleTheme.sm),
                        child: Text(
                          monthName,
                          style: ShuttleTheme.labelCaps.copyWith(
                            fontWeight: FontWeight.w900,
                            color: ShuttleTheme.neonYellow,
                          ),
                        ),
                      ),
                      Expanded(child: Divider(color: ShuttleTheme.neonPink.withOpacity(0.2), height: 1.2)),
                    ],
                  ),
                ),
                
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: sessionsInMonth.length,
                  separatorBuilder: (_, __) => const SizedBox(height: ShuttleTheme.sm),
                  itemBuilder: (context, idx) {
                    return ScheduleCard(session: sessionsInMonth[idx]);
                  },
                ),
                const SizedBox(height: ShuttleTheme.sm),
              ],
            );
          }).toList(),

        const SizedBox(height: ShuttleTheme.md),

        Container(
          height: 160,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(ShuttleTheme.radiusLarge),
            image: const DecorationImage(
              image: NetworkImage(
                'https://lh3.googleusercontent.com/aida-public/AB6AXuBlFhCt3gpgtbOFy3iDH8YQxmbZV2OWjXlCQj-hzDE-iSGLwmPMBBdz_bm7pm9sSmuNhp_FrpTPwp57TnkbKlX-xfGOVIyXoPiI7VNar6-WwZY-7LWNo1nMxG2KfVngI23f-eS9u_GHQj9nm6aNdaHU2229fTV2aTThTeGi_a1PdHLHMA1vq1LP7asbsI2lrl4M2HwmkKJWugCkZH3R0u7DsMpyp6GRsaapyaVf9bJ4g_shJnqCyhYiNDSA2CAHghwQRESsXc5Vb1M'
              ),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(ShuttleTheme.radiusLarge),
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withOpacity(0.85),
                  Colors.transparent,
                ],
              ),
            ),
            padding: const EdgeInsets.all(ShuttleTheme.md),
            alignment: Alignment.bottomLeft,
            child: Text(
              'RALLY. SERVE. SLAY. REPEAT.',
              style: ShuttleTheme.headlineSm.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.0,
                shadows: [
                  Shadow(
                    color: ShuttleTheme.neonPink.withOpacity(0.8),
                    blurRadius: 10,
                  )
                ],
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildResultsTab() {
    return ListView(
      padding: const EdgeInsets.all(ShuttleTheme.marginMobile),
      children: [
        Text(
          'SLAY & ROSTER STATS',
          style: ShuttleTheme.headlineMd.copyWith(color: ShuttleTheme.neonPink, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: ShuttleTheme.sm),
        Text(
          'Track rosters and check session frequencies of your athletic crew.',
          style: ShuttleTheme.bodySm.copyWith(color: ShuttleTheme.onSurfaceVariant),
        ),
        const SizedBox(height: ShuttleTheme.md),

        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.sports_handball_outlined,
                title: 'Total Players',
                value: _getDistinctPlayers().length.toString(),
                color: ShuttleTheme.neonTeal,
              ),
            ),
            const SizedBox(width: ShuttleTheme.sm),
            Expanded(
              child: _buildStatCard(
                icon: Icons.calendar_month_outlined,
                title: 'Sessions Booked',
                value: _sessions.length.toString(),
                color: ShuttleTheme.neonYellow,
              ),
            ),
          ],
        ),
        const SizedBox(height: ShuttleTheme.md),

        Container(
          decoration: BoxDecoration(
            color: ShuttleTheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(ShuttleTheme.radiusDefault),
            border: Border.all(color: ShuttleTheme.neonPink.withOpacity(0.2), width: 1.2),
          ),
          padding: const EdgeInsets.all(ShuttleTheme.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ROSTER FREQUENCIES',
                style: ShuttleTheme.headlineSm.copyWith(color: ShuttleTheme.onBackground),
              ),
              const SizedBox(height: 12),
              if (_getDistinctPlayers().isEmpty)
                Text('No roster loaded. Paste a schedule to see player listings.', style: ShuttleTheme.bodyMd)
              else
                ..._getDistinctPlayers().map((player) {
                  final sessionCount = _sessions.where((s) => s.players.contains(player)).length;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.person_outline, size: 18, color: ShuttleTheme.neonTeal),
                            const SizedBox(width: 8),
                            Text(
                              player, 
                              style: ShuttleTheme.bodyMd.copyWith(
                                fontWeight: FontWeight.bold,
                                color: ShuttleTheme.onBackground,
                              ),
                            ),
                          ],
                        ),
                        InkWell(
                          onTap: () {
                            setState(() {
                              _searchQuery = player;
                              _currentTab = 0;
                            });
                          },
                          borderRadius: BorderRadius.circular(ShuttleTheme.radiusFull),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: ShuttleTheme.neonTeal.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(ShuttleTheme.radiusFull),
                              border: Border.all(color: ShuttleTheme.neonTeal.withOpacity(0.3)),
                            ),
                            child: Text(
                              '$sessionCount ${sessionCount == 1 ? "session" : "sessions"}',
                              style: ShuttleTheme.bodySm.copyWith(
                                color: ShuttleTheme.neonTeal, 
                                fontWeight: FontWeight.w900,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
            ],
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: ShuttleTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(ShuttleTheme.radiusDefault),
        border: Border.all(color: color.withOpacity(0.3), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.05),
            blurRadius: 8,
          )
        ],
      ),
      padding: const EdgeInsets.all(ShuttleTheme.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            title.toUpperCase(),
            style: ShuttleTheme.labelCaps.copyWith(color: ShuttleTheme.onSurfaceVariant, fontSize: 9),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: ShuttleTheme.headlineLgMobile.copyWith(
              color: color,
              fontWeight: FontWeight.w900,
              shadows: [
                Shadow(
                  color: color.withOpacity(0.5),
                  blurRadius: 8,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTab() {
    return ListView(
      padding: const EdgeInsets.all(ShuttleTheme.marginMobile),
      children: [
        Text(
          'CYBER SYSTEM INFO',
          style: ShuttleTheme.headlineMd.copyWith(color: ShuttleTheme.neonPink, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: ShuttleTheme.md),

        Container(
          decoration: BoxDecoration(
            color: ShuttleTheme.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(ShuttleTheme.radiusDefault),
            border: Border.all(color: ShuttleTheme.neonTeal.withOpacity(0.2), width: 1.2),
          ),
          padding: const EdgeInsets.all(ShuttleTheme.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoSection(
                icon: Icons.help_outline,
                title: 'How does parsing work?',
                desc: 'Simply paste any raw textual schedule containing court times, dates, and locations. Our smart heuristics search for times (like 2pm-5pm), location CC names (like Pek Kio CC), court details, and player rosters, converting them instantly into interactive dashboards.',
              ),
              Divider(color: ShuttleTheme.neonTeal.withOpacity(0.15), height: 24),
              _buildInfoSection(
                icon: Icons.sports_tennis,
                title: 'Slay or Sashay Away',
                desc: 'Badminton is all about energy and precision! Match courts with intense, robust play, follow guidelines, and represent absolute athletic readiness. Keep your racquet swinging and stay on top of the list.',
              ),
              Divider(color: ShuttleTheme.neonTeal.withOpacity(0.15), height: 24),
              _buildInfoSection(
                icon: Icons.star_border,
                title: 'Slay Philosophy',
                desc: 'ShuttleSummary matches a high-energy sport-glow design. The Neon Pink, Cyan, and Volt Yellow accents provide absolute visual scan-path readability under intense court environments, ensuring you always know where and when you play.',
              ),
            ],
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  Widget _buildInfoSection({
    required IconData icon,
    required String title,
    required String desc,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: ShuttleTheme.neonTeal, size: 24),
            const SizedBox(width: 8),
            Text(
              title,
              style: ShuttleTheme.headlineSm.copyWith(color: ShuttleTheme.onBackground),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          desc,
          style: ShuttleTheme.bodyMd.copyWith(color: ShuttleTheme.onSurfaceVariant, height: 1.4),
        ),
      ],
    );
  }

  void _showProfileDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: ShuttleTheme.surfaceContainerLowest,
          surfaceTintColor: ShuttleTheme.surfaceContainerLowest,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ShuttleTheme.radiusLarge),
            side: const BorderSide(color: ShuttleTheme.neonPink, width: 1.5),
          ),
          title: Row(
            children: [
              const Icon(Icons.flash_on, color: ShuttleTheme.neonYellow, size: 28),
              const SizedBox(width: 8),
              Text(
                'ATHLETE PROFILE', 
                style: ShuttleTheme.headlineSm.copyWith(color: ShuttleTheme.neonPink, fontWeight: FontWeight.w900),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'SLAY OR SASHAY AWAY!', 
                style: ShuttleTheme.bodyMd.copyWith(fontWeight: FontWeight.w900, color: ShuttleTheme.neonTeal),
              ),
              const SizedBox(height: 8),
              Text(
                'Good luck, play hard, and check schedule listings to guarantee court slot bookings.',
                style: ShuttleTheme.bodySm.copyWith(color: ShuttleTheme.onBackground),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'CLOSE',
                style: ShuttleTheme.bodyMd.copyWith(color: ShuttleTheme.neonPink, fontWeight: FontWeight.w900),
              ),
            ),
          ],
        );
      },
    );
  }
}

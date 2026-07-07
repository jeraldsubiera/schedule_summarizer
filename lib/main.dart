import 'package:flutter/material.dart';
import 'theme.dart';
import 'views/main_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ShuttleSummaryApp());
}

class ShuttleSummaryApp extends StatelessWidget {
  const ShuttleSummaryApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final shared = Uri.base.queryParameters['shared'] ?? '';
    return MaterialApp(
      title: 'ShuttleSummary - Badminton Schedule Summarizer',
      theme: ShuttleTheme.lightThemeData,
      debugShowCheckedModeBanner: false,
      home: ResponsiveFrameSelector(initialSharedText: shared),
    );
  }
}

class ResponsiveFrameSelector extends StatefulWidget {
  final String initialSharedText;
  const ResponsiveFrameSelector({Key? key, this.initialSharedText = ''}) : super(key: key);

  @override
  State<ResponsiveFrameSelector> createState() => _ResponsiveFrameSelectorState();
}

class _ResponsiveFrameSelectorState extends State<ResponsiveFrameSelector> {
  bool _forceFullScreen = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width > 600;

    if (!isDesktop || _forceFullScreen) {
      return MainView(initialSharedText: widget.initialSharedText);
    }

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF06070C), // Obsidian Dark Black
              Color(0xFF1E112A), // Cyberpunk Deep Purple/Violet
            ],
          ),
        ),
        child: Stack(
          children: [
            // Background shuttlecock glowing icon
            Positioned(
              right: -100,
              bottom: -100,
              child: Opacity(
                opacity: 0.08,
                child: Icon(
                  Icons.sports_tennis,
                  size: size.height * 0.8,
                  color: ShuttleTheme.neonPink,
                ),
              ),
            ),
            
            // Background stars & sparkle overlay mimicking the poster
            Positioned(
              left: 120,
              top: 80,
              child: Opacity(
                opacity: 0.15,
                child: Icon(Icons.star, size: 80, color: ShuttleTheme.neonYellow),
              ),
            ),
            Positioned(
              right: 220,
              top: 150,
              child: Opacity(
                opacity: 0.1,
                child: Icon(Icons.flash_on, size: 100, color: ShuttleTheme.neonTeal),
              ),
            ),
            
            // Left-side branding text & controls for presentation
            Positioned(
              left: 48,
              top: 0,
              bottom: 0,
              child: SizedBox(
                width: 320,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: ShuttleTheme.neonPink.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(ShuttleTheme.radiusFull),
                        border: Border.all(color: ShuttleTheme.neonPink.withOpacity(0.5)),
                        boxShadow: [
                          BoxShadow(
                            color: ShuttleTheme.neonPink.withOpacity(0.2),
                            blurRadius: 8,
                          )
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.sports_tennis, color: ShuttleTheme.neonTeal, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            'SLAY OR SASHAY AWAY',
                            style: ShuttleTheme.labelCaps.copyWith(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'SHUTTLE\nSUMMARY',
                      style: ShuttleTheme.headlineLg.copyWith(
                        fontSize: 48,
                        height: 1.0,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            color: ShuttleTheme.neonPink.withOpacity(0.8),
                            blurRadius: 15,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Rally. Serve. Slay. Repeat. A high-octane schedule parser representing absolute court energy. Slay your badminton games.',
                      style: ShuttleTheme.bodyMd.copyWith(
                        color: Colors.white.withOpacity(0.7),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Mode Toggle controls
                    Text(
                      'VIEWPORT PRESET',
                      style: ShuttleTheme.labelCaps.copyWith(
                        color: ShuttleTheme.neonYellow,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildToggleOption(
                      icon: Icons.phone_android,
                      title: 'Mobile Frame View',
                      subtitle: 'Slay standard viewport (390 x 844)',
                      isSelected: !_forceFullScreen,
                      onTap: () => setState(() => _forceFullScreen = false),
                    ),
                    const SizedBox(height: 8),
                    _buildToggleOption(
                      icon: Icons.fullscreen,
                      title: 'Responsive Web View',
                      subtitle: 'Expand cyber app to full width',
                      isSelected: _forceFullScreen,
                      onTap: () => setState(() => _forceFullScreen = true),
                    ),
                  ],
                ),
              ),
            ),
            
            // Centered Mock Phone Container
            Center(
              child: Container(
                margin: const EdgeInsets.only(left: 320), // Offset from control panel
                width: 390 + 32, // Phone width + bezel
                height: 844 + 32, // Phone height + bezel
                decoration: BoxDecoration(
                  color: const Color(0xFF0F111E),
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: [
                    BoxShadow(
                      color: ShuttleTheme.neonPink.withOpacity(0.2),
                      blurRadius: 40,
                      spreadRadius: 2,
                    ),
                  ],
                  border: Border.all(
                    color: ShuttleTheme.neonPink.withOpacity(0.6),
                    width: 2.0,
                  ),
                ),
                padding: const EdgeInsets.all(16.0), // Phone bezel thickness
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: MainView(initialSharedText: widget.initialSharedText),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(ShuttleTheme.radiusDefault),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected 
              ? Colors.white.withOpacity(0.08) 
              : Colors.transparent,
          borderRadius: BorderRadius.circular(ShuttleTheme.radiusDefault),
          border: Border.all(
            color: isSelected 
                ? ShuttleTheme.neonPink.withOpacity(0.6) 
                : Colors.white.withOpacity(0.05),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? ShuttleTheme.neonTeal : Colors.white.withOpacity(0.6),
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title.toUpperCase(),
                    style: ShuttleTheme.bodyMd.copyWith(
                      color: isSelected ? Colors.white : Colors.white.withOpacity(0.8),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: ShuttleTheme.bodySm.copyWith(
                      color: Colors.white.withOpacity(0.4),
                      fontSize: 11,
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

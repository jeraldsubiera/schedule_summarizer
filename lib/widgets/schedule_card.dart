import 'package:flutter/material.dart';
import '../models/session_model.dart';
import '../theme.dart';

class ScheduleCard extends StatefulWidget {
  final BadmintonSession session;

  const ScheduleCard({
    Key? key,
    required this.session,
  }) : super(key: key);

  @override
  State<ScheduleCard> createState() => _ScheduleCardState();
}

class _ScheduleCardState extends State<ScheduleCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final session = widget.session;

    // Detect if this is a single court or multiple courts
    final isMultiCourt = session.court.toLowerCase().contains('courts') || 
                         session.court.toLowerCase().contains('cts') ||
                         session.court.startsWith('2') || 
                         session.court.startsWith('3');

    // Cyberpunk themed badge mappings
    final badgeColor = isMultiCourt 
        ? ShuttleTheme.neonTeal 
        : ShuttleTheme.neonPink;
        
    final badgeTextColor = isMultiCourt 
        ? const Color(0xFF06070C) 
        : const Color(0xFFFFFFFF);

    // Glowing border color depending on hover state
    final borderColor = _isHovered 
        ? ShuttleTheme.neonTeal.withOpacity(0.8) 
        : ShuttleTheme.neonPink.withOpacity(0.2);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: ShuttleTheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(ShuttleTheme.radiusDefault),
          border: Border.all(color: borderColor, width: 1.2),
          boxShadow: _isHovered ? [
            BoxShadow(
              color: ShuttleTheme.neonTeal.withOpacity(0.15),
              blurRadius: 12,
              spreadRadius: 1,
            )
          ] : [],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Left pink glowing indicator bar on hover
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              left: 0,
              top: 0,
              bottom: 0,
              width: _isHovered ? 4.0 : 0.0,
              child: Container(
                color: ShuttleTheme.neonPink,
              ),
            ),
            
            // Card Content
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: ShuttleTheme.md,
                vertical: ShuttleTheme.md,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Date header
                        Text(
                          session.date,
                          style: ShuttleTheme.bodyLg.copyWith(
                            fontWeight: FontWeight.w800,
                            color: ShuttleTheme.onBackground,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        
                        // Time row
                        Row(
                          children: [
                            const Icon(
                              Icons.schedule_outlined,
                              size: 16,
                              color: ShuttleTheme.neonYellow,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              session.time,
                              style: ShuttleTheme.bodyMd.copyWith(
                                color: ShuttleTheme.onBackground.withOpacity(0.9),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        
                        // Location row
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 16,
                              color: ShuttleTheme.neonTeal,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              session.location,
                              style: ShuttleTheme.bodyMd.copyWith(
                                color: ShuttleTheme.neonTeal,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        
                        // Roster Display (Smart Enhancement)
                        if (session.players.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            children: session.players.map((player) {
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: ShuttleTheme.surfaceContainerLow,
                                  borderRadius: BorderRadius.circular(ShuttleTheme.radiusSmall),
                                  border: Border.all(
                                    color: ShuttleTheme.outline.withOpacity(0.4),
                                    width: 1.0,
                                  ),
                                ),
                                child: Text(
                                  player,
                                  style: ShuttleTheme.bodySm.copyWith(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: ShuttleTheme.neonYellow,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  // Court & Status Badges
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: badgeColor,
                          borderRadius: BorderRadius.circular(ShuttleTheme.radiusFull),
                          boxShadow: [
                            BoxShadow(
                              color: badgeColor.withOpacity(0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            )
                          ],
                        ),
                        child: Text(
                          session.court.toUpperCase(),
                          style: ShuttleTheme.labelCaps.copyWith(
                            color: badgeTextColor,
                            fontSize: 9,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: ShuttleTheme.neonTeal.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(ShuttleTheme.radiusSmall),
                          border: Border.all(
                            color: ShuttleTheme.neonTeal.withOpacity(0.6),
                            width: 1.0,
                          ),
                        ),
                        child: Text(
                          '${session.players.length}/${session.maxPlayers > 0 ? session.maxPlayers : 4} PLAYERS',
                          style: ShuttleTheme.labelCaps.copyWith(
                            color: ShuttleTheme.neonTeal,
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      if (session.isIncomplete) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: ShuttleTheme.neonYellow.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(ShuttleTheme.radiusSmall),
                            border: Border.all(
                              color: ShuttleTheme.neonYellow.withOpacity(0.6),
                              width: 1.0,
                            ),
                          ),
                          child: Text(
                            'INCOMPLETE',
                            style: ShuttleTheme.labelCaps.copyWith(
                              color: ShuttleTheme.neonYellow,
                              fontSize: 8,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ],
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

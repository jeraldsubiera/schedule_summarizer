import '../models/session_model.dart';

class ParserEngine {
  /// Default mock sessions from the Stitch design mockup
  static List<BadmintonSession> get defaultSessions => [
        BadmintonSession(
          date: 'May 31, Sun',
          time: '2pm - 5pm',
          location: 'Pek Kio CC',
          court: 'Court 3',
          players: ['Kat', 'Lita', 'JP', 'Sherwin'],
          month: 'MAY',
          isIncomplete: false,
          maxPlayers: 4,
        ),
        BadmintonSession(
          date: 'June 7, Sun',
          time: '3pm - 6pm',
          location: 'KFF',
          court: '2 courts',
          players: ['Kat', 'Lita', 'JP'],
          month: 'JUNE',
          isIncomplete: true,
          maxPlayers: 4,
        ),
      ];

  /// Parses raw text into a list of BadmintonSessions
  static List<BadmintonSession> parse(String text) {
    if (text.trim().isEmpty) {
      return defaultSessions;
    }

    final List<BadmintonSession> sessions = [];
    
    // Split the text into segments by looking for double newlines or block dividers
    // e.g., sections divided by empty lines, or lines containing a date.
    final blocks = _splitIntoBlocks(text);

    for (var block in blocks) {
      if (block.trim().isEmpty) continue;
      
      final parsed = _parseSingleBlock(block);
      if (parsed != null) {
        final lowerLocation = parsed.location.toLowerCase();
        final lowerDate = parsed.date.toLowerCase();
        final lowerTime = parsed.time.toLowerCase();
        if (lowerLocation.contains('gamelist') ||
            lowerDate.contains('gamelist') ||
            lowerTime.contains('gamelist')) {
          continue;
        }
        sessions.add(parsed);
      }
    }

    // If parsing failed to find anything, return the default sessions
    return sessions.isNotEmpty ? sessions : defaultSessions;
  }

  static List<String> _splitIntoBlocks(String text) {
    final lines = text.split('\n');
    final List<String> blocks = [];
    String currentBlock = '';

    final monthRegex = RegExp(
      r'\b(january|february|march|april|may|june|july|august|september|october|november|december|jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)\b',
      caseSensitive: false,
    );
    final digitRegex = RegExp(r'\d');

    for (var line in lines) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) {
        if (currentBlock.isNotEmpty) {
          currentBlock += '\n' + line;
        }
        continue;
      }

      // Identify a new session header line
      final isNewHeader = monthRegex.hasMatch(trimmed) && 
                          digitRegex.hasMatch(trimmed) &&
                          !trimmed.contains(RegExp(r'^\d+\s*[\.\)]')) &&
                          !trimmed.toLowerCase().contains('pending') &&
                          !trimmed.toLowerCase().contains('closed') &&
                          !trimmed.toLowerCase().contains('gamelist');

      if (isNewHeader && currentBlock.isNotEmpty) {
        blocks.add(currentBlock);
        currentBlock = line;
      } else {
        if (currentBlock.isEmpty) {
          currentBlock = line;
        } else {
          currentBlock += '\n' + line;
        }
      }
    }
    if (currentBlock.isNotEmpty) {
      blocks.add(currentBlock);
    }
    
    return blocks;
  }

  static BadmintonSession? _parseSingleBlock(String block) {
    final lines = block.split('\n').map((l) => l.trim()).toList();
    if (lines.isEmpty) return null;

    String date = '';
    String time = '';
    String location = '';
    String court = '';
    List<String> players = [];
    String month = 'UPCOMING';

    // Regex patterns
    final monthRegex = RegExp(r'\b(january|february|march|april|may|june|july|august|september|october|november|december|jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)\b', caseSensitive: false);
    final timeRegex = RegExp(r'\b(\d{1,2}(?::\d{2})?\s*(?:am|pm)?\s*(?:-|to)\s*\d{1,2}(?::\d{2})?\s*(?:am|pm))\b', caseSensitive: false);
    final courtRegex = RegExp(r'\b(court\s*\d+|ct\s*\d+|\d+\s*courts)\b', caseSensitive: false);
    final playersLabelRegex = RegExp(r'(?:players|roster|names|with|attendees)\s*:\s*(.*)', caseSensitive: false);

    // Heuristics: Scan for player entries
    final numberedPlayerRegex = RegExp(r'^(\d+)\s*[\.\)]\s*(.*)');
    final List<String> numberedLines = [];
    int maxSlotNumber = 0;
    bool hasEmptyNumberedSlot = false;
    bool inPendingSection = false;
    for (var line in lines) {
      if (line.toLowerCase().contains('pending')) {
        inPendingSection = true;
      }
      final match = numberedPlayerRegex.firstMatch(line);
      if (match != null) {
        final slotNum = int.tryParse(match.group(1) ?? '') ?? 0;
        final playerPart = match.group(2)!.trim();
        
        if (!inPendingSection) {
          if (slotNum > maxSlotNumber) {
            maxSlotNumber = slotNum;
          }
          if (playerPart.isNotEmpty) {
            numberedLines.add(playerPart);
          } else {
            hasEmptyNumberedSlot = true;
          }
        }
      }
    }

    if (numberedLines.isNotEmpty) {
      for (var playerPart in numberedLines) {
        final cleaned = _capitalizeWords(playerPart);
        if (cleaned.isNotEmpty) {
          players.add(cleaned);
        }
      }
    } else {
      // Fallback: Comma-separated or labeled lines
      for (var line in lines) {
        final playerMatch = playersLabelRegex.firstMatch(line);
        if (playerMatch != null) {
          final rawPlayers = playerMatch.group(1) ?? '';
          players.addAll(_extractPlayers(rawPlayers));
          continue;
        }
        
        if (line.contains(',') && !line.contains(RegExp(r'\d')) && line.split(',').length >= 2) {
          players.addAll(_extractPlayers(line));
          continue;
        }
      }
    }

    players = players.toSet().toList(); // Remove duplicates

    // Remove the player line from active parsing lines if found
    final activeLines = lines.where((line) {
      return !playersLabelRegex.hasMatch(line) && 
             !numberedPlayerRegex.hasMatch(line) &&
             !line.toLowerCase().contains('closed') &&
             !line.toLowerCase().contains('pending');
    }).toList();

    // Scan lines for time, court, date, and location
    for (var line in activeLines) {
      if (line.isEmpty) continue;

      // Extract Time if not found yet
      if (time.isEmpty) {
        final timeMatch = timeRegex.firstMatch(line);
        if (timeMatch != null) {
          time = timeMatch.group(1) ?? '';
        }
      }

      // Extract Court if not found yet
      if (court.isEmpty) {
        final courtMatch = courtRegex.firstMatch(line);
        if (courtMatch != null) {
          court = courtMatch.group(1) ?? '';
        }
      }

      // Extract Month & Date if not found yet
      if (date.isEmpty) {
        final monthMatch = monthRegex.firstMatch(line);
        if (monthMatch != null) {
          final rawMonth = monthMatch.group(1)!.toUpperCase();
          month = rawMonth.substring(0, rawMonth.length > 4 ? 4 : rawMonth.length);
          if (month == 'JUNE') month = 'JUNE'; // Keep full name for June

          var dateCandidate = line;
          dateCandidate = dateCandidate.replaceAll(timeRegex, '');
          dateCandidate = dateCandidate.replaceAll(courtRegex, '');
          dateCandidate = dateCandidate.split(RegExp(r'[,|-]')).first.trim();
          
          if (dateCandidate.isNotEmpty) {
            final dayMatch = RegExp(r'\b(sun|mon|tue|wed|thu|fri|sat|sunday|monday|tuesday|wednesday|thursday|friday|saturday)\b', caseSensitive: false).firstMatch(line);
            if (dayMatch != null) {
              final shortDay = dayMatch.group(1)!.substring(0, 3);
              date = '${dateCandidate.trim()}, ${shortDay[0].toUpperCase()}${shortDay.substring(1).toLowerCase()}';
            } else {
              date = dateCandidate.trim();
            }
          }
        }
      }
    }

    // Determine Location
    List<String> locationCandidates = [];
    for (var line in activeLines) {
      var cleanedLine = line
          .replaceAll(timeRegex, '')
          .replaceAll(courtRegex, '');
          
      if (date.isNotEmpty) {
        final dateBase = date.split(',').first;
        cleanedLine = cleanedLine.replaceAll(dateBase, '');
        cleanedLine = cleanedLine.replaceAll(RegExp(r'\b(sun|mon|tue|wed|thu|fri|sat|sunday|monday|tuesday|wednesday|thursday|friday|saturday)\b', caseSensitive: false), '');
      }

      cleanedLine = cleanedLine.replaceAll(RegExp(r'[,;|\-()]'), ' ').trim();
      cleanedLine = cleanedLine.replaceAll(RegExp(r'\s+'), ' ');
      
      if (cleanedLine.length > 2) {
        locationCandidates.add(cleanedLine);
      }
    }

    if (locationCandidates.isNotEmpty) {
      location = locationCandidates.firstWhere(
        (c) => c.contains(RegExp(r'\b(CC|Club|Hall|Sports|KFF|Arena)\b', caseSensitive: false)),
        orElse: () => locationCandidates.first,
      );
    }

    // Final clean-ups and fallbacks
    if (date.isEmpty) date = 'Upcoming';
    if (time.isEmpty) time = 'TBD';
    if (location.isEmpty) location = 'Badminton Court';
    if (court.isEmpty) court = '1 court';
    if (month == 'UPCOMING' && date.isNotEmpty) {
      final monthMatch = monthRegex.firstMatch(date);
      if (monthMatch != null) {
        month = monthMatch.group(1)!.toUpperCase();
        if (month.length > 4 && month != 'JUNE') {
          month = month.substring(0, 3);
        }
      }
    }

    final bool isIncomplete = players.length < 4 || hasEmptyNumberedSlot;

    final int maxPlayers = maxSlotNumber > 0
        ? maxSlotNumber
        : (isIncomplete ? 4 : players.length);

    return BadmintonSession(
      date: _capitalizeWords(date),
      time: time.trim(),
      location: location.trim(),
      court: _capitalizeWords(court),
      players: players,
      month: month,
      isIncomplete: isIncomplete,
      maxPlayers: maxPlayers,
    );
  }

  static List<String> _extractPlayers(String rawText) {
    // Find all alphabetical words
    final wordRegex = RegExp(r'\b[a-zA-Z]+\b');
    final matches = wordRegex.allMatches(rawText);
    final List<String> names = [];
    
    // Common noise words in roster listings
    final noiseWords = {
      'pending', 'closed', 'court', 'courts', 'cc', 'kff', 'pm', 'am', 
      'hr', 'hrs', 'plus', 'with', 'and', 'gamelist', 'list', 'the', 'for'
    };

    for (var match in matches) {
      final word = match.group(0)!;
      final lowerWord = word.toLowerCase();
      
      // Skip single letters
      if (word.length <= 1) continue;
      
      // Skip noise words
      if (noiseWords.contains(lowerWord)) continue;
      
      names.add(_capitalizeWords(word));
    }
    
    return names;
  }

  static String _capitalizeWords(String str) {
    if (str.isEmpty) return str;
    return str.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }
}

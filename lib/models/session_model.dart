import 'dart:convert';

class BadmintonSession {
  final String date;
  final String time;
  final String location;
  final String court;
  final List<String> players;
  final String month;
  final bool isIncomplete;
  final int maxPlayers;

  BadmintonSession({
    required this.date,
    required this.time,
    required this.location,
    required this.court,
    required this.players,
    required this.month,
    this.isIncomplete = false,
    this.maxPlayers = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'time': time,
      'location': location,
      'court': court,
      'players': players,
      'month': month,
      'isIncomplete': isIncomplete,
      'maxPlayers': maxPlayers,
    };
  }

  factory BadmintonSession.fromJson(Map<String, dynamic> json) {
    final playersList = List<String>.from(json['players'] ?? []);
    return BadmintonSession(
      date: json['date'] as String? ?? '',
      time: json['time'] as String? ?? '',
      location: json['location'] as String? ?? '',
      court: json['court'] as String? ?? '',
      players: playersList,
      month: json['month'] as String? ?? '',
      isIncomplete: json['isIncomplete'] as bool? ?? (playersList.length < 4),
      maxPlayers: json['maxPlayers'] as int? ?? 0,
    );
  }

  static String encodeList(List<BadmintonSession> list) {
    return jsonEncode(list.map((item) => item.toJson()).toList());
  }

  static List<BadmintonSession> decodeList(String jsonString) {
    if (jsonString.isEmpty) return [];
    try {
      final decoded = jsonDecode(jsonString) as List;
      return decoded.map((item) => BadmintonSession.fromJson(item as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }
}

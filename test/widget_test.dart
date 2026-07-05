import 'package:flutter_test/flutter_test.dart';
import 'package:shuttle_summary/utils/parser_engine.dart';

void main() {
  test('ParserEngine default sessions parsing test', () {
    final sessions = ParserEngine.parse('');
    expect(sessions.length, 2);
    expect(sessions[0].location, 'Pek Kio CC');
    expect(sessions[1].court, '2 courts');
  });

  test('ParserEngine custom parsing test', () {
    const rawText = 'May 28, Thu, 7pm - 9pm, Arena CC, Court 1\nPlayers: Jerald, Sam';
    final sessions = ParserEngine.parse(rawText);
    
    expect(sessions.length, 1);
    expect(sessions[0].location, 'Arena CC');
    expect(sessions[0].court, 'Court 1');
    expect(sessions[0].players.contains('Jerald'), true);
  });

  test('ParserEngine numbered list and Noy test', () {
    const rawText = '''
May 31, Sun, 1pm-3pm (2 courts), Pek Kio CC
1.Ryan
2.Karyn
3.Kat
4.JM
5.Tiki +1 (Janrey+1)
6.Teej
7.Noy
8.Jun
CLOSED! 

(Pending)
1.
''';
    final sessions = ParserEngine.parse(rawText);
    expect(sessions.length, 1);
    expect(sessions[0].location, 'Pek Kio CC');
    expect(sessions[0].players.contains('Noy'), true);
    expect(sessions[0].players.contains('Tiki +1 (Janrey+1)'), true);
    expect(sessions[0].players.contains('Ryan'), true);
    expect(sessions[0].isIncomplete, false);
    expect(sessions[0].maxPlayers, 8);
  });

  test('ParserEngine blank numbered slot and incomplete detection test', () {
    const rawText = '''
June 7, Sun, 1pm-3pm, Pek Kio CC
1.Ryan
2.Jun
3.Ms Universe
4.Karyn
5.Jen
6.Kat
7.
CLOSED! 
''';
    final sessions = ParserEngine.parse(rawText);
    expect(sessions.length, 1);
    expect(sessions[0].players.length, 6);
    expect(sessions[0].isIncomplete, true);
    expect(sessions[0].maxPlayers, 7);
  });

  test('ParserEngine ignore gamelist noise block test', () {
    const rawText = '''
GAMELIST:

June 7, Sun, 1pm-3pm, Pek Kio CC
1.Ryan
2.Jun
3.Ms Universe
4.Karyn
5.Jen
6.Kat
7.
CLOSED! 
''';
    final sessions = ParserEngine.parse(rawText);
    expect(sessions.length, 1);
    expect(sessions[0].location, 'Pek Kio CC');
    expect(sessions[0].players.length, 6);
    expect(sessions[0].maxPlayers, 7);
  });

  test('ParserEngine user custom schedule test', () {
    const rawText = '''
May 31, Sun, 1pm-3pm (2 courts), Pek Kio CC
1.Ryan
2.Karyn
3.Kat
4.JM
5.Tiki +1 (Janrey+1)
6.Teej
7.Noy
8.Jun
9.Ms Universe
10.Ervin +1 (Janrey)
11.Oliver +1 (Thomas)
12.Allan
13.
14.
CLOSED! 
''';
    final sessions = ParserEngine.parse(rawText);
    expect(sessions.length, 1);
    expect(sessions[0].players.length, 12);
    expect(sessions[0].maxPlayers, 14);
    expect(sessions[0].isIncomplete, true);
  });
}

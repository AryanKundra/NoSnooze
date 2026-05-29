import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../models/alarm.dart';
import '../models/puzzle.dart';

class PuzzleService {
  static final _rng = Random();

  static Future<Puzzle> generate(PuzzleType type) async{
    switch(type) {
      case PuzzleType.math:
        return _mathPuzzle();
      case PuzzleType.trivia:
        return _triviaPuzzle();
      case PuzzleType.pattern:
        return _patternPuzzle();
    }
  }

  static Puzzle _mathPuzzle() {
    final ops = ['+', '-', 'x','÷'];
    final op = ops[_rng.nextInt(4)];
    int a, b, answer;

    switch(op) {
      case '+':
      a = _rng.nextInt(50) + 10;
      b = _rng.nextInt(50) + 10;
      answer = a + b;

      case '-':
        a = _rng.nextInt(50) + 30;
        b = _rng.nextInt(a);
        answer = a - b;

      case 'x':
        a = _rng.nextInt(11) + 2;
        b = _rng.nextInt(11) + 2;
        answer = a*b;

      case '÷':
        b = _rng.nextInt(10) + 2;
        answer = _rng.nextInt(10) + 2;
        a = b * answer;

      default:
        a = 5; b = 5; answer = 10;
    }

    return Puzzle(
      question: 'What is $a $op $b?',
      answer: answer.toString(),
      hint: 'The answer is $answer',
      category: PuzzleCategory.math,
    );
  }

  static Future<Puzzle> _triviaPuzzle() async{
    try{
      final uri = Uri.parse('https://opentdb.com/api.php?amount=1&type=multiple&difficulty=easy');

      final response = await http.get(uri).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final results = data['results'] as List;
        if (results.isNotEmpty) {
          final item = results.first as Map<String, dynamic>;
          final question = _decodeHtml(item['question'] as String);
          final correct = _decodeHtml(item['correct_answer'] as String);
          final incorrect = (item['incorrect_answers'] as List).map((e) => _decodeHtml(e as String)).toList();
          final options = [...incorrect, correct]..shuffle(_rng);
          final letters = ['A', 'B', 'C', 'D'];
          final answerIndex = options.indexOf(correct);

          final questionText = '$question\n${List.generate(
            options.length,
            (i) => '${letters[i]}) ${options[i]}',
          ).join('  ')}';

          return Puzzle(
            question: questionText,
            answer: letters[answerIndex],
            hint: 'The correct answer is: $correct',
            category: PuzzleCategory.trivia,
          );
        }
      }
    } catch(_) {

    }
    return _mathPuzzle();
  }

    static Puzzle _patternPuzzle() {
    final start = _rng.nextInt(20) + 1;
    final step = _rng.nextInt(9) + 2;
    final terms = List.generate(4, (i) => start + step * i);
    final next = start + step * 4;
    return Puzzle(
      question: 'What comes next?\n${terms.join(', ')}, ?',
      answer: next.toString(),
      hint: 'The pattern increases by $step each time.',
      category: PuzzleCategory.pattern,
    );
  }
    static String _decodeHtml(String s) => s
      .replaceAll('&amp;', '&')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&quot;', '"')
      .replaceAll('&#039;', "'")
      .replaceAll('&ldquo;', '"')
      .replaceAll('&rdquo;', '"');
}
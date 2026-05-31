import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../models/alarm.dart';
import '../models/puzzle.dart';

// Class that oversees the puzzle challenges.
// This class will algorithmically generate arithmetic problems for math, and request online trivia
// questions/answers asynchronously using API.
class PuzzleService {
  // Generate a random number.
  static final _rng = Random();

  // Method for requesting the user for a specific alarm puzzle category.
  // Parameters:
  //   - type - The enum puzzle style requested by the user.
  // Returns: A Future that yields a fully populated Puzzle instance.
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

  // Method that creates a pseudorandom basic arithmetic puzzle with constraints.
  // Returns: A basic arithmetic math Puzzle structure.
  static Puzzle _mathPuzzle() {
    final ops = ['+', '-', 'x','÷'];
    final op = ops[_rng.nextInt(4)];
    int a, b, answer;

    switch(op) {
      case '+':
      // Generate values between 10 and 59.
      a = _rng.nextInt(50) + 10;
      b = _rng.nextInt(50) + 10;
      answer = a + b;
      // Generate larger left term numbers to guarantee positive answers.
      case '-':
        a = _rng.nextInt(50) + 30;
        b = _rng.nextInt(a);
        answer = a - b;
      // Make sure we stay between 2 and 12 to keep multiplication simple.
      case 'x':
        a = _rng.nextInt(11) + 2;
        b = _rng.nextInt(11) + 2;
        answer = a*b;
      // Division parts should be made by reverse multiplication, guaranteeing integer quotients.
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

  // Method that communicates with an external Open Trivia Web API to for an easy multiple-choice
  // question to answer.
  // If there are connection errors, we'll default to a math puzzle.
  // Returns: A Future containing the network-sourced puzzle or a math puzzle otherwise.
  static Future<Puzzle> _triviaPuzzle() async{
    try{
      final uri = Uri.parse('https://opentdb.com/api.php?amount=1&type=multiple&difficulty=easy');
      // The max timeout limit for execution so we don't stall and block too long.
      final response = await http.get(uri).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final results = data['results'] as List;
        if (results.isNotEmpty) {
          final item = results.first as Map<String, dynamic>;
          final question = _decodeHtml(item['question'] as String);
          final correct = _decodeHtml(item['correct_answer'] as String);
          
          // All incorrect answer text tokens should be extracted from the string array.
          final incorrect = (item['incorrect_answers'] as List).map((e) => _decodeHtml(e as String)).toList();
          
          // Flatten option choices and randomize their order positions.
          final options = [...incorrect, correct]..shuffle(_rng);
          final letters = ['A', 'B', 'C', 'D'];
          final answerIndex = options.indexOf(correct);

          // Build out structural answer sheet layouts.
          final questionText = '$question\n${List.generate(
            options.length,
            (i) => '${letters[i]}) ${options[i]}',
          ).join('  ')}';

          return Puzzle(
            question: questionText,
            // The answer is a specific uppercase index choice letter.
            answer: letters[answerIndex],
            hint: 'The correct answer is: $correct',
            category: PuzzleCategory.trivia,
          );
        }
      }
    } catch(_) {
      // Catch connection issues if they occur.
    }
    // Return the math puzzle if connection does fail.
    return _mathPuzzle();
  }

  // Method that generates an ascending arithmetic progression puzzle.
  // Returns: A number pattern sequence Puzzle instance.
  static Puzzle _patternPuzzle() {
    // Configure random seed starts and the increments.
    final start = _rng.nextInt(20) + 1;
    final step = _rng.nextInt(9) + 2;
    // Populate sequential sequence values iterating up with the generated properties.
    final terms = List.generate(4, (i) => start + step * i);
    final next = start + step * 4;
    return Puzzle(
      question: 'What comes next?\n${terms.join(', ')}, ?',
      answer: next.toString(),
      hint: 'The pattern increases by $step each time.',
      category: PuzzleCategory.pattern,
    );
  }

  // Method that cleans up text inputs by converting browser HTML escapes into legible characters.
  // Parameters:
  //   - s - The raw string payload containing encoded HTML.
  // Returns: A cleaner text representation fit for the UI components.
  static String _decodeHtml(String s) => s
    .replaceAll('&amp;', '&')
    .replaceAll('&lt;', '<')
    .replaceAll('&gt;', '>')
    .replaceAll('&quot;', '"')
    .replaceAll('&#039;', "'")
    .replaceAll('&ldquo;', '"')
    .replaceAll('&rdquo;', '"');
}
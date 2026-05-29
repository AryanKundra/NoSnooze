
class Puzzle{
  final String question;
  final String answer;
  final String? hint;
  final PuzzleCategory category;

  const Puzzle({
    required this.question,
    required this.answer,
    this.hint,
    this.category = PuzzleCategory.math,
  });

  bool check(String input) =>input.trim().toLowerCase() == answer.trim().toLowerCase();
}

enum PuzzleCategory{math, trivia, pattern}

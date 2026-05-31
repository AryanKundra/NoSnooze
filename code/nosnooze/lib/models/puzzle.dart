// Class for the type of challenge needed to turn off an alarm.
class Puzzle{
  // The prompt/problem/question the user has to answer.
  final String question;
  // The correct reply needed to solve the puzzle.
  final String answer;
  // A clue for solving the puzzle.
  final String? hint;
  // The type of puzzle the user needs to solve.
  final PuzzleCategory category;

  // Constructor for a puzzle instance.
  // Parameters:
  //   - question - The prompt/problem/question.
  //   - answer - The solution.
  //   - hint - A clue the user can use, null by default.
  //   - category - The type of puzzle.
  const Puzzle({
    required this.question,
    required this.answer,
    this.hint,
    // The puzzle will be math by default.
    this.category = PuzzleCategory.math,
  });

  // Status of whether the input matches the solution.
  // Parameters:
  //   - input - The text the user input.
  // Returns: A boolean, true if the input matches the solution even despite leading/trailing
  // spaces and letter casing; or else, false.
  bool check(String input) =>input.trim().toLowerCase() == answer.trim().toLowerCase();
}

// Puzzle classification types.
enum PuzzleCategory{math, trivia, pattern}

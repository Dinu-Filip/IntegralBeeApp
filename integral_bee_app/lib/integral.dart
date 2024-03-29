class Integral {
  final String integral;
  final String answer;
  final String difficulty;
  bool played;
  final String years;
  final bool isTiebreak;
  final int idx;

  Integral(
      {required this.integral,
      required this.answer,
      required this.difficulty,
      required this.played,
      required this.years,
      required this.isTiebreak,
      required this.idx});

  Map<String, dynamic> toJson() {
    return {
      "integral": integral,
      "answer": answer,
      "difficulty": difficulty,
      "played": played,
      "years": years,
      "tiebreak": isTiebreak,
      "idx": idx
    };
  }
}

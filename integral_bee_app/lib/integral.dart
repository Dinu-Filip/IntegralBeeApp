class Integral {
  final String integral;
  final String answer;
  final String difficulty;
  bool played;
  final String years;
  final bool isTiebreak;

  Integral(
      {required this.integral,
      required this.answer,
      required this.difficulty,
      required this.played,
      required this.years,
      required this.isTiebreak});

  Map<String, dynamic> toJson() {
    return {
      "integral": integral,
      "answer": answer,
      "difficulty": difficulty,
      "played": played,
      "years": years,
      "tiebreak": isTiebreak
    };
  }
}

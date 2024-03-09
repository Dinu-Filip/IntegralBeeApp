class Player {
  final String name;
  final String school;
  final String year;
  final bool studiesFM;
  String? lastRound;

  Player(
      {required this.name,
      required this.school,
      required this.year,
      required this.studiesFM});

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "school": school,
      "year": year,
      "studiesFM": studiesFM
    };
  }
}

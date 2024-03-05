enum Rounds {
  quarterfinalRound("Quarterfinal"),
  semifinalRound("Semifinal"),
  finalRound("Final");

  final String round;
  const Rounds(this.round);
}

enum Schools {
  Beths("Beths Grammar School");

  final String schoolName;
  const Schools(this.schoolName);
}

enum Years {
  allYears("all"),
  year12("12"),
  year13("13");

  final String year;
  const Years(this.year);
}

const String playerFile = "player.txt";
const String integralFile = "integrals.txt";

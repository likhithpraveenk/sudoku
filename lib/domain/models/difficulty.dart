enum Difficulty {
  easy(1, 'Easy'),
  medium(2, 'Medium'),
  hard(3, 'Hard'),
  expert(4, 'Expert');

  final int value;
  final String displayName;

  const Difficulty(this.value, this.displayName);

  static Difficulty fromValue(int value) {
    return Difficulty.values.firstWhere(
      (d) => d.value == value,
      orElse: () => Difficulty.easy,
    );
  }

  bool operator >(Difficulty other) {
    return value > other.value;
  }

  bool operator >=(Difficulty other) {
    return value >= other.value;
  }

  bool operator <(Difficulty other) {
    return value < other.value;
  }

  bool operator <=(Difficulty other) {
    return value <= other.value;
  }
}

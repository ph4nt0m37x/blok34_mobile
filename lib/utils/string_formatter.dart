String formatEnumName(String input) {
  final spaced = input.replaceAllMapped(
    RegExp(r'(?<=[a-z])(?=[A-Z])'),
        (match) => ' ',
  );

  return spaced[0].toUpperCase() + spaced.substring(1);
}
class NutrientInfo {
  final String color;
  final String englishMessage;
  final String hindiMessage;
  final String? additionalText;

  NutrientInfo({
    required this.color,
    required this.englishMessage,
    required this.hindiMessage,
    this.additionalText,
  });

  factory NutrientInfo.fromJson(Map<String, dynamic> json) {
    return NutrientInfo(
      color: json['color'] ?? 'unknown',
      englishMessage: json['english'] ?? 'No message in English',
      hindiMessage: json['hindi'] ?? 'No message in Hindi',
      additionalText: json['text'], // optional field
    );
  }
}

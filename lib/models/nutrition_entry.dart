class NutritionEntry {
  final String? foodName;
  final int calories;
  final double protein;
  final double carbs;
  final double fat;
  final DateTime timestamp;

  NutritionEntry({
    this.foodName,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'foodName': foodName,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory NutritionEntry.fromMap(Map<String, dynamic> map) {
    return NutritionEntry(
      foodName: map['foodName'],
      calories: map['calories'],
      protein: map['protein'] is int ? (map['protein'] as int).toDouble() : map['protein'],
      carbs: map['carbs'] is int ? (map['carbs'] as int).toDouble() : map['carbs'],
      fat: map['fat'] is int ? (map['fat'] as int).toDouble() : map['fat'],
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
} 
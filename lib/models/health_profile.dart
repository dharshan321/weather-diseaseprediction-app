class HealthProfile {
  final int age;
  final double height; // in cm
  final double weight; // in kg
  final List<String> conditions;

  HealthProfile({
    required this.age,
    required this.height,
    required this.weight,
    required this.conditions,
  });

  double get bmi {
    if (height <= 0) return 0;
    final heightInMeters = height / 100;
    return weight / (heightInMeters * heightInMeters);
  }

  String get bmiCategory {
    final val = bmi;
    if (val < 18.5) return 'Underweight';
    if (val < 25) return 'Normal';
    if (val < 30) return 'Overweight';
    return 'Obese';
  }

  Map<String, dynamic> toJson() => {
        'age': age,
        'height': height,
        'weight': weight,
        'conditions': conditions,
      };

  factory HealthProfile.fromJson(Map<String, dynamic> json) => HealthProfile(
        age: json['age'],
        height: json['height'],
        weight: json['weight'],
        conditions: List<String>.from(json['conditions']),
      );

  factory HealthProfile.initial() => HealthProfile(
        age: 25,
        height: 170,
        weight: 70,
        conditions: [],
      );
}

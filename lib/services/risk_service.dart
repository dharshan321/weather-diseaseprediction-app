import '../models/weather_model.dart';
import '../models/health_profile.dart';

enum RiskLevel { LOW, MODERATE, HIGH }

class RiskAssessment {
  final int score;
  final RiskLevel level;
  final List<String> alerts;
  final List<HealthRecommendation> recommendations;

  RiskAssessment({
    required this.score,
    required this.level,
    required this.alerts,
    required this.recommendations,
  });
}

class HealthRecommendation {
  final String title;
  final String description;
  final String icon; // Icon name/path

  HealthRecommendation({
    required this.title,
    required this.description,
    required this.icon,
  });
}

class RiskService {
  RiskAssessment calculateRisk(WeatherData weather, HealthProfile profile) {
    int score = 0;
    List<String> alerts = [];
    List<HealthRecommendation> recommendations = [];

    // 1. Temperature Logic
    if (weather.temperature > 35) {
      score += 30;
      alerts.add("Extreme Heat Warning");
      recommendations.add(HealthRecommendation(
        title: "Hydration Focus",
        description: "Drink plenty of cold water and eat Watermelon or Cucumber.",
        icon: "water_drop",
      ));
    } else if (weather.temperature < 15) {
      score += 15;
      alerts.add("Cold Weather Advisory");
      recommendations.add(HealthRecommendation(
        title: "Stay Warm",
        description: "Drink hot water or ginger tea. Eat energy-rich fruits like Bananas.",
        icon: "hot_tub",
      ));
    }

    // 2. AQI Logic
    // OpenWeather AQI: 1=Good, 2=Fair, 3=Moderate, 4=Poor, 5=Very Poor
    if (weather.aqi >= 4) {
      score += 40;
      alerts.add("High Air Pollution detected.");
      recommendations.add(HealthRecommendation(
        title: "Wear Mask",
        description: "Avoid outdoor activities. Eat Apples or Berries for antioxidants.",
        icon: "mask",
      ));
    } else if (weather.aqi == 3) {
      score += 20;
    }

    // 3. UV Index Logic
    if (weather.uvIndex > 6) {
      score += 20;
      alerts.add("High UV Exposure");
      recommendations.add(HealthRecommendation(
        title: "Sun Protection",
        description: "Apply sunscreen. Eat Lycopene-rich foods like Tomatoes.",
        icon: "wb_sunny",
      ));
    }

    // 4. Health Profile & Sensitive Groups
    bool isSensitive = profile.age > 60 || profile.age < 5 || profile.conditions.isNotEmpty;
    
    if (isSensitive) {
      score += 15;
      if (weather.aqi >= 3 && profile.conditions.contains("Asthma")) {
        score += 30;
        alerts.add("Trigger Warning: Asthma vs Air Quality");
      }
      if (weather.temperature > 35 && profile.conditions.contains("Heart Disease")) {
        score += 30;
        alerts.add("Cardiac Stress Warning: Extreme Heat");
      }
    }

    // BMI Impact
    if (profile.bmi > 30) {
      score += 10;
      if (weather.temperature > 30) score += 10;
    }

    // Normalize Score
    if (score > 100) score = 100;

    // Determine Level
    RiskLevel level;
    if (score < 30) {
      level = RiskLevel.LOW;
    } else if (score < 70) {
      level = RiskLevel.MODERATE;
    } else {
      level = RiskLevel.HIGH;
    }

    // Add generic if empty
    if (recommendations.isEmpty) {
      recommendations.add(HealthRecommendation(
        title: "Condition Normal",
        description: "Maintain your daily health routine and stay active.",
        icon: "check_circle",
      ));
    }

    return RiskAssessment(
      score: score,
      level: level,
      alerts: alerts,
      recommendations: recommendations,
    );
  }
}

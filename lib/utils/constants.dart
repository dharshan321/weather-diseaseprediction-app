import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  // OpenWeather API Key - Read from .env file
  static String get openWeatherApiKey => dotenv.env['OPEN_WEATHER_API_KEY'] ?? '';

  // Base URLs
  static const String weatherBaseUrl = 'api.openweathermap.org';
  static const String airPollutionPath = '/data/2.5/air_pollution';
  static const String weatherPath = '/data/2.5/weather';
  static const String oneCallPath =
      '/data/3.0/onecall'; // Requires One Call 3.0 subscription

  // Storage Keys
  static const String userKey = 'user_data';
  static const String healthProfileKey = 'health_profile';
  static const String isLoggedInKey = 'is_logged_in';
}

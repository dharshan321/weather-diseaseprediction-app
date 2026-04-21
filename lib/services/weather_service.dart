import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';
import '../utils/constants.dart';

class WeatherService {
  Future<WeatherData> fetchWeatherData(double lat, double lon) async {
    final apiKey = AppConstants.openWeatherApiKey;

    // 1. Fetch Current Weather (Temp, Humidity, Condition)
    final weatherUrl = Uri.https(
      AppConstants.weatherBaseUrl,
      AppConstants.weatherPath,
      {
        'lat': lat.toString(),
        'lon': lon.toString(),
        'appid': apiKey,
        'units': 'metric',
      },
    );

    // 2. Fetch AQI
    final aqiUrl = Uri.https(
      AppConstants.weatherBaseUrl,
      AppConstants.airPollutionPath,
      {
        'lat': lat.toString(),
        'lon': lon.toString(),
        'appid': apiKey,
      },
    );

    // 1. Fetch Current Weather (Required)
    final weatherResponse = await http.get(weatherUrl);
    if (weatherResponse.statusCode != 200) {
      throw Exception('Failed to fetch weather data: ${weatherResponse.body}');
    }
    final weatherJson = json.decode(weatherResponse.body);

    // 2. Fetch AQI (Optional fallback)
    int aqiValue = 1;
    try {
      final aqiResponse = await http.get(aqiUrl);
      if (aqiResponse.statusCode == 200) {
        final aqiJson = json.decode(aqiResponse.body);
        final aqiList = aqiJson['list'] as List;
        aqiValue = (aqiList[0]['main']['aqi'] as num).toInt();
      }
    } catch (e) {
      // Keep AQI as 1
    }

    // 3. Fetch UV Index (Optional fallback for One Call 3.0)
    double uvIndex = 0.0;
    try {
      final oneCallUrl = Uri.https(
        AppConstants.weatherBaseUrl,
        AppConstants.oneCallPath,
        {
          'lat': lat.toString(),
          'lon': lon.toString(),
          'appid': apiKey,
          'exclude': 'minutely,hourly,daily,alerts',
        },
      );
      final oneCallResponse = await http.get(oneCallUrl);
      if (oneCallResponse.statusCode == 200) {
        final data = json.decode(oneCallResponse.body);
        uvIndex = (data['current']?['uvi'] as num?)?.toDouble() ?? 0.0;
      }
    } catch (e) {
      // One Call failed, keep UV as 0.0
    }

    final weatherList = weatherJson['weather'] as List;
    final main = weatherJson['main'];
    
    return WeatherData(
      city: weatherJson['name'] ?? 'Unknown',
      temperature: (main['temp'] as num).toDouble(),
      humidity: (main['humidity'] as num).toInt(),
      aqi: aqiValue,
      uvIndex: uvIndex,
      condition: weatherList[0]['main'],
      description: weatherList[0]['description'],
      iconCode: weatherList[0]['icon'],
    );
  }
}

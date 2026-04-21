class WeatherData {
  final String city;
  final double temperature;
  final int humidity;
  final int aqi;
  final double uvIndex;
  final String condition;
  final String description;
  final String iconCode;

  WeatherData({
    required this.city,
    required this.temperature,
    required this.humidity,
    required this.aqi,
    required this.uvIndex,
    required this.condition,
    required this.description,
    required this.iconCode,
  });

  factory WeatherData.initial() => WeatherData(
        city: 'Loading...',
        temperature: 0,
        humidity: 0,
        aqi: 0,
        uvIndex: 0,
        condition: 'Clear',
        description: 'clear sky',
        iconCode: '01d',
      );
}

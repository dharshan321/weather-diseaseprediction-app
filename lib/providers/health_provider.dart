import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/health_profile.dart';
import '../models/weather_model.dart';
import '../services/risk_service.dart';
import '../utils/constants.dart';

class HealthProvider with ChangeNotifier {
  final RiskService _riskService = RiskService();
  HealthProfile _profile = HealthProfile.initial();
  RiskAssessment? _assessment;

  HealthProfile get profile => _profile;
  RiskAssessment? get assessment => _assessment;

  Future<void> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final profileJson = prefs.getString(AppConstants.healthProfileKey);
    if (profileJson != null) {
      _profile = HealthProfile.fromJson(json.decode(profileJson));
      notifyListeners();
    }
  }

  Future<void> updateProfile(HealthProfile newProfile) async {
    _profile = newProfile;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.healthProfileKey, json.encode(_profile.toJson()));
    notifyListeners();
  }

  void calculateRisk(WeatherData weather) {
    _assessment = _riskService.calculateRisk(weather, _profile);
    notifyListeners();
  }
}

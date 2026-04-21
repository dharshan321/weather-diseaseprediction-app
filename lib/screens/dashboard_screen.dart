import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/location_provider.dart';
import '../providers/weather_provider.dart';
import '../providers/health_provider.dart';
import '../widgets/info_card.dart';
import '../widgets/risk_meter.dart';
import '../widgets/recommendation_card.dart';
import 'profile_screen.dart';
import 'login_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    _refreshData();
  }

  Future<void> _refreshData() async {
    final locationP = Provider.of<LocationProvider>(context, listen: false);
    final weatherP = Provider.of<WeatherProvider>(context, listen: false);
    final healthP = Provider.of<HealthProvider>(context, listen: false);

    await healthP.loadProfile();

    // 1. Instant Load: Fetch weather for a default location (London) immediately
    // so the user sees data right away.
    await weatherP.fetchWeather(80.1883, 12.923);
    if (weatherP.weatherData != null) {
      healthP.calculateRisk(weatherP.weatherData!);
    }

    // 2. Background Update: Attempt to get actual location
    await locationP.determinePosition();

    // 3. If a different location is found, update the weather
    if (locationP.currentPosition != null &&
        (locationP.currentPosition!.latitude != 80.1883 ||
            locationP.currentPosition!.longitude != 12.923)) {
      await weatherP.fetchWeather(
        locationP.currentPosition!.latitude,
        locationP.currentPosition!.longitude,
      );
      if (weatherP.weatherData != null) {
        healthP.calculateRisk(weatherP.weatherData!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final locationP = Provider.of<LocationProvider>(context);
    final weatherP = Provider.of<WeatherProvider>(context);
    final healthP = Provider.of<HealthProvider>(context);

    return Scaffold(
      drawer: _buildDrawer(context, auth),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Header with Gradient and Current Weather
          SliverAppBar(
            expandedHeight: 220.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).primaryColor,
                      const Color(0xFF0F172A)
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 100, left: 24, right: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              color: Colors.white70, size: 18),
                          const SizedBox(width: 4),
                          Text(
                            weatherP.weatherData?.city ?? "Locating...",
                            style: const TextStyle(
                                color: Colors.white, fontSize: 18),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "${weatherP.weatherData?.temperature.round() ?? '--'}°C",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 56,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        weatherP.weatherData?.description.toUpperCase() ??
                            "Wait while we fetch data",
                        style: const TextStyle(
                            color: Colors.white70, letterSpacing: 1.5),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Weather Info Grid
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        InfoCard(
                          title: "AQI Index",
                          value: weatherP.weatherData?.aqi.toString() ?? "--",
                          unit: "Index",
                          icon: Icons.air,
                          iconColor: Colors.teal,
                        ),
                        const SizedBox(width: 16),
                        InfoCard(
                          title: "Humidity",
                          value:
                              weatherP.weatherData?.humidity.toString() ?? "--",
                          unit: "%",
                          icon: Icons.water_drop,
                          iconColor: Colors.blue,
                        ),
                        const SizedBox(width: 16),
                        InfoCard(
                          title: "UV Index",
                          value: weatherP.weatherData?.uvIndex
                                  .toStringAsFixed(1) ??
                              "--",
                          unit: "UVI",
                          icon: Icons.wb_sunny,
                          iconColor: Colors.orange,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Risk Meter Section
                  Center(
                    child: Column(
                      children: [
                        Text("Personal Health Risk",
                            style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 24),
                        if (healthP.assessment != null)
                          RiskMeter(
                            score: healthP.assessment!.score,
                            level: healthP.assessment!.level,
                          )
                        else
                          const CircularProgressIndicator(),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Recommendations Section
                  Text("Recommendations",
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  if (healthP.assessment != null)
                    ...healthP.assessment!.recommendations
                        .map((rec) => RecommendationCard(recommendation: rec))
                        .toList(),

                  const SizedBox(height: 20),

                  // Footer Actions
                  if (healthP.assessment?.alerts.isNotEmpty ?? false)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.red.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded,
                              color: Colors.red),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              healthP.assessment!.alerts.first,
                              style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _refreshData,
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, AuthProvider auth) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(auth.user?.name ?? "User"),
            accountEmail: Text(auth.user?.email ?? ""),
            currentAccountPicture:
                const CircleAvatar(child: Icon(Icons.person, size: 40)),
          ),
          ListStep(
            icon: Icons.person_outline,
            title: "Health Profile",
            onTap: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ProfileScreen())),
          ),
          ListStep(
            icon: Icons.settings_outlined,
            title: "Settings",
            onTap: () {},
          ),
          const Spacer(),
          ListStep(
            icon: Icons.logout,
            title: "Logout",
            onTap: () {
              auth.logout();
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()));
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class ListStep extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  const ListStep(
      {super.key,
      required this.icon,
      required this.title,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: onTap,
    );
  }
}

import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<Position> getCurrentLocation() async {
    // Default position: London
    final Position defaultPosition = Position(
      latitude: 51.5074,
      longitude: -0.1278,
      timestamp: DateTime.now(),
      accuracy: 0.0,
      altitude: 0.0,
      altitudeAccuracy: 0.0,
      heading: 0.0,
      headingAccuracy: 0.0,
      speed: 0.0,
      speedAccuracy: 0.0,
    );

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled().timeout(const Duration(seconds: 1));
      if (!serviceEnabled) return defaultPosition;

      LocationPermission permission = await Geolocator.checkPermission().timeout(const Duration(seconds: 1));
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission().timeout(const Duration(seconds: 3));
        if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
          return defaultPosition;
        }
      }

      // Try last known position first as it's nearly instant
      Position? lastPosition = await Geolocator.getLastKnownPosition().timeout(const Duration(seconds: 1));
      if (lastPosition != null) return lastPosition;

      // Try current position with a very short timeout
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.low),
      ).timeout(const Duration(seconds: 3));
    } catch (e) {
      // On any error or timeout, return London immediately
      return defaultPosition;
    }
  }
}

import 'package:geolocator/geolocator.dart';

class GeoPoint {
  const GeoPoint(this.lat, this.lng);
  final double lat;
  final double lng;
}

/// Thin wrapper around geolocator so the UI can show friendly, localized
/// messages instead of plugin exceptions.
class LocationService {
  const LocationService();

  Future<GeoPoint?> current() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const LocationProblem(LocationProblemKind.disabled);
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      throw const LocationProblem(LocationProblemKind.blockedForever);
    }
    if (permission == LocationPermission.denied) {
      throw const LocationProblem(LocationProblemKind.denied);
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 15),
        ),
      );
      return GeoPoint(position.latitude, position.longitude);
    } catch (_) {
      // Fall back to the last known fix when the device is slow to lock on.
      final last = await Geolocator.getLastKnownPosition();
      if (last != null) return GeoPoint(last.latitude, last.longitude);
      throw const LocationProblem(LocationProblemKind.unavailable);
    }
  }

  Future<bool> openSettings() => Geolocator.openAppSettings();
}

enum LocationProblemKind { disabled, denied, blockedForever, unavailable }

class LocationProblem implements Exception {
  const LocationProblem(this.kind);
  final LocationProblemKind kind;
}

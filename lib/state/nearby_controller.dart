import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/services/location_service.dart';
import '../data/services/nearby_service.dart';

enum NearbyStage { initial, locating, loading, ready, error }

/// Drives the "restaurants near me" screen: device location, manual city
/// fallback, loading/error states and the client-side name filter.
class NearbyController extends ChangeNotifier {
  NearbyController({
    NearbyService? service,
    LocationService? location,
  })  : _service = service ?? NearbyService(),
        _location = location ?? const LocationService();

  final NearbyService _service;
  final LocationService _location;

  NearbyStage stage = NearbyStage.initial;
  List<NearbyPlace> places = const [];
  String query = '';
  double? lat;
  double? lng;
  String? cityName;
  String? cityNameSi;
  bool usingGps = false;
  bool usingSaved = false;
  LocationProblemKind? locationProblem;
  String? errorCode;

  List<NearbyPlace> get visible {
    if (query.trim().isEmpty) return places;
    final needle = query.toLowerCase().trim();
    return places
        .where((p) =>
            p.name.toLowerCase().contains(needle) ||
            (p.cuisine ?? '').toLowerCase().contains(needle) ||
            p.category.toLowerCase().contains(needle))
        .toList(growable: false);
  }

  bool get hasOrigin => lat != null && lng != null;

  void setQuery(String value) {
    query = value;
    notifyListeners();
  }

  Future<void> useDeviceLocation() async {
    stage = NearbyStage.locating;
    locationProblem = null;
    errorCode = null;
    notifyListeners();

    try {
      final point = await _location.current();
      if (point == null) {
        stage = NearbyStage.error;
        locationProblem = LocationProblemKind.denied;
        notifyListeners();
        return;
      }
      lat = point.lat;
      lng = point.lng;
      cityName = null;
      cityNameSi = null;
      usingGps = true;
      await _load();
    } on LocationProblem catch (problem) {
      stage = NearbyStage.error;
      locationProblem = problem.kind;
      notifyListeners();
    } catch (_) {
      stage = NearbyStage.error;
      errorCode = 'unexpected';
      notifyListeners();
    }
  }

  Future<void> useCity(CityAnchor city) async {
    lat = city.lat;
    lng = city.lng;
    cityName = city.name;
    cityNameSi = city.nameSi;
    usingGps = false;
    locationProblem = null;
    errorCode = null;
    await _load();
  }

  Future<void> refresh() async {
    if (!hasOrigin) return;
    NearbyService.clearCache();
    await _load();
  }

  Future<void> _load() async {
    if (!hasOrigin) return;
    errorCode = null;

    // Show the last real result for this area immediately; a returning user
    // should never stare at a spinner while the free map service wakes up.
    final saved = await _service.savedNearby(lat!, lng!);
    if (saved != null && saved.isNotEmpty) {
      places = saved;
      usingSaved = true;
      stage = NearbyStage.ready;
    } else {
      usingSaved = false;
      stage = NearbyStage.loading;
    }
    notifyListeners();

    try {
      places = await _service.restaurantsNear(lat!, lng!);
      usingSaved = false;
      stage = NearbyStage.ready;
    } on NearbyException catch (error) {
      await _fallBackToSaved(error.message);
    } catch (_) {
      await _fallBackToSaved('unexpected');
    }
    notifyListeners();
  }

  /// Keeps the screen useful when OpenStreetMap is slow or offline: show the
  /// last real results for this area instead of an empty error screen.
  Future<void> _fallBackToSaved(String code) async {
    if (usingSaved && places.isNotEmpty) return;
    final saved = await _service.savedNearby(lat!, lng!);
    if (saved != null && saved.isNotEmpty) {
      places = saved;
      usingSaved = true;
      stage = NearbyStage.ready;
      return;
    }
    errorCode = code;
    stage = NearbyStage.error;
  }

  Future<void> openSystemLocationSettings() async {
    await _location.openSettings();
  }
}

final nearbyProvider = ChangeNotifierProvider<NearbyController>((ref) {
  return NearbyController();
});

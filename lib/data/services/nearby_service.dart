import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

/// A real restaurant/café returned by OpenStreetMap (Photon or Overpass).
class NearbyPlace {
  const NearbyPlace({
    required this.id,
    required this.name,
    required this.category,
    required this.lat,
    required this.lng,
    required this.distanceKm,
    this.cuisine,
    this.address,
    this.phone,
    this.website,
    this.openingHours,
  });

  factory NearbyPlace.fromJson(Map<String, dynamic> json) => NearbyPlace(
        id: json['id'] as String? ?? '',
        name: json['name'] as String? ?? '',
        category: json['category'] as String? ?? 'restaurant',
        lat: (json['lat'] as num?)?.toDouble() ?? 0,
        lng: (json['lng'] as num?)?.toDouble() ?? 0,
        distanceKm: (json['distanceKm'] as num?)?.toDouble() ?? 0,
        cuisine: json['cuisine'] as String?,
        address: json['address'] as String?,
        phone: json['phone'] as String?,
        website: json['website'] as String?,
        openingHours: json['openingHours'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'category': category,
        'lat': lat,
        'lng': lng,
        'distanceKm': distanceKm,
        'cuisine': cuisine,
        'address': address,
        'phone': phone,
        'website': website,
        'openingHours': openingHours,
      };

  final String id;
  final String name;
  final String category; // restaurant | cafe | fast_food
  final double lat;
  final double lng;
  final double distanceKm;
  final String? cuisine;
  final String? address;
  final String? phone;
  final String? website;
  final String? openingHours;

  String get directionsUrl =>
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng';

  String get placeUrl =>
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
}

class NearbyException implements Exception {
  const NearbyException(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Looks up real restaurants around a point using OpenStreetMap data.
/// Nominatim is tried first because it is fast and allows cross-origin
/// requests; Photon covers what its keyword search misses; Overpass (native
/// only, since it does not send CORS headers) is the last resort.
class NearbyService {
  NearbyService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  static const _endpoints = [
    'https://overpass-api.de/api/interpreter',
    // Public mirror, used when the main instance is overloaded.
    'https://overpass.kumi.systems/api/interpreter',
  ];

  /// Nominatim is the primary source: it answers in a second or two and sends
  /// CORS headers, so the web build can use it. Overpass does *not* send CORS
  /// headers, which is why it is only used on native platforms now.
  static const _nominatim = 'https://nominatim.openstreetmap.org/search';
  static const _nominatimQueries = ['restaurant', 'cafe', 'food'];

  static const _cacheTtl = Duration(minutes: 10);
  static const _savedPrefix = 'mm.nearby.saved.';

  /// Photon matches names, so query a spread of food keywords and merge the
  /// results. Categories stay aligned with the filters used by the UI.
  ///
  /// Photon is a free community service and throttles bursts, so the list stays
  /// deliberately small: four broad keywords already cover dense city centres
  /// and each extra request makes a 503 more likely.
  static const _photonQueries = <_PhotonQuery>[
    _PhotonQuery('restaurant', 'amenity:restaurant', 'restaurant'),
    _PhotonQuery('cafe', 'amenity:cafe', 'cafe'),
    _PhotonQuery('fast food', 'amenity:fast_food', 'fast_food'),
    _PhotonQuery('bakery', 'shop:bakery', 'cafe'),
  ];

  static final Map<String, _CacheEntry> _cache = {};

  /// Forces the next lookup to hit the network (pull-to-refresh).
  static void clearCache() => _cache.clear();

  /// Best-effort persisted copy of the last successful lookup for this area.
  /// Used when OpenStreetMap is unreachable so the screen can still show real
  /// places the user has already seen.
  Future<List<NearbyPlace>?> savedNearby(double lat, double lng,
      {int radiusMeters = 2500}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      for (final key in [
        _savedKey(lat, lng, radiusMeters, 3),
        _savedKey(lat, lng, radiusMeters, 2),
      ]) {
        final raw = prefs.getString(key);
        if (raw == null) continue;
        final decoded = jsonDecode(raw);
        if (decoded is! List) continue;
        final places = decoded
            .whereType<Map<String, dynamic>>()
            .map(NearbyPlace.fromJson)
            .toList(growable: false);
        if (places.isNotEmpty) return places;
      }
    } catch (_) {
      // Cache is a convenience, never a hard dependency.
    }
    return null;
  }

  static String _savedKey(double lat, double lng, int radius, int decimals) =>
      '$_savedPrefix${lat.toStringAsFixed(decimals)},'
      '${lng.toStringAsFixed(decimals)},$radius';

  Future<void> _save(
      double lat, double lng, int radius, List<NearbyPlace> places) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _savedKey(lat, lng, radius, 2),
        jsonEncode(places.map((p) => p.toJson()).toList()),
      );
    } catch (_) {
      // Ignore storage failures; the in-memory cache still applies.
    }
  }

  Future<List<NearbyPlace>> restaurantsNear(
    double lat,
    double lng, {
    int radiusMeters = 2500,
    int limit = 40,
  }) async {
    final key =
        '${lat.toStringAsFixed(3)},${lng.toStringAsFixed(3)},$radiusMeters';
    final cached = _cache[key];
    if (cached != null && DateTime.now().difference(cached.at) < _cacheTtl) {
      return cached.places;
    }

    // 1. Nominatim first: it answers in a second or two and allows cross-origin
    // requests, so the deployed web build can use it too.
    final nominatim = await _viaNominatim(lat, lng, radiusMeters, limit);
    if (nominatim != null && nominatim.isNotEmpty) {
      return _remember(key, lat, lng, radiusMeters, nominatim);
    }

    // 2. Photon next: a name search that covers what Nominatim's keyword
    // matching misses. It is rate limited, so it is never the only source.
    final photon = await _viaPhoton(lat, lng, radiusMeters, limit);
    if (photon != null && photon.isNotEmpty) {
      return _remember(key, lat, lng, radiusMeters, photon);
    }

    // If a source answered with no places at all, the area has no listings and
    // an empty list is the honest answer instead of an error.
    if (nominatim != null || photon != null) {
      _cache[key] = _CacheEntry(const [], DateTime.now());
      return const [];
    }

    // 3. Overpass is the richest source, but it does not send CORS headers, so
    // it can only be used by the native app. The web build stops here.
    if (kIsWeb) throw const NearbyException('network');

    final query = '''
[out:json][timeout:25];
(
  node["amenity"~"^(restaurant|cafe|fast_food)\$"](around:$radiusMeters,$lat,$lng);
  way["amenity"~"^(restaurant|cafe|fast_food)\$"](around:$radiusMeters,$lat,$lng);
);
out center tags 80;''';

    http.Response? response;
    String? failure;
    // Overpass is a free community service and occasionally slow or throttled.
    // A short per-endpoint timeout plus a mirror keeps the screen usable. The
    // mirror is only tried when the first instance answered with a throttle or
    // server error; a network timeout would almost certainly repeat there and
    // would leave the user staring at a spinner for too long.
    for (var i = 0; i < _endpoints.length; i++) {
      final endpoint = _endpoints[i];
      var retryMirror = false;
      try {
        final attempt = await _client.post(
          Uri.parse(endpoint),
          headers: const {
            'Accept': 'application/json',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
          body: {'data': query},
        ).timeout(const Duration(seconds: 12));
        if (attempt.statusCode == 200) {
          response = attempt;
          break;
        }
        failure = (attempt.statusCode == 429 || attempt.statusCode >= 500)
            ? 'timeout'
            : 'server';
        retryMirror = attempt.statusCode == 429 || attempt.statusCode >= 500;
      } on TimeoutException {
        failure = 'timeout';
      } catch (_) {
        failure = 'network';
      }
      if (!retryMirror) break;
      if (i == _endpoints.length - 1) break;
      // A tiny pause gives a throttled instance a moment to recover.
      await Future<void>.delayed(const Duration(milliseconds: 250));
    }

    if (response == null) {
      throw NearbyException(failure ?? 'network');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final elements = (decoded['elements'] as List?) ?? const [];
    final places = <NearbyPlace>[];

    for (final raw in elements) {
      if (raw is! Map<String, dynamic>) continue;
      final tags = (raw['tags'] as Map<String, dynamic>?) ?? const {};
      final name = (tags['name'] as String?)?.trim();
      if (name == null || name.isEmpty) continue;

      final center = raw['center'] as Map<String, dynamic>?;
      final placeLat = (raw['lat'] as num?)?.toDouble() ??
          (center?['lat'] as num?)?.toDouble();
      final placeLng = (raw['lon'] as num?)?.toDouble() ??
          (center?['lon'] as num?)?.toDouble();
      if (placeLat == null || placeLng == null) continue;

      final distance = _distanceKm(lat, lng, placeLat, placeLng);
      if (distance > radiusMeters / 1000) continue;

      places.add(
        NearbyPlace(
          id: '${raw['type'] ?? 'node'}/${raw['id']}',
          name: name,
          category: (tags['amenity'] as String?) ?? 'restaurant',
          lat: placeLat,
          lng: placeLng,
          distanceKm: distance,
          cuisine: _clean(tags['cuisine']),
          address: _address(tags),
          phone: _clean(tags['phone'] ?? tags['contact:phone']),
          website: _clean(tags['website'] ?? tags['contact:website']),
          openingHours: _clean(tags['opening_hours']),
        ),
      );
    }

    places.sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    final result = places.take(limit).toList(growable: false);
    return _remember(key, lat, lng, radiusMeters, result);
  }

  Future<List<NearbyPlace>> _remember(
    String key,
    double lat,
    double lng,
    int radiusMeters,
    List<NearbyPlace> places,
  ) async {
    _cache[key] = _CacheEntry(places, DateTime.now());
    await _save(lat, lng, radiusMeters, places);
    return places;
  }

  /// Nominatim search. Structurally identical to Photon for our purposes, but
  /// it is CORS-friendly and returns OSM `type` tags, which keeps the category
  /// filters meaningful. Returns `null` when every request failed, so callers
  /// can tell "nothing here" apart from "the network is down".
  Future<List<NearbyPlace>?> _viaNominatim(
    double lat,
    double lng,
    int radiusMeters,
    int limit,
  ) async {
    final dLat = radiusMeters / 111320.0;
    final dLng = radiusMeters / (111320.0 * math.cos(lat * math.pi / 180));
    // Nominatim wants left,top,right,bottom (lonMin, latMax, lonMax, latMin).
    final viewbox = '${(lng - dLng).toStringAsFixed(5)},'
        '${(lat + dLat).toStringAsFixed(5)},'
        '${(lng + dLng).toStringAsFixed(5)},'
        '${(lat - dLat).toStringAsFixed(5)}';

    var answered = false;
    final found = <String, NearbyPlace>{};
    for (var i = 0; i < _nominatimQueries.length; i++) {
      // A dense city usually fills the list from the first keyword, so the
      // slower follow-up searches are skipped instead of always running.
      if (found.length >= limit) break;
      if (i > 0) {
        // The public instance asks for at most one request per second.
        await Future<void>.delayed(const Duration(milliseconds: 400));
      }
      final batch = await _fetchNominatim(
        _nominatimQueries[i],
        viewbox,
        lat,
        lng,
        radiusMeters,
        limit,
      );
      if (batch == null) continue;
      answered = true;
      for (final place in batch) {
        found.putIfAbsent(place.id, () => place);
      }
    }
    if (!answered) return null;

    final places = found.values.toList()
      ..sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    return places.take(limit).toList(growable: false);
  }

  Future<List<NearbyPlace>?> _fetchNominatim(
    String keyword,
    String viewbox,
    double lat,
    double lng,
    int radiusMeters,
    int limit,
  ) async {
    try {
      final uri = Uri.parse(_nominatim).replace(queryParameters: {
        'q': keyword,
        'format': 'jsonv2',
        'limit': '${limit + 10}',
        'viewbox': viewbox,
        'bounded': '1',
        'addressdetails': '1',
        'extratags': '1',
      });
      final response = await _client.get(uri, headers: const {
        'Accept': 'application/json'
      }).timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) return null;

      final decoded = jsonDecode(response.body);
      if (decoded is! List) return null;

      final places = <NearbyPlace>[];
      for (final raw in decoded) {
        if (raw is! Map<String, dynamic>) continue;
        final name = (raw['name'] as String?)?.trim();
        if (name == null || name.isEmpty) continue;
        if (!_isFoodPlace(raw)) continue;

        final placeLat = double.tryParse('${raw['lat']}');
        final placeLng = double.tryParse('${raw['lon']}');
        if (placeLat == null || placeLng == null) continue;

        final distance = _distanceKm(lat, lng, placeLat, placeLng);
        if (distance > radiusMeters / 1000) continue;

        final extra = raw['extratags'];
        final tags = extra is Map<String, dynamic> ? extra : const {};
        places.add(
          NearbyPlace(
            id: '${raw['osm_type'] ?? 'node'}/${raw['osm_id'] ?? name}',
            name: name,
            category: _normaliseCategory(raw['type'] as String?, 'restaurant'),
            lat: placeLat,
            lng: placeLng,
            distanceKm: distance,
            cuisine: _clean(tags['cuisine']),
            address: _nominatimAddress(raw),
            phone: _clean(tags['phone'] ?? tags['contact:phone']),
            website: _clean(tags['website'] ?? tags['contact:website']),
            openingHours: _clean(tags['opening_hours']),
          ),
        );
      }
      return places;
    } catch (_) {
      // One failed keyword should not hide the others.
      return null;
    }
  }

  /// Nominatim also matches streets, shops and hotels for a word like "food",
  /// so keep only entries that really are places to eat.
  static bool _isFoodPlace(Map<String, dynamic> raw) {
    const foodTypes = {
      'restaurant',
      'cafe',
      'fast_food',
      'bakery',
      'bar',
      'pub',
      'food_court',
      'ice_cream',
      'coffee_shop',
    };
    final type = raw['type'];
    return type is String && foodTypes.contains(type);
  }

  static String? _nominatimAddress(Map<String, dynamic> raw) {
    final address = raw['address'];
    if (address is! Map<String, dynamic>) return null;
    final parts = [
      address['house_number'],
      address['road'],
      address['suburb'] ?? address['neighbourhood'],
      address['city'] ?? address['town'] ?? address['village'],
    ]
        .whereType<String>()
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList();
    if (parts.isEmpty) return null;
    return parts.join(', ');
  }

  /// Lightweight OpenStreetMap search used when Overpass is at capacity.
  /// Photon returns GeoJSON and allows cross-origin requests. Text search only
  /// matches names, so several food-related keywords are queried in parallel
  /// and merged; this is what makes dense city centres show enough places.
  Future<List<NearbyPlace>?> _viaPhoton(
    double lat,
    double lng,
    int radiusMeters,
    int limit,
  ) async {
    final dLat = radiusMeters / 111320.0;
    final dLng = radiusMeters / (111320.0 * math.cos(lat * math.pi / 180));
    final bbox = '${(lng - dLng).toStringAsFixed(5)},'
        '${(lat - dLat).toStringAsFixed(5)},'
        '${(lng + dLng).toStringAsFixed(5)},'
        '${(lat + dLat).toStringAsFixed(5)}';

    final batches = await Future.wait(
      _photonQueries.map(
        (query) => _fetchPhotonQuery(query, bbox, lat, lng, radiusMeters),
      ),
    );

    if (batches.every((batch) => batch == null)) return null;

    final found = <String, NearbyPlace>{};
    final seen = <String>{};
    for (final batch in batches) {
      for (final place in batch ?? const <NearbyPlace>[]) {
        if (found.containsKey(place.id)) continue;
        // Node and way entries occasionally describe the same venue; keep the
        // closest one instead of showing it twice.
        final signature = '${place.name.toLowerCase()}|'
            '${place.lat.toStringAsFixed(4)}|${place.lng.toStringAsFixed(4)}';
        if (!seen.add(signature)) continue;
        found[place.id] = place;
      }
    }

    final places = found.values.toList()
      ..sort((a, b) => a.distanceKm.compareTo(b.distanceKm));
    return places.take(limit).toList(growable: false);
  }

  Future<List<NearbyPlace>?> _fetchPhotonQuery(
    _PhotonQuery query,
    String bbox,
    double lat,
    double lng,
    int radiusMeters,
  ) async {
    try {
      final uri = Uri.parse('https://photon.komoot.io/api/').replace(
        queryParameters: {
          'q': query.query,
          'bbox': bbox,
          'limit': '50',
          'lang': 'en',
          'osm_tag': query.osmTag,
        },
      );
      http.Response? response;
      for (var attempt = 0; attempt < 2; attempt++) {
        response = await _client.get(uri).timeout(const Duration(seconds: 8));
        if (response.statusCode == 200) break;
        // A short, single retry smooths over Photon's burst throttling.
        if (response.statusCode == 429 || response.statusCode == 503) {
          await Future<void>.delayed(
              Duration(milliseconds: 300 * (attempt + 1)));
          continue;
        }
        return null;
      }
      if (response == null || response.statusCode != 200) return null;

      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) return null;
      final features = decoded['features'];
      if (features is! List) return null;

      final places = <NearbyPlace>[];
      for (final raw in features) {
        if (raw is! Map<String, dynamic>) continue;
        final props = (raw['properties'] as Map<String, dynamic>?) ?? const {};
        final name = (props['name'] as String?)?.trim();
        if (name == null || name.isEmpty) continue;

        final geometry = raw['geometry'];
        if (geometry is! Map<String, dynamic>) continue;
        final coords = geometry['coordinates'];
        if (coords is! List || coords.length < 2) continue;
        final placeLng = (coords[0] as num?)?.toDouble();
        final placeLat = (coords[1] as num?)?.toDouble();
        if (placeLat == null || placeLng == null) continue;

        final distance = _distanceKm(lat, lng, placeLat, placeLng);
        if (distance > radiusMeters / 1000) continue;

        final category = _normaliseCategory(
          props['osm_value'] as String?,
          query.fallbackCategory,
        );
        final id = '${props['osm_type'] ?? 'node'}/${props['osm_id'] ?? name}';
        places.add(NearbyPlace(
          id: id,
          name: name,
          category: category,
          lat: placeLat,
          lng: placeLng,
          distanceKm: distance,
          address: _photonAddress(props),
        ));
      }
      return places;
    } catch (_) {
      // One failed keyword should not hide the others.
      return null;
    }
  }

  static String _normaliseCategory(String? osmValue, String fallback) {
    switch (osmValue) {
      case 'restaurant':
      case 'food_court':
      case 'bar':
      case 'pub':
        return 'restaurant';
      case 'cafe':
      case 'ice_cream':
      case 'bakery':
        return 'cafe';
      case 'fast_food':
        return 'fast_food';
      default:
        return fallback;
    }
  }

  static String? _photonAddress(Map<String, dynamic> props) {
    final parts = [
      props['housenumber'],
      props['street'],
      props['district'],
      props['city'],
    ]
        .whereType<String>()
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toSet()
        .toList();
    if (parts.isEmpty) return null;
    return parts.join(', ');
  }

  static String? _clean(Object? value) {
    if (value is! String) return null;
    final trimmed = value.trim();
    if (trimmed.isEmpty || trimmed == 'no') return null;
    return trimmed;
  }

  static String? _address(Map<String, dynamic> tags) {
    final parts = [
      tags['addr:housenumber'],
      tags['addr:street'],
      tags['addr:suburb'],
      tags['addr:city'],
    ].whereType<String>().map((e) => e.trim()).where((e) => e.isNotEmpty);
    if (parts.isEmpty) return null;
    return parts.join(', ');
  }

  static double _distanceKm(
      double lat1, double lon1, double lat2, double lon2) {
    const earth = 6371.0;
    double rad(double deg) => deg * math.pi / 180;
    final dLat = rad(lat2 - lat1);
    final dLon = rad(lon2 - lon1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(rad(lat1)) *
            math.cos(rad(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    return earth * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }
}

class _CacheEntry {
  const _CacheEntry(this.places, this.at);
  final List<NearbyPlace> places;
  final DateTime at;
}

class _PhotonQuery {
  const _PhotonQuery(this.query, this.osmTag, this.fallbackCategory);
  final String query;
  final String osmTag;
  final String fallbackCategory;
}

/// A place the user can pick when they do not want to share GPS location.
class CityAnchor {
  const CityAnchor(this.name, this.nameSi, this.lat, this.lng);
  final String name;
  final String nameSi;
  final double lat;
  final double lng;

  String localized(bool isSi) => isSi ? nameSi : name;
}

const cityAnchors = <CityAnchor>[
  CityAnchor('Colombo', 'කොළඹ', 6.9271, 79.8612),
  CityAnchor('Kandy', 'මහනුවර', 7.2906, 80.6337),
  CityAnchor('Galle', 'ගාල්ල', 6.0535, 80.2210),
  CityAnchor('Negombo', 'මීගමුව', 7.2083, 79.8358),
  CityAnchor('Jaffna', 'යාපනය', 9.6615, 80.0255),
  CityAnchor('Battaramulla', 'බත්තරමුල්ල', 6.8964, 79.9181),
];

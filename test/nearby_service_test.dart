import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:moodmeal/data/services/nearby_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Nominatim `jsonv2` rows, trimmed to the fields the app reads.
const _nominatimPayload = [
  {
    'osm_type': 'node',
    'osm_id': 11,
    'lat': '6.9275',
    'lon': '79.8615',
    'category': 'amenity',
    'type': 'cafe',
    'name': 'Cafe One',
    'address': {
      'road': 'Galle Road',
      'suburb': 'Kollupitiya',
      'city': 'Colombo',
    },
    'extratags': {
      'cuisine': 'coffee_shop',
      'opening_hours': 'Mo-Su 08:00-20:00',
      'phone': '+94 11 234 5678',
    },
  },
  {
    'osm_type': 'way',
    'osm_id': 12,
    'lat': '6.9300',
    'lon': '79.8650',
    'category': 'amenity',
    'type': 'restaurant',
    'name': 'Way Place',
    'address': {'house_number': '5', 'road': 'Main St'},
  },
  {
    // A supermarket can match the word "food" but is not a place to eat.
    'osm_type': 'node',
    'osm_id': 13,
    'lat': '6.9200',
    'lon': '79.8600',
    'category': 'shop',
    'type': 'supermarket',
    'name': 'Not Food',
  },
];

const _overpassPayload = {
  'elements': [
    {
      'type': 'node',
      'id': 1,
      'lat': 6.9275,
      'lon': 79.8615,
      'tags': {
        'amenity': 'cafe',
        'name': 'Cafe One',
        'cuisine': 'coffee_shop',
      },
    },
    {
      // No name: should be skipped rather than shown as a blank card.
      'type': 'node',
      'id': 2,
      'lat': 6.92,
      'lon': 79.86,
      'tags': {'amenity': 'restaurant'},
    },
  ],
};

Map<String, dynamic> _photonFeature({
  required int id,
  required String name,
  required String value,
  required double lat,
  required double lng,
}) =>
    {
      'geometry': {
        'coordinates': [lng, lat],
      },
      'properties': {
        'osm_type': 'N',
        'osm_id': id,
        'osm_value': value,
        'name': name,
      },
    };

bool _isNominatim(http.Request request) =>
    request.url.host == 'nominatim.openstreetmap.org';

bool _isPhoton(http.Request request) => request.url.host == 'photon.komoot.io';

bool _isOverpass(http.Request request) => request.url.host.contains('overpass');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    NearbyService.clearCache();
  });

  test('reads Nominatim first and keeps only real places to eat', () async {
    final hosts = <String>[];
    late http.Request first;
    final service = NearbyService(
      client: MockClient((request) async {
        hosts.add(request.url.host);
        first = request;
        return http.Response(jsonEncode(_nominatimPayload), 200);
      }),
    );

    final places = await service.restaurantsNear(6.9271, 79.8612);

    expect(hosts.every((host) => host == 'nominatim.openstreetmap.org'), isTrue,
        reason: 'Photon and Overpass must not run when Nominatim answers');
    expect(first.url.queryParameters['format'], 'jsonv2');
    expect(first.url.queryParameters['bounded'], '1');
    // left,top,right,bottom around the requested point.
    final box = first.url.queryParameters['viewbox']!.split(',');
    expect(box.length, 4);
    expect(double.parse(box[1]), greaterThan(6.9271));
    expect(double.parse(box[3]), lessThan(6.9271));

    expect(places.map((p) => p.name), ['Cafe One', 'Way Place']);
    expect(places.first.category, 'cafe');
    expect(places.first.cuisine, 'coffee_shop');
    expect(places.first.openingHours, 'Mo-Su 08:00-20:00');
    expect(places.first.phone, '+94 11 234 5678');
    expect(places.first.address, 'Galle Road, Kollupitiya, Colombo');
    expect(places.last.address, '5, Main St');
    // Nearest first.
    expect(places.first.distanceKm, lessThan(places.last.distanceKm));
  });

  test('falls back to Photon when Nominatim has nothing here', () async {
    final service = NearbyService(
      client: MockClient((request) async {
        if (_isNominatim(request)) return http.Response('[]', 200);
        if (_isPhoton(request)) {
          return http.Response(
            jsonEncode({
              'features': [
                _photonFeature(
                  id: 42,
                  name: 'Photon Cafe',
                  value: 'cafe',
                  lat: 6.9276,
                  lng: 79.8617,
                ),
              ],
            }),
            200,
          );
        }
        fail('Overpass should not be reached while Photon has an answer');
      }),
    );

    final places = await service.restaurantsNear(6.9271, 79.8612);
    expect(places.length, 1);
    expect(places.first.name, 'Photon Cafe');
    expect(places.first.category, 'cafe');
  });

  test('uses Overpass when the web-friendly sources cannot answer', () async {
    final service = NearbyService(
      client: MockClient((request) async {
        if (_isNominatim(request) || _isPhoton(request)) {
          throw http.ClientException('offline');
        }
        expect(_isOverpass(request), isTrue);
        expect(request.method, 'POST');
        return http.Response(jsonEncode(_overpassPayload), 200);
      }),
    );

    final places = await service.restaurantsNear(6.9271, 79.8612);
    expect(places.length, 1);
    expect(places.first.name, 'Cafe One');
  });

  test('an empty area is reported as empty instead of as an error', () async {
    final service = NearbyService(
      client: MockClient((request) async {
        if (_isNominatim(request)) return http.Response('[]', 200);
        return http.Response(jsonEncode({'features': []}), 200);
      }),
    );

    final places = await service.restaurantsNear(6.9271, 79.8612);
    expect(places, isEmpty);
  });

  test('reports a timeout code when every source is throttled', () async {
    final service = NearbyService(
      client: MockClient((request) async => http.Response('busy', 429)),
    );

    await expectLater(
      service.restaurantsNear(6.9271, 79.8612),
      throwsA(isA<NearbyException>()
          .having((e) => e.message, 'message', 'timeout')),
    );
  });

  test('saves the last result so it can be shown while offline', () async {
    final service = NearbyService(
      client: MockClient((request) async {
        if (_isNominatim(request)) {
          return http.Response(jsonEncode(_nominatimPayload), 200);
        }
        return http.Response('[]', 200);
      }),
    );

    final live = await service.restaurantsNear(6.9271, 79.8612);
    final saved = await service.savedNearby(6.9274, 79.8614);

    expect(saved, isNotNull);
    expect(saved!.map((p) => p.id), live.map((p) => p.id));
    expect(saved.first.name, 'Cafe One');
  });
}

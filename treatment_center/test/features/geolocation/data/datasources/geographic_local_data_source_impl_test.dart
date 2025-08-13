import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:treatment_center/core/error/exceptions.dart';
import 'package:treatment_center/features/geolocation/data/datasources/geographic_local_data_source_impl.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late GeographicLocalDataSourceImpl dataSource;
  late MapAssetBundle bundle;

  setUp(() {
    // fresh, isolated bundle per test, no global caches involved
    bundle = MapAssetBundle({
      countriesKey: null,
      statesKey: null,
      citiesKey: null,
    });

    // reset class static caches
    GeographicLocalDataSourceImpl.clearCaches();

    dataSource = GeographicLocalDataSourceImpl(bundle: bundle);
  });

  group('getCountries', () {
    test('throws CacheException when asset load fails', () async {
      // keep countriesKey as null -> MapAssetBundle throws -> we map to CacheException
      expect(() => dataSource.getCountries(), throwsA(isA<CacheException>()));
    });

    test('returns parsed list on success', () async {
      bundle.assets[countriesKey] = countriesJson;

      final list = await dataSource.getCountries();
      expect(list, hasLength(2));
      expect(list.first.name, 'Italy');
      expect(list.first.iso2, 'IT');
      expect(list.first.emoji, '🇮🇹');
      expect(list.first.phonecode, '39');
    });

    test(
      'returns cached list on subsequent calls (even if asset later fails)',
      () async {
        bundle.assets[countriesKey] = countriesJson;
        final first = await dataSource.getCountries();
        expect(first, hasLength(2));

        // Now simulate a failure; should still return cached data
        bundle.assets[countriesKey] = null;
        final second = await dataSource.getCountries();
        expect(second, hasLength(2));
        expect(identical(first, second), isTrue);
      },
    );
  });

  group('getStates', () {
    test('throws CacheException when asset load fails', () async {
      expect(() => dataSource.getStates(), throwsA(isA<CacheException>()));
    });

    test('returns parsed list on success', () async {
      bundle.assets[statesKey] = statesJson;

      final list = await dataSource.getStates();
      expect(list, hasLength(2));
      expect(list.first.name, 'Lombardy');
      expect(list.first.countryCode, 'IT');
      expect(list.first.stateCode, 'IT-25');
    });

    test('returns cached list on subsequent calls', () async {
      bundle.assets[statesKey] = statesJson;
      final first = await dataSource.getStates();

      bundle.assets[statesKey] = null; // would fail if not cached
      final second = await dataSource.getStates();

      expect(second, hasLength(2));
      expect(identical(first, second), isTrue);
    });
  });

  group('getCities', () {
    test('throws CacheException when asset load fails', () async {
      expect(() => dataSource.getCities(), throwsA(isA<CacheException>()));
    });

    test('returns parsed list on success', () async {
      bundle.assets[citiesKey] = citiesJson;

      final list = await dataSource.getCities();
      expect(list, hasLength(2));
      expect(list.first.name, 'Milan');
      expect(list.first.stateCode, 'IT-25');
    });

    test('returns cached list on subsequent calls', () async {
      bundle.assets[citiesKey] = citiesJson;
      final first = await dataSource.getCities();

      bundle.assets[citiesKey] = null;
      final second = await dataSource.getCities();

      expect(second, hasLength(2));
      expect(identical(first, second), isTrue);
    });
  });
  group('constructor / bundle selection', () {
    test('defaults to rootBundle when bundle not provided', () async {
      // Mock rootBundle once for this test
      final messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

      final stableManifestJson = jsonEncode({
        countriesKey: [countriesKey],
        statesKey: [statesKey],
        citiesKey: [citiesKey],
      });

      messenger.setMockMessageHandler('flutter/assets', (
        ByteData? message,
      ) async {
        final key = const StringCodec().decodeMessage(message!)!;
        if (key == 'AssetManifest.json') return _bd(stableManifestJson);
        if (key == 'AssetManifest.bin') return null; // fallback to JSON
        if (key == countriesKey) return _bd(countriesJson);
        return null; // others "missing"
      });

      // fresh caches
      GeographicLocalDataSourceImpl.clearCaches();

      // No bundle provided -> uses rootBundle internally (exercises `_bundle`)
      final ds = GeographicLocalDataSourceImpl();
      final list = await ds.getCountries();

      expect(list, hasLength(2));
      expect(list.first.name, 'Italy');

      // Cleanup so later tests aren't affected
      messenger.setMockMessageHandler('flutter/assets', null);
    });
  });
}

class MapAssetBundle extends AssetBundle {
  MapAssetBundle(this.assets);
  final Map<String, String?> assets;

  @override
  Future<ByteData> load(String key) async {
    final s = await loadString(key, cache: false);
    return ByteData.sublistView(Uint8List.fromList(utf8.encode(s)));
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    final v = assets[key];
    if (v == null) {
      // Simulate load failure just like real bundle would
      throw FlutterError('Unable to load asset: $key');
    }
    return v;
  }

  @override
  void evict(String key) {
    /* no-op */
  }
}

// Keys used by the SUT.
const countriesKey = 'assets/geolocation/countries.json';
const statesKey = 'assets/geolocation/states.json';
const citiesKey = 'assets/geolocation/cities.json';

// ------------------------ Test data ------------------------

const countriesJson = '''
[
  {"id":1,"name":"Italy","iso2":"IT","emoji":"🇮🇹","phonecode":"39"},
  {"id":2,"name":"Iran","iso2":"IR","emoji":"🇮🇷","phonecode":"98"}
]
''';

const statesJson = '''
[
  {"id":10,"name":"Lombardy","country_code":"IT","iso3166_2":"IT-25"},
  {"id":11,"name":"Tehran Province","country_code":"IR","iso3166_2":"IR-23"}
]
''';

const citiesJson = '''
[
  {"id":100,"name":"Milan","state_code":"IT-25"},
  {"id":101,"name":"Tehran","state_code":"IR-23"}
]
''';
// helper (near your other helpers)
ByteData _bd(String s) =>
    ByteData.sublistView(Uint8List.fromList(utf8.encode(s)));

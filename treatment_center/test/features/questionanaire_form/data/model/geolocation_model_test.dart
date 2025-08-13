import 'package:flutter_test/flutter_test.dart';
import 'package:treatment_center/features/questionnaire_form/data/models/geolocation_model.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/geolocation_entity.dart';

void main() {
  final tGeoLocationModel = GeoLocationModel(
    country: 'United States',
    regionProvince: 'California',
    district: 'San Francisco',
    cityVillage: 'San Francisco',
    addressOrCoordinates: '123 Main St',
    locationType: FacilityLocationType.urban,
    latitude: -12.2,
    longitude: 83.2,
  );

  final tGeoLocationJson = {
    'country': 'United States',
    'region_province': 'California',
    'district': 'San Francisco',
    'city_village': 'San Francisco',
    'address_or_coordinates': '123 Main St',
    'latitude': -12.2,
    'longitude': 83.2,
    'location_type': 0, // urban = 0
  };

  final tGeoLocationModelPeriUrban = GeoLocationModel(
    country: 'United States',
    regionProvince: 'California',
    district: 'San Francisco',
    cityVillage: 'Daly City',
    addressOrCoordinates: '456 Side St',
    locationType: FacilityLocationType.periUrban,
    latitude: 10.2,
    longitude: -12.2,
  );

  final tGeoLocationJsonPeriUrban = {
    'country': 'United States',
    'region_province': 'California',
    'district': 'San Francisco',
    'city_village': 'Daly City',
    'address_or_coordinates': '456 Side St',
    'latitude': 10.2,
    'longitude': -12.2,
    'location_type': 1, // periUrban = 1
  };

  final tGeoLocationModelRural = GeoLocationModel(
    country: 'United States',
    regionProvince: 'California',
    district: 'Mendocino',
    cityVillage: 'Point Arena',
    addressOrCoordinates: '789 Country Rd',
    locationType: FacilityLocationType.rural,
    latitude: 42.3,
    longitude: 32.2,
  );

  final tGeoLocationJsonRural = {
    'country': 'United States',
    'region_province': 'California',
    'district': 'Mendocino',
    'city_village': 'Point Arena',
    'address_or_coordinates': '789 Country Rd',
    'latitude': 42.3,
    'longitude': 32.2,
    'location_type': 2, // rural = 2
  };

  group('GeoLocationModel', () {
    test('should be a subclass of GeoLocation entity', () {
      // Arrange
      // Act
      // Assert
      expect(tGeoLocationModel, isA<GeoLocationEntity>());
    });

    group('fromJson', () {
      test('should return a valid model for urban when the JSON is valid', () {
        // Arrange
        final Map<String, dynamic> jsonMap = tGeoLocationJson;
        // Act
        final result = GeoLocationModel.fromJson(jsonMap);
        // Assert
        expect(result, tGeoLocationModel);
      });

      test(
        'should return a valid model for peri-urban when the JSON is valid',
        () {
          // Arrange
          final Map<String, dynamic> jsonMap = tGeoLocationJsonPeriUrban;
          // Act
          final result = GeoLocationModel.fromJson(jsonMap);
          // Assert
          expect(result, tGeoLocationModelPeriUrban);
        },
      );

      test('should return a valid model for rural when the JSON is valid', () {
        // Arrange
        final Map<String, dynamic> jsonMap = tGeoLocationJsonRural;
        // Act
        final result = GeoLocationModel.fromJson(jsonMap);
        // Assert
        expect(result, tGeoLocationModelRural);
      });

      test('should correctly parse the location type enum', () {
        // Arrange
        final Map<String, dynamic> jsonMap = {
          'country': 'United States',
          'region_province': 'California',
          'district': 'San Francisco',
          'city_village': 'San Francisco',
          'address_or_coordinates': '123 Main St',
          'location_type': 0, // urban
        };
        // Act
        final result = GeoLocationModel.fromJson(jsonMap);
        // Assert
        expect(result.locationType, FacilityLocationType.urban);
      });
    });

    group('toJson', () {
      test('should return a JSON map containing the proper data', () {
        // Arrange
        // Act
        final result = tGeoLocationModel.toJson();
        // Assert
        expect(result, tGeoLocationJson);
      });

      test('should correctly convert the location type enum to integer', () {
        // Arrange
        // Act
        final urbanResult = tGeoLocationModel.toJson();
        final periUrbanResult = tGeoLocationModelPeriUrban.toJson();
        final ruralResult = tGeoLocationModelRural.toJson();

        // Assert
        expect(urbanResult['location_type'], 0);
        expect(periUrbanResult['location_type'], 1);
        expect(ruralResult['location_type'], 2);
      });
    });

    group('fromEntity', () {
      test('should return a valid model when converting from entity', () {
        // Arrange
        final entity = GeoLocationEntity(
          country: 'United States',
          regionProvince: 'California',
          district: 'San Francisco',
          cityVillage: 'San Francisco',
          addressOrCoordinates: '123 Main St',
          latitude: -12.2,
          longitude: 83.2,
          locationType: FacilityLocationType.urban,
        );
        // Act
        final result = GeoLocationModel.fromEntity(entity);
        // Assert
        expect(result, tGeoLocationModel);
        expect(result.country, entity.country);
        expect(result.regionProvince, entity.regionProvince);
        expect(result.district, entity.district);
        expect(result.cityVillage, entity.cityVillage);
        expect(result.addressOrCoordinates, entity.addressOrCoordinates);
        expect(result.locationType, entity.locationType);
      });
    });
  });

  group('toEntity', () {
    test(
      'should return a valid entity when converting from urban location model',
      () {
        // Arrange
        // Act
        final result = tGeoLocationModel.toEntity();
        // Assert
        expect(result, isA<GeoLocationEntity>());
        expect(result.country, tGeoLocationModel.country);
        expect(result.regionProvince, tGeoLocationModel.regionProvince);
        expect(result.district, tGeoLocationModel.district);
        expect(result.cityVillage, tGeoLocationModel.cityVillage);
        expect(
          result.addressOrCoordinates,
          tGeoLocationModel.addressOrCoordinates,
        );
        expect(result.latitude, tGeoLocationModel.latitude);
        expect(result.longitude, tGeoLocationModel.longitude);
        expect(result.locationType, tGeoLocationModel.locationType);
      },
    );

    test(
      'should return a valid entity when converting from peri-urban location model',
      () {
        // Arrange
        // Act
        final result = tGeoLocationModelPeriUrban.toEntity();
        // Assert
        expect(result, isA<GeoLocationEntity>());
        expect(result.country, tGeoLocationModelPeriUrban.country);
        expect(
          result.regionProvince,
          tGeoLocationModelPeriUrban.regionProvince,
        );
        expect(result.district, tGeoLocationModelPeriUrban.district);
        expect(result.cityVillage, tGeoLocationModelPeriUrban.cityVillage);
        expect(
          result.addressOrCoordinates,
          tGeoLocationModelPeriUrban.addressOrCoordinates,
        );
        expect(result.latitude, tGeoLocationModelPeriUrban.latitude);
        expect(result.longitude, tGeoLocationModelPeriUrban.longitude);
        expect(result.locationType, tGeoLocationModelPeriUrban.locationType);
      },
    );

    test(
      'should return a valid entity when converting from rural location model',
      () {
        // Arrange
        // Act
        final result = tGeoLocationModelRural.toEntity();
        // Assert
        expect(result, isA<GeoLocationEntity>());
        expect(result.country, tGeoLocationModelRural.country);
        expect(result.regionProvince, tGeoLocationModelRural.regionProvince);
        expect(result.district, tGeoLocationModelRural.district);
        expect(result.cityVillage, tGeoLocationModelRural.cityVillage);
        expect(
          result.addressOrCoordinates,
          tGeoLocationModelRural.addressOrCoordinates,
        );
        expect(result.latitude, tGeoLocationModelRural.latitude);
        expect(result.longitude, tGeoLocationModelRural.longitude);
        expect(result.locationType, tGeoLocationModelRural.locationType);
      },
    );

    test(
      'should correctly preserve all location type enums when converting to entity',
      () {
        // Arrange
        // Act
        final urbanResult = tGeoLocationModel.toEntity();
        final periUrbanResult = tGeoLocationModelPeriUrban.toEntity();
        final ruralResult = tGeoLocationModelRural.toEntity();
        // Assert
        expect(urbanResult.locationType, FacilityLocationType.urban);
        expect(periUrbanResult.locationType, FacilityLocationType.periUrban);
        expect(ruralResult.locationType, FacilityLocationType.rural);
      },
    );

    test(
      'should correctly preserve coordinate values when converting to entity',
      () {
        // Arrange
        // Act
        final urbanResult = tGeoLocationModel.toEntity();
        final periUrbanResult = tGeoLocationModelPeriUrban.toEntity();
        final ruralResult = tGeoLocationModelRural.toEntity();
        // Assert
        expect(urbanResult.latitude, -12.2);
        expect(urbanResult.longitude, 83.2);
        expect(periUrbanResult.latitude, 10.2);
        expect(periUrbanResult.longitude, -12.2);
        expect(ruralResult.latitude, 42.3);
        expect(ruralResult.longitude, 32.2);
      },
    );

    test('should maintain type consistency after conversion', () {
      // Arrange
      // Act
      final entity = tGeoLocationModel.toEntity();
      final backToModel = GeoLocationModel.fromEntity(entity);
      // Assert
      expect(backToModel.country, tGeoLocationModel.country);
      expect(backToModel.regionProvince, tGeoLocationModel.regionProvince);
      expect(backToModel.district, tGeoLocationModel.district);
      expect(backToModel.cityVillage, tGeoLocationModel.cityVillage);
      expect(
        backToModel.addressOrCoordinates,
        tGeoLocationModel.addressOrCoordinates,
      );
      expect(backToModel.latitude, tGeoLocationModel.latitude);
      expect(backToModel.longitude, tGeoLocationModel.longitude);
      expect(backToModel.locationType, tGeoLocationModel.locationType);
    });

    test('should create entity with same values but different type', () {
      // Arrange
      // Act
      final result = tGeoLocationModel.toEntity();
      // Assert
      expect(result, isNot(isA<GeoLocationModel>()));
      expect(result, isA<GeoLocationEntity>());
      expect(result.country, equals(tGeoLocationModel.country));
      expect(result.regionProvince, equals(tGeoLocationModel.regionProvince));
      expect(result.district, equals(tGeoLocationModel.district));
      expect(result.cityVillage, equals(tGeoLocationModel.cityVillage));
      expect(
        result.addressOrCoordinates,
        equals(tGeoLocationModel.addressOrCoordinates),
      );
      expect(result.latitude, equals(tGeoLocationModel.latitude));
      expect(result.longitude, equals(tGeoLocationModel.longitude));
      expect(result.locationType, equals(tGeoLocationModel.locationType));
    });

    test(
      'should handle edge case coordinate values correctly when converting to entity',
      () {
        // Arrange
        final edgeCaseModel = GeoLocationModel(
          country: 'Test Country',
          regionProvince: 'Test Region',
          district: 'Test District',
          cityVillage: 'Test City',
          addressOrCoordinates: 'Test Address',
          latitude: 0.0, // Edge case: exact equator
          longitude: 0.0, // Edge case: exact prime meridian
          locationType: FacilityLocationType.urban,
        );
        // Act
        final result = edgeCaseModel.toEntity();
        // Assert
        expect(result.latitude, 0.0);
        expect(result.longitude, 0.0);
        expect(result.country, 'Test Country');
        expect(result.locationType, FacilityLocationType.urban);
      },
    );

    test(
      'should handle extreme coordinate values correctly when converting to entity',
      () {
        // Arrange
        final extremeModel = GeoLocationModel(
          country: 'Test Country',
          regionProvince: 'Test Region',
          district: 'Test District',
          cityVillage: 'Test City',
          addressOrCoordinates: 'Test Address',
          latitude: -90.0, // Edge case: South Pole
          longitude: 180.0, // Edge case: International Date Line
          locationType: FacilityLocationType.rural,
        );
        // Act
        final result = extremeModel.toEntity();
        // Assert
        expect(result.latitude, -90.0);
        expect(result.longitude, 180.0);
        expect(result.locationType, FacilityLocationType.rural);
      },
    );

    test(
      'should handle null coordinate values correctly when converting to entity',
      () {
        // Arrange
        final nullCoordinateModel = GeoLocationModel(
          country: 'Test Country',
          regionProvince: 'Test Region',
          district: 'Test District',
          cityVillage: 'Test City',
          addressOrCoordinates: 'Test Address',
          latitude: null,
          longitude: null,
          locationType: FacilityLocationType.periUrban,
        );
        // Act
        final result = nullCoordinateModel.toEntity();
        // Assert
        expect(result.latitude, null);
        expect(result.longitude, null);
        expect(result.country, 'Test Country');
        expect(result.locationType, FacilityLocationType.periUrban);
      },
    );

    test(
      'should preserve all string fields accurately when converting to entity',
      () {
        // Arrange
        final customModel = GeoLocationModel(
          country: 'Custom Country Name',
          regionProvince: 'Custom Region/Province',
          district: 'Custom District',
          cityVillage: 'Custom City/Village',
          addressOrCoordinates: 'Custom Address or Coordinates',
          latitude: 25.5,
          longitude: -75.3,
          locationType: FacilityLocationType.urban,
        );
        // Act
        final result = customModel.toEntity();
        // Assert
        expect(result.country, 'Custom Country Name');
        expect(result.regionProvince, 'Custom Region/Province');
        expect(result.district, 'Custom District');
        expect(result.cityVillage, 'Custom City/Village');
        expect(result.addressOrCoordinates, 'Custom Address or Coordinates');
      },
    );

    test(
      'should correctly handle precision in coordinate values when converting to entity',
      () {
        // Arrange
        final precisionModel = GeoLocationModel(
          country: 'Precision Test',
          regionProvince: 'Precision Region',
          district: 'Precision District',
          cityVillage: 'Precision City',
          addressOrCoordinates: 'Precision Address',
          latitude: 37.774929, // High precision coordinates
          longitude: -122.419416,
          locationType: FacilityLocationType.urban,
        );
        // Act
        final result = precisionModel.toEntity();
        // Assert
        expect(result.latitude, 37.774929);
        expect(result.longitude, -122.419416);
      },
    );
  });
}

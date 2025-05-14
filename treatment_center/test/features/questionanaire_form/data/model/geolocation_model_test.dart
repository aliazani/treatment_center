import 'package:flutter_test/flutter_test.dart';
import 'package:treatment_center/features/questionnaire_form/data/models/geolocation_model.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/geolocation.dart';

void main() {
  final tGeoLocationModel = GeoLocationModel(
    country: 'United States',
    regionProvince: 'California',
    district: 'San Francisco',
    cityVillage: 'San Francisco',
    addressOrCoordinates: '123 Main St',
    locationType: FacilityLocationType.urban,
  );

  final tGeoLocationJson = {
    'country': 'United States',
    'region_province': 'California',
    'district': 'San Francisco',
    'city_village': 'San Francisco',
    'address_or_coordinates': '123 Main St',
    'location_type': 0, // urban = 0
  };

  final tGeoLocationModelPeriUrban = GeoLocationModel(
    country: 'United States',
    regionProvince: 'California',
    district: 'San Francisco',
    cityVillage: 'Daly City',
    addressOrCoordinates: '456 Side St',
    locationType: FacilityLocationType.periUrban,
  );

  final tGeoLocationJsonPeriUrban = {
    'country': 'United States',
    'region_province': 'California',
    'district': 'San Francisco',
    'city_village': 'Daly City',
    'address_or_coordinates': '456 Side St',
    'location_type': 1, // periUrban = 1
  };

  final tGeoLocationModelRural = GeoLocationModel(
    country: 'United States',
    regionProvince: 'California',
    district: 'Mendocino',
    cityVillage: 'Point Arena',
    addressOrCoordinates: '789 Country Rd',
    locationType: FacilityLocationType.rural,
  );

  final tGeoLocationJsonRural = {
    'country': 'United States',
    'region_province': 'California',
    'district': 'Mendocino',
    'city_village': 'Point Arena',
    'address_or_coordinates': '789 Country Rd',
    'location_type': 2, // rural = 2
  };

  group('GeoLocationModel', () {
    test('should be a subclass of GeoLocation entity', () {
      // assert
      expect(tGeoLocationModel, isA<GeoLocation>());
    });

    group('fromJson', () {
      test('should return a valid model for urban when the JSON is valid', () {
        // arrange
        final Map<String, dynamic> jsonMap = tGeoLocationJson;
        // act
        final result = GeoLocationModel.fromJson(jsonMap);
        // assert
        expect(result, tGeoLocationModel);
      });

      test('should return a valid model for peri-urban when the JSON is valid', () {
        // arrange
        final Map<String, dynamic> jsonMap = tGeoLocationJsonPeriUrban;
        // act
        final result = GeoLocationModel.fromJson(jsonMap);
        // assert
        expect(result, tGeoLocationModelPeriUrban);
      });

      test('should return a valid model for rural when the JSON is valid', () {
        // arrange
        final Map<String, dynamic> jsonMap = tGeoLocationJsonRural;
        // act
        final result = GeoLocationModel.fromJson(jsonMap);
        // assert
        expect(result, tGeoLocationModelRural);
      });

      test('should correctly parse the location type enum', () {
        // arrange
        final Map<String, dynamic> jsonMap = {
          'country': 'United States',
          'region_province': 'California',
          'district': 'San Francisco',
          'city_village': 'San Francisco',
          'address_or_coordinates': '123 Main St',
          'location_type': 0, // urban
        };
        // act
        final result = GeoLocationModel.fromJson(jsonMap);
        // assert
        expect(result.locationType, FacilityLocationType.urban);
      });
    });

    group('toJson', () {
      test('should return a JSON map containing the proper data', () {
        // act
        final result = tGeoLocationModel.toJson();
        // assert
        expect(result, tGeoLocationJson);
      });

      test('should correctly convert the location type enum to integer', () {
        // act
        final urbanResult = tGeoLocationModel.toJson();
        final periUrbanResult = tGeoLocationModelPeriUrban.toJson();
        final ruralResult = tGeoLocationModelRural.toJson();
        
        // assert
        expect(urbanResult['location_type'], 0);
        expect(periUrbanResult['location_type'], 1);
        expect(ruralResult['location_type'], 2);
      });
    });

    group('fromEntity', () {
      test('should return a valid model when converting from entity', () {
        // arrange
        final entity = GeoLocation(
          country: 'United States',
          regionProvince: 'California',
          district: 'San Francisco',
          cityVillage: 'San Francisco',
          addressOrCoordinates: '123 Main St',
          locationType: FacilityLocationType.urban,
        );
        // act
        final result = GeoLocationModel.fromEntity(entity);
        // assert
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
}
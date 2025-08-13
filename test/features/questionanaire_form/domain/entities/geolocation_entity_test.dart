import 'package:flutter_test/flutter_test.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/geolocation_entity.dart';

void main() {
  group('GeoLocation', () {
    test('should create a valid GeoLocation instance', () {
      // Arrange & Act
      final geoLocation = GeoLocationEntity(
        country: 'Uganda',
        regionProvince: 'Western Region',
        district: 'Kasese',
        cityVillage: 'Bwera',
        addressOrCoordinates: '0.14825, 29.71769',
        locationType: FacilityLocationType.rural,
      );

      // Assert
      expect(geoLocation.country, 'Uganda');
      expect(geoLocation.regionProvince, 'Western Region');
      expect(geoLocation.district, 'Kasese');
      expect(geoLocation.cityVillage, 'Bwera');
      expect(geoLocation.addressOrCoordinates, '0.14825, 29.71769');
      expect(geoLocation.locationType, FacilityLocationType.rural);
    });

    test('two instances with the same values should be equal', () {
      // Arrange
      final geoLocation1 = GeoLocationEntity(
        country: 'Uganda',
        regionProvince: 'Western Region',
        district: 'Kasese',
        cityVillage: 'Bwera',
        addressOrCoordinates: '0.14825, 29.71769',
        locationType: FacilityLocationType.rural,
      );

      final geoLocation2 = GeoLocationEntity(
        country: 'Uganda',
        regionProvince: 'Western Region',
        district: 'Kasese',
        cityVillage: 'Bwera',
        addressOrCoordinates: '0.14825, 29.71769',
        locationType: FacilityLocationType.rural,
      );

      // Act & Assert
      expect(geoLocation1, equals(geoLocation2));
    });

    test('should create instances with different location types', () {
      // Arrange & Act
      final urbanLocation = GeoLocationEntity(
        country: 'Uganda',
        regionProvince: 'Central Region',
        district: 'Kampala',
        cityVillage: 'Kampala',
        addressOrCoordinates: 'Plot 123, Main Street',
        locationType: FacilityLocationType.urban,
      );

      final periUrbanLocation = GeoLocationEntity(
        country: 'Uganda',
        regionProvince: 'Central Region',
        district: 'Wakiso',
        cityVillage: 'Entebbe',
        addressOrCoordinates: 'Airport Road',
        locationType: FacilityLocationType.periUrban,
      );

      // Assert
      expect(urbanLocation.locationType, FacilityLocationType.urban);
      expect(periUrbanLocation.locationType, FacilityLocationType.periUrban);
    });
  });
}

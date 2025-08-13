import 'package:fpdart/fpdart.dart';
import 'package:treatment_center/core/error/failures.dart';
import 'package:treatment_center/features/geolocation/domain/entities/city_entity.dart';
import 'package:treatment_center/features/geolocation/domain/entities/country_entity.dart';
import 'package:treatment_center/features/geolocation/domain/entities/region_entity.dart';
import 'package:treatment_center/features/geolocation/domain/entities/country_phone_code.dart';

abstract class GeographicRepository {
  Future<Either<Failure, List<CountryEntity>>> getCountries();
  Future<Either<Failure, List<RegionEntity>>> getStates();
  Future<Either<Failure, List<CityEntity>>> getCities();
  Future<Either<Failure, List<RegionEntity>>> getStatesByCountry(
    String countryCode,
  );
  Future<Either<Failure, List<CityEntity>>> getCitiesByState(String stateCode);
  Future<Either<Failure, List<CountryPhoneCodeEntity>>> getCountryCodes();
  Future<Either<Failure, CountryPhoneCodeEntity?>> getPhoneCodeByCountry(
    String countryName,
  );
}

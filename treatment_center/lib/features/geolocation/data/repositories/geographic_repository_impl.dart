import 'package:fpdart/fpdart.dart';
import 'package:treatment_center/core/error/exceptions.dart';
import 'package:treatment_center/core/error/failures.dart';
import 'package:treatment_center/features/geolocation/data/datasources/geographic_local_data_source.dart';
import 'package:treatment_center/features/geolocation/domain/entities/city_entity.dart';
import 'package:treatment_center/features/geolocation/domain/entities/country_entity.dart';
import 'package:treatment_center/features/geolocation/domain/entities/region_entity.dart';
import 'package:treatment_center/features/geolocation/domain/repositories/geographic_repository.dart';
import 'package:treatment_center/features/geolocation/domain/entities/country_phone_code.dart';

class GeographicRepositoryImpl implements GeographicRepository {
  final GeographicLocalDataSource localDataSource;

  GeographicRepositoryImpl({required this.localDataSource});

  @override
  Future<Either<Failure, List<CountryEntity>>> getCountries() async {
    try {
      final countries = await localDataSource.getCountries();
      return Right(countries);
    } on CacheException {
      return Left(
        CacheFailure(message: 'Failed to load countries from assets'),
      );
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<RegionEntity>>> getStates() async {
    try {
      final states = await localDataSource.getStates();

      return Right(states);
    } on CacheException {
      return Left(CacheFailure(message: 'Failed to load states from assets'));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CityEntity>>> getCities() async {
    try {
      final cities = await localDataSource.getCities();
      return Right(cities);
    } on CacheException {
      return Left(CacheFailure(message: 'Failed to load cities from assets'));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<RegionEntity>>> getStatesByCountry(
    String countryCode,
  ) async {
    try {
      final states = await localDataSource.getStates();

      final filteredStates =
          states.where((state) => state.countryCode == countryCode).toList();
      return Right(filteredStates);
    } on CacheException {
      return Left(CacheFailure(message: 'Failed to load states from assets'));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CityEntity>>> getCitiesByState(
    String stateCode,
  ) async {
    try {
      final cities = await localDataSource.getCities();

      final normalized =
          stateCode.contains('-')
              ? stateCode
                  .split('-')
                  .last
                  .toLowerCase() // e.g. "AF-BDS" → "BDS"
              : stateCode.toLowerCase();
      final filteredCities =
          cities.where((city) {
            return city.stateCode.toLowerCase() == normalized;
          }).toList();

      return Right(filteredCities);
    } on CacheException {
      return Left(CacheFailure(message: 'Failed to load cities from assets'));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CountryPhoneCodeEntity>>>
  getCountryCodes() async {
    try {
      final countries = await localDataSource.getCountries();
      final countryCodes =
          countries
              .map(
                (country) => CountryPhoneCodeEntity(
                  country: country.name,
                  code: '+${country.phonecode}',
                  flag: country.emoji,
                  iso2: country.iso2,
                ),
              )
              .toList()
            ..sort((a, b) => a.country.compareTo(b.country));
      return Right(countryCodes);
    } on CacheException {
      return Left(
        CacheFailure(message: 'Failed to load countries from assets'),
      );
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CountryPhoneCodeEntity?>> getPhoneCodeByCountry(
    String countryName,
  ) async {
    try {
      final countries = await localDataSource.getCountries();
      try {
        final country = countries.firstWhere(
          (c) => c.name.toLowerCase() == countryName.toLowerCase(),
        );
        final phoneCode = CountryPhoneCodeEntity(
          country: country.name,
          code: '+${country.phonecode}',
          flag: country.emoji,
          iso2: country.iso2,
        );
        return Right(phoneCode);
      } catch (_) {
        return const Right(null);
      }
    } on CacheException {
      return Left(
        CacheFailure(message: 'Failed to load countries from assets'),
      );
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }
}

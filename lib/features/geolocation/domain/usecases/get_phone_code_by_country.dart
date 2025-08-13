import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import 'package:treatment_center/core/error/failures.dart';
import 'package:treatment_center/features/geolocation/domain/repositories/geographic_repository.dart';
import 'package:treatment_center/features/geolocation/domain/entities/country_phone_code.dart';
import 'package:treatment_center/features/questionnaire_form/domain/usecases/usecase.dart';

class GetPhoneCodeByCountry
    extends UseCase<CountryPhoneCodeEntity?, PhoneCodeByCountryParams> {
  final GeographicRepository repository;

  GetPhoneCodeByCountry(this.repository);

  @override
  Future<Either<Failure, CountryPhoneCodeEntity?>> call(
    PhoneCodeByCountryParams params,
  ) async {
    return await repository.getPhoneCodeByCountry(params.countryName);
  }
}

class PhoneCodeByCountryParams extends Equatable {
  final String countryName;

  const PhoneCodeByCountryParams({required this.countryName});

  @override
  List<Object?> get props => [countryName];
}

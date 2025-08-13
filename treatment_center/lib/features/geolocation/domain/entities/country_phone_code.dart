import 'package:equatable/equatable.dart';

class CountryPhoneCodeEntity extends Equatable {
  final String country;
  final String code;
  final String flag;
  final String iso2;

  const CountryPhoneCodeEntity({
    required this.country,
    required this.code,
    required this.flag,
    required this.iso2,
  });

  @override
  List<Object?> get props => [country, code, flag, iso2];
}

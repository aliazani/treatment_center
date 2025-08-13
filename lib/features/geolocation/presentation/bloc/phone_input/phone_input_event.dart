import 'package:equatable/equatable.dart';
import 'package:treatment_center/features/geolocation/domain/entities/country_phone_code.dart';

abstract class PhoneInputEvent extends Equatable {
  const PhoneInputEvent();

  @override
  List<Object?> get props => [];
}

class LoadCountryCodesEvent extends PhoneInputEvent {
  final bool forceRefresh;
  final CountryPhoneCodeEntity? initialCountryCode;
  final String? initialPhoneNumber;

  const LoadCountryCodesEvent({
    this.forceRefresh = false,
    this.initialCountryCode,
    this.initialPhoneNumber,
  });

  @override
  List<Object?> get props => [
    forceRefresh,
    initialCountryCode,
    initialPhoneNumber,
  ];
}

class SelectCountryCodeEvent extends PhoneInputEvent {
  final CountryPhoneCodeEntity countryCode;

  const SelectCountryCodeEvent({required this.countryCode});

  @override
  List<Object> get props => [countryCode];
}

class UpdatePhoneNumberEvent extends PhoneInputEvent {
  final String phoneNumber;

  const UpdatePhoneNumberEvent({required this.phoneNumber});

  @override
  List<Object> get props => [phoneNumber];
}

class ResetPhoneInputEvent extends PhoneInputEvent {
  const ResetPhoneInputEvent();
}

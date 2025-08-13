import 'package:equatable/equatable.dart';
import 'package:treatment_center/features/geolocation/domain/entities/country_phone_code.dart';

abstract class PhoneInputState extends Equatable {
  const PhoneInputState();

  @override
  List<Object?> get props => [];
}

class PhoneInputInitial extends PhoneInputState {
  const PhoneInputInitial();
}

class PhoneInputLoading extends PhoneInputState {
  const PhoneInputLoading();
}

class PhoneInputLoaded extends PhoneInputState {
  final List<CountryPhoneCodeEntity> countryCodes;
  final CountryPhoneCodeEntity? selectedCountryCode;
  final String phoneNumber;
  final bool isValid;
  final bool isInitialized;
  static const _sentinel = Object();

  const PhoneInputLoaded({
    required this.countryCodes,
    this.selectedCountryCode,
    required this.phoneNumber,
    required this.isValid,
    this.isInitialized = false,
  });

  PhoneInputLoaded copyWith({
    List<CountryPhoneCodeEntity>? countryCodes,
    Object? selectedCountryCode = _sentinel,
    String? phoneNumber,
    bool? isValid,
    bool? isInitialized,
  }) {
    return PhoneInputLoaded(
      countryCodes: countryCodes ?? this.countryCodes,
      selectedCountryCode:
          identical(selectedCountryCode, _sentinel)
              ? this.selectedCountryCode
              : selectedCountryCode as CountryPhoneCodeEntity?, // allows null
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isValid: isValid ?? this.isValid,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }

  @override
  List<Object?> get props => [
    countryCodes,
    selectedCountryCode,
    phoneNumber,
    isValid,
    isInitialized,
  ];
}

class PhoneInputError extends PhoneInputState {
  final String message;

  const PhoneInputError({required this.message});

  @override
  List<Object?> get props => [message];
}

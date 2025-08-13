import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:treatment_center/core/error/failures.dart';
import 'package:treatment_center/features/geolocation/domain/entities/country_phone_code.dart';
import 'package:treatment_center/features/geolocation/domain/usecases/get_country_codes.dart';
import 'package:treatment_center/features/questionnaire_form/domain/usecases/usecase.dart';
import 'phone_input_event.dart';
import 'phone_input_state.dart';

class PhoneInputBloc extends Bloc<PhoneInputEvent, PhoneInputState> {
  final GetCountryCodesUsecase getCountryCodesUsecase;

  // Cache for country codes to avoid repeated loading
  List<CountryPhoneCodeEntity>? _cachedCountryCodes;
  bool _isDisposed = false;

  PhoneInputBloc({required this.getCountryCodesUsecase})
    : super(PhoneInputInitial()) {
    on<LoadCountryCodesEvent>(_onLoadCountryCodes);
    on<SelectCountryCodeEvent>(_onSelectCountryCode);
    on<UpdatePhoneNumberEvent>(_onUpdatePhoneNumber);
    on<ResetPhoneInputEvent>(_onResetPhoneInput);
  }

  @override
  Future<void> close() {
    _isDisposed = true;
    _cachedCountryCodes = null;
    return super.close();
  }

  Future<void> _onLoadCountryCodes(
    LoadCountryCodesEvent event,
    Emitter<PhoneInputState> emit,
  ) async {
    if (_isDisposed) return;

    ({CountryPhoneCodeEntity? code, String number}) computeInitials(
      List<CountryPhoneCodeEntity> codes,
    ) {
      CountryPhoneCodeEntity? selected = event.initialCountryCode;
      String number = event.initialPhoneNumber ?? '';

      if (selected == null &&
          number.isNotEmpty &&
          number.trim().startsWith('+')) {
        final parsed = parseFullPhoneNumber(number, codes);
        selected = parsed.country ?? selected;
        number = parsed.number;
      }
      return (code: selected, number: number);
    }

    // Use cached
    if (_cachedCountryCodes != null && !event.forceRefresh) {
      final init = computeInitials(_cachedCountryCodes!);

      if (!_isDisposed) {
        emit(
          PhoneInputLoaded(
            countryCodes: _cachedCountryCodes!,
            selectedCountryCode: init.code,
            phoneNumber: init.number,
            isValid: _isPhoneInputValid(init.code, init.number),
            isInitialized: true,
          ),
        );
      }
      return;
    }

    if (!_isDisposed) emit(PhoneInputLoading());

    try {
      final result = await getCountryCodesUsecase(NoParams());
      if (_isDisposed) return;

      result.fold(
        (failure) {
          if (!_isDisposed) {
            emit(PhoneInputError(message: _mapFailureToMessage(failure)));
          }
        },
        (countryCodes) {
          _cachedCountryCodes = countryCodes;

          final init = computeInitials(countryCodes);

          if (!_isDisposed) {
            emit(
              PhoneInputLoaded(
                countryCodes: countryCodes,
                selectedCountryCode: init.code,
                phoneNumber: init.number,
                isValid: _isPhoneInputValid(init.code, init.number),
                isInitialized: true,
              ),
            );
          }
        },
      );
    } catch (e) {
      if (!_isDisposed) {
        emit(
          PhoneInputError(
            message: 'Unexpected error loading country codes: ${e.toString()}',
          ),
        );
      }
    }
  }

  void _onSelectCountryCode(
    SelectCountryCodeEvent event,
    Emitter<PhoneInputState> emit,
  ) {
    if (_isDisposed) return;

    if (state is PhoneInputLoaded) {
      final currentState = state as PhoneInputLoaded;
      if (!_isDisposed) {
        emit(
          currentState.copyWith(
            selectedCountryCode: event.countryCode,
            isValid: _isPhoneInputValid(
              event.countryCode,
              currentState.phoneNumber,
            ),
            isInitialized: currentState.isInitialized,
          ),
        );
      }
    }
  }

  void _onUpdatePhoneNumber(
    UpdatePhoneNumberEvent event,
    Emitter<PhoneInputState> emit,
  ) {
    if (_isDisposed) return;

    if (state is PhoneInputLoaded) {
      final currentState = state as PhoneInputLoaded;

      CountryPhoneCodeEntity? selected = currentState.selectedCountryCode;
      String number = event.phoneNumber;

      if (number.trim().startsWith('+') && _cachedCountryCodes != null) {
        final parsed = parseFullPhoneNumber(number, _cachedCountryCodes!);
        if (parsed.country != null) {
          selected = parsed.country;
          number = parsed.number;
        }
      }

      if (!_isDisposed) {
        emit(
          currentState.copyWith(
            selectedCountryCode: selected,
            phoneNumber: number,
            isValid: _isPhoneInputValid(selected, number),
            isInitialized: currentState.isInitialized,
          ),
        );
      }
    }
  }

  void _onResetPhoneInput(
    ResetPhoneInputEvent event,
    Emitter<PhoneInputState> emit,
  ) {
    if (_isDisposed) return;

    if (state is PhoneInputLoaded) {
      final currentState = state as PhoneInputLoaded;
      if (!_isDisposed) {
        emit(
          currentState.copyWith(
            selectedCountryCode: null,
            phoneNumber: '',
            isValid: false,
            isInitialized: currentState.isInitialized,
          ),
        );
      }
    }
  }

  bool _isPhoneInputValid(
    CountryPhoneCodeEntity? countryCode,
    String phoneNumber,
  ) {
    if (countryCode == null) {
      return false;
    }

    if (phoneNumber.isEmpty) {
      return false;
    }

    final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    if (cleanPhone.length < 7) {
      return false;
    }
    if (cleanPhone.length > 15) {
      return false;
    }
    if (!RegExp(r'^\d+$').hasMatch(cleanPhone)) {
      return false;
    }

    return true;
  }

  /// Longest-prefix parser. Returns the matched country code (if any) and remaining national number.
  ({CountryPhoneCodeEntity? country, String number}) parseFullPhoneNumber(
    String raw,
    List<CountryPhoneCodeEntity> codes,
  ) {
    String s = raw.trim();

    // Keep only '+' and digits; then ensure only leading '+' remains
    s = s.replaceAll(RegExp(r'[^+\d]'), '');
    if (s.startsWith('+')) {
      s = '+${s.substring(1).replaceAll(RegExp(r'\D'), '')}';
    } else {
      s = s.replaceAll(RegExp(r'\D'), '');
    }

    if (!s.startsWith('+')) {
      // National format: no country inferred
      return (country: null, number: s);
    }

    // Prepare candidate code strings, longest first
    final candidateCodes =
        codes
            .map((c) => c.code.startsWith('+') ? c.code : '+${c.code}')
            .toSet()
            .toList()
          ..sort((a, b) => b.length.compareTo(a.length));

    String? matchedCode;
    for (final code in candidateCodes) {
      if (s.startsWith(code)) {
        matchedCode = code;
        break;
      }
    }

    if (matchedCode == null) {
      return (country: null, number: s.substring(1)); // drop '+'
    }

    CountryPhoneCodeEntity? matchedCountry;
    for (final c in codes) {
      final cc = c.code.startsWith('+') ? c.code : '+${c.code}';
      if (cc == matchedCode) {
        matchedCountry = c;
        break;
      }
    }

    String national = s.substring(matchedCode.length);
    national = national.replaceAll(RegExp(r'[^\d]'), '');

    return (country: matchedCountry, number: national);
  }

  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case const (CacheFailure):
        return 'Failed to load country codes from local storage. Please check your device storage.';
      case const (ServerFailure):
        return 'Failed to load country codes from server. Please check your internet connection.';
      case const (NetworkFailure):
        return 'Network error occurred. Please check your internet connection.';
      case const (UnexpectedFailure):
        return 'An unexpected error occurred while loading country codes.';
      default:
        return 'Failed to load country codes. Please try again.';
    }
  }

  String? getFullPhoneNumber() {
    if (state is PhoneInputLoaded) {
      final s = state as PhoneInputLoaded;
      if (s.selectedCountryCode != null && s.phoneNumber.isNotEmpty) {
        return '${s.selectedCountryCode!.code}${s.phoneNumber}';
      }
    }
    return null;
  }

  bool get isInputComplete {
    if (state is PhoneInputLoaded) {
      final s = state as PhoneInputLoaded;
      return s.isValid &&
          s.selectedCountryCode != null &&
          s.phoneNumber.isNotEmpty;
    }
    return false;
  }

  CountryPhoneCodeEntity? get currentCountryCode {
    if (state is PhoneInputLoaded) {
      return (state as PhoneInputLoaded).selectedCountryCode;
    }
    return null;
  }

  String get currentPhoneNumber {
    if (state is PhoneInputLoaded) {
      return (state as PhoneInputLoaded).phoneNumber;
    }
    return '';
  }
}

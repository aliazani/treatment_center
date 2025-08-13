import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';
import 'package:treatment_center/features/geolocation/domain/entities/city_entity.dart';
import 'package:treatment_center/features/geolocation/domain/entities/country_entity.dart';
import 'package:treatment_center/features/geolocation/domain/entities/country_phone_code.dart';
import 'package:treatment_center/features/geolocation/domain/entities/region_entity.dart';
import 'package:treatment_center/features/geolocation/presentation/bloc/phone_input/phone_input_bloc.dart';
import 'package:treatment_center/features/geolocation/presentation/bloc/phone_input/phone_input_event.dart';
import 'package:treatment_center/features/geolocation/presentation/bloc/phone_input/phone_input_state.dart';
import 'package:treatment_center/features/geolocation/presentation/widgets/geographic_dropdowns_widget.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessment_form_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/assessor_info_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/geolocation_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/facility_identification_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/facility_services_entity.dart';
import 'package:treatment_center/features/questionnaire_form/domain/entities/photo_entity.dart';
import 'package:treatment_center/features/questionnaire_form/presentation/breakpoints.dart';
import 'package:treatment_center/features/questionnaire_form/presentation/widgets/map_location_picker.dart';
import 'package:treatment_center/features/questionnaire_form/presentation/widgets/photo_picker_widget.dart';
import 'package:treatment_center/injection_container.dart' as di;

// Enhanced Country Code Finder Helper
class CountryCodeFinder {
  static CountryPhoneCodeEntity? findByCode(
    List<CountryPhoneCodeEntity> countryCodes,
    String code,
  ) {
    try {
      final found = countryCodes.firstWhere((country) => country.code == code);

      return found;
    } catch (e) {
      return null;
    }
  }

  static CountryPhoneCodeEntity? findByIso2(
    List<CountryPhoneCodeEntity> countryCodes,
    String iso2,
  ) {
    try {
      final found = countryCodes.firstWhere(
        (country) => country.iso2.toLowerCase() == iso2.toLowerCase(),
      );

      return found;
    } catch (e) {
      return null;
    }
  }

  static ({CountryPhoneCodeEntity? country, String number}) parseWithCatalog(
    String fullPhone,
    List<CountryPhoneCodeEntity> countryCodes,
  ) {
    if (fullPhone.isEmpty) return (country: null, number: '');

    // keep '+' only at the start and digits
    String s = fullPhone.trim().replaceAll(RegExp(r'[^+\d]'), '');
    if (s.startsWith('+')) {
      s = '+${s.substring(1).replaceAll(RegExp(r'\D'), '')}';
    } else {
      s = s.replaceAll(RegExp(r'\D'), '');
    }

    if (!s.startsWith('+')) return (country: null, number: s);

    // candidates longest-first (e.g., +998 > +99 > +9)
    final candidates =
        countryCodes
            .map((c) => c.code.startsWith('+') ? c.code : '+${c.code}')
            .toSet()
            .toList()
          ..sort((a, b) => b.length.compareTo(a.length));

    String? matched;
    for (final c in candidates) {
      if (s.startsWith(c)) {
        matched = c;
        break;
      }
    }
    if (matched == null) return (country: null, number: s.substring(1));

    CountryPhoneCodeEntity? country;
    try {
      country = countryCodes.firstWhere(
        (c) => (c.code.startsWith('+') ? c.code : '+${c.code}') == matched,
      );
    } catch (e) {
      country = null;
    }
    final national = s.substring(matched.length).replaceAll(RegExp(r'\D'), '');
    return (country: country, number: national);
  }
}

class PhoneValidationHelper {
  static String? validatePhoneNumber(
    String? value,
    CountryPhoneCodeEntity? countryCode,
  ) {
    if (countryCode == null) {
      return 'Please select a country code';
    }

    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }

    if (value.length < 7) {
      return 'Phone number is too short';
    }

    if (value.length > 15) {
      return 'Phone number is too long';
    }

    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return 'Phone number can only contain digits';
    }

    return null;
  }
}

// Searchable Country Code Picker Dialog
class CountryCodePickerDialog extends StatefulWidget {
  final List<CountryPhoneCodeEntity> countryCodes;
  final CountryPhoneCodeEntity? selectedCountryCode;
  final ValueChanged<CountryPhoneCodeEntity> onCountryCodeSelected;

  const CountryCodePickerDialog({
    super.key,
    required this.countryCodes,
    this.selectedCountryCode,
    required this.onCountryCodeSelected,
  });

  @override
  State<CountryCodePickerDialog> createState() =>
      _CountryCodePickerDialogState();
}

class _CountryCodePickerDialogState extends State<CountryCodePickerDialog> {
  late TextEditingController _searchController;
  List<CountryPhoneCodeEntity> _filteredCountries = [];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filteredCountries = widget.countryCodes;
    _searchController.addListener(_filterCountries);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterCountries() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredCountries = widget.countryCodes;
      } else {
        _filteredCountries =
            widget.countryCodes.where((country) {
              return country.country.toLowerCase().contains(query) ||
                  country.code.toLowerCase().contains(query) ||
                  country.iso2.toLowerCase().contains(query);
            }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.85,
        height: MediaQuery.of(context).size.height * 0.75,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Select Country Code',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Search Field
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search countries...',
                hintText: 'Type country name, code, or ISO',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: theme.colorScheme.surface,
              ),
            ),
            const SizedBox(height: 16),

            // Countries List
            Expanded(
              child:
                  _filteredCountries.isEmpty
                      ? Center(
                        child: Text(
                          'No countries found',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      )
                      : ListView.builder(
                        itemCount: _filteredCountries.length,
                        itemBuilder: (context, index) {
                          final country = _filteredCountries[index];
                          final isSelected =
                              widget.selectedCountryCode?.iso2 == country.iso2;

                          return ListTile(
                            leading: Text(
                              country.flag,
                              style: const TextStyle(fontSize: 24),
                            ),
                            title: Text(
                              country.country,
                              style: TextStyle(
                                fontWeight:
                                    isSelected
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                              ),
                            ),
                            subtitle: Text('${country.code} (${country.iso2})'),
                            trailing:
                                isSelected
                                    ? Icon(
                                      Icons.check_circle,
                                      color: theme.colorScheme.primary,
                                    )
                                    : null,
                            selected: isSelected,
                            selectedTileColor: theme
                                .colorScheme
                                .primaryContainer
                                .withValues(alpha: 0.3),
                            onTap: () {
                              widget.onCountryCodeSelected(country);
                              Navigator.of(context).pop();
                            },
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
    );
  }
}

class Section1PhoneInputWidget extends StatefulWidget {
  final String label;
  final String? initialFullPhone; // Add this to receive initial phone
  final CountryPhoneCodeEntity?
  initialCountryCode; // Add this for initial country
  final ValueChanged<String>? onFullPhoneChanged;
  final String? Function(String?, CountryPhoneCodeEntity?)? validator;
  final bool isMobile;
  final bool enabled;

  const Section1PhoneInputWidget({
    super.key,
    this.label = 'Phone Number',
    this.initialFullPhone, // Accept initial phone
    this.initialCountryCode, // Accept initial country code
    this.onFullPhoneChanged,
    this.validator,
    this.isMobile = false,
    this.enabled = true,
  });

  @override
  State<Section1PhoneInputWidget> createState() =>
      _Section1PhoneInputWidgetState();
}

class _Section1PhoneInputWidgetState extends State<Section1PhoneInputWidget> {
  late TextEditingController _phoneController;
  bool _isInitialized = false;
  String? _lastEmittedPhone;

  /// Keep only national digits; if it starts with the selected code, strip it.
  String _nationalFrom(String raw, CountryPhoneCodeEntity? code) {
    if (raw.isEmpty) return '';
    final digits = raw.replaceAll(RegExp(r'[^0-9+]'), '');
    // if pasted with + sign, normalize to digits only for comparison
    final onlyDigits = digits.startsWith('+') ? digits.substring(1) : digits;
    if (code == null) return onlyDigits.replaceAll(RegExp(r'[^0-9]'), '');
    final codeDigits = code.code.replaceAll(RegExp(r'[^0-9]'), '');
    var national = onlyDigits;
    if (codeDigits.isNotEmpty && national.startsWith(codeDigits)) {
      national = national.substring(codeDigits.length);
    }
    return national.replaceAll(RegExp(r'[^0-9]'), '');
  }

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController();
    // Don't set text here - wait for bloc state
  }

  @override
  void didUpdateWidget(Section1PhoneInputWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If initial phone changed externally, reinitialize the bloc
    if (oldWidget.initialFullPhone != widget.initialFullPhone ||
        oldWidget.initialCountryCode != widget.initialCountryCode) {
      _isInitialized = false;

      // Reload the bloc with new initial values
      final bloc = context.read<PhoneInputBloc>();
      bloc.add(
        LoadCountryCodesEvent(
          forceRefresh: true,
          initialPhoneNumber: widget.initialFullPhone,
          initialCountryCode: widget.initialCountryCode,
        ),
      );
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _emitFull(PhoneInputLoaded state) {
    // String? fullPhone;

    // if (state.selectedCountryCode != null && state.phoneNumber.isNotEmpty) {
    //   fullPhone = '${state.selectedCountryCode!.code}${state.phoneNumber}';
    // } else if (widget.initialFullPhone != null && !_isInitialized) {
    //   // Use initial value if we haven't initialized yet
    //   fullPhone = widget.initialFullPhone;
    // }

    // // Only emit if the phone has actually changed
    // if (fullPhone != null && fullPhone != _lastEmittedPhone) {
    //   _lastEmittedPhone = fullPhone;
    //   widget.onFullPhoneChanged?.call(fullPhone);
    // }
    final code = state.selectedCountryCode;
    if (code == null) return;
    // Derive national strictly from current state (even if it was full E.164)
    final national = _nationalFrom(state.phoneNumber, code);
    final fullPhone = '${code.code}$national';

    if (fullPhone != _lastEmittedPhone) {
      _lastEmittedPhone = fullPhone;
      widget.onFullPhoneChanged?.call(fullPhone);
    }
  }

  void _showCountryPicker(
    List<CountryPhoneCodeEntity> countryCodes,
    CountryPhoneCodeEntity? selected,
  ) {
    final bloc = context.read<PhoneInputBloc>();
    showDialog(
      context: context,
      builder:
          (_) => CountryCodePickerDialog(
            countryCodes: countryCodes,
            selectedCountryCode: selected,
            onCountryCodeSelected: (country) {
              final national = _nationalFrom(_phoneController.text, country);
              if (_phoneController.text != national) {
                _phoneController.text = national;
                _phoneController.selection = TextSelection.collapsed(
                  offset: national.length,
                );
              }
              bloc.add(SelectCountryCodeEvent(countryCode: country));
              // Also tell bloc the national digits we want to keep
              bloc.add(UpdatePhoneNumberEvent(phoneNumber: national));
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocListener<PhoneInputBloc, PhoneInputState>(
      listenWhen: (prev, current) => current is PhoneInputLoaded,
      listener: (context, state) {
        if (state is PhoneInputLoaded) {
          // Mark as initialized when we get the first loaded state
          if (!_isInitialized && state.isInitialized) {
            _isInitialized = true;
          }

          // // Update controller text if it's different
          // if (_phoneController.text != state.phoneNumber) {
          //   _phoneController.text = state.phoneNumber;
          //   _phoneController.selection = TextSelection.collapsed(
          //     offset: _phoneController.text.length,
          //   );
          // }

          // _emitFull(state);
          // Set only the national part in the text field
          // Reflect only the national part in the UI, even if bloc gave us full
          final national = _nationalFrom(
            state.phoneNumber,
            state.selectedCountryCode,
          );
          if (_phoneController.text != national) {
            _phoneController.text = national;
            _phoneController.selection = TextSelection.collapsed(
              offset: national.length,
            );
          }

          _emitFull(state);
        }
      },
      child: BlocBuilder<PhoneInputBloc, PhoneInputState>(
        builder: (context, state) {
          if (state is PhoneInputLoading || state is PhoneInputInitial) {
            return _buildLoadingField(theme);
          }
          if (state is PhoneInputError) {
            return _buildErrorField(theme, state.message);
          }

          final loadedState = state as PhoneInputLoaded;
          return _buildPhoneInputField(theme, loadedState);
        },
      ),
    );
  }

  Widget _buildLoadingField(ThemeData theme) {
    return Container(
      height: widget.isMobile ? 56 : 60,
      decoration: BoxDecoration(
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.5),
        ),
        borderRadius: BorderRadius.circular(12),
        color: theme.colorScheme.surface,
      ),
      child: const Center(
        child: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
    );
  }

  Widget _buildErrorField(ThemeData theme, String error) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: widget.isMobile ? 12 : 16,
        vertical: widget.isMobile ? 12 : 16,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.error),
        borderRadius: BorderRadius.circular(12),
        color: theme.colorScheme.surface,
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: theme.colorScheme.error,
            size: widget.isMobile ? 18 : 20,
          ),
          SizedBox(width: widget.isMobile ? 8 : 12),
          Expanded(
            child: Text(
              'Error loading country codes',
              style: TextStyle(
                color: theme.colorScheme.error,
                fontSize: widget.isMobile ? 13 : 14,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              // Retry with current initial values

              context.read<PhoneInputBloc>().add(
                LoadCountryCodesEvent(
                  forceRefresh: true,
                  initialPhoneNumber: widget.initialFullPhone,
                  initialCountryCode: widget.initialCountryCode,
                ),
              );
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneInputField(ThemeData theme, PhoneInputLoaded state) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Country Code Selector
        SizedBox(
          width: widget.isMobile ? 120 : 140,
          child: InkWell(
            onTap:
                widget.enabled
                    ? () => _showCountryPicker(
                      state.countryCodes,
                      state.selectedCountryCode,
                    )
                    : null,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: widget.isMobile ? 8 : 12,
                vertical: widget.isMobile ? 12 : 16,
              ),
              decoration: BoxDecoration(
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.5),
                ),
                borderRadius: BorderRadius.circular(12),
                color: theme.colorScheme.surface,
              ),
              child: Row(
                children: [
                  if (state.selectedCountryCode != null) ...[
                    Text(
                      state.selectedCountryCode!.flag,
                      style: TextStyle(fontSize: widget.isMobile ? 14 : 16),
                    ),
                    SizedBox(width: widget.isMobile ? 4 : 6),
                    Expanded(
                      child: Text(
                        state.selectedCountryCode!.code,
                        style: TextStyle(
                          fontSize: widget.isMobile ? 12 : 13,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ] else ...[
                    Expanded(
                      child: Text(
                        'Code',
                        style: TextStyle(
                          fontSize: widget.isMobile ? 12 : 13,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                  Icon(
                    Icons.arrow_drop_down,
                    color: theme.colorScheme.onSurfaceVariant,
                    size: widget.isMobile ? 18 : 20,
                  ),
                ],
              ),
            ),
          ),
        ),

        SizedBox(width: widget.isMobile ? 8 : 12),

        // Phone Number Field
        Expanded(
          child: TextFormField(
            controller: _phoneController,
            enabled: widget.enabled,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
              LengthLimitingTextInputFormatter(15),
            ],
            style: TextStyle(fontSize: widget.isMobile ? 14 : null),
            decoration: InputDecoration(
              labelText: widget.label,
              labelStyle: TextStyle(fontSize: widget.isMobile ? 13 : null),
              hintText: 'Enter phone number',
              hintStyle: TextStyle(
                fontSize: widget.isMobile ? 13 : null,
                color: theme.colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.6,
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: theme.colorScheme.outline),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.colorScheme.outline.withValues(alpha: 0.5),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: theme.colorScheme.primary,
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: theme.colorScheme.error),
              ),
              filled: true,
              fillColor: theme.colorScheme.surface,
              contentPadding: EdgeInsets.symmetric(
                horizontal: widget.isMobile ? 12 : 16,
                vertical: widget.isMobile ? 12 : 16,
              ),
            ),
            onChanged: (value) {
              final bloc = context.read<PhoneInputBloc>();
              final code =
                  (bloc.state is PhoneInputLoaded)
                      ? (bloc.state as PhoneInputLoaded).selectedCountryCode
                      : null;
              // If user pastes "+44..." or "0044...", keep only national
              final national = _nationalFrom(value, code);

              if (_phoneController.text != national) {
                _phoneController.text = national;
                _phoneController.selection = TextSelection.collapsed(
                  offset: national.length,
                );
              }
              bloc.add(UpdatePhoneNumberEvent(phoneNumber: national));
            },
            validator:
                (v) => widget.validator?.call(v, state.selectedCountryCode),
          ),
        ),
      ],
    );
  }
}

class AssessmentSectionOneFormData {
  String assessmentDate;
  String assessorName;
  String assessorEmail;
  String assessorPhone;
  String assessorPhoneNumber;
  String country;
  String region;
  String district;
  String city;
  CountryPhoneCodeEntity? assessorPhoneCountryCode;
  CountryPhoneCodeEntity? directorPhoneCountryCode;
  CountryEntity? selectedCountry;
  RegionEntity? selectedRegion;
  CityEntity? selectedCity;
  String address;
  double? latitude;
  double? longitude;
  FacilityLocationType? facilityLocation;
  String facilityCode;
  String facilityName;
  ManagingAuthorityType? managingAuthority;
  String otherManagingAuthority;
  String directorName;
  String directorPhone;
  String directorPhoneNumber;
  String directorEmail;
  String respondentName;
  String respondentPosition;
  FacilityStructureType? structureType;
  FacilityType? facilityType;
  ExistingFacilityType? existingFacilityType;
  String otherExistingFacilityType;
  bool offersOutpatientServices;
  bool offersInpatientServices;
  String totalBeds;
  String icuBeds;
  bool has24HourEmergency;
  bool hasIntensiveCare;
  List<PhotoEntity> photos;

  AssessmentSectionOneFormData({
    this.assessmentDate = '',
    this.assessorName = '',
    this.assessorEmail = '',
    this.assessorPhone = '',
    this.assessorPhoneNumber = '',
    this.country = '',
    this.region = '',
    this.district = '',
    this.city = '',
    this.selectedCountry,
    this.selectedRegion,
    this.selectedCity,
    this.address = '',
    this.latitude,
    this.longitude,
    this.facilityLocation,
    this.facilityCode = '',
    this.facilityName = '',
    this.managingAuthority,
    this.otherManagingAuthority = '',
    this.directorName = '',
    this.directorPhone = '',
    this.directorPhoneNumber = '',
    this.directorEmail = '',
    this.respondentName = '',
    this.respondentPosition = '',
    this.structureType,
    this.facilityType,
    this.existingFacilityType,
    this.otherExistingFacilityType = '',
    this.offersOutpatientServices = false,
    this.offersInpatientServices = false,
    this.totalBeds = '',
    this.icuBeds = '',
    this.has24HourEmergency = false,
    this.hasIntensiveCare = false,
    this.photos = const [],
    this.assessorPhoneCountryCode,
    this.directorPhoneCountryCode,
  });

  String get fullAssessorPhone {
    // if (assessorPhoneCountryCode != null && assessorPhoneNumber.isNotEmpty) {
    //   final fullPhone = '${assessorPhoneCountryCode!.code}$assessorPhoneNumber';
    //   return fullPhone;
    // }

    // return assessorPhone;
    // Prefer what the widget just set (E.164)
    if (assessorPhone.isNotEmpty) return assessorPhone;

    if (assessorPhoneCountryCode != null && assessorPhoneNumber.isNotEmpty) {
      return '${assessorPhoneCountryCode!.code}$assessorPhoneNumber';
    }
    return '';
  }

  String get fullDirectorPhone {
    // if (directorPhoneCountryCode != null && directorPhoneNumber.isNotEmpty) {
    //   final fullPhone = '${directorPhoneCountryCode!.code}$directorPhoneNumber';
    //   return fullPhone;
    // }

    // return directorPhone;
    if (directorPhone.isNotEmpty) return directorPhone;

    if (directorPhoneCountryCode != null && directorPhoneNumber.isNotEmpty) {
      return '${directorPhoneCountryCode!.code}$directorPhoneNumber';
    }
    return '';
  }

  static Future<AssessmentSectionOneFormData> fromAssessmentFormAsync(
    AssessmentFormEntity? form,
    List<CountryPhoneCodeEntity> countryCodes,
  ) async {
    if (form == null) {
      return AssessmentSectionOneFormData(assessmentDate: '');
    }

    final assessorParsed = CountryCodeFinder.parseWithCatalog(
      form.assessorInfo.phoneNumber,
      countryCodes,
    );
    final assessorCountryCode = assessorParsed.country;

    final directorParsed = CountryCodeFinder.parseWithCatalog(
      form.facilityIdentification.directorPhone,
      countryCodes,
    );
    final directorCountryCode = directorParsed.country;

    return AssessmentSectionOneFormData(
      assessmentDate:
          form.assessorInfo.assessmentDate != null
              ? DateFormat(
                'dd/MM/yyyy',
              ).format(form.assessorInfo.assessmentDate!)
              : '',
      assessorName: form.assessorInfo.name,
      assessorEmail: form.assessorInfo.email,
      assessorPhone: form.assessorInfo.phoneNumber,
      assessorPhoneNumber: assessorParsed.number,
      assessorPhoneCountryCode: assessorCountryCode,
      country: form.geoLocation.country,
      region: form.geoLocation.regionProvince,
      district: form.geoLocation.district,
      city: form.geoLocation.cityVillage,
      address: form.geoLocation.addressOrCoordinates,
      latitude: form.geoLocation.latitude,
      longitude: form.geoLocation.longitude,
      facilityLocation: form.geoLocation.locationType,
      facilityCode: form.facilityIdentification.facilityCode,
      facilityName: form.facilityIdentification.facilityName,
      managingAuthority: form.facilityIdentification.managingAuthority,
      otherManagingAuthority:
          form.facilityIdentification.otherManagingAuthority ?? '',
      directorName: form.facilityIdentification.directorName,
      directorPhone: form.facilityIdentification.directorPhone,
      directorPhoneNumber: directorParsed.number,
      directorPhoneCountryCode: directorCountryCode,
      directorEmail: form.facilityIdentification.directorEmail,
      respondentName: form.facilityIdentification.respondentName,
      respondentPosition: form.facilityIdentification.respondentPosition,
      structureType: form.facilityIdentification.structureType,
      facilityType: form.facilityIdentification.facilityType,
      existingFacilityType: form.facilityIdentification.existingFacilityType,
      otherExistingFacilityType:
          form.facilityIdentification.otherExistingFacilityType ?? '',
      offersOutpatientServices:
          form.facilityServices.hasOutpatientServices ?? false,
      offersInpatientServices:
          form.facilityServices.hasInpatientServices ?? false,
      totalBeds: form.facilityServices.totalInpatientBeds?.toString() ?? '',
      icuBeds: form.facilityServices.icuBeds?.toString() ?? '',
      has24HourEmergency: form.facilityServices.hasEmergencyUnit ?? false,
      hasIntensiveCare:
          form.facilityServices.hasIcuOrHighDependencyUnit ?? false,
      photos: form.photos,
    );
  }

  static AssessmentSectionOneFormData fromAssessmentForm(
    AssessmentFormEntity? form,
  ) {
    if (form == null) {
      return AssessmentSectionOneFormData(assessmentDate: '');
    }

    Map<String, String> simpleParse(String s) {
      if (s.trim().startsWith('+')) {
        final digits = s.replaceAll(RegExp(r'[^\d]'), '');
        return {'phoneNumber': digits.substring(1)};
      }
      return {'phoneNumber': s.replaceAll(RegExp(r'\D'), '')};
    }

    final assessorPhoneParts = simpleParse(form.assessorInfo.phoneNumber);
    final directorPhoneParts = simpleParse(
      form.facilityIdentification.directorPhone,
    );

    return AssessmentSectionOneFormData(
      assessmentDate:
          form.assessorInfo.assessmentDate != null
              ? DateFormat(
                'dd/MM/yyyy',
              ).format(form.assessorInfo.assessmentDate!)
              : '',
      assessorName: form.assessorInfo.name,
      assessorEmail: form.assessorInfo.email,
      assessorPhone: form.assessorInfo.phoneNumber,
      assessorPhoneNumber: assessorPhoneParts['phoneNumber'] ?? '',
      assessorPhoneCountryCode: null,
      country: form.geoLocation.country,
      region: form.geoLocation.regionProvince,
      district: form.geoLocation.district,
      city: form.geoLocation.cityVillage,
      address: form.geoLocation.addressOrCoordinates,
      latitude: form.geoLocation.latitude,
      longitude: form.geoLocation.longitude,
      facilityLocation: form.geoLocation.locationType,
      facilityCode: form.facilityIdentification.facilityCode,
      facilityName: form.facilityIdentification.facilityName,
      managingAuthority: form.facilityIdentification.managingAuthority,
      otherManagingAuthority:
          form.facilityIdentification.otherManagingAuthority ?? '',
      directorName: form.facilityIdentification.directorName,
      directorPhone: form.facilityIdentification.directorPhone,
      directorPhoneNumber: directorPhoneParts['phoneNumber'] ?? '',
      directorPhoneCountryCode: null,
      directorEmail: form.facilityIdentification.directorEmail,
      respondentName: form.facilityIdentification.respondentName,
      respondentPosition: form.facilityIdentification.respondentPosition,
      structureType: form.facilityIdentification.structureType,
      facilityType: form.facilityIdentification.facilityType,
      existingFacilityType: form.facilityIdentification.existingFacilityType,
      otherExistingFacilityType:
          form.facilityIdentification.otherExistingFacilityType ?? '',
      offersOutpatientServices:
          form.facilityServices.hasOutpatientServices ?? false,
      offersInpatientServices:
          form.facilityServices.hasInpatientServices ?? false,
      totalBeds: form.facilityServices.totalInpatientBeds?.toString() ?? '',
      icuBeds: form.facilityServices.icuBeds?.toString() ?? '',
      has24HourEmergency: form.facilityServices.hasEmergencyUnit ?? false,
      hasIntensiveCare:
          form.facilityServices.hasIcuOrHighDependencyUnit ?? false,
      photos: form.photos,
    );
  }
}

class AssessmentSectionOnePage extends StatefulWidget {
  final AssessmentFormEntity? assessmentForm;
  final Function(AssessmentFormEntity) onUpdateForm;

  const AssessmentSectionOnePage({
    super.key,
    this.assessmentForm,
    required this.onUpdateForm,
  });

  @override
  State<AssessmentSectionOnePage> createState() =>
      _AssessmentSectionOnePageState();
}

class _AssessmentSectionOnePageState extends State<AssessmentSectionOnePage> {
  final _formKey = GlobalKey<FormState>();

  AssessmentSectionOneFormData? _formData;
  bool _autoValidate = false;
  bool _isInitializing = true;

  // Store country codes list for initialization
  List<CountryPhoneCodeEntity>? _countryCodes;

  @override
  void initState() {
    super.initState();
    // Don't initialize form data yet - wait for async data
    _initializeFormData();
  }

  Future<void> _initializeFormData() async {
    if (!mounted) return;

    // First, load country codes
    try {
      // Create a temporary bloc to load country codes
      final phoneBloc = di.sl<PhoneInputBloc>();
      phoneBloc.add(const LoadCountryCodesEvent());

      // Wait for country codes to load
      await for (final state in phoneBloc.stream) {
        if (state is PhoneInputLoaded) {
          _countryCodes = state.countryCodes;
          break;
        } else if (state is PhoneInputError) {
          // Fall back to synchronous initialization if loading fails
          break;
        }
      }

      await phoneBloc.close();
    } catch (e) {
      // print('Error loading country codes: $e');
    }

    // Now initialize form data with country codes
    if (mounted) {
      if (_countryCodes != null && _countryCodes!.isNotEmpty) {
        // Use async initialization with country codes
        _formData = await AssessmentSectionOneFormData.fromAssessmentFormAsync(
          widget.assessmentForm,
          _countryCodes!,
        );
      } else {
        // Fall back to synchronous initialization
        _formData = AssessmentSectionOneFormData.fromAssessmentForm(
          widget.assessmentForm,
        );
      }

      setState(() {
        _isInitializing = false;
      });
    }
  }

  @override
  void didUpdateWidget(AssessmentSectionOnePage oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Check if the assessment form has changed significantly
    if (oldWidget.assessmentForm?.id != widget.assessmentForm?.id) {
      // Re-initialize if we're switching to a different assessment
      _isInitializing = true;
      _initializeFormData();
    } else if (widget.assessmentForm != null &&
        oldWidget.assessmentForm != null &&
        _formData != null &&
        !_isInitializing) {
      // Check if external updates need to be reflected
      _checkForExternalUpdates();
    }
  }

  void _checkForExternalUpdates() {
    if (widget.assessmentForm == null || _formData == null) return;

    final form = widget.assessmentForm!;
    bool needsUpdate = false;

    // Check if key fields have been updated externally
    if (form.assessorInfo.name != _formData!.assessorName ||
        form.assessorInfo.email != _formData!.assessorEmail ||
        form.geoLocation.country != _formData!.country ||
        form.geoLocation.regionProvince != _formData!.region ||
        form.geoLocation.cityVillage != _formData!.city) {
      needsUpdate = true;
    }

    if (needsUpdate) {
      // Preserve phone country codes if already set
      final currentAssessorCode = _formData!.assessorPhoneCountryCode;
      final currentDirectorCode = _formData!.directorPhoneCountryCode;

      // Update form data while preserving country codes
      if (_countryCodes != null && _countryCodes!.isNotEmpty) {
        AssessmentSectionOneFormData.fromAssessmentFormAsync(
          widget.assessmentForm,
          _countryCodes!,
        ).then((newFormData) {
          if (mounted) {
            setState(() {
              // Preserve country codes if they were already selected
              if (currentAssessorCode != null) {
                newFormData.assessorPhoneCountryCode = currentAssessorCode;
              }
              if (currentDirectorCode != null) {
                newFormData.directorPhoneCountryCode = currentDirectorCode;
              }
              _formData = newFormData;
            });
          }
        });
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _updateFormData(VoidCallback update) {
    if (_formData != null && mounted) {
      setState(update);
      _notifyFormUpdate();
    }
  }

  void _onAssessorFullPhoneChanged(String fullPhone) {
    // _updateFormData(() {
    //   _formData!.assessorPhone = fullPhone;
    // });
    _updateFormData(() {
      _formData!.assessorPhone = fullPhone;

      // keep split fields synced (optional)
      if (_countryCodes != null && _countryCodes!.isNotEmpty) {
        final parsed = CountryCodeFinder.parseWithCatalog(
          fullPhone,
          _countryCodes!,
        );
        _formData!.assessorPhoneCountryCode = parsed.country;
        _formData!.assessorPhoneNumber = parsed.number;
      }
    });
  }

  void _onDirectorFullPhoneChanged(String fullPhone) {
    _updateFormData(() {
      _formData!.directorPhone = fullPhone;

      if (_countryCodes != null && _countryCodes!.isNotEmpty) {
        final parsed = CountryCodeFinder.parseWithCatalog(
          fullPhone,
          _countryCodes!,
        );
        _formData!.directorPhoneCountryCode = parsed.country;
        _formData!.directorPhoneNumber = parsed.number;
      }
    });
  }

  void _onLocationSelected(GeoLocationEntity locationData) {
    _updateFormData(() {
      _formData!.address = locationData.addressOrCoordinates;
      _formData!.latitude = locationData.latitude;
      _formData!.longitude = locationData.longitude;

      if (locationData.country.isNotEmpty && _formData!.country.isEmpty) {
        _formData!.country = locationData.country;
      }
      if (locationData.regionProvince.isNotEmpty && _formData!.region.isEmpty) {
        _formData!.region = locationData.regionProvince;
      }
      if (locationData.cityVillage.isNotEmpty && _formData!.city.isEmpty) {
        _formData!.city = locationData.cityVillage;
      }
      if (locationData.district.isNotEmpty && _formData!.district.isEmpty) {
        _formData!.district = locationData.district;
      }
    });
  }

  void _notifyFormUpdate() {
    if (_formData == null) return;

    DateTime? assessmentDate;
    if (_formData!.assessmentDate.isNotEmpty) {
      try {
        assessmentDate = DateFormat(
          'dd/MM/yyyy',
        ).parse(_formData!.assessmentDate);
      } catch (e) {
        assessmentDate = null;
      }
    }

    final assessorInfo = AssessorInfoEntity(
      name: _formData!.assessorName,
      email: _formData!.assessorEmail,
      phoneNumber: _formData!.fullAssessorPhone,
      assessmentDate: assessmentDate,
    );

    final geoLocation = GeoLocationEntity(
      country: _formData!.country,
      regionProvince: _formData!.region,
      district: _formData!.district,
      cityVillage: _formData!.city,
      addressOrCoordinates: _formData!.address,
      latitude: _formData!.latitude,
      longitude: _formData!.longitude,
      locationType: _formData!.facilityLocation,
    );

    final facilityIdentification = FacilityIdentificationEntity(
      facilityCode: _formData!.facilityCode,
      facilityName: _formData!.facilityName,
      managingAuthority: _formData!.managingAuthority,
      otherManagingAuthority:
          _formData!.managingAuthority == ManagingAuthorityType.other
              ? _formData!.otherManagingAuthority
              : null,
      directorName: _formData!.directorName,
      directorPhone: _formData!.fullDirectorPhone,
      directorEmail: _formData!.directorEmail,
      respondentName: _formData!.respondentName,
      respondentPosition: _formData!.respondentPosition,
      structureType: _formData!.structureType,
      facilityType: _formData!.facilityType,
      existingFacilityType:
          _formData!.facilityType == FacilityType.screeningAndTemporaryIsolation
              ? _formData!.existingFacilityType
              : null,
      otherExistingFacilityType:
          _formData!.existingFacilityType == ExistingFacilityType.other
              ? _formData!.otherManagingAuthority
              : null,
    );

    final int? totalBeds = int.tryParse(_formData!.totalBeds);
    final int? icuBeds = int.tryParse(_formData!.icuBeds);

    final facilityServices = FacilityServicesEntity(
      hasOutpatientServices: _formData!.offersOutpatientServices,
      hasInpatientServices: _formData!.offersInpatientServices,
      totalInpatientBeds: _formData!.offersInpatientServices ? totalBeds : null,
      icuBeds: _formData!.offersInpatientServices ? icuBeds : null,
      hasEmergencyUnit:
          _formData!.offersInpatientServices
              ? _formData!.has24HourEmergency
              : null,
      hasIcuOrHighDependencyUnit:
          _formData!.offersInpatientServices
              ? _formData!.hasIntensiveCare
              : null,
    );

    final updatedForm =
        widget.assessmentForm?.copyWith(
          assessorInfo: assessorInfo,
          geoLocation: geoLocation,
          facilityIdentification: facilityIdentification,
          facilityServices: facilityServices,
          photos: _formData!.photos,
        ) ??
        AssessmentFormEntity(
          id:
              widget.assessmentForm?.id ??
              DateTime.now().millisecondsSinceEpoch.toString(),
          assessorInfo: assessorInfo,
          geoLocation: geoLocation,
          facilityIdentification: facilityIdentification,
          facilityServices: facilityServices,
          sections: widget.assessmentForm?.sections ?? [],
          photos: _formData!.photos,
          isSubmitted: widget.assessmentForm?.isSubmitted ?? false,
          createdAt: widget.assessmentForm?.createdAt ?? DateTime.now(),
          updatedAt: DateTime.now(),
        );

    widget.onUpdateForm(updatedForm);
  }

  bool validateAndUpdateForm() {
    if (_formData == null) return false;

    bool isValid = true;

    if (!_formKey.currentState!.validate()) {
      isValid = false;
    }

    if (_formData!.address.isEmpty) {
      _showLocationRequiredDialog();
      isValid = false;
    }

    if (!isValid) {
      setState(() {
        _autoValidate = true;
      });
      return false;
    }

    _notifyFormUpdate();

    return true;
  }

  void _showLocationRequiredDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Location Required'),
            content: const Text(
              'Please select a location on the map to continue.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_formData == null || _isInitializing) {
      return Scaffold(
        backgroundColor: theme.colorScheme.surface,
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading form data...'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          final contentWidth = AdaptiveBreakpoints.getContentWidth(screenWidth);
          final isMobile = AdaptiveBreakpoints.isMobile(screenWidth);

          return SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: contentWidth),
                child: Column(
                  children: [
                    if (AdaptiveBreakpoints.isDesktop(screenWidth))
                      Padding(
                        padding: const EdgeInsets.only(top: 24, bottom: 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Assessment Information',
                                style: theme.textTheme.headlineMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                    Expanded(
                      child: Form(
                        key: _formKey,
                        autovalidateMode:
                            _autoValidate
                                ? AutovalidateMode.always
                                : AutovalidateMode.disabled,
                        child: SingleChildScrollView(
                          key: const PageStorageKey(
                            'assessment_section_one_scroll',
                          ),
                          physics: const BouncingScrollPhysics(),
                          padding: AdaptiveBreakpoints.getScreenPadding(
                            screenWidth,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildHeaderSection(theme, isMobile),
                              SizedBox(height: isMobile ? 20 : 24),
                              _buildAssessmentInfoSection(theme, isMobile),
                              SizedBox(height: isMobile ? 20 : 24),
                              _buildGeographicalLocationSection(
                                theme,
                                isMobile,
                              ),
                              SizedBox(height: isMobile ? 20 : 24),
                              _buildFacilityIdentificationSection(
                                theme,
                                isMobile,
                              ),
                              SizedBox(height: isMobile ? 20 : 24),
                              _buildFacilityServicesSection(theme, isMobile),
                              SizedBox(height: isMobile ? 20 : 24),
                              _buildPhotoDocumentationSection(theme, isMobile),
                              SizedBox(height: isMobile ? 24 : 40),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderSection(ThemeData theme, bool isMobile) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: EdgeInsets.all(isMobile ? 16 : 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primaryContainer,
              theme.colorScheme.primaryContainer.withValues(alpha: 0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(isMobile ? 8 : 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
              ),
              child: Icon(
                Icons.local_hospital_outlined,
                color: theme.colorScheme.onPrimary,
                size: isMobile ? 20 : 24,
              ),
            ),
            SizedBox(width: isMobile ? 12 : 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Section 1: Facility Information',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onPrimaryContainer,
                      fontSize: isMobile ? 16 : null,
                    ),
                  ),
                  SizedBox(height: isMobile ? 2 : 4),
                  Text(
                    'Necessary information about the facility being assessed.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer.withValues(
                        alpha: 0.8,
                      ),
                      fontSize: isMobile ? 13 : null,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssessmentInfoSection(ThemeData theme, bool isMobile) {
    return _FormSection(
      title: '1.1 Assessment Information',
      icon: Icons.assignment,
      isMobile: isMobile,
      children: [
        _DateField(
          label: 'Date of assessment',
          value: _formData!.assessmentDate,
          onChanged:
              (date) => _updateFormData(() => _formData!.assessmentDate = date),
          isMobile: isMobile,
        ),
        SizedBox(height: isMobile ? 12 : 16),
        _TextField(
          label: 'Assessor Name',
          value: _formData!.assessorName,
          onChanged:
              (value) => _updateFormData(() => _formData!.assessorName = value),
          isMobile: isMobile,
        ),
        SizedBox(height: isMobile ? 12 : 16),
        _TextField(
          label: 'Email Address',
          value: _formData!.assessorEmail,
          onChanged:
              (value) =>
                  _updateFormData(() => _formData!.assessorEmail = value),
          keyboardType: TextInputType.emailAddress,
          isMobile: isMobile,
        ),
        SizedBox(height: isMobile ? 12 : 16),

        BlocProvider<PhoneInputBloc>(
          create:
              (_) =>
                  di.sl<PhoneInputBloc>()..add(
                    LoadCountryCodesEvent(
                      initialPhoneNumber: _formData!.assessorPhone,
                      initialCountryCode: _formData!.assessorPhoneCountryCode,
                    ),
                  ),
          child: Section1PhoneInputWidget(
            label: 'Phone Number',
            isMobile: isMobile,
            enabled: true,
            onFullPhoneChanged: _onAssessorFullPhoneChanged,
            validator:
                (value, selectedCountry) =>
                    PhoneValidationHelper.validatePhoneNumber(
                      value,
                      selectedCountry,
                    ),
          ),
        ),
      ],
    );
  }

  Widget _buildGeographicalLocationSection(ThemeData theme, bool isMobile) {
    return _FormSection(
      title: '1.2 Geographical Location',
      icon: Icons.location_on,
      isMobile: isMobile,
      children: [
        GeographicCascadeDropdown(
          key: const ValueKey('geographic_cascade'),

          // key: ValueKey(
          //   'geographic_${_formData!.country}_${_formData!.region}_${_formData!.city}',
          // ),
          savedCountryName:
              _formData!.country.isNotEmpty ? _formData!.country : null,
          savedRegionName:
              _formData!.region.isNotEmpty ? _formData!.region : null,
          savedCityName: _formData!.city.isNotEmpty ? _formData!.city : null,

          onSelectionChanged: (selection) {
            _updateFormData(() {
              _formData!.selectedCountry = selection.country;
              _formData!.country = selection.country?.name ?? '';
              _formData!.selectedRegion = selection.state;
              _formData!.region = selection.state?.name ?? '';
              _formData!.selectedCity = selection.city;
              _formData!.city = selection.city?.name ?? '';
            });
          },

          countryHint: 'Country',
          stateHint: 'State/Region',
          cityHint: 'City',
          enabled: true,
        ),

        SizedBox(height: isMobile ? 12 : 16),

        _TextField(
          label: 'District',
          value: _formData!.district,
          onChanged:
              (value) => _updateFormData(() => _formData!.district = value),
          isMobile: isMobile,
        ),

        SizedBox(height: isMobile ? 12 : 16),

        _Dropdown<FacilityLocationType>(
          label: 'Facility Location Type',
          value: _formData!.facilityLocation,
          items: FacilityLocationType.values,
          itemBuilder: (type) {
            switch (type) {
              case FacilityLocationType.urban:
                return 'Urban';
              case FacilityLocationType.periUrban:
                return 'Peri-/Ex-urban';
              case FacilityLocationType.rural:
                return 'Rural';
            }
          },
          onChanged:
              (value) =>
                  _updateFormData(() => _formData!.facilityLocation = value!),
          isMobile: isMobile,
        ),

        SizedBox(height: isMobile ? 12 : 16),

        SizedBox(
          height: isMobile ? 180 : 200,
          width: double.infinity,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SimpleMapPicker(
              initialPosition:
                  (_formData!.latitude != null && _formData!.longitude != null)
                      ? LatLng(_formData!.latitude!, _formData!.longitude!)
                      : null,
              onPicked:
                  (pos, addr) => _onLocationSelected(
                    GeoLocationEntity(
                      addressOrCoordinates: addr,
                      latitude: pos.latitude,
                      longitude: pos.longitude,
                      country: _formData!.country,
                      regionProvince: _formData!.region,
                      district: _formData!.district,
                      cityVillage: _formData!.city,
                      locationType:
                          _formData!.facilityLocation ??
                          FacilityLocationType.urban,
                    ),
                  ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFacilityIdentificationSection(ThemeData theme, bool isMobile) {
    return _FormSection(
      title: '1.3 Facility Identification',
      icon: Icons.business,
      isMobile: isMobile,
      children: [
        if (isMobile) ...[
          _TextField(
            label: 'Facility Code',
            value: _formData!.facilityCode,
            onChanged:
                (value) =>
                    _updateFormData(() => _formData!.facilityCode = value),
            isMobile: isMobile,
          ),
          const SizedBox(height: 12),
          _TextField(
            label: 'Facility Name',
            value: _formData!.facilityName,
            onChanged:
                (value) =>
                    _updateFormData(() => _formData!.facilityName = value),
            isMobile: isMobile,
          ),
        ] else ...[
          Row(
            children: [
              Expanded(
                child: _TextField(
                  label: 'Facility Code',
                  value: _formData!.facilityCode,
                  onChanged:
                      (value) => _updateFormData(
                        () => _formData!.facilityCode = value,
                      ),
                  isMobile: isMobile,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: _TextField(
                  label: 'Facility Name',
                  value: _formData!.facilityName,
                  onChanged:
                      (value) => _updateFormData(
                        () => _formData!.facilityName = value,
                      ),
                  isMobile: isMobile,
                ),
              ),
            ],
          ),
        ],
        SizedBox(height: isMobile ? 12 : 16),
        _Dropdown<ManagingAuthorityType>(
          label: 'Managing Authority',
          value: _formData!.managingAuthority,
          items: ManagingAuthorityType.values,
          itemBuilder: (type) {
            switch (type) {
              case ManagingAuthorityType.government:
                return 'Government / Public';
              case ManagingAuthorityType.privateForProfit:
                return 'Private for Profit';
              case ManagingAuthorityType.privateNotForProfit:
                return 'Private Not for Profit (NGO, Faith-based)';
              case ManagingAuthorityType.militaryPoliceNationalGuard:
                return 'Military/Police/National Guard';
              case ManagingAuthorityType.university:
                return 'University';
              case ManagingAuthorityType.other:
                return 'Other';
            }
          },
          onChanged:
              (value) =>
                  _updateFormData(() => _formData!.managingAuthority = value!),
          isMobile: isMobile,
        ),
        SizedBox(height: isMobile ? 16 : 24),
        _SubsectionTitle('Director/Manager Information', theme, isMobile),
        SizedBox(height: isMobile ? 12 : 16),
        _TextField(
          label: 'Director/Manager Name',
          value: _formData!.directorName,
          onChanged:
              (value) => _updateFormData(() => _formData!.directorName = value),
          isMobile: isMobile,
        ),
        SizedBox(height: isMobile ? 12 : 16),

        if (isMobile) ...[
          BlocProvider<PhoneInputBloc>(
            create:
                (_) =>
                    di.sl<PhoneInputBloc>()..add(
                      LoadCountryCodesEvent(
                        initialPhoneNumber: _formData!.directorPhone,
                        initialCountryCode: _formData!.directorPhoneCountryCode,
                      ),
                    ),
            child: Section1PhoneInputWidget(
              label: 'Director Phone',
              isMobile: isMobile,
              enabled: true,
              onFullPhoneChanged: _onDirectorFullPhoneChanged,
              validator:
                  (value, selectedCountry) =>
                      PhoneValidationHelper.validatePhoneNumber(
                        value,
                        selectedCountry,
                      ),
            ),
          ),

          const SizedBox(height: 12),
          _TextField(
            label: 'Director Email',
            value: _formData!.directorEmail,
            onChanged:
                (value) =>
                    _updateFormData(() => _formData!.directorEmail = value),
            keyboardType: TextInputType.emailAddress,
            isMobile: isMobile,
          ),
        ] else ...[
          Row(
            children: [
              Expanded(
                child: BlocProvider<PhoneInputBloc>(
                  create:
                      (_) =>
                          di.sl<PhoneInputBloc>()..add(
                            LoadCountryCodesEvent(
                              initialPhoneNumber: _formData!.directorPhone,
                              initialCountryCode:
                                  _formData!.directorPhoneCountryCode,
                            ),
                          ),
                  child: Section1PhoneInputWidget(
                    label: 'Director Phone',
                    isMobile: isMobile,
                    enabled: true,
                    onFullPhoneChanged: _onDirectorFullPhoneChanged,
                    validator:
                        (value, selectedCountry) =>
                            PhoneValidationHelper.validatePhoneNumber(
                              value,
                              selectedCountry,
                            ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _TextField(
                  label: 'Director Email',
                  value: _formData!.directorEmail,
                  onChanged:
                      (value) => _updateFormData(
                        () => _formData!.directorEmail = value,
                      ),
                  keyboardType: TextInputType.emailAddress,
                  isMobile: isMobile,
                ),
              ),
            ],
          ),
        ],
        SizedBox(height: isMobile ? 16 : 24),
        _SubsectionTitle('Respondent Information', theme, isMobile),
        SizedBox(height: isMobile ? 12 : 16),
        if (isMobile) ...[
          _TextField(
            label: 'Respondent Name',
            value: _formData!.respondentName,
            onChanged:
                (value) =>
                    _updateFormData(() => _formData!.respondentName = value),
            isMobile: isMobile,
          ),
          const SizedBox(height: 12),
          _TextField(
            label: 'Position',
            value: _formData!.respondentPosition,
            onChanged:
                (value) => _updateFormData(
                  () => _formData!.respondentPosition = value,
                ),
            isMobile: isMobile,
          ),
        ] else ...[
          Row(
            children: [
              Expanded(
                child: _TextField(
                  label: 'Respondent Name',
                  value: _formData!.respondentName,
                  onChanged:
                      (value) => _updateFormData(
                        () => _formData!.respondentName = value,
                      ),
                  isMobile: isMobile,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _TextField(
                  label: 'Position',
                  value: _formData!.respondentPosition,
                  onChanged:
                      (value) => _updateFormData(
                        () => _formData!.respondentPosition = value,
                      ),
                  isMobile: isMobile,
                ),
              ),
            ],
          ),
        ],
        SizedBox(height: isMobile ? 16 : 24),
        _SubsectionTitle('Facility Structure & Type', theme, isMobile),
        SizedBox(height: isMobile ? 12 : 16),
        _Dropdown<FacilityStructureType>(
          label: 'Structure Type',
          value: _formData!.structureType,
          items: FacilityStructureType.values,
          itemBuilder: (type) {
            switch (type) {
              case FacilityStructureType.permanent:
                return 'Permanent Facility (concrete, bricks, etc.)';
              case FacilityStructureType.temporaryMediumTerm:
                return 'Temporary Medium-term (concrete slabs, wooden structure)';
              case FacilityStructureType.temporaryShortTerm:
                return 'Temporary Short-term (tents, etc.)';
            }
          },
          onChanged:
              (value) =>
                  _updateFormData(() => _formData!.structureType = value!),
          isMobile: isMobile,
        ),
        SizedBox(height: isMobile ? 12 : 16),
        _Dropdown<FacilityType>(
          label: 'Facility Type',
          value: _formData!.facilityType,
          items: FacilityType.values,
          itemBuilder: (type) {
            switch (type) {
              case FacilityType.screeningAndTemporaryIsolation:
                return 'Screening and Temporary Isolation';
              case FacilityType.standaloneTreatmentCenter:
                return 'Ebola/Marburg Stand-alone Treatment Centre';
            }
          },
          onChanged:
              (value) =>
                  _updateFormData(() => _formData!.facilityType = value!),
          isMobile: isMobile,
        ),
        if (_formData!.facilityType ==
            FacilityType.screeningAndTemporaryIsolation) ...[
          SizedBox(height: isMobile ? 12 : 16),
          _Dropdown<ExistingFacilityType>(
            label: 'Type of Existing Healthcare Facility',
            value: _formData!.existingFacilityType,
            items: ExistingFacilityType.values,
            itemBuilder: (type) {
              switch (type) {
                case ExistingFacilityType.firstReferralHospital:
                  return 'First Referral/District Hospital';
                case ExistingFacilityType.regionalProvincialReferralHospital:
                  return 'Regional/Provincial Referral Hospital';
                case ExistingFacilityType.nationalReferralHospital:
                  return 'National Referral Hospital';
                case ExistingFacilityType.otherGeneralHospital:
                  return 'Other General/Specialty Hospital';
                case ExistingFacilityType.infectiousDiseasesUnit:
                  return 'Infectious Diseases Unit (IDU)';
                case ExistingFacilityType.primaryHealthClinic:
                  return 'Primary Health Clinic';
                case ExistingFacilityType.other:
                  return 'Other';
              }
            },
            onChanged:
                (value) => _updateFormData(
                  () => _formData!.existingFacilityType = value,
                ),
            isMobile: isMobile,
          ),
        ],
      ],
    );
  }

  Widget _buildFacilityServicesSection(ThemeData theme, bool isMobile) {
    return _FormSection(
      title: '1.4 Existing Healthcare Facility Services',
      icon: Icons.medical_services,
      isMobile: isMobile,
      children: [
        _Switch(
          label: 'Offers Outpatient Services',
          value: _formData!.offersOutpatientServices,
          onChanged:
              (value) => _updateFormData(
                () => _formData!.offersOutpatientServices = value,
              ),
          isMobile: isMobile,
        ),
        SizedBox(height: isMobile ? 12 : 16),
        _Switch(
          label: 'Offers Inpatient Services',
          value: _formData!.offersInpatientServices,
          onChanged:
              (value) => _updateFormData(
                () => _formData!.offersInpatientServices = value,
              ),
          isMobile: isMobile,
        ),
        if (_formData!.offersInpatientServices) ...[
          SizedBox(height: isMobile ? 16 : 24),
          _SubsectionTitle('Inpatient Service Details', theme, isMobile),
          SizedBox(height: isMobile ? 12 : 16),
          if (isMobile) ...[
            _TextField(
              label: 'Total Inpatient Beds',
              value: _formData!.totalBeds,
              onChanged:
                  (value) =>
                      _updateFormData(() => _formData!.totalBeds = value),
              keyboardType: TextInputType.number,
              isMobile: isMobile,
            ),
            const SizedBox(height: 12),
            _TextField(
              label: 'ICU Beds',
              value: _formData!.icuBeds,
              onChanged:
                  (value) => _updateFormData(() => _formData!.icuBeds = value),
              keyboardType: TextInputType.number,
              isMobile: isMobile,
            ),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: _TextField(
                    label: 'Total Inpatient Beds',
                    value: _formData!.totalBeds,
                    onChanged:
                        (value) =>
                            _updateFormData(() => _formData!.totalBeds = value),
                    keyboardType: TextInputType.number,
                    isMobile: isMobile,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _TextField(
                    label: 'ICU Beds',
                    value: _formData!.icuBeds,
                    onChanged:
                        (value) =>
                            _updateFormData(() => _formData!.icuBeds = value),
                    keyboardType: TextInputType.number,
                    isMobile: isMobile,
                  ),
                ),
              ],
            ),
          ],
          SizedBox(height: isMobile ? 12 : 16),
          _Switch(
            label: 'Has 24-hour Staffed Emergency Unit',
            value: _formData!.has24HourEmergency,
            onChanged:
                (value) => _updateFormData(
                  () => _formData!.has24HourEmergency = value,
                ),
            isMobile: isMobile,
          ),
          SizedBox(height: isMobile ? 12 : 16),
          _Switch(
            label: 'Has Intensive Care or High-Dependency Unit',
            value: _formData!.hasIntensiveCare,
            onChanged:
                (value) =>
                    _updateFormData(() => _formData!.hasIntensiveCare = value),
            isMobile: isMobile,
          ),
        ],
      ],
    );
  }

  Widget _buildPhotoDocumentationSection(ThemeData theme, bool isMobile) {
    return _FormSection(
      title: '1.5 Photo Documentation',
      icon: Icons.photo_camera,
      isMobile: isMobile,
      children: [
        Text(
          'Take photos to document the facility condition, equipment, and infrastructure. These photos will help provide visual context for your assessment.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: isMobile ? 13 : null,
          ),
        ),
        SizedBox(height: isMobile ? 12 : 16),
        PhotoPickerWidget(
          photos: _formData!.photos,
          onPhotosChanged:
              (photos) => _updateFormData(() {
                _formData!.photos = photos;
              }),
          maxPhotos: 10,
        ),
      ],
    );
  }
}

class _FormSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  final bool isMobile;

  const _FormSection({
    required this.title,
    required this.icon,
    required this.children,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(isMobile ? 6 : 8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: theme.colorScheme.onPrimaryContainer,
                    size: isMobile ? 18 : 20,
                  ),
                ),
                SizedBox(width: isMobile ? 8 : 12),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                      fontSize: isMobile ? 16 : null,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: isMobile ? 16 : 20),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _SubsectionTitle extends StatelessWidget {
  final String title;
  final ThemeData theme;
  final bool isMobile;

  const _SubsectionTitle(this.title, this.theme, this.isMobile);

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w500,
        color: theme.colorScheme.primary,
        fontSize: isMobile ? 14 : null,
      ),
    );
  }
}

class _TextField extends StatelessWidget {
  final String label;
  final String value;
  final ValueChanged<String> onChanged;
  final TextInputType? keyboardType;
  final bool isMobile;

  const _TextField({
    required this.label,
    required this.value,
    required this.onChanged,
    this.keyboardType,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextFormField(
      initialValue: value,
      onChanged: onChanged,
      keyboardType: keyboardType,
      style: TextStyle(fontSize: isMobile ? 14 : null),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: isMobile ? 13 : null),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.5),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.error),
        ),
        filled: true,
        fillColor: theme.colorScheme.surface,
        contentPadding: EdgeInsets.symmetric(
          horizontal: isMobile ? 12 : 16,
          vertical: isMobile ? 12 : 16,
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final String label;
  final String value;
  final ValueChanged<String> onChanged;
  final bool isMobile;

  const _DateField({
    required this.label,
    required this.value,
    required this.onChanged,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextFormField(
      readOnly: true,
      controller: TextEditingController(text: value),
      style: TextStyle(fontSize: isMobile ? 14 : null),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: isMobile ? 13 : null),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.5),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
        ),
        filled: true,
        fillColor: theme.colorScheme.surface,
        contentPadding: EdgeInsets.symmetric(
          horizontal: isMobile ? 12 : 16,
          vertical: isMobile ? 12 : 16,
        ),
        suffixIcon: Icon(
          Icons.calendar_today,
          color: theme.colorScheme.primary,
          size: isMobile ? 18 : 20,
        ),
      ),
      onTap: () async {
        final initial =
            value.isNotEmpty
                ? DateFormat('dd/MM/yyyy').parse(value)
                : DateTime.now();
        final date = await showDatePicker(
          context: context,
          initialDate: initial,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
          builder: (context, child) {
            return Theme(
              data: theme.copyWith(
                colorScheme: theme.colorScheme.copyWith(
                  primary: theme.colorScheme.primary,
                ),
              ),
              child: child!,
            );
          },
        );
        if (date != null) {
          onChanged(DateFormat('dd/MM/yyyy').format(date));
        }
      },
    );
  }
}

class _Dropdown<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<T> items;
  final String Function(T) itemBuilder;
  final ValueChanged<T?> onChanged;
  final bool isMobile;

  const _Dropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.itemBuilder,
    required this.onChanged,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DropdownButtonFormField<T>(
      value: value,
      style: TextStyle(
        fontSize: isMobile ? 14 : null,
        color: theme.colorScheme.onSurface,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(fontSize: isMobile ? 13 : null),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.5),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
        ),
        filled: true,
        fillColor: theme.colorScheme.surface,
        contentPadding: EdgeInsets.symmetric(
          horizontal: isMobile ? 12 : 16,
          vertical: isMobile ? 12 : 16,
        ),
      ),
      items:
          items.map((item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(
                itemBuilder(item),
                style: TextStyle(fontSize: isMobile ? 13 : 14),
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
      onChanged: onChanged,
      isExpanded: true,
      icon: Icon(
        Icons.keyboard_arrow_down,
        color: theme.colorScheme.onSurfaceVariant,
        size: isMobile ? 18 : 20,
      ),
    );
  }
}

class _Switch extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isMobile;

  const _Switch({
    required this.label,
    required this.value,
    required this.onChanged,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 16,
        vertical: isMobile ? 10 : 12,
      ),
      decoration: BoxDecoration(
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                fontSize: isMobile ? 13 : null,
              ),
            ),
          ),
          Transform.scale(
            scale: isMobile ? 0.8 : 1.0,
            child: Switch.adaptive(
              value: value,
              onChanged: onChanged,
              activeColor: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:treatment_center/features/geolocation/domain/entities/country_phone_code.dart';
import 'package:treatment_center/features/geolocation/presentation/bloc/phone_input/phone_input_bloc.dart';
import 'package:treatment_center/features/geolocation/presentation/bloc/phone_input/phone_input_event.dart';
import 'package:treatment_center/features/geolocation/presentation/bloc/phone_input/phone_input_state.dart';
import 'package:treatment_center/injection_container.dart' as di;

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

// Enhanced Phone Input Widget with Search and Debug
class Section1PhoneInputWidget extends StatefulWidget {
  final String label;
  final CountryPhoneCodeEntity? selectedCountryCode;
  final String phoneNumber;
  final ValueChanged<CountryPhoneCodeEntity>? onCountryCodeChanged;
  final ValueChanged<String>? onPhoneNumberChanged;
  final ValueChanged<String>? onFullPhoneChanged;
  final String? Function(String?)? validator;
  final bool isMobile;
  final bool enabled;

  const Section1PhoneInputWidget({
    super.key,
    this.label = 'Phone Number',
    required this.selectedCountryCode,
    required this.phoneNumber,
    this.onCountryCodeChanged,
    this.onPhoneNumberChanged,
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

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController(text: widget.phoneNumber);
  }

  @override
  void didUpdateWidget(Section1PhoneInputWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.phoneNumber != widget.phoneNumber) {
      _phoneController.text = widget.phoneNumber;
    }

    if (oldWidget.selectedCountryCode != widget.selectedCountryCode) {}
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _updateFullPhone() {
    if (widget.selectedCountryCode != null &&
        _phoneController.text.isNotEmpty) {
      final fullPhone =
          '${widget.selectedCountryCode!.code}${_phoneController.text}';

      if (widget.onFullPhoneChanged != null) {
        widget.onFullPhoneChanged!(fullPhone);
      }
    } else {}
  }

  void _showCountryPicker(List<CountryPhoneCodeEntity> countryCodes) {
    showDialog(
      context: context,
      builder:
          (context) => CountryCodePickerDialog(
            countryCodes: countryCodes,
            selectedCountryCode: widget.selectedCountryCode,
            onCountryCodeSelected: (country) {
              if (widget.onCountryCodeChanged != null) {
                widget.onCountryCodeChanged!(country);
              }
              _updateFullPhone();
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider(
      create:
          (context) => di.sl<PhoneInputBloc>()..add(LoadCountryCodesEvent()),
      child: BlocBuilder<PhoneInputBloc, PhoneInputState>(
        builder: (context, state) {
          if (state is PhoneInputLoading) {
            return _buildLoadingField(theme);
          }

          if (state is PhoneInputError) {
            return _buildErrorField(theme, state.message);
          }

          if (state is PhoneInputLoaded) {
            return _buildPhoneInputField(theme, state.countryCodes);
          }

          return _buildLoadingField(theme);
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
              // Retry loading
              context.read<PhoneInputBloc>().add(LoadCountryCodesEvent());
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneInputField(
    ThemeData theme,
    List<CountryPhoneCodeEntity> countryCodes,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Country Code Selector Button
        SizedBox(
          width: widget.isMobile ? 120 : 140,
          child: InkWell(
            onTap:
                widget.enabled ? () => _showCountryPicker(countryCodes) : null,
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
                  if (widget.selectedCountryCode != null) ...[
                    Text(
                      widget.selectedCountryCode!.flag,
                      style: TextStyle(fontSize: widget.isMobile ? 14 : 16),
                    ),
                    SizedBox(width: widget.isMobile ? 4 : 6),
                    Expanded(
                      child: Text(
                        widget.selectedCountryCode!.code,
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
              // Only allow digits and limit length
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
              if (widget.onPhoneNumberChanged != null) {
                widget.onPhoneNumberChanged!(value);
              }
              _updateFullPhone();
            },
            validator: widget.validator,
          ),
        ),
      ],
    );
  }
}

// Enhanced Phone Validation Helper with Debug
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

  static Map<String, dynamic> parsePhoneNumber(String fullPhone) {
    if (fullPhone.isEmpty) {
      return {'countryCode': null, 'phoneNumber': ''};
    }

    if (fullPhone.startsWith('+')) {
      // Try to parse country code (1-4 digits after +)
      final regex = RegExp(r'^\+(\d{1,4})(.*)');
      final match = regex.firstMatch(fullPhone);
      if (match != null) {
        final code = '+${match.group(1)}';
        final number = match.group(2) ?? '';

        return {'countryCode': code, 'phoneNumber': number};
      }
    }

    // If no country code found, treat entire string as phone number

    return {'countryCode': null, 'phoneNumber': fullPhone};
  }
}

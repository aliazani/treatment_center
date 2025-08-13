// import 'package:flutter/material.dart';
// import 'package:treatment_center/features/geolocation/domain/entities/city_entity.dart';
// import 'package:treatment_center/features/geolocation/domain/entities/country_entity.dart';
// import 'package:treatment_center/features/geolocation/domain/entities/region_entity.dart';
// import 'package:treatment_center/features/geolocation/domain/repositories/geographic_repository.dart';
// import 'package:treatment_center/features/geolocation/presentation/widgets/auto_suggest_dropdown.dart';

// class GeographicLocationSection extends StatefulWidget {
//   final GeographicRepository repository;
//   final String initialCountry;
//   final String initialRegion;
//   final String initialDistrict;
//   final String initialCity;
//   final Function(String country, String region, String district, String city)
//   onChanged;
//   final bool isMobile;

//   const GeographicLocationSection({
//     super.key,
//     required this.repository,
//     required this.initialCountry,
//     required this.initialRegion,
//     required this.initialDistrict,
//     required this.initialCity,
//     required this.onChanged,
//     required this.isMobile,
//   });

//   @override
//   State<GeographicLocationSection> createState() =>
//       _GeographicLocationSectionState();
// }

// class _GeographicLocationSectionState extends State<GeographicLocationSection> {
//   List<CountryEntity> _countries = [];
//   List<RegionEntity> _states = [];
//   List<CityEntity> _cities = [];

//   CountryEntity? _selectedCountry;
//   RegionEntity? _selectedState;
//   CityEntity? _selectedCity;

//   bool _loadingCountries = false;
//   bool _loadingStates = false;
//   bool _loadingCities = false;

//   String? _countryError;
//   String? _stateError;
//   String? _cityError;

//   @override
//   void initState() {
//     super.initState();
//     _loadCountries();
//   }

//   Future<void> _loadCountries() async {
//     setState(() {
//       _loadingCountries = true;
//       _countryError = null;
//     });

//     final result = await widget.repository.getCountries();
//     result.fold(
//       (failure) {
//         setState(() {
//           _countryError = 'Failed to load countries';
//           _loadingCountries = false;
//         });
//       },
//       (countries) {
//         setState(() {
//           _countries = countries;
//           _loadingCountries = false;
//         });

//         // Try to find and set initial country
//         if (widget.initialCountry.isNotEmpty) {
//           try {
//             _selectedCountry = countries.firstWhere(
//               (c) =>
//                   c.name.toLowerCase() == widget.initialCountry.toLowerCase(),
//             );
//             _loadStates(_selectedCountry!.iso2);
//           } catch (e) {
//             // Country not found, ignore
//           }
//         }
//       },
//     );
//   }

//   Future<void> _loadStates(String countryCode) async {
//     setState(() {
//       _loadingStates = true;
//       _stateError = null;
//       _states = [];
//       _cities = [];
//       _selectedState = null;
//       _selectedCity = null;
//     });

//     final result = await widget.repository.getStatesByCountry(countryCode);
//     result.fold(
//       (failure) {
//         setState(() {
//           _stateError = 'Failed to load states';
//           _loadingStates = false;
//         });
//       },
//       (states) {
//         setState(() {
//           _states = states;
//           _loadingStates = false;
//         });

//         // Try to find and set initial state
//         if (widget.initialRegion.isNotEmpty) {
//           try {
//             _selectedState = states.firstWhere(
//               (s) => s.name.toLowerCase() == widget.initialRegion.toLowerCase(),
//             );
//             _loadCities(_selectedState!.stateCode);
//           } catch (e) {
//             // State not found, ignore
//           }
//         }
//       },
//     );
//   }

//   Future<void> _loadCities(String stateCode) async {
//     setState(() {
//       _loadingCities = true;
//       _cityError = null;
//       _cities = [];
//       _selectedCity = null;
//     });

//     final result = await widget.repository.getCitiesByState(stateCode);
//     result.fold(
//       (failure) {
//         setState(() {
//           _cityError = 'Failed to load cities';
//           _loadingCities = false;
//         });
//       },
//       (cities) {
//         setState(() {
//           _cities = cities;
//           _loadingCities = false;
//         });

//         // Try to find and set initial city
//         if (widget.initialCity.isNotEmpty) {
//           try {
//             _selectedCity = cities.firstWhere(
//               (c) => c.name.toLowerCase() == widget.initialCity.toLowerCase(),
//             );
//           } catch (e) {
//             // City not found, ignore
//           }
//         }
//       },
//     );
//   }

//   void _onCountrySelected(CountryEntity? country) {
//     setState(() {
//       _selectedCountry = country;
//       _selectedState = null;
//       _selectedCity = null;
//       _states = [];
//       _cities = [];
//     });

//     if (country != null) {
//       _loadStates(country.iso2);
//     }

//     _notifyChange();
//   }

//   void _onStateSelected(RegionEntity? state) {
//     setState(() {
//       _selectedState = state;
//       _selectedCity = null;
//       _cities = [];
//     });

//     if (state != null) {
//       _loadCities(state.stateCode);
//     }

//     _notifyChange();
//   }

//   void _onCitySelected(CityEntity? city) {
//     setState(() {
//       _selectedCity = city;
//     });

//     _notifyChange();
//   }

//   void _notifyChange() {
//     widget.onChanged(
//       _selectedCountry?.name ?? '',
//       _selectedState?.name ?? '',
//       '', // district - you might want to add this field
//       _selectedCity?.name ?? '',
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         // Country Dropdown
//         AutoSuggestDropdown<CountryEntity>(
//           items: _countries,
//           displayFunction: (country) => country.name,
//           onSelected: _onCountrySelected,
//           hintText: 'Select Country',
//           labelText: 'Country',
//           initialValue: _selectedCountry,
//           enabled: !_loadingCountries,
//           isLoading: _loadingCountries,
//           errorText: _countryError,
//           prefixIcon:
//               _selectedCountry != null
//                   ? Padding(
//                     padding: const EdgeInsets.all(12.0),
//                     child: Text(
//                       _selectedCountry!.emoji,
//                       style: const TextStyle(fontSize: 16),
//                     ),
//                   )
//                   : const Icon(Icons.public),
//         ),

//         SizedBox(height: widget.isMobile ? 12 : 16),

//         // State/Region Dropdown
//         AutoSuggestDropdown<RegionEntity>(
//           items: _states,
//           displayFunction: (state) => state.name,
//           onSelected: _onStateSelected,
//           hintText: 'Select State/Region',
//           labelText: 'Region/Province',
//           initialValue: _selectedState,
//           enabled: !_loadingStates && _selectedCountry != null,
//           isLoading: _loadingStates,
//           errorText: _stateError,
//           prefixIcon: const Icon(Icons.location_on),
//         ),

//         SizedBox(height: widget.isMobile ? 12 : 16),

//         // City Dropdown
//         AutoSuggestDropdown<CityEntity>(
//           items: _cities,
//           displayFunction: (city) => city.name,
//           onSelected: _onCitySelected,
//           hintText: 'Select City',
//           labelText: 'City/Village',
//           initialValue: _selectedCity,
//           enabled: !_loadingCities && _selectedState != null,
//           isLoading: _loadingCities,
//           errorText: _cityError,
//           prefixIcon: const Icon(Icons.location_city),
//         ),

//         SizedBox(height: widget.isMobile ? 12 : 16),

//         // District field (if you still need it as a text field)
//         _TextField(
//           label: 'District',
//           value: widget.initialDistrict,
//           onChanged: (value) {
//             // Handle district change
//             widget.onChanged(
//               _selectedCountry?.name ?? '',
//               _selectedState?.name ?? '',
//               value,
//               _selectedCity?.name ?? '',
//             );
//           },
//           isMobile: widget.isMobile,
//         ),
//       ],
//     );
//   }
// }

// class _TextField extends StatelessWidget {
//   final String label;
//   final String value;
//   final ValueChanged<String> onChanged;
//   final bool isMobile;

//   const _TextField({
//     required this.label,
//     required this.value,
//     required this.onChanged,
//     required this.isMobile,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     return TextFormField(
//       initialValue: value,
//       onChanged: onChanged,
//       style: TextStyle(fontSize: isMobile ? 14 : null),
//       decoration: InputDecoration(
//         labelText: label,
//         labelStyle: TextStyle(fontSize: isMobile ? 13 : null),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(color: theme.colorScheme.outline),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(
//             color: theme.colorScheme.outline.withValues(alpha: 0.5),
//           ),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
//         ),
//         errorBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: BorderSide(color: theme.colorScheme.error),
//         ),
//         filled: true,
//         fillColor: theme.colorScheme.surface,
//         contentPadding: EdgeInsets.symmetric(
//           horizontal: isMobile ? 12 : 16,
//           vertical: isMobile ? 12 : 16,
//         ),
//       ),
//     );
//   }
// }

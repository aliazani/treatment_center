import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:treatment_center/features/geolocation/domain/entities/city_entity.dart';
import 'package:treatment_center/features/geolocation/domain/entities/country_entity.dart';
import 'package:treatment_center/features/geolocation/domain/entities/region_entity.dart';
import 'package:treatment_center/features/geolocation/domain/usecases/get_countries.dart';
import 'package:treatment_center/features/geolocation/domain/usecases/get_regions_by_country.dart';
import 'package:treatment_center/features/geolocation/domain/usecases/get_cities_by_region.dart';
import 'package:treatment_center/features/geolocation/presentation/widgets/geographic_dropdowns_widget.dart';
import 'package:treatment_center/features/questionnaire_form/domain/usecases/usecase.dart';

import 'geographic_cascade_event.dart';
import 'geographic_cascade_state.dart';

class GeographicCascadeBloc
    extends Bloc<GeographicCascadeEvent, GeographicCascadeState> {
  final GetCountries getCountries;
  final GetRegionsByCountry getRegionsByCountry;
  final GetCitiesByRegion getCitiesByRegion;

  GeographicCascadeBloc(
    this.getCountries,
    this.getRegionsByCountry,
    this.getCitiesByRegion,
  ) : super(const GeographicCascadeState()) {
    // Public events
    on<InitializeGeographicCascade>(_onInitialize);
    on<SelectCountry>(_onSelectCountry);
    on<SelectRegion>(_onSelectRegion);
    on<SelectCity>(_onSelectCity);
    on<ResetGeographicCascade>(_onReset);

    // Internal events
    on<LoadCountries>(_onLoadCountries);
    on<LoadRegions>(_onLoadRegions);
    on<LoadCities>(_onLoadCities);
  }

  /// Initialize the cascade and optionally hydrate from saved values
  Future<void> _onInitialize(
    InitializeGeographicCascade event,
    Emitter<GeographicCascadeState> emit,
  ) async {
    // Set hydration targets and start the process
    emit(
      state.copyWith(
        hydrationStatus: HydrationStatus.hydrating,
        targetCountryName: event.savedCountryName,
        targetRegionName: event.savedRegionName,
        targetCityName: event.savedCityName,
        clearHydrationError: true,
      ),
    );

    // Load countries first
    add(const LoadCountries());
  }

  /// Load all countries
  Future<void> _onLoadCountries(
    LoadCountries event,
    Emitter<GeographicCascadeState> emit,
  ) async {
    emit(state.copyWith(loadingCountries: true, clearCountriesError: true));

    final result = await getCountries(NoParams());

    await result.match(
      (failure) async {
        emit(
          state.copyWith(
            loadingCountries: false,
            countriesError: 'Failed to load countries',
            hydrationStatus: HydrationStatus.failed,
            hydrationError: 'Could not load countries',
          ),
        );
      },
      (countries) async {
        emit(
          state.copyWith(
            loadingCountries: false,
            countries: countries,
            clearCountriesError: true,
          ),
        );

        // Try to hydrate country if we have a target
        if (state.targetCountryName != null &&
            state.targetCountryName!.isNotEmpty) {
          await _hydrateCountry(countries, emit);
        } else {
          // No hydration needed, mark as complete
          emit(
            state.copyWith(
              hydrationStatus: HydrationStatus.completed,
              clearTargets: true,
            ),
          );
        }
      },
    );
  }

  /// Find and select country by name, then continue hydration
  Future<void> _hydrateCountry(
    List<CountryEntity> countries,
    Emitter<GeographicCascadeState> emit,
  ) async {
    final targetName = state.targetCountryName!.trim().toLowerCase();

    final matchingCountry = countries.cast<CountryEntity?>().firstWhere(
      (country) =>
          country != null && country.name.trim().toLowerCase() == targetName,
      orElse: () => null,
    );

    if (matchingCountry == null) {
      emit(
        state.copyWith(
          hydrationStatus: HydrationStatus.failed,
          hydrationError: 'Country "${state.targetCountryName}" not found',
        ),
      );
      return;
    }

    // Select the country
    emit(
      state.copyWith(
        selection: state.selection.copyWith(country: matchingCountry),
      ),
    );

    // Load regions for this country
    add(LoadRegions(matchingCountry));
  }

  /// Load regions for the selected country
  Future<void> _onLoadRegions(
    LoadRegions event,
    Emitter<GeographicCascadeState> emit,
  ) async {
    emit(
      state.copyWith(
        loadingRegions: true,
        clearRegionsError: true,
        regions: const [], // Clear previous regions
      ),
    );

    final result = await getRegionsByCountry(
      RegionsByCountryParams(countryCode: event.country.iso2),
    );

    await result.match(
      (failure) async {
        emit(
          state.copyWith(
            loadingRegions: false,
            regionsError: 'Failed to load regions',
            hydrationStatus: HydrationStatus.failed,
            hydrationError: 'Could not load regions for ${event.country.name}',
          ),
        );
      },
      (regions) async {
        emit(
          state.copyWith(
            loadingRegions: false,
            regions: regions,
            clearRegionsError: true,
          ),
        );

        // Try to hydrate region if we have a target
        if (state.targetRegionName != null &&
            state.targetRegionName!.isNotEmpty) {
          await _hydrateRegion(regions, emit);
        } else {
          if (state.hydrationStatus == HydrationStatus.hydrating) {
            emit(
              state.copyWith(
                hydrationStatus: HydrationStatus.completed,
                clearTargets: true,
              ),
            );
          }
        }
      },
    );
  }

  /// Find and select region by name, then continue hydration
  Future<void> _hydrateRegion(
    List<RegionEntity> regions,
    Emitter<GeographicCascadeState> emit,
  ) async {
    final targetName = state.targetRegionName!.trim().toLowerCase();

    final matchingRegion = regions.cast<RegionEntity?>().firstWhere(
      (region) =>
          region != null && region.name.trim().toLowerCase() == targetName,
      orElse: () => null,
    );

    if (matchingRegion == null) {
      emit(
        state.copyWith(
          hydrationStatus: HydrationStatus.failed,
          hydrationError: 'Region "${state.targetRegionName}" not found',
        ),
      );
      return;
    }

    // Select the region
    emit(
      state.copyWith(
        selection: state.selection.copyWith(state: matchingRegion),
      ),
    );

    // Load cities for this region
    add(LoadCities(matchingRegion));
  }

  /// Load cities for the selected region
  Future<void> _onLoadCities(
    LoadCities event,
    Emitter<GeographicCascadeState> emit,
  ) async {
    emit(
      state.copyWith(
        loadingCities: true,
        clearCitiesError: true,
        cities: const [], // Clear previous cities
      ),
    );

    final result = await getCitiesByRegion(
      CitiesByStateParams(stateCode: event.region.stateCode),
    );

    await result.match(
      (failure) async {
        emit(
          state.copyWith(
            loadingCities: false,
            citiesError: 'Failed to load cities',
            hydrationStatus: HydrationStatus.failed,
            hydrationError: 'Could not load cities for ${event.region.name}',
          ),
        );
      },
      (cities) async {
        emit(
          state.copyWith(
            loadingCities: false,
            cities: cities,
            clearCitiesError: true,
          ),
        );

        // Try to hydrate city if we have a target
        if (state.targetCityName != null && state.targetCityName!.isNotEmpty) {
          await _hydrateCity(cities, emit);
        } else {
          if (state.hydrationStatus == HydrationStatus.hydrating) {
            emit(
              state.copyWith(
                hydrationStatus: HydrationStatus.completed,
                clearTargets: true,
              ),
            );
          }
        }
      },
    );
  }

  /// Find and select city by name, then complete hydration
  Future<void> _hydrateCity(
    List<CityEntity> cities,
    Emitter<GeographicCascadeState> emit,
  ) async {
    final targetName = state.targetCityName!.trim().toLowerCase();

    final matchingCity = cities.cast<CityEntity?>().firstWhere(
      (city) => city != null && city.name.trim().toLowerCase() == targetName,
      orElse: () => null,
    );

    if (matchingCity == null) {
      emit(
        state.copyWith(
          hydrationStatus: HydrationStatus.failed,
          hydrationError: 'City "${state.targetCityName}" not found',
        ),
      );
      return;
    }

    // Select the city and mark hydration as complete
    emit(
      state.copyWith(
        selection: state.selection.copyWith(city: matchingCity),
        hydrationStatus: HydrationStatus.completed,
        clearTargets: true,
      ),
    );
  }

  /// User manually selects a country
  Future<void> _onSelectCountry(
    SelectCountry event,
    Emitter<GeographicCascadeState> emit,
  ) async {
    if (event.country == null) {
      // Clear everything
      emit(
        state.copyWith(
          selection: const GeographicSelection(),
          regions: const [],
          cities: const [],
          clearRegionsError: true,
          clearCitiesError: true,
          hydrationStatus: HydrationStatus.idle,
          clearTargets: true,
        ),
      );
      return;
    }

    // Update selection and clear dependent data
    emit(
      state.copyWith(
        selection: GeographicSelection(country: event.country),
        regions: const [],
        cities: const [],
        clearRegionsError: true,
        clearCitiesError: true,
        hydrationStatus: HydrationStatus.idle,
        clearTargets: true,
      ),
    );

    // Load regions for the selected country
    add(LoadRegions(event.country!));
  }

  /// User manually selects a region
  Future<void> _onSelectRegion(
    SelectRegion event,
    Emitter<GeographicCascadeState> emit,
  ) async {
    if (event.region == null) {
      emit(
        state.copyWith(
          selection: GeographicSelection(
            country: state.selection.country, // Keep country
            state: null, // Clear region
            city: null, // Clear city
          ),
          cities: const [],
          clearCitiesError: true,
          hydrationStatus: HydrationStatus.idle,
        ),
      );
      return;
    }

    // Update selection and clear cities
    emit(
      state.copyWith(
        selection: state.selection.copyWith(state: event.region, city: null),
        cities: const [],
        clearCitiesError: true,
      ),
    );

    // Load cities for the selected region
    add(LoadCities(event.region!));
  }

  /// User manually selects a city
  Future<void> _onSelectCity(
    SelectCity event,
    Emitter<GeographicCascadeState> emit,
  ) async {
    emit(state.copyWith(selection: state.selection.copyWith(city: event.city)));
  }

  /// Reset the entire cascade
  Future<void> _onReset(
    ResetGeographicCascade event,
    Emitter<GeographicCascadeState> emit,
  ) async {
    emit(const GeographicCascadeState());
  }
}

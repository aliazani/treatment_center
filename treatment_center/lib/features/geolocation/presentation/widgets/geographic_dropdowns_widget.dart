import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:treatment_center/features/geolocation/domain/entities/city_entity.dart';
import 'package:treatment_center/features/geolocation/domain/entities/country_entity.dart';
import 'package:treatment_center/features/geolocation/domain/entities/region_entity.dart';
import 'package:treatment_center/features/geolocation/presentation/bloc/geographic_cascade/geographic_cascade_bloc.dart';
import 'package:treatment_center/features/geolocation/presentation/bloc/geographic_cascade/geographic_cascade_event.dart';
import 'package:treatment_center/features/geolocation/presentation/bloc/geographic_cascade/geographic_cascade_state.dart';
import 'package:treatment_center/features/questionnaire_form/presentation/breakpoints.dart';

class GeographicSelection {
  final CountryEntity? country;
  final RegionEntity? state;
  final CityEntity? city;

  const GeographicSelection({this.country, this.state, this.city});

  GeographicSelection copyWith({
    CountryEntity? country,
    RegionEntity? state,
    CityEntity? city,
  }) {
    return GeographicSelection(
      country: country ?? this.country,
      state: state ?? this.state,
      city: city ?? this.city,
    );
  }

  @override
  String toString() =>
      'Country: ${country?.name}, State: ${state?.name}, City: ${city?.name}';
}

typedef OnGeographicSelectionChanged = void Function(GeographicSelection);

class GeographicCascadeDropdown extends StatefulWidget {
  const GeographicCascadeDropdown({
    super.key,
    required this.onSelectionChanged,
    this.initialSelection,

    // For hydration from saved string values
    this.savedCountryName,
    this.savedRegionName,
    this.savedCityName,

    // UI customization
    this.showCountry = true,
    this.showState = true,
    this.showCity = true,
    this.countryHint = 'Country',
    this.stateHint = 'State/Region',
    this.cityHint = 'City',
    this.padding,
    this.enabled = true,
  });

  final OnGeographicSelectionChanged onSelectionChanged;
  final GeographicSelection? initialSelection;

  // For hydration (much simpler now!)
  final String? savedCountryName;
  final String? savedRegionName;
  final String? savedCityName;

  // UI options
  final bool showCountry;
  final bool showState;
  final bool showCity;
  final String? countryHint;
  final String? stateHint;
  final String? cityHint;
  final EdgeInsetsGeometry? padding;
  final bool enabled;

  @override
  State<GeographicCascadeDropdown> createState() =>
      _GeographicCascadeDropdownState();
}

class _GeographicCascadeDropdownState extends State<GeographicCascadeDropdown> {
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initializeIfNeeded();
  }

  void _initializeIfNeeded() {
    if (!_initialized) {
      context.read<GeographicCascadeBloc>().add(
        InitializeGeographicCascade(
          savedCountryName: widget.savedCountryName,
          savedRegionName: widget.savedRegionName,
          savedCityName: widget.savedCityName,
        ),
      );
      _initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = AdaptiveBreakpoints.isMobile(constraints.maxWidth);

        return Padding(
          padding: widget.padding ?? EdgeInsets.zero,
          child: BlocConsumer<GeographicCascadeBloc, GeographicCascadeState>(
            listenWhen: (prev, curr) => prev.selection != curr.selection,
            listener: (context, state) {
              // Notify parent of selection changes
              widget.onSelectionChanged(state.selection);
            },
            builder: (context, state) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (state.isHydrating) ...[
                    _HydrationIndicator(isMobile: isMobile),
                    SizedBox(height: isMobile ? 8 : 12),
                  ],

                  if (state.hasHydrationFailed) ...[
                    _ErrorIndicator(
                      error: state.hydrationError ?? 'Hydration failed',
                      isMobile: isMobile,
                    ),
                    SizedBox(height: isMobile ? 8 : 12),
                  ],
                  if (widget.showCountry) ...[
                    _PickerButton(
                      isMobile: isMobile,
                      hint: widget.countryHint ?? 'Country',
                      enabled: widget.enabled && !state.loadingCountries,
                      isLoading: state.loadingCountries,
                      valueText: state.selection.country?.name,
                      leading:
                          state.selection.country != null
                              ? Text(
                                state.selection.country!.emoji,
                                style: TextStyle(fontSize: isMobile ? 16 : 18),
                              )
                              : Icon(Icons.public, size: isMobile ? 18 : 20),
                      errorText: state.countriesError,
                      onTap: () async {
                        final picked =
                            await _SearchPickDialog.show<CountryEntity>(
                              context: context,
                              title: 'Country',
                              items: state.countries,
                              selected: state.selection.country,
                              display: (c) => c.name,
                              leading:
                                  (c) => Text(
                                    c.emoji,
                                    style: const TextStyle(fontSize: 18),
                                  ),
                            );
                        if (!context.mounted) return;

                        context.read<GeographicCascadeBloc>().add(
                          SelectCountry(picked),
                        );
                      },
                    ),
                    SizedBox(height: isMobile ? 12 : 16),
                  ],

                  if (widget.showState) ...[
                    _PickerButton(
                      isMobile: isMobile,
                      hint: widget.stateHint ?? 'State/Region',
                      enabled:
                          widget.enabled &&
                          state.selection.country != null &&
                          !state.loadingRegions,
                      isLoading: state.loadingRegions,
                      valueText: state.selection.state?.name,
                      leading: Icon(
                        Icons.location_city,
                        size: isMobile ? 16 : 18,
                      ),
                      errorText: state.regionsError,
                      onTap: () async {
                        final picked =
                            await _SearchPickDialog.show<RegionEntity>(
                              context: context,
                              title: 'State/Region',
                              items: state.regions,
                              selected: state.selection.state,
                              display: (r) => r.name,
                            );
                        if (!context.mounted) return;
                        context.read<GeographicCascadeBloc>().add(
                          SelectRegion(picked),
                        );
                      },
                    ),
                    SizedBox(height: isMobile ? 12 : 16),
                  ],

                  if (widget.showCity) ...[
                    _PickerButton(
                      isMobile: isMobile,
                      hint: widget.cityHint ?? 'City',
                      enabled:
                          widget.enabled &&
                          state.selection.state != null &&
                          !state.loadingCities,
                      isLoading: state.loadingCities,
                      valueText: state.selection.city?.name,
                      leading: Icon(
                        Icons.location_city,
                        size: isMobile ? 16 : 18,
                      ),

                      errorText: state.citiesError,
                      onTap: () async {
                        final picked = await _SearchPickDialog.show<CityEntity>(
                          context: context,
                          title: 'City',
                          items: state.cities,
                          selected: state.selection.city,
                          display: (c) => c.name,
                        );
                        if (!context.mounted) return;
                        context.read<GeographicCascadeBloc>().add(
                          SelectCity(picked),
                        );
                      },
                    ),
                  ],
                ],
              );
            },
          ),
        );
      },
    );
  }
}

/// Shows hydration progress (optional)
class _HydrationIndicator extends StatelessWidget {
  final bool isMobile;

  const _HydrationIndicator({required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 16,
        vertical: isMobile ? 8 : 12,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: isMobile ? 16 : 20,
            height: isMobile ? 16 : 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: theme.colorScheme.primary,
            ),
          ),
          SizedBox(width: isMobile ? 8 : 12),
          Text(
            'Loading saved location...',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
              fontSize: isMobile ? 12 : null,
            ),
          ),
        ],
      ),
    );
  }
}

/// Shows hydration errors
class _ErrorIndicator extends StatelessWidget {
  final String error;
  final bool isMobile;

  const _ErrorIndicator({required this.error, required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 12 : 16,
        vertical: isMobile ? 8 : 12,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: theme.colorScheme.error.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            size: isMobile ? 16 : 20,
            color: theme.colorScheme.onErrorContainer,
          ),
          SizedBox(width: isMobile ? 8 : 12),
          Expanded(
            child: Text(
              error,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onErrorContainer,
                fontSize: isMobile ? 12 : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PickerButton extends StatelessWidget {
  const _PickerButton({
    required this.hint,
    required this.enabled,
    required this.isLoading,
    required this.onTap,
    this.valueText,
    this.leading,
    this.errorText,
    required this.isMobile,
  });

  final String hint;
  final bool enabled;
  final bool isLoading;
  final VoidCallback onTap;
  final String? valueText;
  final Widget? leading;
  final String? errorText;
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasValue = (valueText != null && valueText!.isNotEmpty);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: enabled && !isLoading ? onTap : null,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: theme.colorScheme.surface,
              border: Border.all(
                color:
                    (errorText != null)
                        ? theme.colorScheme.error
                        : theme.colorScheme.outline.withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              children: [
                if (leading != null) ...[leading!, const SizedBox(width: 8)],
                Expanded(
                  child:
                      isLoading
                          ? Align(
                            alignment: Alignment.centerLeft,
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                          : Text(
                            hasValue ? valueText! : hint,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color:
                                  hasValue
                                      ? theme.colorScheme.onSurface
                                      : theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.keyboard_arrow_down,
                  color: theme.colorScheme.onSurfaceVariant,
                  size: isMobile ? 18 : 20,
                ),
              ],
            ),
          ),
        ),
        if (errorText != null) ...[
          const SizedBox(height: 6),
          Text(
            errorText!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ],
      ],
    );
  }
}

class _SearchPickDialog<T> extends StatefulWidget {
  const _SearchPickDialog({
    required this.title,
    required this.items,
    required this.display,
    this.selected,
    this.leading,
  });

  final String title;
  final List<T> items;
  final T? selected;
  final String Function(T) display;
  final Widget Function(T)? leading;

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required List<T> items,
    required String Function(T) display,
    T? selected,
    Widget Function(T)? leading,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: true,
      builder:
          (_) => Dialog(
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 24,
            ),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(16)),
            ),
            child: _SearchPickDialog<T>(
              title: title,
              items: items,
              selected: selected,
              display: display,
              leading: leading,
            ),
          ),
    );
  }

  @override
  State<_SearchPickDialog<T>> createState() => _SearchPickDialogState<T>();
}

class _SearchPickDialogState<T> extends State<_SearchPickDialog<T>> {
  final _search = TextEditingController();
  late List<T> _filtered;

  @override
  void initState() {
    super.initState();
    _filtered = widget.items;
    _search.addListener(() {
      final q = _search.text.trim().toLowerCase();
      setState(() {
        _filtered =
            q.isEmpty
                ? widget.items
                : widget.items
                    .where((e) => widget.display(e).toLowerCase().contains(q))
                    .toList();
      });
    });
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final dialogWidth =
        (screenWidth > 720) ? 780.0 : (screenWidth - 32).clamp(320.0, 560.0);
    final dialogHeight = (screenWidth > 720) ? 520.0 : 560.0;

    return SizedBox(
      width: dialogWidth,
      height: dialogHeight,
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
          ),
          // Search
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _search,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: theme.colorScheme.surface,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // List
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child:
                  _filtered.isEmpty
                      ? Center(
                        child: Text(
                          'No results',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      )
                      : ListView.separated(
                        itemCount: _filtered.length,
                        separatorBuilder:
                            (_, _) => Divider(
                              height: 1,
                              color: theme.colorScheme.outline.withValues(
                                alpha: 0.15,
                              ),
                            ),
                        itemBuilder: (_, i) {
                          final item = _filtered[i];
                          final isSel = widget.selected == item;
                          return ListTile(
                            dense: true,
                            leading: widget.leading?.call(item),
                            title: Text(
                              widget.display(item),
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing:
                                isSel
                                    ? Icon(
                                      Icons.check_circle,
                                      color: theme.colorScheme.primary,
                                    )
                                    : null,
                            selected: isSel,
                            selectedTileColor: theme
                                .colorScheme
                                .primaryContainer
                                .withValues(alpha: 0.3),
                            onTap: () => Navigator.of(context).pop<T>(item),
                          );
                        },
                      ),
            ),
          ),
          // Footer
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop<T>(null),
                child: const Text('Cancel'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

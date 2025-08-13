import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SimpleMapPicker extends StatefulWidget {
  const SimpleMapPicker({
    super.key,
    required this.onPicked,
    this.initialPosition,
  });

  final void Function(LatLng pos, String addr) onPicked;
  final LatLng? initialPosition;

  @override
  State<SimpleMapPicker> createState() => _SimpleMapPickerState();
}

class _SimpleMapPickerState extends State<SimpleMapPicker> {
  // Use the preferred URL (no sub-domains) – see OSM operations #737
  static const _tiles = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
  final _mapCtrl = MapController();
  bool _mapReady = false;

  LatLng? _marker;
  String? _ua;

  @override
  void initState() {
    super.initState();
    _loadUserAgent();
    _initStart();
  }

  Future<void> _loadUserAgent() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _ua = '${info.packageName}/${info.version}+${info.buildNumber}';
    });
  }

  //  UI
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapCtrl,
          options: MapOptions(
            initialCenter: _marker ?? const LatLng(0, 0),
            initialZoom: 4,
            onTap: (_, p) => _place(p, reverseGeocode: true),
            onMapReady: () {
              _mapReady = true;
              if (_marker != null) {
                _mapCtrl.move(_marker!, 15);
              }
            },
          ),
          children: [
            // subdomains removed – OSM now handles connection concurrency
            TileLayer(
              urlTemplate: _tiles,
              // provide a compliant User-Agent for OSM tile servers
              userAgentPackageName: _ua ?? 'com.example.myapp',
            ),
            if (_marker != null)
              MarkerLayer(
                markers: [
                  Marker(
                    point: _marker!,
                    width: 40,
                    height: 40,
                    child: const Icon(Icons.place, color: Colors.red, size: 40),
                  ),
                ],
              ),
          ],
        ),

        // --- floating buttons --------------------------------------------
        Positioned(
          bottom: 12,
          right: 12,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FloatingActionButton.small(
                heroTag: 'locate',
                tooltip: 'Locate me',
                onPressed: _locateMe,
                child: const Icon(Icons.my_location),
              ),
              const SizedBox(height: 12),
              FloatingActionButton.extended(
                heroTag: 'search',
                label: const Text('Search'),
                icon: const Icon(Icons.search),
                onPressed: _openSearchDialog,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  Init helpers
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> _initStart() async {
    var start = widget.initialPosition ?? const LatLng(0, 0);

    if (widget.initialPosition == null) {
      final perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.always ||
          perm == LocationPermission.whileInUse) {
        final pos = await Geolocator.getCurrentPosition();
        start = LatLng(pos.latitude, pos.longitude);
      }
    }
    _place(start);
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  Map helpers
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> _place(
    LatLng p, {
    String? addr, // ← new

    bool reverseGeocode = false,
  }) async {
    setState(() => _marker = p);
    if (_mapReady) _mapCtrl.move(p, 15); // ✅ safe

    String addr =
        '${p.latitude.toStringAsFixed(5)}, ${p.longitude.toStringAsFixed(5)}';

    if (reverseGeocode) {
      addr = await _reverse(p) ?? addr;
    }

    // ✅ fire AFTER the current build/frame is finished
    if (mounted) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onPicked(p, addr);
      });
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  FAB actions
  // ─────────────────────────────────────────────────────────────────────────
  Future<void> _locateMe() async {
    final perm = await Geolocator.requestPermission();
    if (perm != LocationPermission.always &&
        perm != LocationPermission.whileInUse) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission denied')),
        );
      }
      return;
    }
    final pos = await Geolocator.getCurrentPosition();
    _place(LatLng(pos.latitude, pos.longitude), reverseGeocode: true);
  }

  Future<void> _openSearchDialog() async {
    final result = await showDialog<_SearchResult>(
      context: context,
      builder: (_) => const _SearchDialog(),
    );
    if (result != null) {
      _place(result.latLng, addr: result.displayName);
    }
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  Nominatim helpers
  // ─────────────────────────────────────────────────────────────────────────
  Future<String?> _reverse(LatLng p) async {
    final uri = Uri.https('nominatim.openstreetmap.org', '/reverse', {
      'lat': '${p.latitude}',
      'lon': '${p.longitude}',
      'format': 'jsonv2',
    });
    final res = await http.get(
      uri,
      headers: {'User-Agent': 'flutter_map_picker/1.0'},
    );
    if (res.statusCode != 200) return null;
    return (jsonDecode(res.body) as Map)['display_name'] as String?;
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// Search dialog  (private)
// ═══════════════════════════════════════════════════════════════════════════
class _SearchDialog extends StatefulWidget {
  const _SearchDialog();

  @override
  State<_SearchDialog> createState() => _SearchDialogState();
}

class _SearchDialogState extends State<_SearchDialog> {
  final _queryCtrl = TextEditingController();
  Timer? _debounce;
  bool _loading = false;
  List<_SearchResult> _results = [];

  @override
  void dispose() {
    _debounce?.cancel();
    _queryCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Search address'),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _queryCtrl,
              decoration: const InputDecoration(hintText: 'Start typing…'),
              onChanged: _onQueryChanged,
            ),
            const SizedBox(height: 12),
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(12),
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else if (_results.isEmpty)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text('No results', style: theme.textTheme.bodySmall),
              )
            else
              SizedBox(
                height: 250,
                child: ListView.separated(
                  itemCount: _results.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (_, i) {
                    final r = _results[i];
                    return ListTile(
                      dense: true,
                      title: Text(
                        r.displayName,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () => Navigator.of(context).pop(r),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('CLOSE'),
        ),
      ],
    );
  }

  void _onQueryChanged(String q) {
    _debounce?.cancel();
    if (q.trim().length < 3) return;

    _debounce = Timer(const Duration(milliseconds: 400), () async {
      setState(() {
        _loading = true;
        _results = [];
      });
      final res = await _search(q);
      if (!mounted) return;
      setState(() {
        _results = res;
        _loading = false;
      });
    });
  }

  Future<List<_SearchResult>> _search(String q) async {
    final uri = Uri.https(
      'nominatim.openstreetmap.org',
      '/search',
      <String, String>{
        'format': 'jsonv2',
        'addressdetails': '0',
        'limit': '10',
        'q': q,
      },
    );

    final res = await http.get(
      uri,
      headers: {'User-Agent': 'flutter_map_picker/1.0'},
    );

    if (res.statusCode != 200) return const [];

    final list = jsonDecode(res.body) as List;
    return list
        .map(
          (e) => _SearchResult(
            displayName: e['display_name'] as String,
            latLng: LatLng(
              double.parse(e['lat'] as String),
              double.parse(e['lon'] as String),
            ),
          ),
        )
        .toList();
  }
}

// tiny value object only used inside this file
class _SearchResult {
  const _SearchResult({required this.displayName, required this.latLng});
  final String displayName;
  final LatLng latLng;
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';

typedef AutoSuggestSearchFunction<T> = List<T> Function(String query);
typedef AutoSuggestAsyncSearchFunction<T> =
    Future<List<T>> Function(String query);
typedef AutoSuggestDisplayFunction<T> = String Function(T item);
typedef AutoSuggestOnSelected<T> = void Function(T? item);
typedef AutoSuggestItemBuilder<T> =
    Widget Function(BuildContext context, T item, bool isSelected);

class AutoSuggestDropdown<T> extends StatefulWidget {
  final List<T> items;
  final AutoSuggestDisplayFunction<T> displayFunction;
  final AutoSuggestOnSelected<T> onSelected;
  final String? hintText;
  final String? labelText;
  final T? initialValue;
  final bool enabled;
  final String? errorText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int maxSuggestions;
  final Duration searchDelay;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final EdgeInsetsGeometry? contentPadding;
  final InputBorder? border;
  final bool isLoading;
  final Widget? loadingWidget;
  final Widget? emptyWidget;

  /// Existing sync search hook (kept for backwards-compat).
  final AutoSuggestSearchFunction<T>? customSearchFunction;

  /// New: optional async search. If provided, it is preferred over the sync search.
  final AutoSuggestAsyncSearchFunction<T>? asyncSearch;

  /// Optional custom row builder.
  final AutoSuggestItemBuilder<T>? suggestionBuilder;

  /// Style tweak flag (kept).
  final bool isMobile;

  const AutoSuggestDropdown({
    super.key,
    required this.items,
    required this.displayFunction,
    required this.onSelected,
    this.hintText,
    this.labelText,
    this.initialValue,
    this.enabled = true,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.maxSuggestions = 5,
    this.searchDelay = const Duration(milliseconds: 250),
    this.controller,
    this.focusNode,
    this.contentPadding,
    this.border,
    this.isLoading = false,
    this.loadingWidget,
    this.emptyWidget,
    this.customSearchFunction,
    this.asyncSearch,
    this.suggestionBuilder,
    this.isMobile = false,
  });

  @override
  State<AutoSuggestDropdown<T>> createState() => _AutoSuggestDropdownState<T>();
}

class _AutoSuggestDropdownState<T> extends State<AutoSuggestDropdown<T>> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  final LayerLink _layerLink = LayerLink();

  OverlayEntry? _overlayEntry;
  bool _isOpen = false;
  List<T> _filtered = <T>[];
  T? _selected;
  int _highlightIndex = -1;

  Timer? _debounce;
  int _searchToken = 0; // for async search cancellation

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _focusNode = widget.focusNode ?? FocusNode();

    HardwareKeyboard.instance.addHandler(_handleKeyEvent);

    _selected = widget.initialValue;
    if (_selected != null) {
      _controller.text = widget.displayFunction(_selected as T);
    }

    _focusNode.addListener(_onFocusChanged);
    _controller.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(covariant AutoSuggestDropdown<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Items changed -> re-filter against current query
    if (oldWidget.items != widget.items) {
      _refilter();
    }

    // Pull-to-refresh initialValue - FIX: Use post-frame callback
    if (oldWidget.initialValue != widget.initialValue) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _selected = widget.initialValue;
          if (_selected != null) {
            _controller.text = widget.displayFunction(_selected as T);
          } else {
            _controller.clear();
          }
          _refilter();
        }
      });
    }
  }

  @override
  void dispose() {
    _closeOverlay();
    _debounce?.cancel();
    HardwareKeyboard.instance.removeHandler(_handleKeyEvent);

    if (widget.controller == null) _controller.dispose();
    if (widget.focusNode == null) _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    if (!mounted) return;
    if (_focusNode.hasFocus && widget.enabled && !widget.isLoading) {
      _openOverlay();
    } else {
      _closeOverlay();
    }
  }

  void _onTextChanged() {
    if (_selected != null &&
        widget.displayFunction(_selected as T) != _controller.text) {
      // selection is no longer valid, but don't spam parent with null yet
      _selected = null;
    }
    _scheduleSearch();
  }

  void _scheduleSearch() {
    _debounce?.cancel();
    _debounce = Timer(widget.searchDelay, _refilter);
  }

  Future<void> _refilter() async {
    if (!mounted) return;

    final q = _controller.text.trim().toLowerCase();
    // Early list if empty query
    if (q.isEmpty &&
        widget.asyncSearch == null &&
        widget.customSearchFunction == null) {
      setState(() {
        _filtered = widget.items.take(widget.maxSuggestions).toList();
        _highlightIndex = _filtered.isEmpty ? -1 : 0;
      });
      _overlayEntry?.markNeedsBuild();
      return;
    }

    final currentToken = ++_searchToken;

    // Prefer asyncSearch if provided
    if (widget.asyncSearch != null) {
      try {
        final results = await widget.asyncSearch!(q);
        if (!mounted || currentToken != _searchToken) return; // stale result
        setState(() {
          _filtered = results.take(widget.maxSuggestions).toList();
          _highlightIndex = _filtered.isEmpty ? -1 : 0;
        });
      } catch (_) {
        // swallow; leave list as-is
      } finally {
        _overlayEntry?.markNeedsBuild();
      }
      return;
    }

    // Fallback to custom sync search or simple contains
    final List<T> results =
        (widget.customSearchFunction != null)
            ? widget.customSearchFunction!(q)
            : widget.items
                .where(
                  (e) => widget.displayFunction(e).toLowerCase().contains(q),
                )
                .toList();

    if (!mounted) return;
    setState(() {
      _filtered = results.take(widget.maxSuggestions).toList();
      _highlightIndex = _filtered.isEmpty ? -1 : 0;
    });
    _overlayEntry?.markNeedsBuild();
  }

  void _openOverlay() {
    if (_isOpen) return;
    _filtered = widget.items.take(widget.maxSuggestions).toList();
    _highlightIndex = _filtered.isEmpty ? -1 : 0;

    _overlayEntry = _buildOverlay();
    Overlay.of(context).insert(_overlayEntry!);

    setState(() => _isOpen = true);
  }

  void _closeOverlay() {
    if (!_isOpen) return;
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (mounted) setState(() => _isOpen = false);
  }

  void _select(T item) {
    _selected = item;
    _controller.text = widget.displayFunction(item);
    widget.onSelected(item);
    _focusNode.unfocus();
    _closeOverlay();
  }

  void _moveHighlight(int delta) {
    if (_filtered.isEmpty) return;
    setState(() {
      _highlightIndex = (_highlightIndex + delta) % _filtered.length;
      if (_highlightIndex < 0) _highlightIndex = _filtered.length - 1;
    });
    _overlayEntry?.markNeedsBuild();
  }

  OverlayEntry _buildOverlay() {
    final box = context.findRenderObject() as RenderBox;
    final size = box.size;
    final theme = Theme.of(context);

    return OverlayEntry(
      builder: (context) {
        return Positioned(
          width: size.width,
          child: CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: Offset(0, size.height + 6),
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.3),
                ),
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: widget.isMobile ? 200 : 240,
                ),
                child: _buildBody(theme),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(ThemeData theme) {
    if (widget.isLoading) return _loading(theme);
    if (_filtered.isEmpty) return _empty(theme);
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: _filtered.length,
      itemBuilder: (context, i) {
        final item = _filtered[i];
        final isSel = _selected == item || i == _highlightIndex;

        if (widget.suggestionBuilder != null) {
          // ✅ Removed InkWell to eliminate ripple animations
          return GestureDetector(
            onTap: () => _select(item),
            child: widget.suggestionBuilder!(context, item, isSel),
          );
        }

        // ✅ Replaced InkWell with GestureDetector to remove ripple
        return GestureDetector(
          onTap: () => _select(item),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: widget.isMobile ? 12 : 16,
              vertical: widget.isMobile ? 10 : 12,
            ),
            decoration: BoxDecoration(
              color:
                  isSel
                      ? theme.colorScheme.primaryContainer.withValues(
                        alpha: 0.3,
                      )
                      : null,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              widget.displayFunction(item),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: widget.isMobile ? 13 : 14,
                fontWeight: isSel ? FontWeight.w600 : FontWeight.normal,
                color:
                    isSel
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurface,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _loading(ThemeData theme) {
    return widget.loadingWidget ??
        Padding(
          padding: EdgeInsets.all(widget.isMobile ? 12 : 16),
          child: Center(
            child: SizedBox(
              width: widget.isMobile ? 16 : 20,
              height: widget.isMobile ? 16 : 20,
              // ✅ Replaced CircularProgressIndicator with static text
              child: Text(
                '...',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: widget.isMobile ? 14 : 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
  }

  Widget _empty(ThemeData theme) {
    return widget.emptyWidget ??
        Padding(
          padding: EdgeInsets.all(widget.isMobile ? 12 : 16),
          child: Text(
            'No items found',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: widget.isMobile ? 13 : null,
            ),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CompositedTransformTarget(
      link: _layerLink,
      child: TextFormField(
        controller: _controller,
        focusNode: _focusNode,
        enabled: widget.enabled && !widget.isLoading,
        style: TextStyle(fontSize: widget.isMobile ? 14 : null),
        decoration: InputDecoration(
          labelText: widget.labelText,
          hintText: widget.hintText,
          errorText: widget.errorText,
          labelStyle: TextStyle(fontSize: widget.isMobile ? 13 : null),
          hintStyle: TextStyle(fontSize: widget.isMobile ? 13 : null),
          border:
              widget.border ??
              OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: theme.colorScheme.surface,
          contentPadding:
              widget.contentPadding ??
              EdgeInsets.symmetric(
                horizontal: widget.isMobile ? 12 : 16,
                vertical: widget.isMobile ? 12 : 16,
              ),
          prefixIcon: widget.prefixIcon,
          suffixIcon:
              widget.suffixIcon ??
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.isLoading)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: SizedBox(
                        width: widget.isMobile ? 16 : 20,
                        height: widget.isMobile ? 16 : 20,
                        // ✅ Replaced CircularProgressIndicator with static text
                        child: Center(
                          child: Text(
                            '...',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontSize: widget.isMobile ? 10 : 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  Icon(
                    _isOpen
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: widget.isMobile ? 18 : 20,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                ],
              ),
        ),
        onTap: () {
          if (!_isOpen) _openOverlay();
        },
      ),
    );
  }

  bool _handleKeyEvent(KeyEvent event) {
    // Only handle key events when our dropdown is open and focused
    if (!_isOpen || !_focusNode.hasFocus) {
      return false; // Don't consume the event
    }

    // Only handle key down events
    if (event is! KeyDownEvent) return false;

    final key = event.logicalKey;

    if (key == LogicalKeyboardKey.arrowDown) {
      _moveHighlight(1);
      return true; // Consume the event
    } else if (key == LogicalKeyboardKey.arrowUp) {
      _moveHighlight(-1);
      return true; // Consume the event
    } else if (key == LogicalKeyboardKey.enter) {
      if (_highlightIndex >= 0 && _highlightIndex < _filtered.length) {
        _select(_filtered[_highlightIndex]);
      }
      return true; // Consume the event
    } else if (key == LogicalKeyboardKey.escape) {
      _closeOverlay();
      return true; // Consume the event
    }

    return false; // Don't consume other keys
  }
}

import 'package:flutter/material.dart';
import 'dart:async';

class CustomSearchBar extends StatefulWidget {
  final String hintText;
  final Future<List<SearchResult>> Function(String query) onSearch;
  final void Function(SearchResult result) onResultSelected;
  final void Function(String query)? onQueryChanged;
  final Widget Function(SearchResult result)? resultBuilder;
  final Duration debounceTime;
  final int maxResults;
  final bool showRecentSearches;
  final bool showOverlay;

  const CustomSearchBar({
    super.key,
    this.hintText = 'Buscar...',
    required this.onSearch,
    required this.onResultSelected,
    this.onQueryChanged,
    this.resultBuilder,
    this.debounceTime = const Duration(milliseconds: 300),
    this.maxResults = 10,
    this.showRecentSearches = true,
    this.showOverlay = true,
  });

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  Timer? _debounceTimer;
  List<SearchResult> _searchResults = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    _removeOverlay();
    _debounceTimer?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    if (!widget.showOverlay) return;
    
    if (_focusNode.hasFocus) {
      _showOverlay();
    } else {
      _hideOverlay();
    }
  }

  void _onQueryChanged(String query) {
    // Notificar cambio de query inmediatamente para filtrado en tiempo real
    widget.onQueryChanged?.call(query);
    
    _debounceTimer?.cancel();
    
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults.clear();
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    _debounceTimer = Timer(widget.debounceTime, () async {
      try {
        final results = await widget.onSearch(query);
        if (mounted) {
          setState(() {
            _searchResults = results.take(widget.maxResults).toList();
            _isLoading = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _searchResults.clear();
            _isLoading = false;
          });
        }
      }
    });
  }

  void _showOverlay() {
    if (_overlayEntry != null) return;
    
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _hideOverlay() {
    _removeOverlay();
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _createOverlayEntry() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return OverlayEntry(
      builder: (context) => Positioned(
        width: MediaQuery.of(context).size.width - 32,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, 52),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(12),
            color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 300),
              child: _buildResultsList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultsList() {
    if (_isLoading) {
      return Container(
        height: 60,
        alignment: Alignment.center,
        child: const CircularProgressIndicator(
          strokeWidth: 2,
        ),
      );
    }

    if (_searchResults.isEmpty) {
      return Container(
        height: 60,
        alignment: Alignment.center,
        child: Text(
          'No se encontraron resultados',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(8),
      shrinkWrap: true,
      itemCount: _searchResults.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final result = _searchResults[index];
        
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          leading: Icon(
            result.icon,
            color: const Color(0xFF007AFF),
            size: 20,
          ),
          title: Text(
            result.title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          subtitle: result.subtitle != null
              ? Text(
                  result.subtitle!,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                )
              : null,
          onTap: () {
            widget.onResultSelected(result);
            _controller.text = result.title;
            _hideOverlay();
            _focusNode.unfocus();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return CompositedTransformTarget(
      link: _layerLink,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2C2C2E) : const Color(0xFFF2F2F7),
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          controller: _controller,
          focusNode: _focusNode,
          onChanged: _onQueryChanged,
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: TextStyle(
              color: Colors.grey[500],
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: Icon(
              Icons.search,
              color: Colors.grey[500],
              size: 20,
            ),
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: Colors.grey[500],
                      size: 18,
                    ),
                    onPressed: () {
                      _controller.clear();
                      widget.onQueryChanged?.call('');
                      setState(() {
                        _searchResults.clear();
                      });
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class SearchResult {
  final String title;
  final String? subtitle;
  final IconData icon;
  final dynamic data;

  const SearchResult({
    required this.title,
    this.subtitle,
    this.icon = Icons.search,
    this.data,
  });
}
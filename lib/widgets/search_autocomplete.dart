import 'package:flutter/material.dart';
import '../theme.dart';

class SearchAutocomplete extends StatefulWidget {
  final List<String> allPlayers;
  final Function(String query) onSearch;
  final String initialValue;

  const SearchAutocomplete({
    Key? key,
    required this.allPlayers,
    required this.onSearch,
    this.initialValue = '',
  }) : super(key: key);

  @override
  State<SearchAutocomplete> createState() => _SearchAutocompleteState();
}

class _SearchAutocompleteState extends State<SearchAutocomplete> {
  late TextEditingController _searchController;
  final FocusNode _focusNode = FocusNode();
  bool _showDropdown = false;
  List<String> _filteredSuggestions = [];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialValue);
    _searchController.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void didUpdateWidget(covariant SearchAutocomplete oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue) {
      _searchController.text = widget.initialValue;
    }
  }

  @override
  void dispose() {
    _searchController.removeListener(_onTextChanged);
    _focusNode.removeListener(_onFocusChanged);
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) {
        setState(() {
          _showDropdown = _focusNode.hasFocus && _searchController.text.isNotEmpty;
        });
      }
    });
  }

  void _onTextChanged() {
    final query = _searchController.text.toLowerCase().trim();
    if (query.isEmpty) {
      setState(() {
        _filteredSuggestions = [];
        _showDropdown = false;
      });
      widget.onSearch('');
      return;
    }

    final matched = widget.allPlayers.where((player) {
      return player.toLowerCase().contains(query);
    }).toList();

    setState(() {
      _filteredSuggestions = matched;
      _showDropdown = _focusNode.hasFocus && _filteredSuggestions.isNotEmpty;
    });
  }

  void _selectSuggestion(String suggestion) {
    setState(() {
      _searchController.text = suggestion;
      _showDropdown = false;
      _focusNode.unfocus();
    });
    widget.onSearch(suggestion);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ShuttleTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(ShuttleTheme.radiusLarge),
        border: Border.all(color: ShuttleTheme.neonTeal.withOpacity(0.2), width: 1.2),
      ),
      padding: const EdgeInsets.all(ShuttleTheme.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: ShuttleTheme.background,
                    borderRadius: BorderRadius.circular(ShuttleTheme.radiusFull),
                    border: Border.all(
                      color: _focusNode.hasFocus
                          ? ShuttleTheme.neonTeal
                          : ShuttleTheme.neonTeal.withOpacity(0.3),
                      width: _focusNode.hasFocus ? 1.5 : 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10.0),
                        child: Icon(
                          Icons.search,
                          color: ShuttleTheme.neonTeal,
                          size: 20,
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          focusNode: _focusNode,
                          onSubmitted: (val) {
                            widget.onSearch(val);
                            _focusNode.unfocus();
                          },
                          style: ShuttleTheme.bodyMd.copyWith(color: ShuttleTheme.onBackground),
                          decoration: InputDecoration(
                            hintText: 'Search Player',
                            hintStyle: ShuttleTheme.bodyMd.copyWith(color: ShuttleTheme.onSurfaceVariant.withOpacity(0.5)),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: const EdgeInsets.only(right: 12.0),
                          ),
                        ),
                      ),
                      if (_searchController.text.isNotEmpty)
                        IconButton(
                          icon: const Icon(Icons.clear, size: 16, color: ShuttleTheme.neonPink),
                          onPressed: () {
                            _searchController.clear();
                            widget.onSearch('');
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          if (_showDropdown) ...[
            const SizedBox(height: 12),
            Material(
              elevation: 4.0,
              borderRadius: BorderRadius.circular(ShuttleTheme.radiusDefault),
              color: ShuttleTheme.surfaceContainerLow,
              shadowColor: Colors.black.withOpacity(0.3),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(ShuttleTheme.radiusDefault),
                  border: Border.all(color: ShuttleTheme.neonTeal.withOpacity(0.3), width: 1.0),
                ),
                constraints: const BoxConstraints(maxHeight: 180),
                clipBehavior: Clip.antiAlias,
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(ShuttleTheme.baseSpacing),
                  itemCount: _filteredSuggestions.length,
                  itemBuilder: (context, index) {
                    final suggestion = _filteredSuggestions[index];
                    final isKatSampleMatch = suggestion.toLowerCase() == 'kat' ||
                        _searchController.text.toLowerCase() == 'ka';

                    return InkWell(
                      onTap: () => _selectSuggestion(suggestion),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: ShuttleTheme.md,
                          vertical: 10,
                        ),
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(color: ShuttleTheme.background, width: 1.0),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              suggestion,
                              style: ShuttleTheme.bodyMd.copyWith(
                                color: ShuttleTheme.onBackground,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (isKatSampleMatch)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: ShuttleTheme.neonPink.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(ShuttleTheme.radiusSmall),
                                  border: Border.all(color: ShuttleTheme.neonPink.withOpacity(0.5)),
                                ),
                                child: Text(
                                  'MATCH',
                                  style: ShuttleTheme.labelCaps.copyWith(
                                    color: ShuttleTheme.neonPink,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

class TickPageSearchBar extends StatefulWidget {
  final Function(String) onSearch;
  final TextEditingController searchController;

  const TickPageSearchBar({super.key, required this.onSearch, required this.searchController});

  @override
  State<TickPageSearchBar> createState() => _TickPageSearchBarState();
}

class _TickPageSearchBarState extends State<TickPageSearchBar> {
  late final _searchController = widget.searchController;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: TextField(
        controller: _searchController,
        decoration: const InputDecoration(
          labelText: 'Search',
          prefixIcon: Icon(Icons.search),
        ),
        onChanged: (text) => widget.onSearch(text),
      ),
    );
  }
}
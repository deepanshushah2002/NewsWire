// lib/widgets/search_bar_widget.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/news_provider.dart';
import '../utils/theme.dart';

class SearchBarWidget extends StatefulWidget {
  const SearchBarWidget({super.key});

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final _controller = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      context.read<NewsProvider>().search(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Consumer<NewsProvider>(
        builder: (_, provider, __) {
          return TextField(
            controller: _controller,
            onChanged: _onSearchChanged,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 15,
            ),
            decoration: InputDecoration(
              hintText: 'Search headlines...',
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: AppTheme.textMuted,
                size: 20,
              ),
              suffixIcon: provider.isSearching
                  ? GestureDetector(
                      onTap: () {
                        _controller.clear();
                        provider.clearSearch();
                      },
                      child: const Icon(
                        Icons.close_rounded,
                        color: AppTheme.textMuted,
                        size: 20,
                      ),
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }
}

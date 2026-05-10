import 'package:arora/data/datasources/local/hive_database.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';

const _maxEntries = 50;

final searchHistoryProvider =
    NotifierProvider<SearchHistoryNotifier, List<String>>(
  SearchHistoryNotifier.new,
);

class SearchHistoryNotifier extends Notifier<List<String>> {
  Box<String> get _box => Hive.box<String>(HiveDatabase.searchHistoryBoxName);

  @override
  List<String> build() {
    try {
      return _box.values.toList().reversed.toList();
    } catch (_) {
      return [];
    }
  }

  void add(String query) {
    final q = query.trim();
    if (q.isEmpty) return;
    // Remove duplicate so it moves to top
    for (final key in _box.keys.toList()) {
      if (_box.get(key) == q) {
        _box.delete(key);
        break;
      }
    }
    _box.add(q);
    while (_box.length > _maxEntries) {
      _box.deleteAt(0);
    }
    state = _box.values.toList().reversed.toList();
  }

  void remove(String query) {
    for (final key in _box.keys.toList()) {
      if (_box.get(key) == query) {
        _box.delete(key);
        break;
      }
    }
    state = _box.values.toList().reversed.toList();
  }

  void clear() {
    _box.clear();
    state = [];
  }
}

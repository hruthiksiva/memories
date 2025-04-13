import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import '../database_helper.dart';

class Memory {
  final DateTime date;
  final AssetEntity photo;

  Memory({required this.date, required this.photo});
}

class MemoryProvider with ChangeNotifier {
  List<Memory> _memories = [];
  bool _isLoading = true;
  String _errorMessage = '';

  List<Memory> get memories => _memories;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  MemoryProvider() {
    loadMemories();
  }

  Future<void> loadMemories() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final memoriesData = await DatabaseHelper().getMemories();
      final memories = <Memory>[];
      for (var data in memoriesData) {
        final id = data['id'] as String;
        final asset = await AssetEntity.fromId(id);
        if (asset != null) {
          final date = DateTime.parse(data['swipe_date'] as String);
          memories.add(Memory(date: date, photo: asset));
        }
      }
      _memories = memories;
    } catch (e) {
      _errorMessage = 'Error loading memories: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void addMemory(Memory memory) {
    _memories.add(memory);
    DatabaseHelper().insertSwipedImage(memory.photo.id, 1, memory.date.toIso8601String());
    notifyListeners();
  }
  void refresh() {
    print('Refreshing memories: ${_memories.length}');
    notifyListeners();
  }
}
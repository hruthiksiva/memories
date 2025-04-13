import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class Memory {
  final DateTime date;
  final AssetEntity photo;

  Memory({required this.date, required this.photo});
}

class MemoryProvider with ChangeNotifier {
  List<Memory> _memories = [];

  List<Memory> get memories => _memories;

  void addMemory(Memory memory) {
    print('Adding memory for date: ${memory.date.toIso8601String()}');
    _memories.removeWhere((m) =>
        m.date.toIso8601String().substring(0, 10) ==
        memory.date.toIso8601String().substring(0, 10));
    _memories.add(memory);
    print('Total memories: ${_memories.length}');
    notifyListeners();
  }

  void clearMemories() {
    _memories.clear();
    notifyListeners();
  }

  void refresh() {
    print('Refreshing memories: ${_memories.length}');
    notifyListeners();
  }
}
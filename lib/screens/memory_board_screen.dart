import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/memory_provider.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'photo_view_screen.dart';
import 'dart:typed_data';

class MemoryBoardScreen extends StatefulWidget {
  const MemoryBoardScreen({super.key});

  @override
  State<MemoryBoardScreen> createState() => _MemoryBoardScreenState();
}

class _MemoryBoardScreenState extends State<MemoryBoardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _addTodayMemory() async {
    final cameraStatus = await Permission.camera.status;
    if (!cameraStatus.isGranted) {
      final result = await Permission.camera.request();
      if (!result.isGranted) {
        _showPermissionDeniedDialog('Camera');
        return;
      }
    }

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      final asset = await PhotoManager.editor.saveImage(
        await pickedFile.readAsBytes(),
        filename: 'memory_${DateTime.now().toIso8601String()}.jpg',
      );
      if (asset != null) {
        final memoryProvider = Provider.of<MemoryProvider>(context, listen: false);
        final today = DateTime.now();
        final newMemory = Memory(date: today, photo: asset);
        final existingMemory = memoryProvider.memories.firstWhere(
          (m) =>
              m.date.toIso8601String().substring(0, 10) ==
              today.toIso8601String().substring(0, 10),
          orElse: () => Memory(date: DateTime(0), photo: asset),
        );
        if (existingMemory.date.year != 0) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Memory Exists'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('A memory already exists for today. Choose an action:'),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Existing Memory Thumbnail
                        Column(
                          children: [
                            Text(
                              'Existing',
                              style: TextStyle(
                                color: const Color(0xFF0D47A1),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PhotoViewScreen(
                                      photo: existingMemory.photo,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: FutureBuilder<Uint8List?>(
                                  future: existingMemory.photo.thumbnailDataWithSize(
                                    const ThumbnailSize(100, 100),
                                    quality: 80,
                                  ),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Center(
                                        child: CircularProgressIndicator(
                                          color: Color(0xFF0D47A1),
                                          strokeWidth: 2,
                                        ),
                                      );
                                    }
                                    if (snapshot.hasData && snapshot.data != null) {
                                      return Image.memory(
                                        snapshot.data!,
                                        fit: BoxFit.cover,
                                        width: 100,
                                        height: 100,
                                      );
                                    }
                                    return Container(
                                      color: Colors.grey[200],
                                      child: const Icon(
                                        Icons.broken_image,
                                        color: Color(0xFF0D47A1),
                                        size: 40,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        // New Memory Thumbnail
                        Column(
                          children: [
                            Text(
                              'New',
                              style: TextStyle(
                                color: const Color(0xFF0D47A1),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 8),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PhotoViewScreen(
                                      photo: newMemory.photo,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: FutureBuilder<Uint8List?>(
                                  future: newMemory.photo.thumbnailDataWithSize(
                                    const ThumbnailSize(100, 100),
                                    quality: 80,
                                  ),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Center(
                                        child: CircularProgressIndicator(
                                          color: Color(0xFF0D47A1),
                                          strokeWidth: 2,
                                        ),
                                      );
                                    }
                                    if (snapshot.hasData && snapshot.data != null) {
                                      return Image.memory(
                                        snapshot.data!,
                                        fit: BoxFit.cover,
                                        width: 100,
                                        height: 100,
                                      );
                                    }
                                    return Container(
                                      color: Colors.grey[200],
                                      child: const Icon(
                                        Icons.broken_image,
                                        color: Color(0xFF0D47A1),
                                        size: 40,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Keep Old',
                    style: TextStyle(color: Color(0xFF0D47A1)),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    memoryProvider.addMemory(newMemory);
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Replace',
                    style: TextStyle(color: Color(0xFF0D47A1)),
                  ),
                ),
              ],
            ),
          );
        } else {
          memoryProvider.addMemory(newMemory);
        }
      }
    }
  }

  void _showPermissionDeniedDialog(String permission) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$permission Permission Denied'),
        content: Text('Please enable $permission access in settings.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Memory Board'),
        backgroundColor: const Color(0xFF0D47A1),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<MemoryProvider>(context, listen: false).refresh();
            },
            tooltip: 'Refresh Memories',
          ),
          IconButton(
            icon: const Icon(Icons.swipe),
            onPressed: () => Navigator.pushNamed(context, '/swipe'),
            tooltip: 'Swipe Memories',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Day'),
            Tab(text: 'Month'),
            Tab(text: 'Year'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          DayView(),
          MonthView(),
          YearView(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF0D47A1),
        onPressed: _addTodayMemory,
        child: const Icon(Icons.camera_alt, color: Colors.white),
      ),
    );
  }
}

class DayView extends StatelessWidget {
  const DayView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MemoryProvider>(
      builder: (context, memoryProvider, child) {
        final memories = memoryProvider.memories;
        print('DayView: Rendering ${memories.length} memories');

        if (memories.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.photo_library_outlined,
                  color: Color(0xFF0D47A1),
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'No memories yet. Add some via camera or swipe!',
                  style: const TextStyle(
                    color: Color(0xFF0D47A1),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        final sortedMemories = memories.toList()
          ..sort((a, b) => b.date.compareTo(a.date));

        return GridView.builder(
          padding: const EdgeInsets.all(8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 0.75,
          ),
          itemCount: sortedMemories.length,
          itemBuilder: (context, index) {
            final memory = sortedMemories[index];
            final dateStr = memory.date.toIso8601String().substring(0, 10);

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PhotoViewScreen(photo: memory.photo),
                  ),
                );
              },
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: FutureBuilder<Uint8List?>(
                        future: memory.photo.thumbnailDataWithSize(
                          const ThumbnailSize(300, 300),
                          quality: 80,
                        ),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFF0D47A1),
                                strokeWidth: 2,
                              ),
                            );
                          }
                          if (snapshot.hasData && snapshot.data != null) {
                            return Image.memory(
                              snapshot.data!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                              errorBuilder: (context, error, stackTrace) => Container(
                                color: Colors.grey[200],
                                child: const Icon(
                                  Icons.broken_image,
                                  color: Color(0xFF0D47A1),
                                  size: 40,
                                ),
                              ),
                            );
                          }
                          return Container(
                            color: Colors.grey[200],
                            child: const Icon(
                              Icons.broken_image,
                              color: Color(0xFF0D47A1),
                              size: 40,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    dateStr,
                    style: const TextStyle(
                      color: Color(0xFF0D47A1),
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ).animate().fadeIn(
                  duration: const Duration(milliseconds: 300),
                  delay: Duration(milliseconds: index * 100),
                ).scale(
                  begin: const Offset(0.8, 0.8),
                  end: const Offset(1, 1),
                  duration: const Duration(milliseconds: 300),
                );
          },
        );
      },
    );
  }
}

class MonthView extends StatelessWidget {
  const MonthView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MemoryProvider>(
      builder: (context, memoryProvider, child) {
        final memories = memoryProvider.memories;
        print('MonthView: Rendering ${memories.length} memories');

        if (memories.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.photo_library_outlined,
                  color: Color(0xFF0D47A1),
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'No memories yet. Add some via camera or swipe!',
                  style: const TextStyle(
                    color: Color(0xFF0D47A1),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        final groupedMonths = <String, List<Memory>>{};
        for (var memory in memories) {
          final monthStr =
              '${memory.date.year}-${memory.date.month.toString().padLeft(2, '0')}';
          groupedMonths.putIfAbsent(monthStr, () => []).add(memory);
        }

        final sortedMonths = groupedMonths.keys.toList()..sort((a, b) => b.compareTo(a));

        return GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.0,
          ),
          itemCount: sortedMonths.length,
          itemBuilder: (context, index) {
            final month = sortedMonths[index];
            final monthMemories = groupedMonths[month]!;

            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MonthPhotosScreen(
                      month: month,
                      memories: monthMemories,
                    ),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white,
                      Colors.grey[100]!,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    if (monthMemories.isNotEmpty)
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: FutureBuilder<Uint8List?>(
                            future: monthMemories.first.photo.thumbnailDataWithSize(
                              const ThumbnailSize(200, 200),
                              quality: 80,
                            ),
                            builder: (context, snapshot) {
                              if (snapshot.hasData && snapshot.data != null) {
                                return Image.memory(
                                  snapshot.data!,
                                  fit: BoxFit.cover,
                                );
                              }
                              return Container(color: Colors.grey[200]);
                            },
                          ),
                        ),
                      ),
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.black.withOpacity(0.3),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            month,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${monthMemories.length} photo${monthMemories.length == 1 ? '' : 's'}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(
                  duration: const Duration(milliseconds: 300),
                  delay: Duration(milliseconds: index * 100),
                ).scale(
                  begin: const Offset(0.9, 0.9),
                  end: const Offset(1, 1),
                  duration: const Duration(milliseconds: 300),
                );
          },
        );
      },
    );
  }
}

class MonthPhotosScreen extends StatelessWidget {
  final String month;
  final List<Memory> memories;

  const MonthPhotosScreen({
    super.key,
    required this.month,
    required this.memories,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Photos for $month'),
        backgroundColor: const Color(0xFF0D47A1),
        foregroundColor: Colors.white,
      ),
      body: memories.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.photo_library_outlined,
                    color: Color(0xFF0D47A1),
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No photos for this month.',
                    style: const TextStyle(
                      color: Color(0xFF0D47A1),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 0.75,
              ),
              itemCount: memories.length,
              itemBuilder: (context, index) {
                final memory = memories[index];
                final dateStr = memory.date.toIso8601String().substring(0, 10);

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PhotoViewScreen(photo: memory.photo),
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: FutureBuilder<Uint8List?>(
                            future: memory.photo.thumbnailDataWithSize(
                              const ThumbnailSize(300, 300),
                              quality: 80,
                            ),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Center(
                                  child: CircularProgressIndicator(
                                    color: Color(0xFF0D47A1),
                                    strokeWidth: 2,
                                  ),
                                );
                              }
                              if (snapshot.hasData && snapshot.data != null) {
                                return Image.memory(
                                  snapshot.data!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                  errorBuilder: (context, error, stackTrace) => Container(
                                    color: Colors.grey[200],
                                    child: const Icon(
                                      Icons.broken_image,
                                      color: Color(0xFF0D47A1),
                                      size: 40,
                                    ),
                                  ),
                                );
                              }
                              return Container(
                                color: Colors.grey[200],
                                child: const Icon(
                                  Icons.broken_image,
                                  color: Color(0xFF0D47A1),
                                  size: 40,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dateStr,
                        style: const TextStyle(
                          color: Color(0xFF0D47A1),
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ).animate().fadeIn(
                      duration: const Duration(milliseconds: 300),
                      delay: Duration(milliseconds: index * 100),
                    ).scale(
                      begin: const Offset(0.8, 0.8),
                      end: const Offset(1, 1),
                      duration: const Duration(milliseconds: 300),
                    );
              },
            ),
    );
  }
}

class YearView extends StatelessWidget {
  const YearView({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MemoryProvider>(
      builder: (context, memoryProvider, child) {
        final memories = memoryProvider.memories;
        print('YearView: Rendering ${memories.length} memories');

        if (memories.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.photo_library_outlined,
                  color: Color(0xFF0D47A1),
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'No memories yet. Add some via camera or swipe!',
                  style: const TextStyle(
                    color: Color(0xFF0D47A1),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        final groupedYears = <int, List<Memory>>{};
        for (var memory in memories) {
          groupedYears.putIfAbsent(memory.date.year, () => []).add(memory);
        }

        final sortedYears = groupedYears.keys.toList()..sort((a, b) => b.compareTo(a));

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: sortedYears.length,
          itemBuilder: (context, index) {
            final year = sortedYears[index];
            final yearMemories = groupedYears[year]!;

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text(
                      '$year',
                      style: const TextStyle(
                        color: Color(0xFF0D47A1),
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 120,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      itemCount: yearMemories.length,
                      itemBuilder: (context, photoIndex) {
                        final memory = yearMemories[photoIndex];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PhotoViewScreen(photo: memory.photo),
                              ),
                            );
                          },
                          child: Container(
                            width: 100,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: FutureBuilder<Uint8List?>(
                              future: memory.photo.thumbnailDataWithSize(
                                const ThumbnailSize(200, 200),
                                quality: 80,
                              ),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return const Center(
                                    child: CircularProgressIndicator(
                                      color: Color(0xFF0D47A1),
                                      strokeWidth: 2,
                                    ),
                                  );
                                }
                                if (snapshot.hasData && snapshot.data != null) {
                                  return Image.memory(
                                    snapshot.data!,
                                    fit: BoxFit.cover,
                                    width: 100,
                                    height: 120,
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      color: Colors.grey[200],
                                      child: const Icon(
                                        Icons.broken_image,
                                        color: Color(0xFF0D47A1),
                                        size: 40,
                                      ),
                                    ),
                                  );
                                }
                                return Container(
                                  color: Colors.grey[200],
                                  child: const Icon(
                                    Icons.broken_image,
                                    color: Color(0xFF0D47A1),
                                    size: 40,
                                  ),
                                );
                              },
                            ),
                          ),
                        ).animate().fadeIn(
                              duration: const Duration(milliseconds: 300),
                              delay: Duration(milliseconds: photoIndex * 100),
                            ).slide(
                              begin: const Offset(0.5, 0),
                              end: Offset.zero,
                              duration: const Duration(milliseconds: 300),
                            );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ).animate().fadeIn(
                  duration: const Duration(milliseconds: 500),
                  delay: Duration(milliseconds: index * 200),
                ).slide(
                  begin: const Offset(0, 0.5),
                  end: Offset.zero,
                  duration: const Duration(milliseconds: 500),
                );
          },
        );
      },
    );
  }
}
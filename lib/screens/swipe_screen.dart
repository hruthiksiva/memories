import 'package:flutter/material.dart';
import 'package:memories/screens/photo_view_screen.dart';
import 'package:provider/provider.dart';
import '../providers/photo_provider.dart';
import '../providers/memory_provider.dart';
import 'package:swipe_cards/swipe_cards.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:typed_data';
import 'dart:io';

class SwipeScreen extends StatefulWidget {
  const SwipeScreen({super.key});

  @override
  State<SwipeScreen> createState() => _SwipeScreenState();
}

class _SwipeScreenState extends State<SwipeScreen> {
  List<SwipeItem> _swipeItems = [];
  MatchEngine? _matchEngine;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _checkPhotosPermission();
  }

  Future<void> _checkPhotosPermission() async {
    final photosStatus = await Permission.photos.status;
    if (!photosStatus.isGranted) {
      final result = await Permission.photos.request();
      if (!result.isGranted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Photos permission denied';
        });
        _showPermissionDeniedDialog();
        return;
      }
    }
    await _loadSwipeItems();
  }

  Future<void> _loadSwipeItems() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final photoProvider = Provider.of<PhotoProvider>(context, listen: false);
      await photoProvider.fetchDiversePhotos();

      if (photoProvider.errorMessage.isNotEmpty) {
        setState(() {
          _isLoading = false;
          _errorMessage = photoProvider.errorMessage;
        });
        return;
      }

      final randomPhotos = photoProvider.photos;

      if (randomPhotos.isEmpty) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'No photos found in the gallery.';
        });
        return;
      }

      _swipeItems = randomPhotos
          .where((photo) => photo != null)
          .map((photo) => SwipeItem(
                content: photo,
                likeAction: () => _handleLike(photo),
                nopeAction: () => _handleNope(photo),
              ))
          .toList();

      _matchEngine = MatchEngine(swipeItems: _swipeItems);
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading swipe items: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error loading photos: $e';
      });
    }
  }
  
  void _handleLike(AssetEntity photo) {
    final memoryProvider = Provider.of<MemoryProvider>(context, listen: false);
    final date = photo.createDateTime ?? DateTime.now();
    final newMemory = Memory(date: date, photo: photo);

    // Check for existing memory
    final existingMemory = memoryProvider.memories.firstWhere(
      (m) =>
          m.date.toIso8601String().substring(0, 10) ==
          date.toIso8601String().substring(0, 10),
      orElse: () => Memory(date: DateTime(0), photo: photo),
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

  void _handleNope(AssetEntity photo) {
    print('Noped photo: ${photo.id}');
    // Optionally track noped photos if needed
    // For now, do nothing beyond logging
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Photos Permission Denied'),
        content: const Text('Please enable photos access in settings.'),
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
    final screenSize = MediaQuery.of(context).size;
    final cardHeight = screenSize.height * 0.7;
    final cardWidth = screenSize.width * 0.9;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Swipe Your Memories'),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF0D47A1),
              ),
            )
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _errorMessage,
                        style: const TextStyle(
                          color: Color(0xFF0D47A1),
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0D47A1),
                          foregroundColor: Colors.white,
                        ),
                        onPressed: _checkPhotosPermission,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _swipeItems.isEmpty || _matchEngine == null
                  ? const Center(
                      child: Text(
                        'No photos available',
                        style: TextStyle(
                          color: Color(0xFF0D47A1),
                          fontSize: 16,
                        ),
                      ),
                    )
                  : Column(
                      children: [
                        Expanded(
                          child: Center(
                            child: SizedBox(
                              width: cardWidth,
                              height: cardHeight,
                              child: SwipeCards(
                                matchEngine: _matchEngine!,
                                itemBuilder: (context, index) {
                                  final photo = _swipeItems[index].content as AssetEntity;
                                  return FutureBuilder<Uint8List?>(
                                    future: photo.thumbnailDataWithSize(
                                      const ThumbnailSize(1080, 1920),
                                      quality: 80,
                                    ),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState == ConnectionState.waiting) {
                                        return const Center(
                                          child: CircularProgressIndicator(
                                            color: Color(0xFF0D47A1),
                                          ),
                                        );
                                      }
                                      if (snapshot.hasData && snapshot.data != null) {
                                        return Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(16),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.2),
                                                blurRadius: 8,
                                                offset: const Offset(0, 4),
                                              ),
                                            ],
                                          ),
                                          clipBehavior: Clip.antiAlias,
                                          child: Image.memory(
                                            snapshot.data!,
                                            fit: BoxFit.cover,
                                            width: cardWidth,
                                            height: cardHeight,
                                            errorBuilder: (context, error, stackTrace) =>
                                                const Center(
                                              child: Text(
                                                'Failed to load image',
                                                style: TextStyle(color: Color(0xFF0D47A1)),
                                              ),
                                            ),
                                          ),
                                        );
                                      }
                                      return const Center(
                                        child: Text(
                                          'Unable to load image',
                                          style: TextStyle(color: Color(0xFF0D47A1)),
                                        ),
                                      );
                                    },
                                  );
                                },
                                onStackFinished: () async {
                                  await _loadSwipeItems();
                                },
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              FloatingActionButton(
                                heroTag: 'nope',
                                backgroundColor: Colors.red,
                                onPressed: () {
                                  _matchEngine?.currentItem?.nope();
                                },
                                child: const Icon(Icons.close, color: Colors.white),
                              ),
                              const SizedBox(width: 40),
                              FloatingActionButton(
                                heroTag: 'like',
                                backgroundColor: Colors.green,
                                onPressed: () {
                                  _matchEngine?.currentItem?.like();
                                },
                                child: const Icon(Icons.favorite, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
    );
  }
}
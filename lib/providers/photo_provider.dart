import 'dart:math';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import '../database_helper.dart';

class PhotoProvider with ChangeNotifier {
  List<AssetEntity> _photos = [];
  bool _isLoading = false;
  String _errorMessage = '';
  // Cache to track recently shown photos (in-memory for simplicity)
  static final Set<String> _recentlyShownIds = {};

  List<AssetEntity> get photos => _photos;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  /// Fetches a diverse set of photos from the gallery, mixing years, months, and days.
  /// Ensures rarely repetitive selections by prioritizing less recently shown photos.
  /// [count] specifies the number of photos to fetch (default: 100).
  Future<void> fetchDiversePhotos({int count = 100}) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      // Request gallery permission
      final permission = await PhotoManager.requestPermissionExtend();
      if (!permission.isAuth) {
        _errorMessage = 'Permission denied to access gallery';
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Get swiped image IDs from database
      final swipedIds = await DatabaseHelper().getSwipedIds();

      // Fetch all albums
      final albums = await PhotoManager.getAssetPathList(type: RequestType.image);
      if (albums.isEmpty) {
        _errorMessage = 'No photo albums found';
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Collect all assets, excluding swiped ones
      final allAssets = <AssetEntity>[];
      for (var album in albums) {
        final assets = await album.getAssetListPaged(page: 0, size: 100);
        allAssets.addAll(assets.where((asset) => !swipedIds.contains(asset.id)));
      }

      if (allAssets.isEmpty) {
        _errorMessage = 'No unswiped photos found in gallery';
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Group assets by year, month, and day
      final groupedAssets = _groupAssetsByDate(allAssets);

      // Select diverse photos
      final selectedAssets = _selectDiversePhotos(groupedAssets, count);

      // Update recently shown cache
      _recentlyShownIds.addAll(selectedAssets.map((asset) => asset.id));
      // Limit cache size to prevent memory issues (e.g., last 500 photos)
      if (_recentlyShownIds.length > 500) {
        final excess = _recentlyShownIds.length - 500;
        final toRemove = _recentlyShownIds.take(excess).toList();
        _recentlyShownIds.removeAll(toRemove);
      }

      // Shuffle the selection for random display order
      selectedAssets.shuffle();

      _photos = selectedAssets;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error fetching photos: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Groups assets by year, month, and day for diverse selection.
  Map<String, List<AssetEntity>> _groupAssetsByDate(List<AssetEntity> assets) {
    final grouped = <String, List<AssetEntity>>{};
    for (var asset in assets) {
      final date = asset.createDateTime;
      if (date != null) {
        final key =
            '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        grouped.putIfAbsent(key, () => []).add(asset);
      }
    }
    return grouped;
  }

  /// Selects diverse photos from different dates, prioritizing less recently shown ones.
  List<AssetEntity> _selectDiversePhotos(
      Map<String, List<AssetEntity>> groupedAssets, int count) {
    final selected = <AssetEntity>[];
    final random = Random();
    final dates = groupedAssets.keys.toList()..shuffle();

    // First pass: Try to select from less recently shown photos
    for (var date in dates) {
      final assetsForDate = groupedAssets[date]!
          .where((asset) => !_recentlyShownIds.contains(asset.id))
          .toList();
      if (assetsForDate.isNotEmpty && selected.length < count) {
        final assetIndex = random.nextInt(assetsForDate.length);
        selected.add(assetsForDate[assetIndex]);
      }
    }

    // Second pass: If needed, include recently shown photos to meet count
    if (selected.length < count) {
      final remainingDates = dates.where((date) => groupedAssets[date]!.isNotEmpty).toList();
      while (selected.length < count && remainingDates.isNotEmpty) {
        final dateIndex = random.nextInt(remainingDates.length);
        final date = remainingDates[dateIndex];
        final assetsForDate = groupedAssets[date]!;
        if (assetsForDate.isNotEmpty) {
          final assetIndex = random.nextInt(assetsForDate.length);
          selected.add(assetsForDate[assetIndex]);
          assetsForDate.removeAt(assetIndex);
        }
        if (assetsForDate.isEmpty) {
          remainingDates.removeAt(dateIndex);
        }
      }
    }

    // Ensure we don't exceed requested count
    return selected.take(count).toList();
  }
}
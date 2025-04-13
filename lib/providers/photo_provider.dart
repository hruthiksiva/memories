import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'dart:math';

class PhotoProvider with ChangeNotifier {
  List<AssetEntity> _photos = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<AssetEntity> get photos => _photos;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  /// Fetches a diverse set of photos from the gallery spanning different years, months, and days.
  /// [count] specifies the number of photos to fetch (default: 100).
  Future<void> fetchDiversePhotos({int count = 100}) async {
    _setLoading(true);
    _clearError();

    try {
      // Request permission to access the gallery
      final permission = await PhotoManager.requestPermissionExtend();
      if (!permission.isAuth) {
        _setError('Permission denied to access gallery');
        _setLoading(false);
        return;
      }

      // Fetch all albums containing images
      final albums = await PhotoManager.getAssetPathList(type: RequestType.image);
      if (albums.isEmpty) {
        _setError('No photo albums found');
        _setLoading(false);
        return;
      }

      // Collect all photos from albums
      final allAssets = <AssetEntity>[];
      for (var album in albums) {
        final assets = await album.getAssetListPaged(page: 0, size: 100);
        allAssets.addAll(assets);
      }

      if (allAssets.isEmpty) {
        _setError('No photos found in gallery');
        _setLoading(false);
        return;
      }

      // Group photos by date (year, month, day)
      final groupedAssets = _groupAssetsByDate(allAssets);

      // Select a diverse set of photos from different dates
      final selectedAssets = _selectDiversePhotos(groupedAssets, count);

      // Shuffle the selection for a random display order
      selectedAssets.shuffle();

      _photos = selectedAssets;
      notifyListeners();
    } catch (e) {
      _setError('Error fetching photos: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Groups assets by their creation date (year-month-day).
  Map<String, List<AssetEntity>> _groupAssetsByDate(List<AssetEntity> assets) {
    final grouped = <String, List<AssetEntity>>{};
    for (var asset in assets) {
      final date = asset.createDateTime;
      if (date != null) {
        final key = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        grouped.putIfAbsent(key, () => []).add(asset);
      }
    }
    return grouped;
  }

  /// Selects a diverse set of photos from different dates up to the specified count.
  List<AssetEntity> _selectDiversePhotos(Map<String, List<AssetEntity>> groupedAssets, int count) {
    final selected = <AssetEntity>[];
    final random = Random();
    final dates = groupedAssets.keys.toList();

    while (selected.length < count && dates.isNotEmpty) {
      // Pick a random date
      final dateIndex = random.nextInt(dates.length);
      final date = dates[dateIndex];
      final assetsForDate = groupedAssets[date]!;

      if (assetsForDate.isNotEmpty) {
        // Pick a random photo from that date
        final assetIndex = random.nextInt(assetsForDate.length);
        selected.add(assetsForDate[assetIndex]);
        assetsForDate.removeAt(assetIndex);
      }

      // Remove the date if no photos remain for it
      if (assetsForDate.isEmpty) {
        dates.removeAt(dateIndex);
      }
    }

    return selected;
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  getRandomAssets(int i) {}
}
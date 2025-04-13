import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'dart:io';

class PhotoViewScreen extends StatelessWidget {
  final AssetEntity photo;

  const PhotoViewScreen({super.key, required this.photo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Memory'),
      ),
      body: Center(
        child: FutureBuilder<File?>(
          future: photo.file,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator(
                color: Color(0xFF0D47A1),
              );
            }
            if (snapshot.hasData && snapshot.data != null) {
              return Image.file(
                snapshot.data!,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Center(
                  child: Text(
                    'Failed to load image',
                    style: TextStyle(color: Color(0xFF0D47A1)),
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
        ),
      ),
    );
  }
}
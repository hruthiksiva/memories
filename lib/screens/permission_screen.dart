import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionScreen extends StatefulWidget {
  const PermissionScreen({super.key});

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen> with WidgetsBindingObserver {
  bool _isCheckingPermissions = true;
  bool _photosGranted = false;
  bool _cameraGranted = false;
  String _statusMessage = 'Checking permissions...';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      print('App resumed, rechecking permissions');
      _checkPermissions();
    }
  }

  Future<void> _checkPermissions() async {
    setState(() {
      _isCheckingPermissions = true;
      _statusMessage = 'Checking permissions...';
    });

    try {
      final photosStatus = await Permission.photos.status;
      final cameraStatus = await Permission.camera.status;

      setState(() {
        _photosGranted = photosStatus.isGranted;
        _cameraGranted = cameraStatus.isGranted;
        _isCheckingPermissions = false;
      });

      print('Photos permission: $photosStatus');
      print('Camera permission: $cameraStatus');

      if (_photosGranted && _cameraGranted) {
        print('All permissions granted, navigating to memory board');
        await Navigator.pushReplacementNamed(context, '/memory_board');
      } else {
        _statusMessage = 'Please grant all permissions to continue.';
      }
    } catch (e) {
      print('Error checking permissions: $e');
      setState(() {
        _isCheckingPermissions = false;
        _statusMessage = 'Error checking permissions. Please try again.';
      });
    }
  }

  Future<void> _requestPhotosPermission() async {
    try {
      final status = await Permission.photos.request();
      setState(() {
        _photosGranted = status.isGranted;
      });
      print('Photos permission requested: $status');
      if (_photosGranted && _cameraGranted) {
        print('All permissions granted, navigating to memory board');
        await Navigator.pushReplacementNamed(context, '/memory_board');
      }
    } catch (e) {
      print('Error requesting photos permission: $e');
      setState(() {
        _statusMessage = 'Error requesting photos permission.';
      });
    }
  }

  Future<void> _requestCameraPermission() async {
    try {
      final status = await Permission.camera.request();
      setState(() {
        _cameraGranted = status.isGranted;
      });
      print('Camera permission requested: $status');
      if (_photosGranted && _cameraGranted) {
        print('All permissions granted, navigating to memory board');
        await Navigator.pushReplacementNamed(context, '/memory_board');
      }
    } catch (e) {
      print('Error requesting camera permission: $e');
      setState(() {
        _statusMessage = 'Error requesting camera permission.';
      });
    }
  }

  void _openSettings() {
    print('Opening app settings');
    openAppSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _isCheckingPermissions
            ? const CircularProgressIndicator(
                color: Color(0xFF0D47A1),
              )
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _statusMessage,
                      style: const TextStyle(
                        color: Color(0xFF0D47A1),
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Photos: ${_photosGranted ? "Granted" : "Denied"}',
                      style: TextStyle(
                        color: _photosGranted ? Colors.green : Colors.red,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D47A1),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(200, 50),
                      ),
                      onPressed: _photosGranted ? null : _requestPhotosPermission,
                      child: Text(_photosGranted ? 'Photos Granted' : 'Allow Photos'),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Camera: ${_cameraGranted ? "Granted" : "Denied"}',
                      style: TextStyle(
                        color: _cameraGranted ? Colors.green : Colors.red,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D47A1),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(200, 50),
                      ),
                      onPressed: _cameraGranted ? null : _requestCameraPermission,
                      child: Text(_cameraGranted ? 'Camera Granted' : 'Allow Camera'),
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: _openSettings,
                      child: const Text(
                        'Open App Settings',
                        style: TextStyle(
                          color: Color(0xFF0D47A1),
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}
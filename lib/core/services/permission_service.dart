import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  static Future<bool> hasLocationPermission() async {
    final permission = await Permission.locationWhenInUse.status;
    return permission.isGranted;
  }

  static Future<bool> requestLocationPermission() async {
    final permission = await Permission.locationWhenInUse.request();
    return permission.isGranted;
  }

  static Future<Position?> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled');
      }

      // Check for permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permission denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permission permanently denied');
      }

      // Get current position
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (e) {
      throw Exception('Failed to get location: $e');
    }
  }
}

class PermissionService {
  static Future<bool> hasCameraPermission() async {
    final permission = await Permission.camera.status;
    return permission.isGranted;
  }

  static Future<bool> requestCameraPermission() async {
    final permission = await Permission.camera.request();
    return permission.isGranted;
  }

  static Future<bool> hasAllPermissions() async {
    final cameraPermission = await Permission.camera.status;
    final locationPermission = await Permission.locationWhenInUse.status;
    
    return cameraPermission.isGranted && locationPermission.isGranted;
  }

  static Future<Map<String, bool>> requestAllPermissions() async {
    final cameraPermission = await Permission.camera.request();
    final locationPermission = await Permission.locationWhenInUse.request();
    
    return {
      'camera': cameraPermission.isGranted,
      'location': locationPermission.isGranted,
    };
  }

  static Future<void> openAppSettings() async {
    await openAppSettings();
  }
}

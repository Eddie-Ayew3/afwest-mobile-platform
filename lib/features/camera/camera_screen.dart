import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/app_utils.dart';

class CameraScreen extends StatefulWidget {
  final String title;

  const CameraScreen({
    super.key,
    required this.title,
  });

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  bool _isCameraInitialized = false;
  bool _isRearCameraSelected = true;
  String? _capturedImagePath;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    try {
      // Check camera permission
      final cameraPermission = await Permission.camera.status;
      if (!cameraPermission.isGranted) {
        final result = await Permission.camera.request();
        if (!result.isGranted) {
          if (mounted) {
            AppUtils.showSnackBar(
              context,
              AppStrings.cameraPermission,
              isError: true,
            );
            Navigator.of(context).pop();
          }
          return;
        }
      }

      // Get available cameras
      _cameras = await availableCameras();
      if (_cameras.isEmpty) {
        if (mounted) {
          AppUtils.showSnackBar(
            context,
            'No cameras available',
            isError: true,
          );
          Navigator.of(context).pop();
        }
        return;
      }

      // Initialize camera with rear camera by default
      await _initializeCameraController(_cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras.first,
      ));
    } catch (e) {
      if (mounted) {
        AppUtils.showSnackBar(
          context,
          'Failed to initialize camera: $e',
          isError: true,
        );
        Navigator.of(context).pop();
      }
    }
  }

  Future<void> _initializeCameraController(CameraDescription camera) async {
    if (_cameraController != null) {
      await _cameraController!.dispose();
    }

    _cameraController = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
    );

    try {
      await _cameraController!.initialize();
      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      if (mounted) {
        AppUtils.showSnackBar(
          context,
          'Failed to initialize camera controller: $e',
          isError: true,
        );
      }
    }
  }

  Future<void> _capturePhoto() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      final XFile photo = await _cameraController!.takePicture();
      
      if (mounted) {
        setState(() {
          _capturedImagePath = photo.path;
        });
      }
    } catch (e) {
      if (mounted) {
        AppUtils.showSnackBar(
          context,
          'Failed to capture photo: $e',
          isError: true,
        );
      }
    }
  }

  void _switchCamera() async {
    if (_cameras.length < 2) return;

    _isRearCameraSelected = !_isRearCameraSelected;
    
    final newCamera = _isRearCameraSelected
        ? _cameras.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.back,
            orElse: () => _cameras.first,
          )
        : _cameras.firstWhere(
            (camera) => camera.lensDirection == CameraLensDirection.front,
            orElse: () => _cameras.first,
          );

    await _initializeCameraController(newCamera);
  }

  void _retakePhoto() {
    setState(() {
      _capturedImagePath = null;
    });
  }

  void _confirmPhoto() {
    if (_capturedImagePath != null) {
      Navigator.of(context).pop(_capturedImagePath);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: _capturedImagePath != null
          ? _buildPhotoPreview()
          : _buildCameraPreview(),
    );
  }

  Widget _buildCameraPreview() {
    if (!_isCameraInitialized || _cameraController == null) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    return Stack(
      children: [
        // Camera Preview
        SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: _cameraController!.value.previewSize!.height,
              height: _cameraController!.value.previewSize!.width,
              child: CameraPreview(_cameraController!),
            ),
          ),
        ),

        // Controls Overlay
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: EdgeInsets.all(AppConstants.padding.w),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Switch Camera Button
                if (_cameras.length > 1)
                  IconButton(
                    onPressed: _switchCamera,
                    icon: const Icon(
                      Icons.flip_camera_ios,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),

                // Capture Button
                GestureDetector(
                  onTap: _capturePhoto,
                  child: Container(
                    width: 70.w,
                    height: 70.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 3,
                      ),
                    ),
                    child: Container(
                      margin: EdgeInsets.all(8.w),
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                // Placeholder for symmetry
                if (_cameras.length > 1)
                  const SizedBox(width: 48),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhotoPreview() {
    return Stack(
      children: [
        // Photo Preview
        SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Image.file(
            File(_capturedImagePath!),
            fit: BoxFit.cover,
          ),
        ),

        // Controls Overlay
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: EdgeInsets.all(AppConstants.padding.w),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Retake Button
                SizedBox(
                  width: 120.w,
                  height: 50.h,
                  child: OutlinedButton(
                    onPressed: _retakePhoto,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white),
                    ),
                    child: const Text(
                      AppStrings.retake,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),

                // Confirm Button
                SizedBox(
                  width: 120.w,
                  height: 50.h,
                  child: ElevatedButton(
                    onPressed: _confirmPhoto,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.primaryColor,
                    ),
                    child: const Text(AppStrings.confirm),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

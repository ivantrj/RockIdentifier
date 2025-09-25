import 'dart:io';
import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:rock_id/core/theme/app_theme.dart';
import 'package:rock_id/services/haptic_service.dart';
import 'package:rock_id/services/logging_service.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:image/image.dart' as img;

class CustomCameraScreen extends StatefulWidget {
  final Function(String) onImageCaptured;

  const CustomCameraScreen({
    super.key,
    required this.onImageCaptured,
  });

  @override
  State<CustomCameraScreen> createState() => _CustomCameraScreenState();
}

class _CustomCameraScreenState extends State<CustomCameraScreen> {
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _isCapturing = false;
  String? _errorMessage;

  // Focus rectangle dimensions (as percentage of screen) - more rectangular
  static const double _focusRectWidth = 0.8;
  static const double _focusRectHeight = 0.4;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        setState(() {
          _errorMessage = 'No cameras available';
        });
        return;
      }

      // Use the back camera (first camera is usually back camera)
      final camera = _cameras!.first;

      _cameraController = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _cameraController!.initialize();

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      LoggingService.error('Failed to initialize camera', error: e, tag: 'CustomCameraScreen');
      setState(() {
        _errorMessage = 'Failed to initialize camera: ${e.toString()}';
      });
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _captureImage() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized || _isCapturing) {
      return;
    }

    // Immediately disable the button and show loading state
    setState(() {
      _isCapturing = true;
    });

    try {
      await HapticService.instance.vibrate();

      // Capture the image
      final XFile image = await _cameraController!.takePicture();

      // Crop the image to the focus rectangle area
      final croppedImagePath = await _cropImageToFocusArea(image.path);

      if (croppedImagePath != null) {
        LoggingService.userAction('Image captured with custom camera', tag: 'CustomCameraScreen');

        // Close camera immediately and let library handle the loading dialog
        if (mounted) {
          Navigator.of(context).pop();
        }

        // Call the callback after closing the camera
        widget.onImageCaptured(croppedImagePath);
        return;
      } else {
        throw Exception('Failed to crop image');
      }
    } catch (e) {
      LoggingService.error('Failed to capture image', error: e, tag: 'CustomCameraScreen');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to capture image: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }

      // Reset capturing state only on error
      if (mounted) {
        setState(() {
          _isCapturing = false;
        });
      }
    }
  }

  Future<String?> _cropImageToFocusArea(String imagePath) async {
    try {
      // Get the image file
      final File imageFile = File(imagePath);
      final Uint8List imageBytes = await imageFile.readAsBytes();

      // Decode the image
      final img.Image? originalImage = img.decodeImage(imageBytes);
      if (originalImage == null) {
        throw Exception('Failed to decode image');
      }

      // Calculate crop area based on focus rectangle
      // The focus rectangle is 70% width and 50% height of the screen
      // We need to map this to the actual image dimensions
      final imageWidth = originalImage.width;
      final imageHeight = originalImage.height;

      // Calculate the crop area (center of the image)
      final cropWidth = (imageWidth * _focusRectWidth).round();
      final cropHeight = (imageHeight * _focusRectHeight).round();
      final cropX = ((imageWidth - cropWidth) / 2).round();
      final cropY = ((imageHeight - cropHeight) / 2).round();

      // Crop the image
      final img.Image croppedImage = img.copyCrop(
        originalImage,
        x: cropX,
        y: cropY,
        width: cropWidth,
        height: cropHeight,
      );

      // Encode the cropped image as JPEG
      final List<int> croppedBytes = img.encodeJpg(croppedImage, quality: 85);

      // Save to app directory with a unique name
      final appDir = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'Rock_cropped_$timestamp.jpg';
      final savedPath = path.join(appDir.path, fileName);

      final savedFile = File(savedPath);
      await savedFile.writeAsBytes(croppedBytes);

      LoggingService.debug(
          'Image cropped successfully - Original: ${imageWidth}x${imageHeight}, Cropped: ${cropWidth}x${cropHeight}',
          tag: 'CustomCameraScreen');

      return savedFile.path;
    } catch (e) {
      LoggingService.error('Failed to crop image', error: e, tag: 'CustomCameraScreen');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: isDarkMode ? AppTheme.nearBlack : Colors.white,
        appBar: AppBar(
          title: const Text('Camera Error'),
          backgroundColor: Colors.transparent,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                HugeIcons.strokeRoundedCamera01,
                size: 64,
                color: AppTheme.errorColor,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    if (!_isInitialized) {
      return Scaffold(
        backgroundColor: isDarkMode ? AppTheme.nearBlack : Colors.white,
        appBar: AppBar(
          title: const Text('Camera'),
          backgroundColor: Colors.transparent,
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Identify Rock', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: Stack(
        children: [
          // Camera preview
          Positioned.fill(
            child: CameraPreview(_cameraController!),
          ),

          // Focus rectangle overlay
          _buildFocusOverlay(isDarkMode),

          // Bottom controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomControls(isDarkMode),
          ),
        ],
      ),
    );
  }

  Widget _buildFocusOverlay(bool isDarkMode) {
    return Positioned.fill(
      child: CustomPaint(
        painter: FocusOverlayPainter(
          focusRectWidth: _focusRectWidth,
          focusRectHeight: _focusRectHeight,
          isDarkMode: isDarkMode,
        ),
      ),
    );
  }

  Widget _buildBottomControls(bool isDarkMode) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withValues(alpha: 0.7),
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Instructions
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppTheme.sandstone.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    HugeIcons.strokeRoundedTarget01,
                    size: 20,
                    color: AppTheme.sandstone,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Position the Rock within the frame',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Capture button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Close button
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.5),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),

                // Capture button
                GestureDetector(
                  onTap: _isCapturing ? null : _captureImage,
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: _isCapturing ? Colors.grey : AppTheme.sandstone,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 4,
                      ),
                    ),
                    child: const Icon(
                      HugeIcons.strokeRoundedCamera01,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),

                // Placeholder for symmetry
                const SizedBox(width: 60),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class FocusOverlayPainter extends CustomPainter {
  final double focusRectWidth;
  final double focusRectHeight;
  final bool isDarkMode;

  FocusOverlayPainter({
    required this.focusRectWidth,
    required this.focusRectHeight,
    required this.isDarkMode,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    final focusPaint = Paint()
      ..color = AppTheme.sandstone
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    // Calculate focus rectangle dimensions
    final focusRectWidth = size.width * this.focusRectWidth;
    final focusRectHeight = size.height * this.focusRectHeight;
    final focusRectLeft = (size.width - focusRectWidth) / 2;
    final focusRectTop = (size.height - focusRectHeight) / 2;

    final focusRect = Rect.fromLTWH(
      focusRectLeft,
      focusRectTop,
      focusRectWidth,
      focusRectHeight,
    );

    // Create path for the overlay (full screen minus focus area)
    final overlayPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRect(focusRect)
      ..fillType = PathFillType.evenOdd;

    // Draw the overlay
    canvas.drawPath(overlayPath, paint);

    // Draw the focus rectangle border
    canvas.drawRect(focusRect, focusPaint);

    // Draw corner indicators
    _drawCornerIndicators(canvas, focusRect, focusPaint);
  }

  void _drawCornerIndicators(Canvas canvas, Rect focusRect, Paint paint) {
    const cornerLength = 20.0;
    const cornerThickness = 3.0;

    final cornerPaint = Paint()
      ..color = AppTheme.sandstone
      ..style = PaintingStyle.stroke
      ..strokeWidth = cornerThickness
      ..strokeCap = StrokeCap.round;

    // Top-left corner
    canvas.drawLine(
      Offset(focusRect.left, focusRect.top + cornerLength),
      Offset(focusRect.left, focusRect.top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(focusRect.left, focusRect.top),
      Offset(focusRect.left + cornerLength, focusRect.top),
      cornerPaint,
    );

    // Top-right corner
    canvas.drawLine(
      Offset(focusRect.right - cornerLength, focusRect.top),
      Offset(focusRect.right, focusRect.top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(focusRect.right, focusRect.top),
      Offset(focusRect.right, focusRect.top + cornerLength),
      cornerPaint,
    );

    // Bottom-left corner
    canvas.drawLine(
      Offset(focusRect.left, focusRect.bottom - cornerLength),
      Offset(focusRect.left, focusRect.bottom),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(focusRect.left, focusRect.bottom),
      Offset(focusRect.left + cornerLength, focusRect.bottom),
      cornerPaint,
    );

    // Bottom-right corner
    canvas.drawLine(
      Offset(focusRect.right - cornerLength, focusRect.bottom),
      Offset(focusRect.right, focusRect.bottom),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(focusRect.right, focusRect.bottom),
      Offset(focusRect.right, focusRect.bottom - cornerLength),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

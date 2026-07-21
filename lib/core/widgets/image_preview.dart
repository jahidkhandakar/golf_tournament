import 'package:flutter/material.dart';

/// Full-screen popup preview of a bundled asset image. Pinch/drag to zoom,
/// tap the dark area or the bottom close button to dismiss.
class ImagePreview {
  ImagePreview._();

  static Future<void> show(BuildContext context, String imagePath) {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.92),
      builder: (dialogContext) {
        return GestureDetector(
          // Tap outside the image dismisses too.
          onTap: () => Navigator.of(dialogContext).pop(),
          child: SizedBox.expand(
            child: Stack(
              children: [
                Positioned.fill(
                  child: InteractiveViewer(
                    minScale: 1,
                    maxScale: 4,
                    child: Center(
                      child: Image.asset(
                        imagePath,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.broken_image_outlined, color: Colors.white54, size: 80),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 40,
                  child: Center(
                    child: Material(
                      color: Colors.white,
                      shape: const CircleBorder(),
                      elevation: 4,
                      child: InkWell(
                        customBorder: const CircleBorder(),
                        onTap: () => Navigator.of(dialogContext).pop(),
                        child: const Padding(
                          padding: EdgeInsets.all(12),
                          child: Icon(Icons.close, color: Colors.black, size: 26),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:image_picker/image_picker.dart';

class FabMenu extends StatelessWidget {
  final bool isOpen;
  final bool isProcessing;
  final VoidCallback onOpen;
  final VoidCallback onClose;
  final Function(ImageSource) onImagePicked;

  const FabMenu({
    super.key,
    required this.isOpen,
    required this.isProcessing,
    required this.onOpen,
    required this.onClose,
    required this.onImagePicked,
  });

  @override
  Widget build(BuildContext context) {
    if (isOpen) {
      return Stack(
        children: [
          // Backdrop
          Positioned.fill(
            child: GestureDetector(
              onTap: onClose,
              child: Container(
                color: Colors.black.withValues(alpha: 0.3),
              ),
            ),
          ),
          // FAB menu
          Positioned(
            right: 24,
            bottom: 100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _ActionButton(
                  icon: HugeIcons.strokeRoundedCamera01,
                  label: 'Take Photo',
                  onTap: () {
                    onClose();
                    onImagePicked(ImageSource.camera);
                  },
                ),
                const SizedBox(height: 16),
                _ActionButton(
                  icon: HugeIcons.strokeRoundedImage02,
                  label: 'Upload Photo',
                  onTap: () {
                    onClose();
                    onImagePicked(ImageSource.gallery);
                  },
                ),
                const SizedBox(height: 16),
                _CloseFabButton(onTap: onClose),
              ],
            ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: isDarkMode ? const Color(0xFF23232B) : Colors.white,
      elevation: 6,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isDarkMode ? Colors.white : const Color(0xFF6C3CE9),
                size: 28,
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CloseFabButton extends StatelessWidget {
  final VoidCallback onTap;

  const _CloseFabButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.redAccent,
      shape: const CircleBorder(),
      elevation: 6,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: const Padding(
          padding: EdgeInsets.all(12),
          child: Icon(Icons.close, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}

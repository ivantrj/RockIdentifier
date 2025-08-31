import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:image_picker/image_picker.dart';
import 'package:coin_id/services/haptic_service.dart';
import 'dart:ui';

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
          // Backdrop with blur
          Positioned.fill(
            child: GestureDetector(
              onTap: onClose,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  color: Colors.black.withOpacity(0.18),
                ),
              ),
            ),
          ),
          // FAB menu
          Positioned(
            right: 24,
            bottom: 100,
            child: _AnimatedFabMenuItems(
              onImagePicked: onImagePicked,
              onClose: onClose,
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

class _AnimatedFabMenuItems extends StatefulWidget {
  final Function(ImageSource) onImagePicked;
  final VoidCallback onClose;
  const _AnimatedFabMenuItems({required this.onImagePicked, required this.onClose});

  @override
  State<_AnimatedFabMenuItems> createState() => _AnimatedFabMenuItemsState();
}

class _AnimatedFabMenuItemsState extends State<_AnimatedFabMenuItems> with TickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        _buildAnimatedMenuItem(
          delay: 0,
          child: _ActionButton(
            icon: HugeIcons.strokeRoundedCamera01,
            label: 'Identify Antique',
            onTap: () async {
              await HapticService.instance.vibrate();
              widget.onClose();
              widget.onImagePicked(ImageSource.camera);
            },
          ),
        ),
        const SizedBox(height: 16),
        _buildAnimatedMenuItem(
          delay: 80,
          child: _ActionButton(
            icon: HugeIcons.strokeRoundedImage02,
            label: 'Upload Antique Photo',
            onTap: () async {
              await HapticService.instance.vibrate();
              widget.onClose();
              widget.onImagePicked(ImageSource.gallery);
            },
          ),
        ),
        const SizedBox(height: 16),
        _buildAnimatedMenuItem(
          delay: 160,
          child: _CloseFabButton(onTap: () async {
            await HapticService.instance.vibrate();
            widget.onClose();
          }),
        ),
      ],
    );
  }

  Widget _buildAnimatedMenuItem({required int delay, required Widget child}) {
    final animation = CurvedAnimation(
      parent: _controller,
      curve: Interval(delay / 400, 1, curve: Curves.easeOutBack),
    );
    return AnimatedBuilder(
      animation: animation,
      builder: (context, childWidget) {
        return Opacity(
          opacity: animation.value.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, 40 * (1 - animation.value)),
            child: childWidget,
          ),
        );
      },
      child: child,
    );
  }
}

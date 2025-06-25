// lib/core/widgets/modal_sheet.dart
import 'package:flutter/material.dart';
import 'package:ai_plant_identifier/core/widgets/primary_button.dart';

/// Shows a modal bottom sheet that matches the design in the image
Future<T?> showAppModalSheet<T>({
  required BuildContext context,
  required String title,
  required Widget content,
  String? buttonText,
  VoidCallback? onButtonPressed,
}) {
  final brightness = MediaQuery.of(context).platformBrightness;
  final isDark = brightness == Brightness.dark;

  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    backgroundColor: isDark ? Colors.black87 : Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => _ModalSheetContent(
      title: title,
      content: content,
      buttonText: buttonText,
      onButtonPressed: onButtonPressed,
    ),
  );
}

/// Shows a password change modal sheet
Future<void> showChangePasswordSheet(BuildContext context) {
  final brightness = MediaQuery.of(context).platformBrightness;
  final isDark = brightness == Brightness.dark;

  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: isDark ? Colors.black87 : Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Close button and title row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Change password',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Icon(
                    Icons.close,
                    size: 24,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Current Password
            Text(
              'Your Current Password',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
            const SizedBox(height: 8),
            _buildPasswordField(context, 'Your current password'),
            const SizedBox(height: 24),

            // New Password
            Text(
              'New Password',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
            const SizedBox(height: 8),
            _buildPasswordField(context, 'Your new password'),
            const SizedBox(height: 24),

            // Confirm Password
            Text(
              'Confirm Password',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
            const SizedBox(height: 8),
            _buildPasswordField(context, 'Confirm password'),
            const SizedBox(height: 32),

            // Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C3CE9), // Purple color from image
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Change Password',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    ),
  );
}

/// Generic modal sheet content widget
class _ModalSheetContent extends StatelessWidget {
  final String title;
  final Widget content;
  final String? buttonText;
  final VoidCallback? onButtonPressed;

  const _ModalSheetContent({
    required this.title,
    required this.content,
    this.buttonText,
    this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Close button and title row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Icon(
                    Icons.close,
                    size: 24,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Content
            content,

            // Button (if provided)
            if (buttonText != null && onButtonPressed != null) ...[
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: PrimaryButton(
                  onPressed: onButtonPressed,
                  text: buttonText!,
                  isFullWidth: true,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

Widget _buildPasswordField(BuildContext context, String hintText) {
  return Container(
    height: 56,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
    ),
    child: TextField(
      obscureText: true,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          color: Colors.grey,
          fontSize: 16,
        ),
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
      ),
    ),
  );
}

import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:provider/provider.dart';
import 'package:ai_plant_identifier/features/library/view/detail_screen.dart';
import '../viewmodel/library_viewmodel.dart';
import 'package:ai_plant_identifier/data/models/identified_item.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:ui';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:http/http.dart' as http;
import 'dart:convert';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LibraryViewModel(),
      child: const _LibraryScreenBody(),
    );
  }
}

class _LibraryScreenBody extends StatefulWidget {
  const _LibraryScreenBody();

  @override
  State<_LibraryScreenBody> createState() => _LibraryScreenBodyState();
}

class _LibraryScreenBodyState extends State<_LibraryScreenBody> {
  bool _fabMenuOpen = false;
  final ImagePicker _picker = ImagePicker();

  void _openFabMenu() => setState(() => _fabMenuOpen = true);
  void _closeFabMenu() => setState(() => _fabMenuOpen = false);

  Future<String> _saveImageToAppDir(String imagePath) async {
    final appDir = await getApplicationDocumentsDirectory();
    final fileName = p.basename(imagePath);
    final savedImage =
        await File(imagePath).copy(p.join(appDir.path, '${DateTime.now().millisecondsSinceEpoch}_$fileName'));
    return savedImage.path;
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source, imageQuality: 85);
    if (pickedFile != null) {
      setState(() => _fabMenuOpen = false);
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );
      try {
        final savedPath = await _saveImageToAppDir(pickedFile.path);
        final aiResult = await _identifyPlantWithAI(File(savedPath));
        if (aiResult != null) {
          final details = <String, dynamic>{
            if (aiResult['characteristics'] != null) 'Characteristics': aiResult['characteristics'],
            if (aiResult['careGuide'] != null) 'Care Guide': aiResult['careGuide'],
            if (aiResult['toxicity'] != null) 'Toxicity': aiResult['toxicity'],
            if (aiResult['uses'] != null) 'Uses': aiResult['uses'],
            if (aiResult['difficultyLevel'] != null) 'Difficulty Level': aiResult['difficultyLevel'],
            if (aiResult['propagation'] != null) 'Propagation': aiResult['propagation'],
            if (aiResult['commonProblems'] != null) 'Common Problems': aiResult['commonProblems'],
            if (aiResult['additionalInfo'] != null) 'Additional Info': aiResult['additionalInfo'],
            if (aiResult['wikiLink'] != null) 'Wikipedia': aiResult['wikiLink'],
            if (aiResult['estimatedPrice'] != null) 'Estimated Price': aiResult['estimatedPrice'],
          };
          final item = IdentifiedItem(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            imagePath: savedPath,
            result: aiResult['commonName'] ?? aiResult['name'] ?? 'Unknown',
            subtitle: aiResult['name'] ?? '',
            confidence: _parseConfidence(aiResult['confidence']),
            details: details,
            dateTime: DateTime.now(),
          );
          if (mounted) {
            context.read<LibraryViewModel>().addItem(item);
          }
        } else {
          _showError('AI did not return a valid result.');
        }
      } catch (e) {
        _showError('Failed to identify image: $e');
      } finally {
        if (mounted) Navigator.of(context, rootNavigator: true).pop();
      }
    }
  }

  double _parseConfidence(dynamic confidence) {
    if (confidence == null) return 0.0;
    if (confidence is num) return confidence.toDouble();
    if (confidence is String) {
      switch (confidence.toLowerCase()) {
        case 'high':
          return 0.95;
        case 'medium':
          return 0.7;
        case 'low':
          return 0.4;
        default:
          final parsed = double.tryParse(confidence);
          return parsed ?? 0.0;
      }
    }
    return 0.0;
  }

  Future<Map<String, dynamic>?> _identifyPlantWithAI(File imageFile) async {
    final uri = Uri.parse('https://own-ai-backend-dev.fly.dev/identify-plant');
    final request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('image', imageFile.path));
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['success'] == true && data['result'] != null) {
        return Map<String, dynamic>.from(data['result']);
      }
    }
    return null;
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _onDeleteItem(String id) async {
    await context.read<LibraryViewModel>().deleteItem(id);
  }

  void _onOpenDetail(IdentifiedItem item) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ItemDetailScreen(
          item: item,
          onDelete: () => _onDeleteItem(item.id),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final items = context.watch<LibraryViewModel>().items;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'My Library',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isDarkMode ? const Color(0xFF2A2A36) : const Color(0xFFF5F5F8),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(HugeIcons.strokeRoundedSettings01, size: 22),
              ),
              onPressed: () {
                Navigator.pushNamed(context, '/settings');
              },
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Main content
          items.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: isDarkMode ? const Color(0xFF2A2A36).withOpacity(0.7) : const Color(0xFFF5F5F8),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          HugeIcons.strokeRoundedImage01,
                          size: 48,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Your library is empty',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Tap the + button to identify something!',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 20,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return GestureDetector(
                      onTap: () => _onOpenDetail(item),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: item.imagePath.isNotEmpty && File(item.imagePath).existsSync()
                                ? Image.file(
                                    File(item.imagePath),
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    color: Colors.grey[200],
                                    alignment: Alignment.center,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: const [
                                        Icon(Icons.broken_image, size: 48, color: Colors.grey),
                                        SizedBox(height: 8),
                                        Text('Image not found', style: TextStyle(color: Colors.grey)),
                                      ],
                                    ),
                                  ),
                          ),
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: ClipRRect(
                              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.black.withOpacity(0.1),
                                        Colors.black.withOpacity(0.6),
                                      ],
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              item.result,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withOpacity(0.25),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              '${(item.confidence * 100).toStringAsFixed(0)}%',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        item.subtitle,
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontStyle: FontStyle.italic,
                                          fontSize: 13,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
          // FAB menu overlay
          if (_fabMenuOpen) ...[
            Positioned.fill(
              child: GestureDetector(
                onTap: _closeFabMenu,
                child: Container(
                  color: Colors.black.withOpacity(0.3),
                ),
              ),
            ),
            // Floating action menu
            Positioned(
              right: 24,
              bottom: 100,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _ActionButton(
                    icon: HugeIcons.strokeRoundedCamera01,
                    label: 'Take Photo',
                    onTap: () async {
                      _closeFabMenu();
                      await _pickImage(ImageSource.camera);
                    },
                  ),
                  const SizedBox(height: 16),
                  _ActionButton(
                    icon: HugeIcons.strokeRoundedImage02,
                    label: 'Upload Photo',
                    onTap: () async {
                      _closeFabMenu();
                      await _pickImage(ImageSource.gallery);
                    },
                  ),
                  const SizedBox(height: 16),
                  _CloseFabButton(onTap: _closeFabMenu),
                ],
              ),
            ),
          ],
        ],
      ),
      floatingActionButton: !_fabMenuOpen
          ? FloatingActionButton(
              onPressed: _openFabMenu,
              child: const Icon(HugeIcons.strokeRoundedCameraAi, size: 32),
            )
          : null,
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({required this.icon, required this.label, required this.onTap});

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
              Icon(icon, color: isDarkMode ? Colors.white : const Color(0xFF6C3CE9), size: 28),
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

import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../services/ai_service.dart';
import '../widgets/app_logo.dart';
import '../widgets/before_after_image_card.dart';
import '../widgets/gradient_action_button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImagePicker _picker = ImagePicker();
  final AiService _aiService = AiService();

  File? _originalImage;
  Uint8List? _enhancedImageBytes;
  bool _isProcessing = false;
  double _comparisonValue = 0.5;

  Future<void> _pickImage(ImageSource source) async {
    try {
      HapticFeedback.selectionClick();
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 100,
      );

      if (pickedFile == null) {
        _showSnackBar('No image selected.');
        return;
      }

      setState(() {
        _originalImage = File(pickedFile.path);
        _enhancedImageBytes = null;
        _comparisonValue = 0.5;
      });

      _showSnackBar('Image selected successfully.');
    } catch (_) {
      _showSnackBar('Could not pick image. Please try again.');
    }
  }

  Future<void> _showSourcePicker() async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: const Text('Take a Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _enhanceImage() async {
    if (_originalImage == null) {
      _showSnackBar('Please select an image first.');
      return;
    }

    HapticFeedback.lightImpact();
    setState(() => _isProcessing = true);

    try {
      final Uint8List enhancedBytes =
          await _aiService.enhanceImage(_originalImage!);

      if (!mounted) return;

      setState(() {
        _enhancedImageBytes = enhancedBytes;
      });
      _showSnackBar('Image enhanced successfully.');
    } on AiServiceException catch (error) {
      if (!mounted) return;
      _showSnackBar(error.message);
    } catch (_) {
      if (!mounted) return;
      _showSnackBar('Something went wrong while enhancing image.');
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _saveEnhancedImage() async {
    if (_enhancedImageBytes == null) {
      _showSnackBar('No enhanced image available to save.');
      return;
    }

    HapticFeedback.mediumImpact();
    try {
      final String savedPath = await _aiService.saveEnhancedImage(
        _enhancedImageBytes!,
      );
      if (!mounted) return;
      _showSnackBar('Enhanced image saved to: $savedPath');
    } on AiServiceException catch (error) {
      if (!mounted) return;
      _showSnackBar(error.message);
    } catch (_) {
      if (!mounted) return;
      _showSnackBar('Could not save image. Please try again.');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        margin: const EdgeInsets.all(14),
        padding: const EdgeInsets.all(14),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('AI Photo Enhancer Pro'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isProcessing ? null : _enhanceImage,
        label: const Text('Quick Enhance'),
        icon: const Icon(Icons.auto_awesome_rounded),
      ),
      body: Stack(
        children: [
          const _GradientBackground(),
          SafeArea(
            child: AnimatedOpacity(
              opacity: _isProcessing ? 0.88 : 1,
              duration: const Duration(milliseconds: 250),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                child: Column(
                  children: [
                    const AppLogo(),
                    const SizedBox(height: 12),
                    Text(
                      'AI Photo Enhancer Pro',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Enhance your photos with AI',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Colors.white.withValues(alpha: 0.88),
                      ),
                    ),
                    const SizedBox(height: 18),
                    _buildGlassActionCard(isDark),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 360,
                      child: BeforeAfterImageCard(
                        originalImage: _originalImage,
                        enhancedImageBytes: _enhancedImageBytes,
                        sliderValue: _comparisonValue,
                        onSliderChanged: (double value) {
                          setState(() => _comparisonValue = value);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_isProcessing) const _ProcessingOverlay(),
        ],
      ),
    );
  }

  Widget _buildGlassActionCard(bool isDark) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.white.withValues(alpha: 0.20),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.25),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 24,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Column(
            children: [
              GradientActionButton(
                label: 'Pick Image',
                icon: Icons.add_photo_alternate_outlined,
                gradientColors: const [
                  Color(0xFF00C9FF),
                  Color(0xFF6C63FF),
                ],
                onPressed: _isProcessing ? null : _showSourcePicker,
              ),
              const SizedBox(height: 10),
              GradientActionButton(
                label: 'Enhance Image',
                icon: Icons.auto_fix_high_rounded,
                gradientColors: const [
                  Color(0xFF6C63FF),
                  Color(0xFFFF6FD8),
                ],
                isPrimary: true,
                onPressed: _isProcessing ? null : _enhanceImage,
              ),
              const SizedBox(height: 10),
              GradientActionButton(
                label: 'Save Image',
                icon: Icons.download_rounded,
                gradientColors: const [
                  Color(0xFF4A7BFF),
                  Color(0xFF00C9FF),
                ],
                onPressed: _isProcessing ? null : _saveEnhancedImage,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GradientBackground extends StatelessWidget {
  const _GradientBackground();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF6C63FF),
            Color(0xFF00C9FF),
            Color(0xFFFF6FD8),
          ],
        ),
      ),
      child: const SizedBox.expand(),
    );
  }
}

class _ProcessingOverlay extends StatelessWidget {
  const _ProcessingOverlay();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.25),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 74,
              height: 74,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00C9FF).withValues(alpha: 0.45),
                    blurRadius: 30,
                    spreadRadius: 6,
                  ),
                ],
              ),
              child: const CircularProgressIndicator(
                strokeWidth: 5,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Enhancing...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
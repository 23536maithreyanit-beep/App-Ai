import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';

class BeforeAfterImageCard extends StatelessWidget {
  const BeforeAfterImageCard({
    super.key,
    required this.originalImage,
    required this.enhancedImageBytes,
    required this.sliderValue,
    required this.onSliderChanged,
  });

  final File? originalImage;
  final Uint8List? enhancedImageBytes;
  final double sliderValue;
  final ValueChanged<double> onSliderChanged;

  @override
  Widget build(BuildContext context) {
    final bool hasImage = originalImage != null;
    final bool hasEnhancedImage = enhancedImageBytes != null;
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: const Color(0xFF6C63FF).withValues(alpha: 0.35),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6FD8).withValues(alpha: 0.14),
            blurRadius: 30,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          color: isDarkMode
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.white.withValues(alpha: 0.30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: !hasImage
                    ? const Center(
                        child: Text(
                          'Pick an image to preview enhancement.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                        ),
                      )
                    : Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.file(
                            originalImage!,
                            fit: BoxFit.cover,
                          ),
                          if (hasEnhancedImage)
                            ClipRect(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                widthFactor: sliderValue,
                                child: SizedBox.expand(
                                  child: Image.memory(
                                    enhancedImageBytes!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          if (hasEnhancedImage)
                            Align(
                              alignment: Alignment(sliderValue * 2 - 1, 0),
                              child: Container(
                                width: 3,
                                color: Colors.white.withValues(alpha: 0.95),
                              ),
                            ),
                          Positioned(
                            left: 12,
                            top: 12,
                            child: _tag('Before'),
                          ),
                          if (hasEnhancedImage)
                            Positioned(
                              right: 12,
                              top: 12,
                              child: _tag('After'),
                            ),
                        ],
                      ),
              ),
              if (hasImage && hasEnhancedImage)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
                  child: Slider(
                    value: sliderValue,
                    min: 0,
                    max: 1,
                    onChanged: onSliderChanged,
                    activeColor: const Color(0xFF00C9FF),
                    inactiveColor: const Color(0xFF6C63FF).withValues(alpha: 0.3),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tag(String text) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';

class GradientActionButton extends StatefulWidget {
  const GradientActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.gradientColors,
    this.onPressed,
    this.isPrimary = false,
  });

  final String label;
  final IconData icon;
  final List<Color> gradientColors;
  final VoidCallback? onPressed;
  final bool isPrimary;

  @override
  State<GradientActionButton> createState() => _GradientActionButtonState();
}

class _GradientActionButtonState extends State<GradientActionButton> {
  double _scale = 1;

  void _onTapDown(TapDownDetails _) {
    setState(() => _scale = 0.98);
  }

  void _onTapUp(TapUpDetails _) {
    setState(() => _scale = 1);
  }

  void _onTapCancel() {
    setState(() => _scale = 1);
  }

  @override
  Widget build(BuildContext context) {
    final bool enabled = widget.onPressed != null;

    return AnimatedScale(
      scale: _scale,
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOut,
      child: Opacity(
        opacity: enabled ? 1 : 0.55,
        child: GestureDetector(
          onTapDown: enabled ? _onTapDown : null,
          onTapUp: enabled ? _onTapUp : null,
          onTapCancel: enabled ? _onTapCancel : null,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: widget.gradientColors,
              ),
              borderRadius: BorderRadius.circular(22),
              boxShadow: widget.isPrimary
                  ? [
                      BoxShadow(
                        color: widget.gradientColors.last.withValues(alpha: 0.45),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ]
                  : null,
            ),
            child: ElevatedButton.icon(
              onPressed: widget.onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              icon: Icon(widget.icon, color: Colors.white),
              label: Text(
                widget.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
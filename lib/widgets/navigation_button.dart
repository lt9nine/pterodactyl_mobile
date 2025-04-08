import 'package:flutter/material.dart';

class NavigationButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onPressed;
  final TextStyle? textStyle; // Optional parameter for text style
  final EdgeInsetsGeometry? padding; // Optional parameter for padding

  const NavigationButton({
    super.key,
    required this.label,
    required this.color,
    required this.onPressed,
    this.textStyle,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(8.0), // Default padding
          child: Text(
            label,
            style: textStyle, // Apply custom text style if provided
          ),
        ),
      ),
    );
  }
}

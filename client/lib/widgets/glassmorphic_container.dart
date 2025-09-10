import 'dart:ui'; // for ImageFilter
import 'package:flutter/material.dart';
import 'package:recruitment_frontend/utils/constants.dart';

class GlassmorphicContainer extends StatelessWidget {
  final Widget child;
  final double? width;        // nullable
  final double? height;       // nullable
  final double borderRadius;
  final double blur;
  final EdgeInsets padding;
  final EdgeInsets margin;
  final Border border;

  const GlassmorphicContainer({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.borderRadius = 20,
    this.blur = 20,
    this.padding = const EdgeInsets.all(20),
    this.margin = EdgeInsets.zero,
    this.border = const Border.fromBorderSide(
      BorderSide(color: Colors.white30),
    ),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity, // full width if not provided
      margin: margin,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        border: border,
        gradient: AppGradients.glassmorphism,
        boxShadow: AppShadows.glassmorphism,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Padding(
            padding: padding,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: 0,          // ensures no infinite height
                maxHeight: height ?? double.infinity, // maxHeight if provided
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}

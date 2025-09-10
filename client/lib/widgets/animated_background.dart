import 'package:flutter/material.dart';
import 'dart:math';

class AnimatedBackground extends StatefulWidget {
  final Widget child;
  final int particleCount;

  const AnimatedBackground({
    super.key,
    required this.child,
    this.particleCount = 20,
  });

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Particle> particles = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // Initialize particles
    final random = Random();
    for (int i = 0; i < widget.particleCount; i++) {
      particles.add(
        Particle(
          x: random.nextDouble() * 100,
          y: random.nextDouble() * 100,
          size: random.nextDouble() * 4 + 1,
          speed: random.nextDouble() * 0.5 + 0.1,
          direction: random.nextDouble() * 2 * pi,
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Update particles
        for (var particle in particles) {
          particle.update();
        }

        return CustomPaint(
          painter: _BackgroundPainter(particles),
          child: widget.child,
        );
      },
    );
  }
}

class Particle {
  double x;
  double y;
  double size;
  double speed;
  double direction;

  Particle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.direction,
  });

  void update() {
    x += cos(direction) * speed;
    y += sin(direction) * speed;

    // Wrap around edges
    if (x > 100) x = 0;
    if (x < 0) x = 100;
    if (y > 100) y = 0;
    if (y < 0) y = 100;
  }
}

class _BackgroundPainter extends CustomPainter {
  final List<Particle> particles;

  _BackgroundPainter(this.particles);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    for (var particle in particles) {
      final x = particle.x / 100 * size.width;
      final y = particle.y / 100 * size.height;
      canvas.drawCircle(Offset(x, y), particle.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../models.dart';
import '../theme.dart';
import 'home_shell.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  /// Drives the one-time entrance: every element slides into place on its own slice of this timeline.
  late final AnimationController _intro = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  );
  late final AnimationController _dots = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat();

  @override
  void initState() {
    super.initState();
    final reduceMotion =
        WidgetsBinding
            .instance
            .platformDispatcher
            .accessibilityFeatures
            .disableAnimations;
    reduceMotion ? _intro.value = 1 : _intro.forward();
    Future.delayed(const Duration(milliseconds: 2600), _next);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage('assets/images/background.png'), context);
  }

  void _next() {
    if (!mounted) return;
    final hasProfile = AppScope.read(context).profile != null;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 2000),
        pageBuilder:
            (_, __, ___) =>
                hasProfile ? const HomeShell() : const OnboardingScreen(),
        transitionsBuilder:
            (_, animation, __, child) =>
                FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  void dispose() {
    _intro.dispose();
    _dots.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const cornerStyle = TextStyle(
      fontSize: 10,
      height: 1.3,
      letterSpacing: 1.5,
      fontWeight: FontWeight.w500,
    );

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const ColoredBox(color: AppColors.bg),
          _Reveal(
            controller: _intro,
            start: 0.0,
            end: 0.4,
            child: Opacity(
              opacity: 0.8,
              child: Image.asset(
                'assets/images/background.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: Stack(
              children: [
                Positioned(
                  top: 16,
                  right: 20,
                  child: _Reveal(
                    controller: _intro,
                    start: 0.55,
                    end: 0.9,
                    from: const Offset(1.5, 0),
                    child: const Text(
                      'PAIN\nTURNS\nINTO\nPOWER',
                      style: cornerStyle,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 24,
                  left: 20,
                  child: _Reveal(
                    controller: _intro,
                    start: 0.6,
                    end: 0.95,
                    from: const Offset(-1.5, 0),
                    child: const Text(
                      'SMALL\nSTEPS\nBIG\nPROGRESS',
                      style: cornerStyle,
                    ),
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _Reveal(
                        controller: _intro,
                        start: 0.1,
                        end: 0.55,
                        scaleFrom: 0.6,
                        curve: Curves.easeOutBack,
                        child: const _Logo(size: 200),
                      ),
                      const SizedBox(height: 32),
                      _Reveal(
                        controller: _intro,
                        start: 0.3,
                        end: 0.65,
                        from: const Offset(-0.4, 0),
                        child: const Text(
                          'Personal Workout',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            height: 1.2,
                          ),
                        ),
                      ),
                      _Reveal(
                        controller: _intro,
                        start: 0.38,
                        end: 0.72,
                        from: const Offset(0.6, 0),
                        child: const Text(
                          'Tracker',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            height: 1.2,
                            color: AppColors.red,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      _Reveal(
                        controller: _intro,
                        start: 0.48,
                        end: 0.8,
                        from: const Offset(0, 0.8),
                        child: const Text(
                          'Consistency is key',
                          style: TextStyle(color: AppColors.muted),
                        ),
                      ),
                      const SizedBox(height: 72),
                      _Reveal(
                        controller: _intro,
                        start: 0.62,
                        end: 1.0,
                        from: const Offset(0, 0.8),
                        child: Column(
                          children: [
                            _LoadingDots(animation: _dots),
                            const SizedBox(height: 14),
                            const Text(
                              'LOADING...',
                              style: TextStyle(
                                color: AppColors.muted,
                                fontSize: 10,
                                letterSpacing: 4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Fades a child in while sliding it from [from] (in multiples of its own size)
/// and/or scaling it up from [scaleFrom], during the [start]–[end] slice of [controller].
class _Reveal extends StatelessWidget {
  const _Reveal({
    required this.controller,
    required this.start,
    required this.end,
    required this.child,
    this.from = Offset.zero,
    this.scaleFrom = 1,
    this.curve = Curves.easeOutCubic,
  });

  final AnimationController controller;
  final double start;
  final double end;
  final Offset from;
  final double scaleFrom;
  final Curve curve;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = CurvedAnimation(
      parent: controller,
      curve: Interval(start, end, curve: curve),
    );
    final fade = CurvedAnimation(
      parent: controller,
      curve: Interval(start, end, curve: Curves.easeOut),
    );
    Widget result = child;
    if (scaleFrom != 1) {
      result = ScaleTransition(
        scale: Tween(begin: scaleFrom, end: 1.0).animate(t),
        child: result,
      );
    }
    if (from != Offset.zero) {
      result = SlideTransition(
        position: Tween(begin: from, end: Offset.zero).animate(t),
        child: result,
      );
    }
    return FadeTransition(opacity: fade, child: result);
  }
}

/// The ring + dumbbell logo with the red glow from the design (flutter_svg skips SVG filters).
class _Logo extends StatelessWidget {
  const _Logo({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) {
    // The SVG's ring (r=125) sits inside a 268px canvas; inset the glow to match the ring.
    final ring = size * 250 / 268;
    return SizedBox.square(
      dimension: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: ring,
            height: ring,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.red.withValues(alpha: 0.55),
                  blurRadius: 28,
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: AppColors.red.withValues(alpha: 0.25),
                  blurRadius: 60,
                  spreadRadius: 8,
                ),
              ],
            ),
          ),
          SvgPicture.asset(
            'assets/icons/Workoutlogo.svg',
            width: size,
            height: size,
          ),
        ],
      ),
    );
  }
}

class _LoadingDots extends StatelessWidget {
  const _LoadingDots({required this.animation});
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder:
          (_, __) => Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(3, (i) {
              final active = (animation.value * 3).floor() == i;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      active
                          ? AppColors.red
                          : AppColors.muted.withValues(alpha: 0.4),
                ),
              );
            }),
          ),
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../notes/presentation/pages/home_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Timer? _timer;

  Animation<double> _interval(double begin, double end,
          [Curve curve = Curves.easeOutCubic]) =>
      CurvedAnimation(
        parent: _controller,
        curve: Interval(begin, end, curve: curve),
      );

  late final Animation<double> _logo = _interval(0.0, 0.5, Curves.easeOutBack);
  late final Animation<double> _fan = _interval(0.25, 0.7, Curves.easeOutBack);
  late final Animation<double> _name = _interval(0.4, 0.8);
  late final Animation<double> _tagline = _interval(0.55, 0.95);
  late final Animation<double> _progress =
      _interval(0.3, 1.0, Curves.easeInOut);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1900),
    )..forward();

    _timer = Timer(const Duration(milliseconds: 2400), _goHome);
  }

  void _goHome() {
    if (!mounted) return;
    Get.off(
      () => const HomePage(),
      transition: Transition.fadeIn,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Widget _fadeUp(Animation<double> a, Widget child, {double dy = 18}) =>
      AnimatedBuilder(
        animation: a,
        child: child,
        builder: (_, child) => Opacity(
          opacity: a.value.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, dy * (1 - a.value)),
            child: child,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
      ),
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: AppColors.primaryGradient),
          child: Stack(
            children: [
              const PositionedDirectional(
                top: -90,
                end: -70,
                child: _Glow(size: 260, alpha: 0.07),
              ),
              const PositionedDirectional(
                bottom: -120,
                start: -80,
                child: _Glow(size: 300, alpha: 0.05),
              ),
              PositionedDirectional(
                bottom: 140,
                end: 40,
                child: _Glow(size: 14, alpha: 1, color: AppColors.accent),
              ),
              const PositionedDirectional(
                top: 170,
                start: 48,
                child: _Glow(size: 8, alpha: 0.5),
              ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedBuilder(
                      animation: _controller,
                      builder: (_, __) => _LogoMark(
                        scale: _logo.value,
                        fan: _fan.value,
                      ),
                    ),
                    const SizedBox(height: 34),
                    _fadeUp(
                      _name,
                      const Text(
                        AppStrings.appName,
                        textDirection: TextDirection.ltr,
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                          color: AppColors.cream,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    _fadeUp(
                      _tagline,
                      Text(
                        AppStrings.tagline,
                        style: TextStyle(
                          fontSize: 15,
                          color: AppColors.cream.withValues(alpha: 0.72),
                        ),
                      ),
                      dy: 12,
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 64,
                child: Center(
                  child: Container(
                    width: 64,
                    height: 4,
                    clipBehavior: Clip.antiAlias,
                    decoration: BoxDecoration(
                      color: AppColors.cream.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: AnimatedBuilder(
                      animation: _progress,
                      builder: (_, __) => FractionallySizedBox(
                        alignment: AlignmentDirectional.centerStart,
                        widthFactor: _progress.value,
                        child: const ColoredBox(color: AppColors.accent),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// شعار من أوراق ملاحظات تنفتح كمروحة.
class _LogoMark extends StatelessWidget {
  final double scale;
  final double fan;

  const _LogoMark({required this.scale, required this.fan});

  @override
  Widget build(BuildContext context) {
    Widget sheet(Color color, double angle, Offset offset) =>
        Transform.translate(
          offset: offset * fan,
          child: Transform.rotate(
            angle: angle * fan,
            child: Container(
              width: 96,
              height: 110,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(26),
              ),
            ),
          ),
        );

    return Transform.scale(
      scale: scale,
      child: SizedBox(
        width: 170,
        height: 150,
        child: Stack(
          alignment: Alignment.center,
          children: [
            sheet(AppColors.noteColors[4], -0.26, const Offset(-22, 6)),
            sheet(AppColors.accent, 0.22, const Offset(22, 4)),
            Container(
              width: 96,
              height: 110,
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
              decoration: BoxDecoration(
                color: AppColors.cream,
                borderRadius: BorderRadius.circular(26),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.18),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final w in [0.55, 1.0, 0.8])
                    Padding(
                      padding: const EdgeInsets.only(bottom: 9),
                      child: FractionallySizedBox(
                        widthFactor: w,
                        child: Container(
                          height: 6,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                  const Spacer(),
                  const Align(
                    alignment: AlignmentDirectional.bottomEnd,
                    child: Icon(
                      Icons.edit_rounded,
                      size: 26,
                      color: AppColors.accent,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Glow extends StatelessWidget {
  final double size;
  final double alpha;
  final Color color;

  const _Glow({
    required this.size,
    required this.alpha,
    this.color = AppColors.cream,
  });

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: alpha),
        ),
      );
}

import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppSlideUpRoute extends PageRouteBuilder {
  final Widget page;
  AppSlideUpRoute({required this.page})
      : super(
          transitionDuration          : const Duration(milliseconds: 380),
          reverseTransitionDuration   : const Duration(milliseconds: 300),
          pageBuilder                 : (_, __, ___) => page,
          transitionsBuilder: (_, animation, secondaryAnimation, child) {
            final slide = Tween<Offset>(
              begin: const Offset(0, 0.06),
              end  : Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve : Curves.easeOutCubic,
            ));
            final fade = CurvedAnimation(
              parent: animation,
              curve : Curves.easeIn,
            );
            return FadeTransition(
              opacity: fade,
              child: SlideTransition(position: slide, child: child),
            );
          },
        );
}

/// Tombol back dengan animasi hover (untuk hero header).
class AppAnimatedBackButton extends StatefulWidget {
  final VoidCallback onTap;
  const AppAnimatedBackButton({Key? key, required this.onTap}) : super(key: key);

  @override
  State<AppAnimatedBackButton> createState() => _AppAnimatedBackButtonState();
}

class _AppAnimatedBackButtonState extends State<AppAnimatedBackButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync     : this,
    duration  : const Duration(milliseconds: 100),
    lowerBound: 0.0,
    upperBound: 1.0,
  );

  late final Animation<double> _scale = Tween<double>(begin: 1.0, end: 0.85)
      .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

  bool _isHovered = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor : SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit : (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => _ctrl.forward(),
        onTapUp  : (_) => _ctrl.reverse(),
        onTapCancel: () => _ctrl.reverse(),
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve   : Curves.easeOut,
          width   : 36, height: 36,
          decoration: BoxDecoration(
            color       : _isHovered ? Colors.white : Colors.white.withOpacity(0.85),
            shape       : BoxShape.circle,
            boxShadow   : _isHovered ? [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)] : [],
          ),
          child: ScaleTransition(
            scale: _scale,
            child: const Icon(Icons.arrow_back_ios_new, size: 16, color: AppColors.navy),
          ),
        ),
      ),
    );
  }
}

/// Motion card untuk interaksi melayang (hover) dan ditekan (press).
/// Berguna untuk Banner atau Card yang bisa di-klik.
class AppPressableMotionCard extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const AppPressableMotionCard({
    Key? key,
    required this.child,
    required this.onTap,
  }) : super(key: key);

  @override
  State<AppPressableMotionCard> createState() => _AppPressableMotionCardState();
}

class _AppPressableMotionCardState extends State<AppPressableMotionCard> {
  bool _isHovered = false;
  bool _isPressed = false;

  void _setHovered(bool value) {
    if (_isHovered == value) return;
    setState(() => _isHovered = value);
  }

  void _setPressed(bool value) {
    if (_isPressed == value) return;
    setState(() => _isPressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => _setHovered(true),
      onExit: (_) => _setHovered(false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        onTapDown: (_) => _setPressed(true),
        onTapUp: (_) => _setPressed(false),
        onTapCancel: () => _setPressed(false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          transform: Matrix4.identity()
            ..translate(0.0, _isHovered ? -6.0 : 0.0) 
            ..scale(_isPressed ? 0.97 : 1.0),         
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(_isHovered ? 0.08 : 0.02),
                blurRadius: _isHovered ? 20 : 10,
                offset: Offset(0, _isHovered ? 10 : 4),
              )
            ],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

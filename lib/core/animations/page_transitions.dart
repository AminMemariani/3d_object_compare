import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Custom page transition animations
class PageTransitions {
  /// Slide transition from right to left
  static Widget slideFromRight(Widget child, Animation<double> animation) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
      child: child,
    );
  }

  /// Slide transition from left to right
  static Widget slideFromLeft(Widget child, Animation<double> animation) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(-1.0, 0.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
      child: child,
    );
  }

  /// Slide transition from bottom to top
  static Widget slideFromBottom(Widget child, Animation<double> animation) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.0, 1.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
      child: child,
    );
  }

  /// Fade transition
  static Widget fade(Widget child, Animation<double> animation) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
      child: child,
    );
  }

  /// Scale transition
  static Widget scale(Widget child, Animation<double> animation) {
    return ScaleTransition(
      scale: Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.elasticOut)),
      child: child,
    );
  }

  /// Rotation transition
  static Widget rotate(Widget child, Animation<double> animation) {
    return RotationTransition(
      turns: Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
      child: child,
    );
  }

  /// Combined slide and fade transition
  static Widget slideAndFade(Widget child, Animation<double> animation) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.0, 0.3),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
      child: FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
        child: child,
      ),
    );
  }

  /// 3D flip transition
  static Widget flip3D(Widget child, Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final isHalfway = animation.value >= 0.5;
        final rotation = animation.value * math.pi;

        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(rotation),
          child: isHalfway
              ? Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()..rotateY(math.pi),
                  child: child,
                )
              : child,
        );
      },
      child: child,
    );
  }

  /// Zoom transition
  static Widget zoom(Widget child, Animation<double> animation) {
    return ScaleTransition(
      scale: Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutBack)),
      child: FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
        child: child,
      ),
    );
  }

  /// Elastic transition
  static Widget elastic(Widget child, Animation<double> animation) {
    return ScaleTransition(
      scale: Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.elasticOut)),
      child: child,
    );
  }

  /// Bounce transition
  static Widget bounce(Widget child, Animation<double> animation) {
    return ScaleTransition(
      scale: Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.bounceOut)),
      child: child,
    );
  }

  /// Slide and scale transition
  static Widget slideAndScale(Widget child, Animation<double> animation) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.0, 0.3),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic)),
      child: ScaleTransition(
        scale: Tween<double>(begin: 0.8, end: 1.0).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
        ),
        child: child,
      ),
    );
  }

  /// 3D cube transition
  static Widget cube3D(Widget child, Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final rotation = animation.value * math.pi / 2;

        return Transform(
          alignment: Alignment.centerLeft,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(rotation),
          child: child,
        );
      },
      child: child,
    );
  }

  /// Curtain transition
  static Widget curtain(Widget child, Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return ClipRect(
          child: Align(
            alignment: Alignment.centerLeft,
            widthFactor: animation.value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  /// Spiral transition
  static Widget spiral(Widget child, Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final rotation = animation.value * 2 * math.pi;
        final scale = Tween<double>(begin: 0.0, end: 1.0)
            .animate(
              CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
            )
            .value;

        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..rotateZ(rotation)
            ..scale(scale),
          child: child,
        );
      },
      child: child,
    );
  }

  /// Wipe transition
  static Widget wipe(Widget child, Animation<double> animation) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return ClipRect(
          child: Align(
            alignment: Alignment.topCenter,
            heightFactor: animation.value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

/// Custom page route with transition
class CustomPageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;
  final PageTransitionType transitionType;
  final Duration duration;
  final Duration reverseDuration;

  CustomPageRoute({
    required this.child,
    this.transitionType = PageTransitionType.slideFromRight,
    this.duration = const Duration(milliseconds: 300),
    this.reverseDuration = const Duration(milliseconds: 300),
  }) : super(
         pageBuilder: (context, animation, secondaryAnimation) => child,
         transitionDuration: duration,
         reverseTransitionDuration: reverseDuration,
         transitionsBuilder: (context, animation, secondaryAnimation, child) {
           return _buildTransitionStatic(transitionType, child, animation);
         },
       );

  static Widget _buildTransitionStatic(
    PageTransitionType type,
    Widget child,
    Animation<double> animation,
  ) {
    switch (type) {
      case PageTransitionType.slideFromRight:
        return PageTransitions.slideFromRight(child, animation);
      case PageTransitionType.slideFromLeft:
        return PageTransitions.slideFromLeft(child, animation);
      case PageTransitionType.slideFromBottom:
        return PageTransitions.slideFromBottom(child, animation);
      case PageTransitionType.fade:
        return PageTransitions.fade(child, animation);
      case PageTransitionType.scale:
        return PageTransitions.scale(child, animation);
      case PageTransitionType.rotate:
        return PageTransitions.rotate(child, animation);
      case PageTransitionType.slideAndFade:
        return PageTransitions.slideAndFade(child, animation);
      case PageTransitionType.flip3D:
        return PageTransitions.flip3D(child, animation);
      case PageTransitionType.zoom:
        return PageTransitions.zoom(child, animation);
      case PageTransitionType.elastic:
        return PageTransitions.elastic(child, animation);
      case PageTransitionType.bounce:
        return PageTransitions.bounce(child, animation);
      case PageTransitionType.slideAndScale:
        return PageTransitions.slideAndScale(child, animation);
      case PageTransitionType.cube3D:
        return PageTransitions.cube3D(child, animation);
      case PageTransitionType.curtain:
        return PageTransitions.curtain(child, animation);
      case PageTransitionType.spiral:
        return PageTransitions.spiral(child, animation);
      case PageTransitionType.wipe:
        return PageTransitions.wipe(child, animation);
    }
  }
}

/// Page transition types
enum PageTransitionType {
  slideFromRight,
  slideFromLeft,
  slideFromBottom,
  fade,
  scale,
  rotate,
  slideAndFade,
  flip3D,
  zoom,
  elastic,
  bounce,
  slideAndScale,
  cube3D,
  curtain,
  spiral,
  wipe,
}

/// Hero transition for shared elements
class HeroPageRoute<T> extends PageRouteBuilder<T> {
  final Widget child;
  final String heroTag;
  final Duration duration;

  HeroPageRoute({
    required this.child,
    required this.heroTag,
    this.duration = const Duration(milliseconds: 300),
  }) : super(
         pageBuilder: (context, animation, secondaryAnimation) => child,
         transitionDuration: duration,
         transitionsBuilder: (context, animation, secondaryAnimation, child) {
           return Hero(
             tag: heroTag,
             child: FadeTransition(opacity: animation, child: child),
           );
         },
       );
}

/// Staggered animation for multiple elements
class StaggeredAnimation extends StatelessWidget {
  final List<Widget> children;
  final Duration duration;
  final Duration staggerDelay;

  const StaggeredAnimation({
    super.key,
    required this.children,
    this.duration = const Duration(milliseconds: 300),
    this.staggerDelay = const Duration(milliseconds: 100),
  });

  @override
  Widget build(BuildContext context) {
    return _StaggeredAnimationWidget(
      duration: duration,
      staggerDelay: staggerDelay,
      children: children,
    );
  }
}

class _StaggeredAnimationWidget extends StatefulWidget {
  final List<Widget> children;
  final Duration duration;
  final Duration staggerDelay;

  const _StaggeredAnimationWidget({
    required this.children,
    required this.duration,
    required this.staggerDelay,
  });

  @override
  State<_StaggeredAnimationWidget> createState() =>
      _StaggeredAnimationWidgetState();
}

class _StaggeredAnimationWidgetState extends State<_StaggeredAnimationWidget>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.children.length,
      (index) => AnimationController(duration: widget.duration, vsync: this),
    );

    _animations = _controllers.map((controller) {
      return Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: controller, curve: Curves.easeOutCubic),
      );
    }).toList();

    _startAnimations();
  }

  void _startAnimations() {
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(
        Duration(milliseconds: widget.staggerDelay.inMilliseconds * i),
        () {
          if (mounted) {
            _controllers[i].forward();
          }
        },
      );
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(widget.children.length, (index) {
        return AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, 50 * (1 - _animations[index].value)),
              child: Opacity(
                opacity: _animations[index].value,
                child: widget.children[index],
              ),
            );
          },
        );
      }),
    );
  }
}

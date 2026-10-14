import 'package:flutter/material.dart';

class ResponsiveWrapper extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final Color? backgroundColor;

  const ResponsiveWrapper({
    super.key,
    required this.child,
    this.maxWidth = 500,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > maxWidth) {
          return Container(
            color: backgroundColor ?? const Color(0xFF0F172A),
            alignment: Alignment.center,
            child: Container(
              constraints: BoxConstraints(maxWidth: maxWidth),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(50),
                    blurRadius: 30,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: child,
            ),
          );
        }
        return Container(
          color: backgroundColor ?? Colors.white,
          child: child,
        );
      },
    );
  }
}

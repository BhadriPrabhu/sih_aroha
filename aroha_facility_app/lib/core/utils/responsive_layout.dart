// lib/core/utils/responsive_layout.dart
import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget web;
  static const double breakpoint = 800.0;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    required this.web,
  });

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width > breakpoint;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return constraints.maxWidth > breakpoint ? web : mobile;
      },
    );
  }
}
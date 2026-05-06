/// Defines responsive breakpoints used throughout the application.
///
/// These constants are consumed by [ResponsiveFramework] at the app root
/// to scale UI across mobile, tablet, and desktop screen sizes.
library;

import 'package:responsive_framework/responsive_framework.dart';

/// Ordered list of responsive breakpoints for the application.
const List<Breakpoint> kBreakpoints = [
  Breakpoint(start: 0, end: 480, name: MOBILE),
  Breakpoint(start: 481, end: 1024, name: TABLET),
  Breakpoint(start: 1025, end: double.infinity, name: DESKTOP),
];

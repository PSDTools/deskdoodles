/// This library contains the primitive block of our Material-based design system.
library;

import 'package:flutter/material.dart';

/// The app's color scheme.
final scheme = ColorScheme.fromSeed(
  seedColor: const Color.fromRGBO(253, 216, 53, 1),
);

/// The app's dark color scheme.
final darkScheme = ColorScheme.fromSeed(
  seedColor: Colors.yellow.shade700,
  brightness: Brightness.dark,
);

/// The app's theme.
final theme = ThemeData(useMaterial3: true, colorScheme: scheme);

/// The app's dark theme.
final darkTheme = ThemeData(useMaterial3: true, colorScheme: darkScheme);

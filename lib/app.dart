import 'package:flutter/material.dart';

import 'data/laundry_repository.dart';
import 'screens/home_screen.dart';

/// Root widget.
///
/// The repository is created once here and shared by every customer screen:
/// when staff update an order on the web dashboard, customer tracking
/// rebuilds with the new status.
class FoldFlowApp extends StatefulWidget {
  const FoldFlowApp({super.key, this.repository});

  /// Optional injected repository (used by tests). When omitted the app owns
  /// a [DemoLaundryRepository] in local demo mode.
  final LaundryRepository? repository;

  @override
  State<FoldFlowApp> createState() => _FoldFlowAppState();
}

class _FoldFlowAppState extends State<FoldFlowApp> {
  late final LaundryRepository _repository =
      widget.repository ?? DemoLaundryRepository();

  @override
  void dispose() {
    if (widget.repository == null) {
      _repository.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FoldFlow Smart Laundry Management System',
      debugShowCheckedModeBanner: false,
      theme: buildFoldFlowTheme(),
      scrollBehavior: const FoldFlowScrollBehavior(),
      home: HomeScreen(repository: _repository),
    );
  }
}

/// The FoldFlow theme: warm cream surfaces, forest-green actions, white
/// cards. Kept in one function so the app, tests and any future route all
/// share exactly the same look.
ThemeData buildFoldFlowTheme() {
  const forestGreen = Color(0xFF214A3A);

  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: forestGreen,
      brightness: Brightness.light,
      surface: const Color(0xFFFAF8F2),
    ),
    // Plain ripple instead of the Material 3 sparkle: quieter, closer to the
    // reference design, and it needs no runtime shader asset.
    splashFactory: InkSplash.splashFactory,
    scaffoldBackgroundColor: const Color(0xFFFAF8F2),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFFAF8F2),
      foregroundColor: Color(0xFF1B3028),
      centerTitle: false,
      elevation: 0,
    ),
    textTheme: const TextTheme(
      headlineMedium: TextStyle(
        color: Color(0xFF1B3028),
        fontWeight: FontWeight.w700,
        letterSpacing: -0.7,
      ),
      titleLarge: TextStyle(
        color: Color(0xFF1B3028),
        fontWeight: FontWeight.w700,
      ),
      bodyLarge: TextStyle(color: Color(0xFF3E4B44), height: 1.5),
      bodyMedium: TextStyle(color: Color(0xFF56615B), height: 1.45),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: forestGreen,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(54),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: forestGreen,
        minimumSize: const Size.fromHeight(54),
        side: const BorderSide(color: Color(0xFFB9C9BD)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE3E7E1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE3E7E1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: forestGreen, width: 1.5),
      ),
    ),
  );
}

/// FoldFlow scroll behaviour: normal scrolling, but without the Material 3
/// shader-based overscroll effect, so the app never needs a compiled
/// fragment shader at runtime.
class FoldFlowScrollBehavior extends MaterialScrollBehavior {
  const FoldFlowScrollBehavior();

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}

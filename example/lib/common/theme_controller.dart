import 'package:flutter/material.dart';

/// Holds the app-wide [ThemeMode] so any screen can cycle it without a
/// state-management package. Exposed via [ThemeController.of] (an
/// [InheritedNotifier]), so widgets that read it rebuild on change.
class ThemeController extends ValueNotifier<ThemeMode> {
  ThemeController() : super(ThemeMode.system);

  /// Cycles System → Light → Dark → System, so both explicit themes can be
  /// checked against the native Klarna views without changing OS settings.
  void cycle() {
    value = switch (value) {
      ThemeMode.system => ThemeMode.light,
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.system,
    };
  }

  IconData get icon => switch (value) {
        ThemeMode.system => Icons.brightness_auto,
        ThemeMode.light => Icons.light_mode,
        ThemeMode.dark => Icons.dark_mode,
      };

  String get label => switch (value) {
        ThemeMode.system => 'System',
        ThemeMode.light => 'Light',
        ThemeMode.dark => 'Dark',
      };

  static ThemeController of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<ThemeControllerScope>();
    assert(scope != null, 'No ThemeControllerScope found in context');
    return scope!.notifier!;
  }
}

/// Makes a [ThemeController] available to the subtree and rebuilds dependents
/// when the mode changes.
class ThemeControllerScope extends InheritedNotifier<ThemeController> {
  const ThemeControllerScope({
    super.key,
    required ThemeController super.notifier,
    required super.child,
  });
}

/// An [AppBar] action that cycles the app theme. Drop into `AppBar.actions`.
class ThemeModeButton extends StatelessWidget {
  const ThemeModeButton({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = ThemeController.of(context);
    return IconButton(
      icon: Icon(controller.icon),
      tooltip: 'Theme: ${controller.label} (tap to change)',
      onPressed: controller.cycle,
    );
  }
}

/// Light/dark [ThemeData] pair for the test app. Both are seeded from the
/// Klarna pink so the app chrome reads as Klarna-branded in either mode.
abstract final class AppTheme {
  static const _seed = Color(0xFFFFB3C7);

  static ThemeData light() => _base(Brightness.light);

  static ThemeData dark() => _base(Brightness.dark);

  static ThemeData _base(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: brightness,
    );
    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surfaceContainer,
        foregroundColor: scheme.onSurface,
      ),
    );
  }
}

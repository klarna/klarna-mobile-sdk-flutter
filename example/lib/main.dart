import 'package:flutter/material.dart';
import 'package:klarna_mobile_sdk_flutter_example/common/theme_controller.dart';
import 'package:klarna_mobile_sdk_flutter_example/home/home_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _themeController = ThemeController();

  @override
  void dispose() {
    _themeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ThemeControllerScope(
      notifier: _themeController,
      child: ValueListenableBuilder<ThemeMode>(
        valueListenable: _themeController,
        builder: (context, themeMode, _) => MaterialApp(
          debugShowCheckedModeBanner: false,
          title: "Klarna Mobile SDK Flutter - Example",
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: themeMode,
          home: HomeScreen(),
        ),
      ),
    );
  }
}

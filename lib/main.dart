import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'utils/color_scheme_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ColorSchemeManager.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeData>(
      valueListenable: ColorSchemeManager.themeChangeNotifier,
      builder: (context, theme, _) {
        return MaterialApp(
          title: 'VCSB',
          theme: theme,
          home: const HomePage(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

// 删除项目管理的所有功能代码

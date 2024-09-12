import 'package:flutter/material.dart';
import '../utils/color_scheme_manager.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('设置'),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '系统配色',
              style: Theme.of(context).textTheme.headline6,
            ),
          ),
          ...ColorSchemeOption.values
              .map((option) => RadioListTile<ColorSchemeOption>(
                    title: Text(option.displayName),
                    value: option,
                    groupValue: ColorSchemeManager.currentScheme,
                    onChanged: (ColorSchemeOption? newValue) {
                      if (newValue != null) {
                        setState(() {
                          ColorSchemeManager.setColorScheme(newValue);
                        });
                      }
                    },
                  ))
              .toList(),
          Divider(),
          // 版本控制支持
          // ... 现有代码 ...
        ],
      ),
    );
  }
}

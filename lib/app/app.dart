import 'package:flutter/material.dart';

import '../features/shell/hub_shell.dart';
import 'theme/app_theme.dart';

class HealthDataHubApp extends StatelessWidget {
  const HealthDataHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Health Data Hub',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      home: const HubShell(),
      builder: (context, child) {
        // The layout is tuned to the design's type scale, so clamp very large
        // system text rather than letting cards overflow.
        final media = MediaQuery.of(context);
        return MediaQuery(
          data: media.copyWith(
            textScaler: media.textScaler.clamp(
              minScaleFactor: 0.9,
              maxScaleFactor: 1.25,
            ),
          ),
          child: child!,
        );
      },
    );
  }
}

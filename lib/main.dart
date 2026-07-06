import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'core/constants/app_constants.dart';
import 'core/di/injection_container.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupLocator();
  runApp(const GgwConnectApp());
}

class GgwConnectApp extends StatelessWidget {
  const GgwConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: GetIt.instance<ThemeController>().themeMode,
      builder: (context, mode, _) {
        return MaterialApp.router(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: mode,
          routerConfig: AppRouter.router,
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/di/injection_container.dart' as di;
import 'core/animations/page_transitions.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/model_viewer/presentation/pages/model_viewer_page.dart';
import 'features/model_viewer/presentation/pages/compare_view_page.dart';
import 'features/model_viewer/presentation/pages/superimposed_viewer_page.dart';
import 'features/model_viewer/presentation/pages/superimposed_viewer_mvvm_page.dart';
import 'features/user_preferences/presentation/pages/settings_page.dart';
import 'features/user_preferences/presentation/providers/user_preferences_provider.dart';
import 'features/model_viewer/presentation/providers/model_viewer_provider.dart';
import 'features/model_viewer/presentation/providers/object_loader_provider.dart';
import 'features/model_viewer/presentation/providers/object_provider.dart';
import 'features/model_viewer/presentation/providers/ui_provider.dart';
import 'features/model_viewer/presentation/viewmodels/object_view_model.dart';
import 'features/model_viewer/presentation/viewmodels/ui_view_model.dart';
import 'features/tutorial/presentation/providers/tutorial_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Legacy providers (for backward compatibility)
        ChangeNotifierProvider(
          create: (_) =>
              di.sl<UserPreferencesProvider>()
                ..loadUserPreferences('default_user'),
        ),
        ChangeNotifierProvider(create: (_) => di.sl<ModelViewerProvider>()),
        ChangeNotifierProvider(create: (_) => di.sl<ObjectLoaderProvider>()),

        // New Provider Architecture
        ChangeNotifierProvider(create: (_) => di.sl<ObjectProvider>()),
        ChangeNotifierProvider(create: (_) => di.sl<UIProvider>()),

        // MVVM ViewModels
        ChangeNotifierProvider(create: (_) => di.sl<ObjectViewModel>()),
        ChangeNotifierProvider(create: (_) => di.sl<UIViewModel>()),

        // Tutorial Provider
        ChangeNotifierProvider(create: (_) => TutorialProvider()),
      ],
      child: Consumer<UserPreferencesProvider>(
        builder: (context, userPrefs, child) {
          return MaterialApp(
            title: 'Flutter 3D App',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.deepPurple,
                brightness: Brightness.light,
              ),
              useMaterial3: true,
              appBarTheme: const AppBarTheme(
                centerTitle: false,
                elevation: 0,
                scrolledUnderElevation: 0,
              ),
              cardTheme: CardThemeData(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              filledButtonTheme: FilledButtonThemeData(
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            darkTheme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: Colors.deepPurple,
                brightness: Brightness.dark,
              ),
              useMaterial3: true,
              appBarTheme: const AppBarTheme(
                centerTitle: false,
                elevation: 0,
                scrolledUnderElevation: 0,
              ),
              cardTheme: CardThemeData(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              filledButtonTheme: FilledButtonThemeData(
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            themeMode: _getThemeMode(userPrefs.preferences?.themeMode),
            onGenerateRoute: (settings) {
              switch (settings.name) {
                case '/':
                  return CustomPageRoute(
                    child: const HomePage(),
                    transitionType: PageTransitionType.fade,
                  );
                case '/model-viewer':
                  return CustomPageRoute(
                    child: const ModelViewerPage(),
                    transitionType: PageTransitionType.slideAndScale,
                  );
                case '/compare-view':
                  return CustomPageRoute(
                    child: const CompareViewPage(),
                    transitionType: PageTransitionType.zoom,
                  );
                case '/superimposed-viewer':
                  return CustomPageRoute(
                    child: const SuperimposedViewerPage(),
                    transitionType: PageTransitionType.cube3D,
                  );
                case '/superimposed-viewer-mvvm':
                  return CustomPageRoute(
                    child: const SuperimposedViewerMVVMPage(),
                    transitionType: PageTransitionType.spiral,
                  );
                case '/settings':
                  return CustomPageRoute(
                    child: const SettingsPage(),
                    transitionType: PageTransitionType.curtain,
                  );
                default:
                  return CustomPageRoute(
                    child: const HomePage(),
                    transitionType: PageTransitionType.fade,
                  );
              }
            },
            initialRoute: '/',
          );
        },
      ),
    );
  }

  ThemeMode _getThemeMode(String? themeMode) {
    switch (themeMode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}

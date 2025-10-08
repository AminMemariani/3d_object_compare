import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/home/presentation/pages/home_page.dart';
import 'features/model_viewer/presentation/pages/model_viewer_page.dart';
import 'features/model_viewer/presentation/pages/compare_view_page.dart';
import 'features/model_viewer/presentation/pages/superimposed_viewer_page.dart';
import 'features/user_preferences/presentation/pages/settings_page.dart';
import 'features/tutorial/presentation/providers/tutorial_provider.dart';
import 'features/model_viewer/presentation/providers/object_loader_provider.dart';
import 'features/model_viewer/presentation/providers/model_viewer_provider.dart';
import 'mvvm/viewmodels/object_comparison_viewmodel.dart';
import 'mvvm/viewmodels/app_viewmodel.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // MVVM ViewModels - Simplified architecture
        ChangeNotifierProvider(create: (_) => ObjectComparisonViewModel()),
        ChangeNotifierProvider(create: (_) => AppViewModel()),
        // Feature Providers
        ChangeNotifierProvider(create: (_) => TutorialProvider()),
        ChangeNotifierProvider(create: (_) => ObjectLoaderProvider()),
        ChangeNotifierProvider(create: (_) => ModelViewerProvider()),
      ],
      child: Consumer<AppViewModel>(
        builder: (context, appVM, child) {
          return MaterialApp(
            title: '3D Object Compare',
            debugShowCheckedModeBanner: false,
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
            themeMode: appVM.themeMode,
            onGenerateRoute: (settings) {
              switch (settings.name) {
                case '/':
                  return MaterialPageRoute(builder: (_) => const HomePage());
                case '/model-viewer':
                  return MaterialPageRoute(builder: (_) => const ModelViewerPage());
                case '/compare-view':
                  return MaterialPageRoute(builder: (_) => const CompareViewPage());
                case '/superimposed-viewer':
                  return MaterialPageRoute(builder: (_) => const SuperimposedViewerPage());
                case '/settings':
                  return MaterialPageRoute(builder: (_) => const SettingsPage());
                default:
                  return MaterialPageRoute(builder: (_) => const HomePage());
              }
            },
            initialRoute: '/',
          );
        },
      ),
    );
  }
}

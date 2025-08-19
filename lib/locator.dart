// lib/locator.dart
import 'package:get_it/get_it.dart';
import 'package:antique_id/features/app_shell/viewmodel/app_shell_viewmodel.dart';
import 'data/sources/local/preferences_service.dart';
import 'services/theme_service.dart';
import 'services/cache_service.dart';
import 'services/connectivity_service.dart';
import 'services/image_processing_service.dart';
// Import other services, repositories, and viewmodels as you create them

// Create a global instance of GetIt
final GetIt locator = GetIt.instance;

// Setup function to register dependencies
Future<void> setupLocator() async {
  // --- Services ---

  // PreferencesService: Register as a singleton.
  // We use registerSingletonAsync because init() is async.
  // Alternative: registerLazySingleton and ensure init() is called in main.
  final preferencesService = PreferencesService();
  await preferencesService.init(); // Initialize it before registering
  locator.registerSingleton<PreferencesService>(preferencesService);

  // ThemeService: Register as a lazy singleton.
  locator.registerLazySingleton<ThemeService>(() => ThemeService());

  // CacheService: Register as a singleton.
  final cacheService = CacheService();
  await cacheService.init();
  locator.registerSingleton<CacheService>(cacheService);

  // ConnectivityService: Register as a singleton.
  locator.registerSingleton<ConnectivityService>(ConnectivityService());

  // ImageProcessingService: Register as a singleton.
  locator.registerSingleton<ImageProcessingService>(ImageProcessingService());

  // --- Repositories ---
  // Example: locator.registerLazySingleton<SettingsRepository>(() => SettingsRepositoryImpl(locator<PreferencesService>()));

  // --- ViewModels ---
  // Usually registered as factories, as you often want a new instance per screen.
  // Example: locator.registerFactory<SettingsViewModel>(() => SettingsViewModel(locator<ThemeService>()));
  // Note: ViewModels used by AppShellScreen might still be created via ChangeNotifierProvider directly in its build method if they are simple.
  // Or register AppShellViewModel here if it needs complex dependencies.
  locator.registerFactory<AppShellViewModel>(() => AppShellViewModel());
}

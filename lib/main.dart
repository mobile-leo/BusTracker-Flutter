import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'core/app_theme.dart';
import 'core/service_locator.dart';
import 'presentation/pages/home/home_page.dart';
import 'presentation/providers/arrival_alert_provider.dart';
import 'presentation/providers/history_provider.dart';
import 'presentation/providers/stop_forecast_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF1A1A1A),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  await dotenv.load(fileName: '.env');

  final apiToken = dotenv.env['SPTRANS_API_TOKEN'] ?? '';

  await ServiceLocator.initialize(apiToken);

  runApp(const BusTrackerApp());
}

class BusTrackerApp extends StatelessWidget {
  const BusTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: ServiceLocator.mapProvider),
        ChangeNotifierProvider.value(value: ServiceLocator.linesProvider),
        ChangeNotifierProvider.value(value: ServiceLocator.favoritesProvider),
        ChangeNotifierProvider.value(value: ServiceLocator.stopForecastProvider),
        ChangeNotifierProvider.value(value: ServiceLocator.historyProvider),
        ChangeNotifierProvider.value(value: ServiceLocator.arrivalAlertProvider),
      ],
      child: MaterialApp(
        title: 'BusTracker SP',
        theme: AppTheme.dark,
        debugShowCheckedModeBanner: false,
        home: const HomePage(),
      ),
    );
  }
}

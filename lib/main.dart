import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/theme/app_theme.dart';
import 'core/routes/app_router.dart';
import 'core/routes/route_names.dart';
import 'core/services/settings_manager.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parking_mobile/shared/notifications/presentation/cubit/notification_cubit.dart';
import 'shared/services/notification_service.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser Firebase
  await Firebase.initializeApp();

  // Charger les paramètres de l'app
  await AppSettingsManager.instance.loadSettings();

  // Initialiser le service de notifications FCM
  await NotificationService.instance.initialize();

  // Configurer le callback de navigation depuis les notifications
  NotificationService.instance.onNotificationTapped = (route, data) {
    AppRouter.router.go(AppRoutes.notificationHistory);
  };

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AppSettingsManager.instance,
      builder: (context, _) {
        return BlocProvider<NotificationCubit>(
          create: (context) => NotificationCubit(),
          child: MaterialApp.router(
            title: 'Plateau Parking',
            scaffoldMessengerKey: scaffoldMessengerKey,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: AppSettingsManager.instance.themeMode,
            locale: Locale(AppSettingsManager.instance.languageCode),
            routerConfig: AppRouter.router,
          ),
        );
      },
    );
  }
}


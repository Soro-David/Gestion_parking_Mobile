import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/theme/app_theme.dart';
import 'core/routes/app_router.dart';
import 'core/routes/route_names.dart';
import 'core/services/settings_manager.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:parking_mobile/shared/notifications/presentation/cubit/notification_cubit.dart';
import 'package:parking_mobile/shared/notifications/domain/entities/app_notification.dart';
import 'package:parking_mobile/features/auth/presentation/pages/splash_page.dart';
import 'shared/services/notification_service.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser Firebase de manière sécurisée
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }

  // Charger les paramètres de l'app
  try {
    await AppSettingsManager.instance.loadSettings();
  } catch (e) {
    debugPrint('Failed to load settings: $e');
  }

  // Initialiser le service de notifications FCM de manière sécurisée
  try {
    await NotificationService.instance.initialize();
  } catch (e) {
    debugPrint('FCM initialization failed: $e');
  }

  // Configurer le callback de navigation depuis les notifications
  try {
    NotificationService.instance.onNotificationTapped = (route, data) {
      if (data != null) {
        final notif = AppNotification(
          id: data['id']?.toString() ?? '',
          title: data['title']?.toString() ?? 'Notification',
          body: data['body']?.toString() ?? '',
          type: data['type']?.toString(),
          data: data['data'] is Map ? Map<String, dynamic>.from(data['data']) : null,
          createdAt: DateTime.now(),
        );

        if (SplashScreen.isSplashActive) {
          NotificationService.pendingNotification = notif;
        } else {
          AppRouter.router.push(AppRoutes.notificationDetail, extra: notif);
        }
      } else {
        AppRouter.router.go(AppRoutes.notificationHistory);
      }
    };
  } catch (e) {
    debugPrint('FCM notification tap callback setup failed: $e');
  }

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


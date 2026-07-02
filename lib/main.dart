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
import 'package:parking_mobile/shared/services/avatar_cache_helper.dart';

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

  // Initialiser le cache d'avatar utilisateur
  try {
    await AvatarCacheHelper.init();
  } catch (e) {
    debugPrint('AvatarCacheHelper initialization failed: $e');
  }

  // Configurer le callback de navigation depuis les notifications
  // IMPORTANT : Doit être configuré AVANT d'initialiser le service FCM
  // pour éviter de perdre l'événement au démarrage de l'app si elle était fermée (Terminated).
  try {
    NotificationService.instance.onNotificationTapped = (route, data) {
      if (data != null) {
        // Convertir de façon sécurisée le champ 'data' quel que soit son type après JSON decode
        Map<String, dynamic>? extraData;
        final rawData = data['data'];
        if (rawData is Map) {
          try {
            extraData = Map<String, dynamic>.from(
              rawData.map((k, v) => MapEntry(k.toString(), v)),
            );
          } catch (_) {
            extraData = null;
          }
        }

        final notif = AppNotification(
          id: data['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
          title: data['title']?.toString() ?? 'Notification',
          body: data['body']?.toString() ?? '',
          type: data['type']?.toString(),
          data: extraData,
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

  // Initialiser le service de notifications FCM de manière sécurisée
  try {
    await NotificationService.instance.initialize();
  } catch (e) {
    debugPrint('FCM initialization failed: $e');
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


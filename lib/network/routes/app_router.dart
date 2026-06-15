// Application Router
import 'package:go_router/go_router.dart';
import 'route_names.dart';

// Import Screens (Auth & Onboarding)
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/onboarding_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';

// Agent Screens
import '../../features/attendant/presentation/pages/dashboard_screen.dart';
import '../../features/attendant/presentation/pages/home_screen.dart';
import '../../features/attendant/presentation/pages/history_screen.dart';
import '../../features/attendant/presentation/pages/parking_screen.dart';
import '../../features/attendant/presentation/pages/scan_screen.dart';
import '../../features/attendant/presentation/pages/profil_screen.dart';
import '../../features/attendant/presentation/pages/settings_screen.dart';
import '../../features/attendant/presentation/pages/versement_screen.dart';
import '../../features/attendant/presentation/pages/detail_versement_screen.dart' as agent_versement_detail;
import '../../features/attendant/presentation/pages/stationnement_screen.dart';
import '../../features/attendant/presentation/pages/stationnements_en_cours_screen.dart' as agent_stationnements_en_cours;
import '../../features/attendant/presentation/pages/entree_detail_screen.dart' as agent_entree_detail;
import '../../features/attendant/presentation/pages/sortie_detail_screen.dart' as agent_sortie_detail;
import '../../features/attendant/presentation/pages/parking_detail_screen.dart' as agent_parking_detail;
import '../../features/attendant/presentation/pages/edit_profile_screen.dart' as agent_edit_profile;
import '../../shared/models/parking_entry_model.dart';
import '../../shared/models/parking_exit_model.dart';

// Caissier Screens
import '../../features/caissier/presentation/pages/dashboard_screen.dart' as caissier_dashboard;
import '../../features/caissier/presentation/pages/home_screen.dart' as caissier_home;
import '../../features/caissier/presentation/pages/historique_screen.dart' as caissier_history;
import '../../features/caissier/presentation/pages/scan_screen.dart' as caissier_scan;
import '../../features/caissier/presentation/pages/profil_screen.dart' as caissier_profile;
import '../../features/caissier/presentation/pages/reports_screen.dart' as caissier_reports;
import '../../features/caissier/presentation/pages/settings_screen.dart' as caissier_settings;
import '../../features/caissier/presentation/pages/versement_screen.dart' as caissier_versement;
import '../../features/caissier/presentation/pages/detail_versement_screen.dart' as caissier_versement_detail;
import '../../features/caissier/presentation/pages/stationnement_screen.dart' as caissier_stationnement;
import '../../features/caissier/presentation/pages/stationnement_detail_screen.dart' as caissier_stationnement_detail;
import '../../features/caissier/presentation/pages/entree_detail_screen.dart' as caissier_entree_detail;
import '../../features/caissier/presentation/pages/sortie_detail_screen.dart' as caissier_sortie_detail;
import '../../features/caissier/presentation/pages/sortie_scan_screen.dart' as caissier_sortie_scan;
import '../../features/caissier/presentation/pages/stationnement_scan_screen.dart' as caissier_stationnement_scan;
import '../../features/caissier/presentation/pages/edit_profile_screen.dart' as caissier_edit_profile;

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      // Auth & Onboarding
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),

      // Agent Routes
      GoRoute(
        path: AppRoutes.agentHome,
        name: 'agentHome',
        builder: (context, state) => const AgentHomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.agentDashboard,
        name: 'agentDashboard',
        builder: (context, state) => const AgentDashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.agentParking,
        name: 'agentParking',
        builder: (context, state) => const AgentParkingScreen(),
      ),
      GoRoute(
        path: AppRoutes.agentHistory,
        name: 'agentHistory',
        builder: (context, state) => const AgentHistoryScreen(),
      ),
      GoRoute(
        path: AppRoutes.agentScan,
        name: 'agentScan',
        builder: (context, state) => const AgentScanScreen(),
      ),
      GoRoute(
        path: AppRoutes.agentProfile,
        name: 'agentProfile',
        builder: (context, state) => const AgentProfilScreen(),
      ),
      GoRoute(
        path: AppRoutes.agentSettings,
        name: 'agentSettings',
        builder: (context, state) => const AgentSettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.agentVersement,
        name: 'agentVersement',
        builder: (context, state) => const AgentVersementScreen(),
      ),
      GoRoute(
        path: AppRoutes.agentStationnement,
        name: 'agentStationnement',
        builder: (context, state) => const AgentStationnementScreen(),
      ),

      GoRoute(
        path: AppRoutes.agentProfileEdit,
        name: 'agentProfileEdit',
        builder: (context, state) => const agent_edit_profile.EditProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.agentVersementDetail,
        name: 'agentVersementDetail',
        builder: (context, state) => agent_versement_detail.AgentDetailVersementScreen(
          versementId: state.extra as int,
        ),
      ),
      GoRoute(
        path: AppRoutes.agentStationnementsEnCours,
        name: 'agentStationnementsEnCours',
        builder: (context, state) => const agent_stationnements_en_cours.AgentStationnementEnCoursScreen(),
      ),
      GoRoute(
        path: AppRoutes.agentEntreeDetail,
        name: 'agentEntreeDetail',
        builder: (context, state) => agent_entree_detail.AgentEntreeDetailScreen(
          entry: state.extra as ParkingEntryModel,
        ),
      ),
      GoRoute(
        path: AppRoutes.agentSortieDetail,
        name: 'agentSortieDetail',
        builder: (context, state) => agent_sortie_detail.AgentSortieDetailScreen(
          exit: state.extra as ParkingExitModel,
        ),
      ),
      GoRoute(
        path: AppRoutes.agentParkingDetail,
        name: 'agentParkingDetail',
        builder: (context, state) => agent_parking_detail.ParkingDetailScreen(
          data: state.extra as Map<String, dynamic>,
        ),
      ),

      // Caissier Routes
      GoRoute(
        path: AppRoutes.caissierHome,
        name: 'caissierHome',
        builder: (context, state) => const caissier_home.CaissierHomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.caissierDashboard,
        name: 'caissierDashboard',
        builder: (context, state) => const caissier_dashboard.CaissierDashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.caissierHistory,
        name: 'caissierHistory',
        builder: (context, state) => const caissier_history.CaissierHistoryScreen(),
      ),
      GoRoute(
        path: AppRoutes.caissierScan,
        name: 'caissierScan',
        builder: (context, state) => const caissier_scan.CaissierScanScreen(),
      ),
      GoRoute(
        path: AppRoutes.caissierProfile,
        name: 'caissierProfile',
        builder: (context, state) => const caissier_profile.CaissierProfilScreen(),
      ),
      GoRoute(
        path: AppRoutes.caissierReports,
        name: 'caissierReports',
        builder: (context, state) => const caissier_reports.CashierReportsScreen(),
      ),
      GoRoute(
        path: AppRoutes.caissierSettings,
        name: 'caissierSettings',
        builder: (context, state) => const caissier_settings.CaissierSettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.caissierVersement,
        name: 'caissierVersement',
        builder: (context, state) => const caissier_versement.CaissierVersementScreen(),
      ),
      GoRoute(
        path: AppRoutes.caissierStationnement,
        name: 'caissierStationnement',
        builder: (context, state) => const caissier_stationnement.CaissierStationnementScreen(),
      ),
      GoRoute(
        path: AppRoutes.caissierProfileEdit,
        name: 'caissierProfileEdit',
        builder: (context, state) => const caissier_edit_profile.CaissierEditProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.caissierVersementDetail,
        name: 'caissierVersementDetail',
        builder: (context, state) => caissier_versement_detail.CaissierDetailVersementScreen(
          versementId: state.extra as int,
        ),
      ),
      GoRoute(
        path: AppRoutes.caissierStationnementDetail,
        name: 'caissierStationnementDetail',
        builder: (context, state) => caissier_stationnement_detail.CaissierStationnementDetailScreen(
          stationnement: state.extra as Map<String, dynamic>,
        ),
      ),
      GoRoute(
        path: AppRoutes.caissierEntreeDetail,
        name: 'caissierEntreeDetail',
        builder: (context, state) => caissier_entree_detail.CaissierEntreeDetailScreen(
          entry: state.extra as ParkingEntryModel,
        ),
      ),
      GoRoute(
        path: AppRoutes.caissierSortieDetail,
        name: 'caissierSortieDetail',
        builder: (context, state) => caissier_sortie_detail.CaissierSortieDetailScreen(
          exit: state.extra as ParkingExitModel,
        ),
      ),
      GoRoute(
        path: AppRoutes.caissierSortieScan,
        name: 'caissierSortieScan',
        builder: (context, state) => const caissier_sortie_scan.CaissierSortieScanScreen(),
      ),
      GoRoute(
        path: AppRoutes.caissierStationnementScan,
        name: 'caissierStationnementScan',
        builder: (context, state) => const caissier_stationnement_scan.CaissierStationnementScanScreen(),
      ),
    ],
  );
}

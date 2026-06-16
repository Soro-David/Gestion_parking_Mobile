// Application Router (moved to core/routes)
import 'package:go_router/go_router.dart';
import 'package:parking_mobile/core/routes/route_names.dart';

// Auth
import 'package:parking_mobile/features/auth/presentation/pages/splash_page.dart';
import 'package:parking_mobile/features/auth/presentation/pages/onboarding_page.dart';
import 'package:parking_mobile/features/auth/presentation/pages/login_page.dart';

// Agent Screens (grouped)
import 'package:parking_mobile/features/agent/presentation/pages/dashboard/dashboard_screen.dart';
import 'package:parking_mobile/features/agent/presentation/pages/home/home_screen.dart';
import 'package:parking_mobile/features/agent/presentation/pages/history/history_screen.dart';
import 'package:parking_mobile/features/agent/presentation/pages/parking/parking_screen.dart';
import 'package:parking_mobile/features/agent/presentation/pages/scan/scan_screen.dart';
import 'package:parking_mobile/features/agent/presentation/pages/profil/profil_screen.dart';
import 'package:parking_mobile/features/agent/presentation/pages/settings/settings_screen.dart';
import 'package:parking_mobile/features/agent/presentation/pages/versement/versement_screen.dart';
import 'package:parking_mobile/features/agent/presentation/pages/versement/detail_versement_screen.dart' as agent_versement_detail;
import 'package:parking_mobile/features/agent/presentation/pages/stationnement/stationnement_screen.dart';
import 'package:parking_mobile/features/agent/presentation/pages/stationnement/stationnements_en_cours_screen.dart' as agent_stationnements_en_cours;
import 'package:parking_mobile/features/agent/presentation/pages/historique/entree_detail_screen.dart' as agent_entree_detail;
import 'package:parking_mobile/features/agent/presentation/pages/sortie/sortie_detail_screen.dart' as agent_sortie_detail;
import 'package:parking_mobile/features/agent/presentation/pages/parking/parking_detail_screen.dart' as agent_parking_detail;
import 'package:parking_mobile/features/agent/presentation/pages/profil/edit_profile_screen.dart' as agent_edit_profile;
import 'package:parking_mobile/shared/domain/entities/parking_entry.dart';
import 'package:parking_mobile/shared/domain/entities/parking_exit.dart';

// Caissier Screens
import 'package:parking_mobile/features/caissier/presentation/pages/dashboard/dashboard_screen.dart' as caissier_dashboard;
import 'package:parking_mobile/features/caissier/presentation/pages/home/home_screen.dart' as caissier_home;
import 'package:parking_mobile/features/caissier/presentation/pages/historique/historique_screen.dart' as caissier_history;
import 'package:parking_mobile/features/caissier/presentation/pages/scan/scan_screen.dart' as caissier_scan;
import 'package:parking_mobile/features/caissier/presentation/pages/profil/profil_screen.dart' as caissier_profile;
import 'package:parking_mobile/features/caissier/presentation/pages/versement/versement_screen.dart' as caissier_versement;
import 'package:parking_mobile/features/caissier/presentation/pages/versement/detail_versement_screen.dart' as caissier_versement_detail;
import 'package:parking_mobile/features/caissier/presentation/pages/stationnement/stationnement_detail_screen.dart' as caissier_stationnement_detail;
import 'package:parking_mobile/features/caissier/presentation/pages/historique/entree_detail_screen.dart' as caissier_entree_detail;
import 'package:parking_mobile/features/caissier/presentation/pages/sortie/sortie_detail_screen.dart' as caissier_sortie_detail;
import 'package:parking_mobile/features/caissier/presentation/pages/scan/sortie_scan_screen.dart' as caissier_sortie_scan;
import 'package:parking_mobile/features/caissier/presentation/pages/scan/stationnement_scan_screen.dart' as caissier_stationnement_scan;
import 'package:parking_mobile/features/caissier/presentation/pages/profil/edit_profile_screen.dart' as caissier_edit_profile;

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
        path: AppRoutes.agentProfileEdit,
        name: 'agentProfileEdit',
        builder: (context, state) => const agent_edit_profile.EditProfileScreen(),
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
        path: AppRoutes.agentVersementDetail,
        name: 'agentVersementDetail',
        builder: (context, state) => agent_versement_detail.AgentDetailVersementScreen(
          versementId: state.extra as int,
        ),
      ),
      GoRoute(
        path: AppRoutes.agentStationnement,
        name: 'agentStationnement',
        builder: (context, state) => const AgentStationnementScreen(),
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
          entry: state.extra as ParkingEntry,
        ),
      ),
      GoRoute(
        path: AppRoutes.agentSortieDetail,
        name: 'agentSortieDetail',
        builder: (context, state) => agent_sortie_detail.AgentSortieDetailScreen(
          exit: state.extra as ParkingExit,
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
        path: AppRoutes.caissierProfileEdit,
        name: 'caissierProfileEdit',
        builder: (context, state) => const caissier_edit_profile.CaissierEditProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.caissierVersement,
        name: 'caissierVersement',
        builder: (context, state) => const caissier_versement.CaissierVersementScreen(),
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
          entry: state.extra as ParkingEntry,
        ),
      ),
      GoRoute(
        path: AppRoutes.caissierSortieDetail,
        name: 'caissierSortieDetail',
        builder: (context, state) => caissier_sortie_detail.CaissierSortieDetailScreen(
          exit: state.extra as ParkingExit,
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


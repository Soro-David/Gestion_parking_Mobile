// Application Routes
class AppRoutes {
  // Notifications partagées
  static const String notificationHistory = '/notifications/history';
  static const String notificationCategories = '/notifications/categories';
  static const String notificationDetail = '/notifications/detail';
  static const String signalementsList = '/signalements/list';

  // Onboarding & Auth
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';

  // Agent Routes
  static const String agentHome = '/agent/home';
  static const String agentDashboard = '/agent/dashboard';
  static const String agentParking = '/agent/parking';
  static const String agentHistory = '/agent/history';
  static const String agentScan = '/agent/scan';
  static const String agentProfile = '/agent/profile';
  static const String agentProfileEdit = '/agent/profile/edit';
  static const String agentSecurity = '/agent/profile/security';
  static const String agentSettings = '/agent/settings';
  static const String agentVersement = '/agent/versement';
  static const String agentVersementDetail = '/agent/versement/detail';
  static const String agentStationnement = '/agent/stationnement';
  static const String agentStationnementsEnCours = '/agent/stationnement/encours';
  static const String agentStationnementDetail = '/agent/stationnement/detail';
  static const String agentEntreeDetail = '/agent/history/entree';
  static const String agentSortieDetail = '/agent/history/sortie';
  static const String agentParkingDetail = '/agent/parking/detail';
  static const String agentNotifications = '/agent/settings/notifications';

  // Caissier Routes
  static const String caissierHome = '/caissier/home';
  static const String caissierDashboard = '/caissier/dashboard';
  static const String caissierHistory = '/caissier/history';
  static const String caissierScan = '/caissier/scan';
  static const String caissierProfile = '/caissier/profile';
  static const String caissierProfileEdit = '/caissier/profile/edit';
  static const String caissierSecurity = '/caissier/profile/security';
  static const String caissierReports = '/caissier/reports';
  static const String caissierSettings = '/caissier/settings';
  static const String caissierVersement = '/caissier/versement';
  static const String caissierVersementDetail = '/caissier/versement/detail';
  static const String caissierStationnement = '/caissier/stationnement';
  static const String caissierStationnementDetail = '/caissier/stationnement/detail';
  static const String caissierStationnementScan = '/caissier/stationnement/scan';
  static const String caissierEntreeDetail = '/caissier/history/entree';
  static const String caissierSortieDetail = '/caissier/history/sortie';
  static const String caissierSortieScan = '/caissier/history/scan';
  static const String caissierNotifications = '/caissier/settings/notifications';

  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
}

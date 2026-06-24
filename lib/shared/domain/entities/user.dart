import 'package:parking_mobile/core/constants/api_constants.dart';

enum UserRole {
  agent,
  caissier,
}

class User {
  final String name;
  final String? firstName;
  final String email;
  final String? phone;
  final String? address;
  final UserRole role;
  final String? avatarUrl;

  const User({
    required this.name,
    this.firstName,
    required this.email,
    this.phone,
    this.address,
    required this.role,
    this.avatarUrl,
  });

  /// Normalise l'URL de l'avatar pour s'assurer qu'elle est valide et utilise HTTPS si nécessaire.
  static String? sanitizeAvatarUrl(String? url) {
    if (url == null || url.isEmpty) return null;
    
    // Si c'est un chemin relatif, on ajoute le baseUrl
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      final base = ApiConstants.baseUrl;
      return '$base${url.startsWith('/') ? '' : '/'}$url';
    }
    
    // Forcer le HTTPS pour ngrok (nécessaire sur iOS/Android pour éviter le blocage du trafic HTTP en clair)
    if (url.startsWith('http://exclusively-untoppled-forest.ngrok-free.dev') || 
        url.contains('ngrok-free.dev')) {
      return url.replaceFirst('http://', 'https://');
    }
    
    return url;
  }
}

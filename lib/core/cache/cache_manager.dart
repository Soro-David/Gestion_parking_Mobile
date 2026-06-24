class CacheItem<T> {
  final T data;
  final DateTime timestamp;

  CacheItem(this.data) : timestamp = DateTime.now();
}

class CacheManager<T> {
  final Duration ttl;
  CacheItem<T>? _cache;

  CacheManager({required this.ttl});

  /// Met à jour la valeur en cache
  void update(T data) {
    _cache = CacheItem<T>(data);
  }

  /// Récupère la valeur en cache si elle existe et n'a pas expiré
  T? get() {
    if (_cache == null) return null;
    final age = DateTime.now().difference(_cache!.timestamp);
    if (age > ttl) {
      _cache = null; // expiré
      return null;
    }
    return _cache!.data;
  }

  /// Invalide le cache explicitement
  void invalidate() {
    _cache = null;
  }

  /// Indique si le cache a une donnée valide
  bool get hasValidCache {
    return get() != null;
  }
}

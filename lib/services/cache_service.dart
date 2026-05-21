import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// Servicio centralizado para gestionar el caché de imágenes
class CacheService {
  static late CacheManager _cacheManager;

  /// Inicializa el gestor de caché con configuración personalizada
  static Future<void> initialize() async {
    _cacheManager = CacheManager(
      Config(
        'luumil_image_cache',
        stalePeriod: const Duration(days: 60), // Mantener en caché 60 días
        maxNrOfCacheObjects: 1000, // Máximo 1000 imágenes en caché
      ),
    );
  }

  /// Obtiene la instancia del cache manager
  static CacheManager get cacheManager => _cacheManager;

  /// Limpia el caché completamente
  static Future<void> clearCache() async {
    await _cacheManager.emptyCache();
  }
}

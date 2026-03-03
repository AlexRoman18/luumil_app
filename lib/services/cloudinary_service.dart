import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';

class CloudinaryService {
  static const String _cloudName = 'dazgodeyz';
  static const String _uploadPreset = 'luumil_upload';

  static Future<String> subirImagen(File imagen) async {
    // Calcular hash del archivo para cache local (evitar re-uploads)
    final bytes = await imagen.readAsBytes();
    final digest = sha1.convert(bytes).toString();
    final cacheKey = 'cloudinary_cache_$digest';

    final prefs = await SharedPreferences.getInstance();
    final cachedUrl = prefs.getString(cacheKey);
    if (cachedUrl != null && cachedUrl.isNotEmpty) {
      return cachedUrl; // Retornar URL cacheada sin re-subir
    }

    final url = Uri.parse(
      'https://api.cloudinary.com/v1_1/$_cloudName/image/upload',
    );

    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = _uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', imagen.path));

    final response = await request.send();

    if (response.statusCode == 200) {
      final res = await http.Response.fromStream(response);
      final data = json.decode(res.body);
      final secureUrl = data['secure_url'];

      // Guardar en cache local para próximos uploads idénticos
      try {
        await prefs.setString(cacheKey, secureUrl);
      } catch (_) {
        // Si falla el guardado de cache, no interrumpir el flujo
      }

      return secureUrl;
    } else {
      throw Exception('Error al subir imagen a Cloudinary');
    }
  }
}

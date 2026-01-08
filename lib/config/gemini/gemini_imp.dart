import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiImp {
  final Dio _http;

  GeminiImp({Dio? http})
    : _http =
          http ?? Dio(BaseOptions(baseUrl: dotenv.env['ENDPOINT_API'] ?? ''));

  Future<String> getResponse(String prompt) async {
    try {
      final body = jsonEncode({'prompt': prompt});
      final response = await _http.post(
        '/basic-prompt',
        data: body,
        options: Options(headers: {'content-type': 'application/json'}),
      );

      return response.data?.toString() ?? '';
    } on DioError catch (e) {
      print(e);
      throw Exception('Error al obtener la respuesta de Gemini: ${e.message}');
    } catch (e) {
      print(e);
      throw Exception('Error al obtener la respuesta de Gemini');
    }
  }

  //Stream
  Stream<String> getResponseStream(String prompt) async* {
    //TODO: Tener presente que enviaremos imágenes
    //!Multipart

    final body = jsonEncode({'prompt': prompt});
    final response = await _http.post(
      '/basic-prompt-stream',
      data: body,
      options: Options(responseType: ResponseType.stream),
    );

    Stream<List<int>> byteStream;
    if (response.data is Stream<List<int>>) {
      byteStream = response.data as Stream<List<int>>;
    } else if (response.data is ResponseBody) {
      byteStream = (response.data as ResponseBody).stream;
    } else {
      return;
    }

    await for (final chunk in byteStream) {
      final chunkString = utf8.decode(chunk, allowMalformed: true);
      yield chunkString;
    }
  }

  Stream<String> getChatStream(String prompt, String chatId) async* {
    final body = {'prompt': prompt, 'chatId': chatId};

    final response = await _http.post(
      '/chat-stream',
      data: jsonEncode(body),
      options: Options(
        responseType: ResponseType.stream,
        headers: {'content-type': 'application/json'},
      ),
    );

    Stream<List<int>> byteStream;

    if (response.data is Stream<List<int>>) {
      byteStream = response.data as Stream<List<int>>;
    } else if (response.data is ResponseBody) {
      byteStream = (response.data as ResponseBody).stream;
    } else {
      return;
    }

    await for (final chunk in byteStream) {
      yield utf8.decode(chunk, allowMalformed: true);
    }
  }
}

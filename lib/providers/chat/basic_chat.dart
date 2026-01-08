import 'package:flutter_chat_types/flutter_chat_types.dart';
import 'package:luumil_app/config/gemini/gemini_imp.dart';
import 'package:luumil_app/providers/chat/is_gemini_writing.dart';
import 'package:luumil_app/providers/users/user_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

part 'basic_chat.g.dart';

final uuid = Uuid();

@riverpod
class BasicChat extends _$BasicChat {
  final gemini = GeminiImp();
  late User geminiUser;

  @override
  List<Message> build() {
    geminiUser = ref.read(geminiUserProvider);
    return [];
  }

  void addMessage({required PartialText partialText, required User user}) {
    //TODO: agregar condicion cuando vengasn imagenes
    _addTextMessage(partialText, user);
  }

  void _addTextMessage(PartialText partialText, User author) {
    _createTextMessage(partialText.text, author);
    _geminiTextResponseStream(partialText.text);
  }

  void _geminiTextResponse(String prompt) async {
    _setGeminiWritingStatus(true);

    final textResponse = await gemini.getResponse(prompt);

    _setGeminiWritingStatus(false);

    _createTextMessage(textResponse, geminiUser);
  }

  void _geminiTextResponseStream(String prompt) async {
    //_setGeminiWritingStatus(true);
    _createTextMessage('Gemini está pensando...', geminiUser);

    gemini.getResponseStream(prompt).listen((responsechunk) {
      if (responsechunk.isEmpty) return;

      final updatedMessages = [...state];
      final updatedMessage = (updatedMessages.first as TextMessage).copyWith(
        text: responsechunk,
      );

      updatedMessages[0] = updatedMessage;
      state = updatedMessages;
    });

    // _setGeminiWritingStatus(false);
    // _createTextMessage(textResponse, geminiUser);
  }

  //Helper methods

  void _createTextMessage(String text, User author) {
    final message = TextMessage(
      id: uuid.v4(),
      author: author,
      text: text,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );

    state = [message, ...state];
  }

  void _setGeminiWritingStatus(bool isWriting) {
    final isGeminiWriting = ref.read(isGeminiWritingProvider.notifier);
    isWriting
        ? isGeminiWriting.setIsWriting()
        : isGeminiWriting.setIsNotWriting();
  }
}

import 'package:flutter_chat_types/flutter_chat_types.dart';
import 'package:luumil_app/config/gemini/gemini_imp.dart';
import 'package:luumil_app/providers/users/user_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

part 'chat_with_context.g.dart';

final uuid = Uuid();

@Riverpod(keepAlive: true)
class ChatWithContext extends _$ChatWithContext {
  final gemini = GeminiImp();
  late User geminiUser;
  late String chatId;

  @override
  List<Message> build() {
    geminiUser = ref.read(geminiUserProvider);
    chatId = uuid.v4();
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

  void _geminiTextResponseStream(String prompt) async {
    _createTextMessage('Gemini está pensando...', geminiUser);

    gemini.getChatStream(prompt, chatId).listen((responseChunk) {
      if (responseChunk.isEmpty) return;

      final updatedMessages = [...state];
      final firstMessage = updatedMessages.first as TextMessage;

      final newText = firstMessage.text == 'Gemini está pensando...'
          ? responseChunk
          : firstMessage.text + responseChunk;

      updatedMessages[0] = firstMessage.copyWith(text: newText);
      state = updatedMessages;
    });
  }

  void newChat() {
    chatId = uuid.v4();
    state = [];
  }

  void _createTextMessage(String text, User author) {
    final message = TextMessage(
      id: uuid.v4(),
      author: author,
      text: text,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );

    state = [message, ...state];
  }
}

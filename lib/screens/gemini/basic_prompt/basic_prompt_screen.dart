import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:luumil_app/providers/chat/basic_chat.dart';
import 'package:luumil_app/providers/chat/is_gemini_writing.dart';
import 'package:luumil_app/providers/users/user_provider.dart';

class BasicPromptScreen extends ConsumerWidget {
  const BasicPromptScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final geminiUser = ref.watch(geminiUserProvider);
    final user = ref.watch(userProvider);
    final IsGeminiWriting = ref.watch(isGeminiWritingProvider);
    final chatMessages = ref.watch(basicChatProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Prompt Básico')),
      body: Chat(
        messages: chatMessages,
        onSendPressed: (types.PartialText partialText) {
          //On Send Message
          final basicChatNotifier = ref.read(basicChatProvider.notifier);
          basicChatNotifier.addMessage(partialText: partialText, user: user);

          print('mensaje: ${partialText.text}');
        },
        user: user,
        theme: DarkChatTheme(),
        showUserNames: true,

        //showUserAvatars: true,
        typingIndicatorOptions: TypingIndicatorOptions(
          typingUsers: IsGeminiWriting ? [geminiUser] : [], //TODO
          customTypingWidget: const Center(
            child: Text('Gemini está pensando...'),
          ),
        ),
      ),
    );
  }
}

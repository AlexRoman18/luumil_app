import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luumil_app/config/theme/gemini/app_theme.dart';
import 'package:luumil_app/providers/chat/chat_with_context.dart';
import 'package:luumil_app/providers/users/user_provider.dart';
import 'package:luumil_app/widgets/gemini/custom_bottom_input.dart';
import 'package:luumil_app/screens/comer/dashboard_screen.dart';

class ChatContextScreen extends ConsumerWidget {
  const ChatContextScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    final chatMessages = ref.watch(chatWithContextProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: seedColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Chat conversacional',
          style: TextStyle(color: Colors.white), // 👈 texto blanco
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const DashboardScreen()),
            );
          },
        ),
        actions: [
          IconButton(
            onPressed: () {
              ref.read(chatWithContextProvider.notifier).newChat();
            },
            icon: const Icon(Icons.restart_alt, color: Colors.white),
          ),
        ],
      ),
      body: Chat(
        messages: chatMessages,
        onSendPressed: (_) {},
        user: user,
        theme: DarkChatTheme(),
        showUserNames: true,

        //showUserAvatars: true,
        customBottomWidget: CustomBottomInput(
          onSend: (partialText, {images = const []}) {
            final chatNotifier = ref.read(chatWithContextProvider.notifier);

            chatNotifier.addMessage(partialText: partialText, user: user);
          },
        ),
      ),
    );
  }
}

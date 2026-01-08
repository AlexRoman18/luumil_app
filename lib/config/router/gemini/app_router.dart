import 'package:go_router/go_router.dart';
import 'package:luumil_app/screens/gemini/basic_prompt/basic_prompt_screen.dart';
import 'package:luumil_app/screens/gemini/chat_context/chat_context_screen.dart';
import 'package:luumil_app/screens/home_screen.dart';

final appRouter = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
    GoRoute(
      path: '/basic-prompt',
      builder: (context, state) => const BasicPromptScreen(),
    ),

    GoRoute(
      path: '/history-chat',
      builder: (context, state) => const ChatContextScreen(),
    ),
  ],
);

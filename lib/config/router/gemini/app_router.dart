import 'package:go_router/go_router.dart';
import 'package:luumil_app/auth/auth_gate.dart';
import 'package:luumil_app/auth/auth_notifier.dart';
import 'package:luumil_app/screens/gemini/basic_prompt/basic_prompt_screen.dart';
import 'package:luumil_app/screens/gemini/chat_context/chat_context_screen.dart';
import 'package:luumil_app/screens/usuario/splash_screen.dart';

final authNotifier = AuthNotifier();

final appRouter = GoRouter(
  refreshListenable: authNotifier,
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
    GoRoute(path: '/auth', builder: (context, state) => const AuthGate()),
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

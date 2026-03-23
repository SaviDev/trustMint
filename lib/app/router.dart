import 'package:go_router/go_router.dart';
import '../features/auth/registration_screen.dart';
import '../features/bandi/bandi_list_screen.dart';
import '../features/bandi/bando_detail_screen.dart';
import '../features/session/session_screen.dart';
import '../features/ema/ema_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/home/home_screen.dart';

final GoRouter routerConfig = GoRouter(
  initialLocation: '/bandi',
  routes: [
    GoRoute(
      path: '/auth',
      builder: (context, state) => const RegistrationScreen(),
    ),
    GoRoute(
      path: '/bandi',
      builder: (context, state) => const BandiListScreen(),
      routes: [
        GoRoute(
          path: 'detail/:id',
          builder: (context, state) => BandoDetailScreen(bandoId: state.pathParameters['id']!),
        ),
      ]
    ),
    GoRoute(
      path: '/collector/:id',
      builder: (context, state) => HomeScreen(bandoId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/session',
      builder: (context, state) => const SessionScreen(),
    ),
    GoRoute(
      path: '/ema/:id',
      builder: (context, state) => EmaScreen(emaId: state.pathParameters['id']!),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);

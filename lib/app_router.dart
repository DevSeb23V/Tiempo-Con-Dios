import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'core/widgets/main_scaffold_with_nav_bar.dart';
import 'features/alert/presentation/alerta_fullscreen_page.dart';
import 'features/guide/presentation/guia_page.dart';
import 'features/home/presentation/home_page.dart';
import 'features/onboarding/presentation/onboarding_page.dart';
import 'features/progress/presentation/progress_page.dart';
import 'features/settings/presentation/settings_page.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

/// Enrutador principal de la aplicación utilizando GoRouter.
/// Configura la navegación basada en shell indexado con 3 ramas principales y rutas modales.
final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainScaffoldWithNavBar(navigationShell: navigationShell);
      },
      branches: [
        // Rama 1: Inicio
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              name: 'home',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: HomePage(),
              ),
            ),
          ],
        ),

        // Rama 2: Mi Progreso
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/progreso',
              name: 'progreso',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: ProgressPage(),
              ),
            ),
          ],
        ),

        // Rama 3: Guía de hoy
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/guia',
              name: 'guia',
              pageBuilder: (context, state) => const NoTransitionPage(
                child: GuiaPage(),
              ),
            ),
          ],
        ),
      ],
    ),
    // Ruta a pantalla completa fuera del shell para la alarma devocional
    GoRoute(
      path: '/alerta',
      name: 'alerta',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => const MaterialPage(
        fullscreenDialog: true,
        child: AlertaFullScreenPage(),
      ),
    ),
    // Ruta a pantalla completa para el Onboarding guiado inicial
    GoRoute(
      path: '/onboarding',
      name: 'onboarding',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => const MaterialPage(
        fullscreenDialog: true,
        child: OnboardingPage(),
      ),
    ),
    // Ruta para la Pantalla de Ajustes
    GoRoute(
      path: '/ajustes',
      name: 'ajustes',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) => const MaterialPage(
        child: SettingsPage(),
      ),
    ),
  ],
);

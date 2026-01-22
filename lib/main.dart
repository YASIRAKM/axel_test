import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/config/app_router.dart';
import 'core/config/theme.dart';
import 'core/services/snackbar_service.dart';
import 'di/injection_container.dart' as di;
import 'features/settings/presentation/bloc/settings_bloc.dart';
import 'features/settings/presentation/bloc/settings_state.dart';

import 'features/auth/presentation/bloc/auth_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<AuthBloc>()),
        BlocProvider(create: (_) => di.sl<SettingsBloc>()),
      ],
      child: BlocBuilder<SettingsBloc, SettingsState>(
        buildWhen: (p, c) => p.themeMode != c.themeMode,
        builder: (context, state) {
          final appRouter = di.sl<AppRouter>();
          return MaterialApp.router(
            routerConfig: appRouter.router,
            scaffoldMessengerKey: scaffoldMessengerKey,
            title: 'Axel Tech Test',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: state.themeMode,
          );
        },
      ),
    );
  }
}

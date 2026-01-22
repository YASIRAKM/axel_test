import 'package:axel_todo_test/core/config/app_routes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/navigation_service.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(AuthCheckRequested());
  }

  @override 
  Widget build(BuildContext context) {
 
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).primaryColor;
    final bgColor = Theme.of(context).scaffoldBackgroundColor;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state   is AuthAuthenticated) {
          NavigationService.pushReplacementNamed(AppRoutes.home);
        } else if (state is AuthUnauthenticated) {
          NavigationService.pushReplacementNamed(AppRoutes.login);
        } else if (state is AuthError) {
          NavigationService.pushReplacementNamed(AppRoutes.login);
        }
      },
      child: Scaffold(
        backgroundColor: bgColor, 
        body: Stack(
          children: [
            
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? const Color(0xFF1C1C1E)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(
                        22,
                      ), 
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(
                      CupertinoIcons.bolt_fill,
                      size: 48,
                      color: primaryColor,
                    ),
                  ),

                  const SizedBox(height: 40),

                  const CupertinoActivityIndicator(radius: 14),
                ],
              ),
            ),

            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 40.0),
                child: Text(
                  "Flutter Clean Arch",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.withOpacity(0.6),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

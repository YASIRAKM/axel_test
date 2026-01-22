import 'package:axel_todo_test/core/config/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/primary_button.dart';

import '../../../../core/services/snackbar_service.dart';
import 'package:go_router/go_router.dart';

import '../bloc/auth_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  void _onLogin(BuildContext context, AuthState state) {
    if (_formKey.currentState!.validate()) {
      bool rememberMe = false;
      if (state is AuthUnauthenticated) {
        rememberMe = state.rememberMe;
      } else if (state is AuthError) {
        rememberMe = state.rememberMe;
      } else if (state is AuthLoading) {
        rememberMe = state.rememberMe;
      }

      context.read<AuthBloc>().add(
        AuthLoginRequested(
          username: _usernameController.text,
          password: _passwordController.text,
          rememberMe: rememberMe,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            SnackbarService.showError(state.message);
          } else if (state is AuthAuthenticated) {
            context.goNamed(AppRoutes.home);
          } else if (state is AuthUnauthenticated) {
            if (state.username != null) {
              _usernameController.text = state.username!;
            }
          }
        },
        builder: (context, state) {
          bool rememberMe = false;
          if (state is AuthUnauthenticated) {
            rememberMe = state.rememberMe;
            if (state.username != null && _usernameController.text.isEmpty) {
              _usernameController.text = state.username!;
            }
          } else if (state is AuthError) {
            rememberMe = state.rememberMe;
          } else if (state is AuthLoading) {
            rememberMe = state.rememberMe;
          }

          return CustomScrollView(
            physics: const ClampingScrollPhysics(),
            slivers: [
              SliverAppBar(
                expandedHeight: 200.0,
                floating: false,
                pinned: true,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                surfaceTintColor: Colors.transparent,
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
                  title: Text(
                    'Welcome Back',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Sign in to continue",
                          style: TextStyle(
                            fontSize: 17,
                            color: Colors.grey.shade600,
                          ),
                        ),

                        const SizedBox(height: 32),
                        CustomTextField(
                          controller: _usernameController,
                          label: 'Username',
                          prefixIcon: const Icon(Icons.person),
                          validator: (val) =>
                              val != null && val.isNotEmpty ? null : 'Required',
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          controller: _passwordController,
                          label: 'Password',
                          isPassword: true,
                          prefixIcon: const Icon(Icons.lock_outline),
                          validator: (val) =>
                              val != null && val.isNotEmpty ? null : 'Required',
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.only(left: 30),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Remember Me',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Switch.adaptive(
                                value: rememberMe,
                                activeThumbColor: Theme.of(
                                  context,
                                ).primaryColor,
                                onChanged: state is AuthLoading
                                    ? null
                                    : (val) {
                                        context.read<AuthBloc>().add(
                                          AuthToggleRememberMe(),
                                        );
                                      },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        PrimaryButton(
                          text: 'Login',
                          onPressed: () => _onLogin(context, state),
                          isLoading: state is AuthLoading,
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () {
                            context.pushNamed(AppRoutes.register);
                          },
                          child: const Text('Don\'t have an account? Register'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

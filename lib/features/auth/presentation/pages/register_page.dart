import 'dart:io';
import 'package:axel_todo_test/core/services/navigation_service.dart';
import '../../../../core/config/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/utils/string_extensions.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/image_picker_sheet.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/services/snackbar_service.dart';
import '../../../../core/utils/date_picker_helper.dart';
import '../../domain/entities/user.dart';
import '../../../../features/profile/presentation/widgets/profile_avatar.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/register_form/register_form_cubit.dart';
import '../bloc/register_form/register_form_state.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RegisterFormCubit(),
      child: const _RegisterPageContent(),
    );
  }
}

class _RegisterPageContent extends StatefulWidget {
  const _RegisterPageContent({super.key});

  @override
  State<_RegisterPageContent> createState() => _RegisterPageContentState();
}

class _RegisterPageContentState extends State<_RegisterPageContent> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  void _onRegister(BuildContext context, RegisterFormState formState) {
    if (_formKey.currentState!.validate() && formState.dateOfBirth != null) {
      final user = User(
        id: const Uuid().v4(),
        username: _usernameController.text,
        fullName: _fullNameController.text,
        dateOfBirth: formState.dateOfBirth,
        profilePicturePath: formState.imageFile?.path,
      );

      context.read<AuthBloc>().add(
        AuthRegisterRequested(user: user, password: _passwordController.text),
      );
    } else if (formState.dateOfBirth == null) {
      SnackbarService.showError('Please select Date of Birth');
    }
  }

  Future<void> _pickImage(BuildContext context) async {
    try {
      final XFile? pickedFile = await ImagePickerSheet.show(context);
      if (pickedFile != null && context.mounted) {
        context.read<RegisterFormCubit>().imageChanged(File(pickedFile.path));
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  Future<void> _pickDate(BuildContext context, DateTime? currentDate) async {
    final picked = await DatePickerHelper.pickDate(
      context,
      initialDate: currentDate,
    );
    if (picked != null && context.mounted) {
      context.read<RegisterFormCubit>().dateOfBirthChanged(picked);
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
            NavigationService.pushNamedAndRemoveUntil(
              AppRoutes.home,
              (route) => false,
            );
          }
        },
        builder: (context, authState) {
          return BlocBuilder<RegisterFormCubit, RegisterFormState>(
            builder: (context, formState) {
              return CustomScrollView(
                slivers: [
                  const SliverAppBar.large(title: Text('Register')),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            ProfileAvatar(
                              imagePath: formState.imageFile?.path,
                              onTap: () => _pickImage(context),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap to upload profile picture',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                            const SizedBox(height: 24),
                            CustomTextField(
                              controller: _fullNameController,
                              label: 'Full Name',
                              prefixIcon: const Icon(
                                CupertinoIcons.person_crop_rectangle,
                              ),
                              validator: (val) => val != null && val.isValidName
                                  ? null
                                  : 'Please enter valid full name',
                            ),
                            const SizedBox(height: 16),
                            CustomTextField(
                              controller: _usernameController,
                              label: 'Username',
                              prefixIcon: const Icon(CupertinoIcons.at),
                              validator: (val) =>
                                  val != null && val.isValidUsername
                                  ? null
                                  : 'Username must be at least 3 chars',
                            ),
                            const SizedBox(height: 16),
                            CustomTextField(
                              controller: TextEditingController(
                                text: formState.dateOfBirth != null
                                    ? "${formState.dateOfBirth!.day}/${formState.dateOfBirth!.month}/${formState.dateOfBirth!.year}"
                                    : "",
                              ),
                              label: 'Date of Birth',
                              readOnly: true,
                              onTap: () =>
                                  _pickDate(context, formState.dateOfBirth),
                              prefixIcon: const Icon(CupertinoIcons.calendar),
                              validator: (val) => formState.dateOfBirth != null
                                  ? null
                                  : 'Required',
                            ),
                            const SizedBox(height: 16),
                            CustomTextField(
                              controller: _passwordController,
                              label: 'Password',
                              isPassword: true,
                              prefixIcon: const Icon(CupertinoIcons.lock),
                              validator: (val) =>
                                  val != null && val.isValidPassword
                                  ? null
                                  : 'Password must have 8+ chars, 1 letter, 1 number',
                            ),
                            const SizedBox(height: 16),
                            CustomTextField(
                              controller: _confirmPasswordController,
                              label: 'Confirm Password',
                              isPassword: true,
                              prefixIcon: const Icon(CupertinoIcons.lock),
                              validator: (val) {
                                if (val == null || val.isEmpty) {
                                  return 'Required';
                                }
                                if (val != _passwordController.text) {
                                  return 'Passwords do not match';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 24),
                            PrimaryButton(
                              text: 'Register',
                              onPressed: () => _onRegister(context, formState),
                              isLoading: authState is AuthLoading,
                            ),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

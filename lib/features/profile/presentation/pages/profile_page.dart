import 'package:axel_todo_test/core/services/navigation_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/widgets/confirmation_dialog.dart';
import '../../../../core/widgets/image_picker_sheet.dart';
import '../../../../core/services/snackbar_service.dart';
import '../../../../core/utils/date_picker_helper.dart';
import '../../../../core/utils/string_extensions.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../di/injection_container.dart';
import '../../../auth/domain/entities/user.dart';
import '../bloc/profile_bloc.dart';
import '../bloc/profile_form/profile_form_cubit.dart';
import '../bloc/profile_form/profile_form_state.dart';
import '../widgets/profile_avatar.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<ProfileBloc>()..add(LoadProfile())),
        BlocProvider(create: (_) => ProfileFormCubit()),
      ],
      child: const ProfileView(),
    );
  }
}

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  late TextEditingController _fullNameController;
  late TextEditingController _dateController;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController();
    _fullNameController = TextEditingController();
    _dateController = TextEditingController();
    _usernameController.addListener(_onFieldChanged);
    _fullNameController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    context.read<ProfileFormCubit>().markDirty();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _fullNameController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  void _populateFields(BuildContext context, User user) {
    _currentUser = user;
    
    if (_usernameController.text.isEmpty) {
      _usernameController.text = user.username;
    }
    if (_fullNameController.text.isEmpty) {
      _fullNameController.text = user.fullName;
    }
    if (_dateController.text.isEmpty) {
      _dateController.text = user.dateOfBirth.toString();
    }

    context.read<ProfileFormCubit>().initialize(user);
  }

  Future<bool> _onWillPop(BuildContext context, bool isDirty) async {
    if (!isDirty) return true;

    final shouldPop = await ConfirmationDialog.show(
      context,
      title: 'Unsaved Changes',
      content: 'You have unsaved changes. Do you really want to leave?',
      confirmText: 'Leave',
    );

    return shouldPop;
  }

  void _saveProfile(BuildContext context, ProfileFormState formState) {
    if (_formKey.currentState!.validate()) {
      final updatedUser = User(
        id: _currentUser!.id,
        username: _usernameController.text,
        fullName: _fullNameController.text,
        profilePicturePath: formState.imagePath,
        dateOfBirth: formState.dateOfBirth,
      );

      context.read<ProfileBloc>().add(UpdateProfileEvent(user: updatedUser));
      context.read<ProfileFormCubit>().resetDirty();
    }
  }

  Future<void> _selectDate(BuildContext context, DateTime? currentDate) async {
    final pickedDate = await DatePickerHelper.pickDate(
      context,
      initialDate: currentDate,
    );

    if (pickedDate != null && pickedDate != currentDate) {
      if (context.mounted) {
        context.read<ProfileFormCubit>().dateChanged(pickedDate);
      }
    }
  }

  Future<void> _pickImage(BuildContext context, String? currentPath) async {
    final pickedFile = await ImagePickerSheet.show(
      context,
      hasImage: currentPath != null,
    );

    if (pickedFile != null && context.mounted) {
      context.read<ProfileFormCubit>().imageChanged(
        pickedFile.path.isEmpty ? null : pickedFile.path,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileFormCubit, ProfileFormState>(
      builder: (context, formState) {
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) async {
            if (!didPop) {
              final shouldPop = await _onWillPop(context, formState.isDirty);
              if (shouldPop) {
                NavigationService.pop();
              }
            }
          },
          child: Scaffold(
            body: BlocConsumer<ProfileBloc, ProfileState>(
              listener: (context, state) {
                if (state is ProfileLoaded) {
                  if (_currentUser == null || state.message != null) {
                    _populateFields(context, state.user);
                  }

                  if (state.message != null) {
                    SnackbarService.showSuccess(state.message!);
                  }
                } else if (state is ProfileError) {
                  SnackbarService.showError(state.message);
                }
              },
              builder: (context, profileState) {
                if (profileState is ProfileLoaded ||
                    profileState is ProfileLoading) {
                  if (formState.dateOfBirth != null) {
                    _dateController.text =
                        "${formState.dateOfBirth!.day}/${formState.dateOfBirth!.month}/${formState.dateOfBirth!.year}";
                  } else {
                    _dateController.text = "";
                  }

                  return CustomScrollView(
                    slivers: [
                      const SliverAppBar.large(title: Text('Edit Profile')),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                ProfileAvatar(
                                  imagePath: formState.imagePath,
                                  onTap: () =>
                                      _pickImage(context, formState.imagePath),
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
                                const SizedBox(height: 32),
                                CustomTextField(
                                  controller: _fullNameController,
                                  label: 'Full Name',
                                  prefixIcon: const Icon(
                                    CupertinoIcons.person_crop_rectangle,
                                  ),
                                  validator: (val) =>
                                      val != null && val.isValidName
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
                                  controller: _dateController,
                                  label: 'Date of Birth',
                                  readOnly: true,
                                  onTap: () => _selectDate(
                                    context,
                                    formState.dateOfBirth,
                                  ),
                                  prefixIcon: const Icon(
                                    CupertinoIcons.calendar,
                                  ),
                                  validator: (val) =>
                                      formState.dateOfBirth != null
                                      ? null
                                      : 'Required',
                                ),
                                const SizedBox(height: 32),
                                PrimaryButton(
                                  text: 'Update Profile',
                                  onPressed: () =>
                                      _saveProfile(context, formState),
                                  isLoading: profileState is ProfileLoading,
                                ),
                                const SizedBox(height: 40), 
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                } else if (profileState is ProfileError) {
                  return Center(child: Text(profileState.message));
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        );
      },
    );
  }
}

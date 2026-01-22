import 'package:axel_todo_test/core/config/app_routes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/services/snackbar_service.dart';
import '../../../../core/widgets/confirmation_dialog.dart';
import '../bloc/settings_bloc.dart';
import '../bloc/settings_event.dart';
import '../bloc/settings_state.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          const SliverAppBar.large(title: Text('Settings')),
          SliverList(
            delegate: SliverChildListDelegate([
              _SettingsSection(
                title: 'Account',
                children: [
                  _SettingsTile(
                    icon: CupertinoIcons.person_fill,
                    iconBgColor: Colors.blue,
                    title: 'Edit Profile',
                    onTap: () => context.pushNamed(AppRoutes.profile),
                  ),
                ],
              ),

              _SettingsSection(
                title: 'Appearance',
                children: [
                  BlocBuilder<SettingsBloc, SettingsState>(
                    buildWhen: (previous, current) =>
                        previous.themeMode != current.themeMode,
                    builder: (context, state) {
                      return _SettingsTile(
                        icon: CupertinoIcons.moon_fill,
                        iconBgColor: Colors.indigo,
                        title: 'Dark Mode',
                        isSwitch: true,
                        switchValue: state.themeMode == ThemeMode.dark,
                        onSwitchChanged: (isDark) {
                          context.read<SettingsBloc>().add(
                            SettingsThemeToggled(
                              isDark ? ThemeMode.dark : ThemeMode.light,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ],
              ),

              _SettingsSection(
                title: 'Data',
                children: [
                  BlocConsumer<SettingsBloc, SettingsState>(
                    listener: (context, state) {
                      if (state.message != null && !state.isCacheClearing) {
                        SnackbarService.show(state.message!);
                        if (state.message!.contains('Success')) {
                          context.read<AuthBloc>().add(AuthLogoutRequested());
                          context.goNamed(AppRoutes.splash);
                        }
                      }
                    },
                    builder: (context, state) {
                      if (state.isCacheClearing) {
                        return const _SettingsTile(
                          icon: CupertinoIcons.hourglass,
                          iconBgColor: Colors.grey,
                          title: 'Clearing Cache...',
                          trailing: CupertinoActivityIndicator(),
                        );
                      }
                      return _SettingsTile(
                        icon: CupertinoIcons.trash_fill,
                        iconBgColor: Colors.red,
                        title: 'Clear Cache',
                        onTap: () async {
                          final confirmed = await ConfirmationDialog.show(
                            context,
                            title: 'Clear Cache?',
                            content:
                                'This will remove all locally saved data and log you out.',
                            confirmText: 'Clear',
                          );

                          if (confirmed == true) {
                            context.read<SettingsBloc>().add(
                              SettingsCacheCleared(),
                            );
                          }
                        },
                      );
                    },
                  ),
                ],
              ),

              _SettingsSection(
                title: 'Session',
                children: [
                  _SettingsTile(
                    icon: CupertinoIcons.square_arrow_right,
                    iconBgColor: Colors.red,
                    title: 'Logout',
                    onTap: () async {
                      final confirmed = await ConfirmationDialog.show(
                        context,
                        title: 'Logout?',
                        content: 'Are you sure you want to logout?',
                        confirmText: 'Logout',
                        isDestructive: true,
                      );

                      if (confirmed == true) {
                        context.read<AuthBloc>().add(AuthLogoutRequested());
                        context.goNamed(AppRoutes.splash);
                      }
                    },
                  ),
                ],
              ),

              const SizedBox(height: 32),
            ]),
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            title.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              letterSpacing: 1.2,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              for (int i = 0; i < children.length; i++) ...[
                children[i],
                if (i != children.length - 1)
                  Padding(
                    padding: const EdgeInsets.only(left: 64),
                    child: Divider(
                      height: 1,
                      thickness: 0.5,
                      color: Theme.of(context).dividerColor.withOpacity(0.5),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconBgColor;
  final String title;
  final VoidCallback? onTap;
  final bool isSwitch;
  final bool switchValue;
  final ValueChanged<bool>? onSwitchChanged;
  final Widget? trailing;

  const _SettingsTile({
    required this.icon,
    required this.iconBgColor,
    required this.title,
    this.onTap,
    this.isSwitch = false,
    this.switchValue = false,
    this.onSwitchChanged,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isSwitch ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 16),

              Expanded(
                child: Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
                ),
              ),

              if (isSwitch)
                Switch.adaptive(
                  value: switchValue,
                  onChanged: onSwitchChanged,
                  activeColor: Colors.green,
                )
              else if (trailing != null)
                trailing!
              else
                Icon(
                  CupertinoIcons.chevron_forward,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurfaceVariant.withOpacity(0.5),
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

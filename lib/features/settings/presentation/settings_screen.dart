import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/theme_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../lists/providers/lists_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentTheme = ref.watch(themeModeProvider);
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        children: [
          // Account Section Header
          _SectionHeader(title: 'Account', isDark: isDark),
          const SizedBox(height: 8),

          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: Column(
              children: [
                if (authState.user != null) ...[
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          AppColors.primary.withValues(alpha: 0.2),
                      child: Text(
                        (authState.user!.displayName?.isNotEmpty ?? false)
                            ? authState.user!.displayName![0].toUpperCase()
                            : (authState.user!.email?.isNotEmpty ?? false)
                                ? authState.user!.email![0].toUpperCase()
                                : 'U',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      authState.user!.displayName ?? 'User',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      authState.user!.email ?? '',
                      style: TextStyle(
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.lock_outline_rounded),
                    title: const Text('Change Password'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => _showChangePasswordDialog(context, ref),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(
                      Icons.logout_rounded,
                      color: AppColors.error,
                    ),
                    title: const Text(
                      'Sign Out',
                      style: TextStyle(color: AppColors.error),
                    ),
                    onTap: () => _confirmSignOut(context, ref),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(
                      Icons.delete_forever_rounded,
                      color: AppColors.error,
                    ),
                    title: const Text(
                      'Delete Account',
                      style: TextStyle(color: AppColors.error),
                    ),
                    onTap: () => _confirmDeleteAccount(context, ref),
                  ),
                ] else ...[
                  ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: AppColors.warning,
                      child: Icon(Icons.person_off_rounded, color: Colors.white),
                    ),
                    title: const Text(
                      'Guest Mode (Offline)',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: const Text('Sign in to sync across devices'),
                    trailing: ElevatedButton(
                      onPressed: () => context.push('/login'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      child: const Text('Sign In'),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Appearance Section
          _SectionHeader(title: 'Appearance', isDark: isDark),
          const SizedBox(height: 8),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Theme Mode',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<ThemeMode>(
                    segments: const [
                      ButtonSegment(
                        value: ThemeMode.system,
                        label: Text('System'),
                        icon: Icon(Icons.settings_brightness_rounded),
                      ),
                      ButtonSegment(
                        value: ThemeMode.light,
                        label: Text('Light'),
                        icon: Icon(Icons.light_mode_rounded),
                      ),
                      ButtonSegment(
                        value: ThemeMode.dark,
                        label: Text('Dark'),
                        icon: Icon(Icons.dark_mode_rounded),
                      ),
                    ],
                    selected: {currentTheme},
                    onSelectionChanged: (Set<ThemeMode> newSelection) {
                      ref
                          .read(themeModeProvider.notifier)
                          .setThemeMode(newSelection.first);
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Data Management
          _SectionHeader(title: 'Data & Storage', isDark: isDark),
          const SizedBox(height: 8),

          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              ),
            ),
            child: ListTile(
              leading: const Icon(
                Icons.cleaning_services_rounded,
                color: AppColors.error,
              ),
              title: const Text(
                'Clear All Data',
                style: TextStyle(color: AppColors.error),
              ),
              subtitle: const Text('Permanently reset local database'),
              onTap: () => _confirmClearData(context, ref),
            ),
          ),
          const SizedBox(height: 32),

          // App Info
          Center(
            child: Column(
              children: [
                Container(
                  height: 64,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset(
                    'assets/images/logo.png',
                    fit: BoxFit.contain,
                  ),
                ),
                Text(
                  AppConstants.appName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Version ${AppConstants.appVersion}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context, WidgetRef ref) {
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Change Password'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'New Password',
              prefixIcon: Icon(Icons.lock_outline),
            ),
            validator: (val) {
              if (val == null || val.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => ctx.pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                try {
                  await ref
                      .read(authNotifierProvider.notifier)
                      .updatePassword(passwordController.text);
                  if (ctx.mounted) ctx.pop();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Password updated successfully!'),
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(e.toString()),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                }
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _confirmSignOut(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => ctx.pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              ctx.pop();
              ref.read(authNotifierProvider.notifier).signOut();
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAccount(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'This action is irreversible. Your account and cloud backups will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => ctx.pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              ctx.pop();
              ref.read(authNotifierProvider.notifier).deleteAccount();
            },
            child: const Text('Delete Permanently'),
          ),
        ],
      ),
    );
  }

  void _confirmClearData(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear All Local Data'),
        content: const Text(
          'Are you sure you want to clear all local tasks and lists? This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => ctx.pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              ctx.pop();
              await ref.read(isarServiceProvider).clearAllData();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All local data cleared.')),
                );
              }
            },
            child: const Text('Clear Everything'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final bool isDark;

  const _SectionHeader({required this.title, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.1,
        color: isDark
            ? AppColors.textSecondaryDark
            : AppColors.textSecondaryLight,
      ),
    );
  }
}

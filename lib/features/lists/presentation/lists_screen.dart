import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';
import '../providers/lists_provider.dart';
import 'create_edit_list_dialog.dart';

class ListsScreen extends ConsumerWidget {
  const ListsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final listsAsync = ref.watch(listsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lists & Projects'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => CreateEditListDialog.show(context),
          ),
        ],
      ),
      body: listsAsync.when(
        data: (lists) {
          if (lists.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.folder_open_rounded,
                    size: 64,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No lists created yet',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  const Text('Organize your tasks into projects and categories'),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () => CreateEditListDialog.show(context),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Create List'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: lists.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final list = lists[index];
              final listColor = Color(list.colorValue);

              return Container(
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: listColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      AppIcons.fromCodePoint(list.iconCodePoint),
                      color: listColor,
                      size: 24,
                    ),
                  ),
                  title: Text(
                    list.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Text(
                    '${list.activeTaskCount} active tasks',
                    style: TextStyle(
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert_rounded),
                        onSelected: (val) async {
                          if (val == 'edit') {
                            CreateEditListDialog.show(
                              context,
                              listToEdit: list,
                            );
                          } else if (val == 'delete') {
                            final deleteTasks = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: Text('Delete "${list.name}"?'),
                                content: const Text(
                                  'Do you also want to delete all tasks inside this list, or keep them unassigned?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => ctx.pop(null),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () => ctx.pop(false),
                                    child: const Text('Keep Tasks'),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.error,
                                      foregroundColor: Colors.white,
                                    ),
                                    onPressed: () => ctx.pop(true),
                                    child: const Text('Delete All'),
                                  ),
                                ],
                              ),
                            );

                            if (deleteTasks != null) {
                              ref.read(listRepositoryProvider).deleteList(
                                    list.id,
                                    deleteTasks: deleteTasks,
                                  );
                            }
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit_outlined, size: 18),
                                SizedBox(width: 8),
                                Text('Edit List'),
                              ],
                            ),
                          ),
                          if (!list.isDefault)
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.delete_outline_rounded,
                                    color: AppColors.error,
                                    size: 18,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Delete',
                                    style: TextStyle(color: AppColors.error),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const Icon(Icons.chevron_right_rounded),
                    ],
                  ),
                  onTap: () {
                    context.push('/lists/${list.id}');
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

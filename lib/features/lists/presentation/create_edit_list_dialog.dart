import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_icons.dart';
import '../../../domain/models/project_list_model.dart';
import '../providers/lists_provider.dart';

class CreateEditListDialog extends ConsumerStatefulWidget {
  final ProjectListModel? listToEdit;

  const CreateEditListDialog({super.key, this.listToEdit});

  static Future<void> show(
    BuildContext context, {
    ProjectListModel? listToEdit,
  }) {
    return showDialog(
      context: context,
      builder: (context) => CreateEditListDialog(listToEdit: listToEdit),
    );
  }

  @override
  ConsumerState<CreateEditListDialog> createState() =>
      _CreateEditListDialogState();
}

class _CreateEditListDialogState extends ConsumerState<CreateEditListDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late int _selectedColor;
  late int _selectedIcon;

  @override
  void initState() {
    super.initState();
    final list = widget.listToEdit;
    _nameController = TextEditingController(text: list?.name ?? '');
    _selectedColor =
        list?.colorValue ?? AppColors.presetColors.first.toARGB32();
    _selectedIcon = list?.iconCodePoint ?? AppIcons.availableIcons.first.codePoint;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final repo = ref.read(listRepositoryProvider);
    final name = _nameController.text.trim();

    if (widget.listToEdit != null) {
      final updated = widget.listToEdit!.copyWith(
        name: name,
        colorValue: _selectedColor,
        iconCodePoint: _selectedIcon,
        updatedAt: DateTime.now(),
      );
      repo.saveList(updated);
    } else {
      final newList = ProjectListModel.create(
        name: name,
        colorValue: _selectedColor,
        iconCodePoint: _selectedIcon,
      );
      repo.saveList(newList);
    }

    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      title: Text(widget.listToEdit != null ? 'Edit List' : 'New List'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // List Name Field
              TextFormField(
                controller: _nameController,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'List Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter a list name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Color Selection
              const Text(
                'Color',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: AppColors.presetColors.map((color) {
                  final colorVal = color.toARGB32();
                  final isSelected = _selectedColor == colorVal;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedColor = colorVal;
                      });
                    },
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color,
                        border: isSelected
                            ? Border.all(color: Colors.white, width: 2.5)
                            : null,
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 16,
                            )
                          : null,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              // Icon Selection
              const Text(
                'Icon',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: AppIcons.availableIcons.map((icon) {
                  final isSelected = _selectedIcon == icon.codePoint;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedIcon = icon.codePoint;
                      });
                    },
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Color(_selectedColor).withValues(alpha: 0.2)
                            : (isDark
                                ? AppColors.darkCard
                                : AppColors.lightCard),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected
                              ? Color(_selectedColor)
                              : Colors.transparent,
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        icon,
                        size: 20,
                        color: isSelected
                            ? Color(_selectedColor)
                            : (isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => context.pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _save,
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(_selectedColor),
            foregroundColor: Colors.white,
          ),
          child: const Text('Save'),
        ),
      ],
    );
  }
}

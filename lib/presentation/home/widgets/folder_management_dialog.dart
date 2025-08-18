import 'package:bevert/core/constants/constants.dart';
import 'package:bevert/core/services/helper/color_to_hex.dart';
import 'package:bevert/data/models/transcript_record/transcript_folder_model.dart';
import 'package:bevert/domain/entities/transcript_folder/folder_edit_result_dto.dart';
import 'package:bevert/presentation/home/bloc/transcript_folder_bloc/folder_bloc.dart';
import 'package:bevert/presentation/home/bloc/transcript_folder_bloc/folder_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FolderManagementDialog extends StatefulWidget {
  final List<Folder> existingFolders;
  final Folder? initialFolder;
  final bool isEditing;

  const FolderManagementDialog({
    super.key,
    required this.existingFolders,
    this.initialFolder,
    this.isEditing = false,
  });

  @override
  State<FolderManagementDialog> createState() => _FolderManagementDialogState();

  static Future<FolderEditResult?> show(
      BuildContext context, {
        required List<Folder> existingFolders,
        Folder? folderToEdit,
      }) async {
    final isEditing = folderToEdit != null;

    return await showDialog<FolderEditResult>(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(24),
        child: FolderManagementDialog(
          existingFolders: existingFolders,
          initialFolder: folderToEdit,
          isEditing: isEditing,
        ),
      ),
    );
  }
}

class _FolderManagementDialogState extends State<FolderManagementDialog> {
  late final TextEditingController _controller;
  String? _errorText;
  late Color _selectedColor;
  bool _isColorPickerVisible = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialFolder?.name ?? '');
    _selectedColor = widget.initialFolder?.color ?? FolderColors.availableColors.first;
  }

  void _onSave() {
    final name = _controller.text.trim();
    final hexColor = colorToHex(_selectedColor);

    if (name.isEmpty) {
      setState(() => _errorText = '폴더명을 입력해주세요.');
      return;
    }

    final isDuplicate = widget.existingFolders.any(
          (f) => f.name == name && f.id != widget.initialFolder?.id,
    );

    if (isDuplicate) {
      setState(() => _errorText = '이미 존재하는 폴더입니다.');
      return;
    }

    final bloc = context.read<FolderBloc>();

    if (widget.isEditing) {
      bloc.add(UpdateFolderEvent(
        folderId: widget.initialFolder!.id,
        oldName: widget.initialFolder!.name,
        newName: name,
        newColorHex: hexColor,
      ));
    } else {
      bloc.add(CreateFolderEvent(name, hexColor));
    }

    Navigator.of(context).pop(FolderEditResult(name: name, color: _selectedColor));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.isEditing ? '폴더 수정' : '폴더 생성', style: theme.textTheme.titleLarge?.copyWith(color: theme.primaryColor, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            // Color Picker Section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('색상 선택', style: theme.textTheme.bodyMedium,),
                    const SizedBox(width: 16),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isColorPickerVisible = !_isColorPickerVisible;
                        });
                      },
                      child: CircleAvatar(
                        backgroundColor: _selectedColor,
                        radius: 16,
                        child: const Icon(Icons.folder, color: Colors.white, size: 14),
                      ),
                    ),
                  ],
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: Visibility(
                    visible: _isColorPickerVisible,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 16.0),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: FolderColors.availableColors.map((color) {
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedColor = color;
                                _isColorPickerVisible = false;
                              });
                            },
                            child: CircleAvatar(
                              backgroundColor: color,
                              radius: 20,
                              child: _selectedColor == color
                                  ? const Icon(Icons.check, color: Colors.white)
                                  : null,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // 텍스트 필드
            TextField(
              controller: _controller,
              autofocus: true,
              decoration: InputDecoration(
                labelText: '폴더 이름',
                errorText: _errorText,
                border: const OutlineInputBorder(),
              ),
              onSubmitted: (_) => _onSave(),
            ),
            const SizedBox(height: 24),

            // 버튼
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('취소', style: theme.textTheme.labelLarge?.copyWith(color: theme.hintColor)),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: _onSave,
                  child: Text(
                    widget.isEditing ? '저장' : '생성',
                    style: theme.textTheme.labelLarge?.copyWith(color: theme.primaryColor),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
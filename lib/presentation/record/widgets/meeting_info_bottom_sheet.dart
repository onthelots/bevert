import 'package:flutter/material.dart';

class MeetingInfoBottomSheet extends StatefulWidget {
  final String initialTitle;
  final String initialContext;
  final Function(String title, String context) onSave;

  const MeetingInfoBottomSheet({
    Key? key,
    required this.initialTitle,
    required this.initialContext,
    required this.onSave,
  }) : super(key: key);

  @override
  State<MeetingInfoBottomSheet> createState() => _MeetingInfoBottomSheetState();
}

class _MeetingInfoBottomSheetState extends State<MeetingInfoBottomSheet> {
  late TextEditingController titleController;
  late TextEditingController contextController;

  final FocusNode _contextFocusNode = FocusNode();

  double _modalInitialSize = 0.6; // 초기값 0.6

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.initialTitle);
    contextController = TextEditingController(text: widget.initialContext);

    _contextFocusNode.addListener(() {
      if (_contextFocusNode.hasFocus) {
        setState(() {
          _modalInitialSize = 0.9; // 키보드 올라올 때 크게
        });
      } else {
        setState(() {
          _modalInitialSize = 0.6; // 키보드 내려가면 작게
        });
      }
    });
  }

  @override
  void dispose() {
    titleController.dispose();
    contextController.dispose();
    _contextFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: _modalInitialSize,
      minChildSize: 0.6,
      maxChildSize: 0.95,
      builder: (_, controller) {
        return GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus(); // 키보드 내림
          },
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                top: 12,
                left: 16,
                right: 16,
              ),
              child: SingleChildScrollView(
                controller: controller,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '회의 정보를 알려주세요',
                          style: theme.textTheme.bodyLarge,
                        ),
                        TextButton(
                          onPressed: () {
                            final now = DateTime.now().toLocal();
                            final fallbackTitle =
                                '제목없음_${now.toString().substring(0, 16)}';

                            final titleText = titleController.text.trim().isEmpty
                                ? fallbackTitle
                                : titleController.text.trim();

                            final contextText = contextController.text.trim();

                            widget.onSave(titleText, contextText);
                            Navigator.of(context).pop();
                          },
                          child: const Text(
                            '저장',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: titleController,
                      maxLength: 20,
                      style: theme.textTheme.bodyMedium,
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding:
                        const EdgeInsets.symmetric(vertical: 15, horizontal: 12),
                        hintText: '제목을 입력해주세요',
                        hintStyle: theme.textTheme.bodyMedium,
                        filled: true,
                        fillColor: theme.cardColor,
                        alignLabelWithHint: true,
                        border: InputBorder.none,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: theme.cardColor,
                            width: 0.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: theme.primaryColor,
                            width: 0.8,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: contextController,
                      focusNode: _contextFocusNode,
                      maxLength: 100,
                      maxLines: 5,
                      style: theme.textTheme.bodyMedium,
                      decoration: InputDecoration(
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 14,
                        ),
                        hintText: '대화 주제 / 상황 / 맥락을 간략히 입력해주세요',
                        hintStyle: theme.textTheme.bodyMedium,
                        filled: true,
                        fillColor: theme.cardColor,
                        alignLabelWithHint: true,
                        border: InputBorder.none,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: theme.cardColor,
                            width: 0.5,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: theme.primaryColor,
                            width: 0.8,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

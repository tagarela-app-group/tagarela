import 'package:flutter/material.dart';

import 'package:tagarela/app/app_scope.dart';
import 'package:tagarela/design_system/design_system.dart';

class TextCaptureSheet extends StatefulWidget {
  const TextCaptureSheet({super.key});

  static const maxLength = 500;

  @override
  State<TextCaptureSheet> createState() => _TextCaptureSheetState();
}

class _TextCaptureSheetState extends State<TextCaptureSheet> {
  final _text = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final capture = await AppScope.of(
      context,
    ).captures.createText(_text.text.trim());
    if (mounted) Navigator.pop(context, capture);
  }

  @override
  Widget build(BuildContext context) => AppSheet(
    icon: AppIcons.text,
    accent: AppAccent.violet,
    title: 'Digitar texto',
    subtitle: 'O que você ouviu ou leu hoje',
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.s4,
      children: [
        AppTextField(
          label: 'Palavra, expressão ou frase',
          helperText: 'Frase ou trecho. Os termos você escolhe no Inbox.',
          controller: _text,
          lines: 4,
          maxLength: TextCaptureSheet.maxLength,
          autofocus: true,
        ),
        ListenableBuilder(
          listenable: _text,
          builder: (context, _) => AppButton(
            label: 'Salvar no Inbox',
            expand: true,
            loading: _saving,
            onPressed: _text.text.trim().isEmpty ? null : _save,
          ),
        ),
      ],
    ),
  );
}

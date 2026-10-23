import 'package:flutter/material.dart';

import 'package:tagarela/app/app_scope.dart';
import 'package:tagarela/data/models.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/features/inbox/term_selection.dart';
import 'package:tagarela/features/inbox/widgets/capture_card.dart';
import 'package:tagarela/features/inbox/widgets/word_picker.dart';

class PickTermsPage extends StatefulWidget {
  const PickTermsPage({super.key, required this.capture});

  final Capture capture;

  @override
  State<PickTermsPage> createState() => _PickTermsPageState();
}

class _PickTermsPageState extends State<PickTermsPage> {
  late TermSelection _selection = TermSelection.of(widget.capture);
  late final _text = TextEditingController(text: widget.capture.text);
  bool _editing = false;
  bool _saving = false;
  bool _discarding = false;

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  void _pick(int first, int last) {
    final span = _selection.spanOf(first, last);
    final limit = _selection.limit(span);
    if (limit != null) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(_limitMessage(limit))));
      return;
    }
    setState(() => _selection = _selection.toggle(span));
  }

  void _remove(Span span) =>
      setState(() => _selection = _selection.remove(span));

  void _finishEditing() {
    final text = _text.text.trim();
    setState(() {
      if (text.isNotEmpty) _selection = _selection.edit(text);
      _text.text = _selection.text;
      _editing = false;
    });
  }

  Future<void> _confirm() async {
    if (_editing) _finishEditing();
    setState(() => _saving = true);
    await AppScope.of(context).captures.confirm(
      widget.capture,
      text: _selection.text,
      terms: _selection.toTerms(),
    );
    if (mounted) Navigator.pop(context);
  }

  Future<void> _discard() async {
    setState(() => _discarding = true);
    await AppScope.of(context).captures.discard(widget.capture);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final capture = widget.capture;
    final count = _selection.spans.length;

    return SheetPage(
      header: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.s4,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppIconButton(
                icon: AppIcons.back,
                tooltip: 'Voltar',
                variant: AppIconButtonVariant.onHeader,
                onPressed: () => Navigator.maybePop(context),
              ),
              AppIconButton(
                icon: AppIcons.delete,
                tooltip: 'Descartar captura',
                variant: AppIconButtonVariant.onHeader,
                onPressed: _saving || _discarding ? null : _discard,
              ),
            ],
          ),
          PageHeader(
            title: 'Escolher termos',
            subtitle:
                '${capture.source.label} · ${timeAgo(capture.capturedAt, DateTime.now())}',
          ),
        ],
      ),
      gap: AppSpacing.s4,
      footer: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.s2,
        children: [
          Text(
            'Ao confirmar, a IA monta a ficha de cada termo.',
            textAlign: TextAlign.center,
            style: AppText.label.copyWith(
              fontWeight: FontWeight.w400,
              color: c.inkSoft,
            ),
          ),
          AppButton(
            label: count == 0
                ? 'Escolha pelo menos um termo'
                : 'Confirmar análise · $count ${count == 1 ? 'termo' : 'termos'}',
            size: AppButtonSize.large,
            expand: true,
            loading: _saving,
            onPressed: count == 0 || _discarding ? null : _confirm,
          ),
        ],
      ),
      children: [
        Text(
          'Arraste o dedo sobre as palavras pra marcar uma expressão. '
          'Toque numa palavra pra marcar só ela.',
          style: AppText.bodyMd.copyWith(color: c.inkSoft),
        ),
        AppCard(
          padding: const EdgeInsets.all(AppSpacing.s3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: AppSpacing.s1,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: AppSpacing.s1),
                      child: Text(
                        'Texto',
                        style: AppText.pill.copyWith(color: c.inkSoft),
                      ),
                    ),
                  ),
                  AppButton(
                    label: _editing ? 'Pronto' : 'Editar texto',
                    leading: Icon(
                      _editing ? AppIcons.check : AppIcons.edit,
                      size: 16,
                    ),
                    variant: AppButtonVariant.text,
                    size: AppButtonSize.small,
                    onPressed: _editing
                        ? _finishEditing
                        : () => setState(() => _editing = true),
                  ),
                ],
              ),
              if (_editing)
                AppTextField(
                  controller: _text,
                  helperText:
                      'Corrija o que saiu errado. Os termos marcados continuam quando a palavra não mudar.',
                  lines: 5,
                  maxLength: TermSelection.maxTextLength,
                  autofocus: true,
                )
              else
                WordPicker(selection: _selection, onPick: _pick),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: AppSpacing.s3,
          children: [
            Text(
              'Termos escolhidos · $count'.toUpperCase(),
              style: AppText.overline.copyWith(color: c.inkSoft),
            ),
            if (count == 0)
              Text(
                'Nenhum ainda. Toque numa palavra do texto.',
                style: AppText.bodyMd.copyWith(color: c.inkSoft),
              )
            else
              Wrap(
                spacing: AppSpacing.s2,
                runSpacing: AppSpacing.s2,
                children: [
                  for (final span in _selection.spans)
                    TermChip(
                      label: _selection.termText(span),
                      onRemove: () => _remove(span),
                    ),
                ],
              ),
          ],
        ),
      ],
    );
  }
}

String _limitMessage(TermLimit limit) => switch (limit) {
  TermLimit.tooLong =>
    'Expressão grande demais. Marque até ${TermSelection.maxTermLength} caracteres.',
  TermLimit.tooMany =>
    'Limite de ${TermSelection.maxTerms} termos por captura.',
};

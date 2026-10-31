import 'package:flutter/material.dart';

import 'package:tagarela/app/app_scope.dart';
import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/features/inbox/logic/term_selection.dart';
import 'package:tagarela/features/inbox/widgets/word_picker.dart';
import 'package:tagarela/l10n/l10n.dart';
import 'package:tagarela/shared/logic/time_ago.dart';

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
      AppToast.notice(context, _limitMessage(context.l10n, limit));
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

    return AppPage(
      header: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.s4,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppIconButton(
                icon: AppIcons.back,
                tooltip: context.l10n.back,
                variant: AppIconButtonVariant.onHeader,
                onPressed: () => Navigator.maybePop(context),
              ),
              AppIconButton(
                icon: AppIcons.delete,
                tooltip: context.l10n.discardCapture,
                variant: AppIconButtonVariant.onHeader,
                onPressed: _saving || _discarding ? null : _discard,
              ),
            ],
          ),
          PageHeader(
            title: context.l10n.pickTerms,
            subtitle:
                '${context.l10n.captureSource(capture.source.name)} · '
                '${timeAgo(context.l10n, capture.capturedAt, DateTime.now())}',
          ),
        ],
      ),
      gap: AppSpacing.s4,
      footer: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.s2,
        children: [
          Text(
            context.l10n.confirmHint,
            textAlign: TextAlign.center,
            style: AppText.label.copyWith(
              fontWeight: FontWeight.w400,
              color: c.inkSoft,
            ),
          ),
          AppButton(
            label: count == 0
                ? context.l10n.pickAtLeastOne
                : context.l10n.confirmAnalysisCount(count),
            size: AppButtonSize.large,
            expand: true,
            loading: _saving,
            onPressed: count == 0 || _discarding ? null : _confirm,
          ),
        ],
      ),
      children: [
        Text(
          context.l10n.pickHelp,
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
                        context.l10n.textSection,
                        style: AppText.pill.copyWith(color: c.inkSoft),
                      ),
                    ),
                  ),
                  AppButton(
                    label: _editing ? context.l10n.done : context.l10n.editText,
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
                  helperText: context.l10n.editTextHelper,
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
              context.l10n.chosenTermsCount(count).toUpperCase(),
              style: AppText.overline.copyWith(color: c.inkSoft),
            ),
            if (count == 0)
              Text(
                context.l10n.noTermsYetTap,
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

String _limitMessage(AppLocalizations l10n, TermLimit limit) => switch (limit) {
  TermLimit.tooLong => l10n.termTooLong(TermSelection.maxTermLength),
  TermLimit.tooMany => l10n.tooManyTerms(TermSelection.maxTerms),
};

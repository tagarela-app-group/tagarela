import 'package:flutter/material.dart';

import 'package:tagarela/app/app_scope.dart';
import 'package:tagarela/data/models.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/features/inbox/pick_terms_page.dart';
import 'package:tagarela/features/inbox/widgets/capture_card.dart';

enum InboxTab {
  all('Todas', CaptureSection.values),
  ready('Prontas', [CaptureSection.ready]),
  pending('Pendentes', [
    CaptureSection.attention,
    CaptureSection.processing,
    CaptureSection.waiting,
  ]),
  done('Analisadas', [CaptureSection.done]);

  const InboxTab(this.label, this.sections);

  final String label;
  final List<CaptureSection> sections;
}

class InboxPage extends StatefulWidget {
  const InboxPage({super.key});

  @override
  State<InboxPage> createState() => _InboxPageState();
}

class _InboxPageState extends State<InboxPage> {
  InboxTab _tab = InboxTab.all;

  Future<void> _run(Future<void> Function() action) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await action();
    } on Exception {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Sem conexão. Tente de novo quando tiver internet.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final captures = AppScope.of(context).captures;

    return ListenableBuilder(
      listenable: captures,
      builder: (context, _) {
        final items = captures.data;
        return SheetPage(
          header: PageHeader(
            title: 'Inbox',
            subtitle: items == null ? null : summary(items),
          ),
          gap: AppSpacing.s3,
          onRefresh: () => _run(captures.sync),
          centerLast: items == null || _sections(items).isEmpty,
          children: items == null
              ? [AsyncStatus(error: captures.error, onRetry: captures.load)]
              : _list(items),
        );
      },
    );
  }

  Iterable<(CaptureSection, List<Capture>)> _sections(List<Capture> items) => [
    for (final section in _tab.sections)
      (
        section,
        [
          for (final c in items)
            if (c.section == section) c,
        ],
      ),
  ].where((s) => s.$2.isNotEmpty);

  List<Widget> _list(List<Capture> items) {
    if (items.isEmpty) {
      return const [
        StateMessage(
          icon: AppIcons.inbox,
          title: 'Inbox zerado',
          message: 'Use o + para capturar um termo novo.',
        ),
      ];
    }
    final captures = AppScope.of(context).captures;
    final now = DateTime.now();
    final sections = _sections(items);

    return [
      SegmentedControl(
        options: [for (final tab in InboxTab.values) tab.label],
        selected: _tab.index,
        onChanged: (i) => setState(() => _tab = InboxTab.values[i]),
      ),
      if (sections.isEmpty)
        const StateMessage(
          icon: AppIcons.inbox,
          title: 'Nada por aqui',
          message: 'Nenhuma captura nessa aba.',
        ),
      for (final (section, group) in sections) ...[
        _SectionLabel('${section.label} · ${group.length}'),
        for (final capture in group)
          CaptureCard(
            key: ValueKey(capture.id),
            capture: capture,
            now: now,
            onDiscard: () => captures.discard(capture),
            onProcess: () => _run(() => captures.processNow(capture)),
            onPick: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => PickTermsPage(capture: capture),
              ),
            ),
            onConfirm: () => captures.confirm(capture),
          ),
      ],
    ];
  }
}

String summary(List<Capture> items) {
  final count = items.length == 1 ? '1 captura' : '${items.length} capturas';
  final waiting = items.where((c) => c.pending.isNotEmpty).length;
  return waiting == 0 ? count : '$count · $waiting esperando envio';
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.s1),
      child: Text(
        text.toUpperCase(),
        style: AppText.overline.copyWith(color: context.colors.inkSoft),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import 'package:tagarela/app/app_scope.dart';
import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/features/inbox/pick_terms_page.dart';
import 'package:tagarela/features/inbox/widgets/capture_card.dart';
import 'package:tagarela/l10n/l10n.dart';

enum InboxTab {
  all(CaptureSection.values),
  ready([CaptureSection.ready]),
  pending([CaptureSection.attention, CaptureSection.processing]);

  const InboxTab(this.sections);

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
    try {
      await action();
    } on Exception {
      if (mounted) AppToast.notice(context, context.l10n.noConnectionRetry);
    }
  }

  @override
  Widget build(BuildContext context) {
    final captures = AppScope.of(context).captures;

    return ListenableBuilder(
      listenable: captures,
      builder: (context, _) {
        final items = captures.data?.where((c) => c.section != null).toList();
        return AppPage(
          header: PageHeader(
            title: context.l10n.tabInbox,
            subtitle: items == null ? null : summary(context.l10n, items),
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
      return [
        StateMessage(
          icon: AppIcons.inbox,
          title: context.l10n.inboxEmptyTitle,
          message: context.l10n.inboxEmptyMessage,
        ),
      ];
    }
    final captures = AppScope.of(context).captures;
    final now = DateTime.now();
    final sections = _sections(items);

    return [
      SegmentedControl(
        options: [
          for (final tab in InboxTab.values) context.l10n.inboxTab(tab.name),
        ],
        selected: _tab.index,
        onChanged: (i) => setState(() => _tab = InboxTab.values[i]),
      ),
      if (sections.isEmpty)
        StateMessage(
          icon: AppIcons.inbox,
          title: context.l10n.nothingHere,
          message: context.l10n.noCapturesInTab,
        ),
      for (final (section, group) in sections) ...[
        SectionLabel(
          label:
              '${context.l10n.captureSection(section.name)} · ${group.length}',
        ),
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

String summary(AppLocalizations l10n, List<Capture> items) {
  final count = l10n.captureCount(items.length);
  final waiting = items.where((c) => c.pending.isNotEmpty).length;
  return waiting == 0 ? count : '$count · ${l10n.waitingUpload(waiting)}';
}

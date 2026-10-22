import 'package:flutter/material.dart';

import 'package:tagarela/app/app_scope.dart';
import 'package:tagarela/data/models.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/features/inbox/widgets/inbox_item_card.dart';

/// Termos capturados aguardando análise ou revisão.
class InboxPage extends StatelessWidget {
  const InboxPage({super.key});

  Future<void> _resolve(
    BuildContext context,
    InboxItem item, {
    required bool added,
  }) async {
    final inbox = AppScope.of(context).inbox;
    final messenger = ScaffoldMessenger.of(context);
    try {
      added ? await inbox.accept(item) : await inbox.discard(item);
    } on Exception {
      messenger.showSnackBar(
        const SnackBar(content: Text('Não deu pra salvar. Tente de novo.')),
      );
      return;
    }
    if (added) {
      messenger.showSnackBar(
        SnackBar(content: Text('Adicionado em ${item.suggestion!.groupName}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final inbox = AppScope.of(context).inbox;

    return ListenableBuilder(
      listenable: inbox,
      builder: (context, _) {
        final items = inbox.data;
        return SheetPage(
          header: PageHeader(
            title: 'Inbox',
            subtitle: items == null
                ? null
                : '${items.length} termos aguardando análise',
          ),
          gap: AppSpacing.s3,
          children: items == null
              ? [AsyncStatus(error: inbox.error, onRetry: inbox.load)]
              : _list(context, items),
        );
      },
    );
  }

  List<Widget> _list(BuildContext context, List<InboxItem> items) {
    final ready = items.where((i) => i.status == InboxStatus.ready).toList();
    final pending = items.where((i) => i.status != InboxStatus.ready).toList();
    return [
      if (items.isEmpty)
        const StateMessage(
          icon: AppIcons.inbox,
          title: 'Inbox zerado',
          message: 'Use o + para capturar um termo novo.',
        ),
      if (ready.isNotEmpty)
        _SectionLabel('Prontos para revisar · ${ready.length}'),
      for (final item in ready)
        InboxItemCard(
          item: item,
          onAdd: () => _resolve(context, item, added: true),
          onDiscard: () => _resolve(context, item, added: false),
        ),
      if (pending.isNotEmpty) _SectionLabel('Em análise · ${pending.length}'),
      for (final item in pending) InboxItemCard(item: item),
    ];
  }
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

import 'package:flutter/material.dart';

import 'package:tagarela/app/app_scope.dart';
import 'package:tagarela/data/models.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/features/vocabulary/count_label.dart';
import 'package:tagarela/features/vocabulary/widgets/move_sheet.dart';
import 'package:tagarela/features/vocabulary/widgets/group_sheet.dart';
import 'package:tagarela/features/vocabulary/widgets/term_tile.dart';

class GroupPage extends StatefulWidget {
  const GroupPage({super.key, required String this.groupId});

  const GroupPage.ungrouped({super.key}) : groupId = null;

  final String? groupId;

  @override
  State<GroupPage> createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  static const _filters = [null, TermStatus.learning, TermStatus.mastered];

  int _filter = 0;
  Set<String>? _selected;
  TermGroup? _group;
  bool _moving = false;
  bool _deleting = false;

  void _select(Set<String>? selected) => setState(() => _selected = selected);

  void _toggle(String id) => _select(
    _selected!.contains(id)
        ? ({..._selected!}..remove(id))
        : {..._selected!, id},
  );

  Future<void> _openMenu(TermGroup group) async {
    final action = await AppSheet.show<_MenuAction>(
      context,
      (_) => _GroupMenu(group: group),
    );
    if (!mounted) return;
    switch (action) {
      case _MenuAction.edit:
        await AppSheet.show<TermGroup>(
          context,
          (_) => GroupSheet(group: group),
        );
      case _MenuAction.select:
        _select({});
      case _MenuAction.delete:
        final deleted = await AppSheet.show<bool>(
          context,
          (_) => _DeleteGroupSheet(group: group),
        );
        if (deleted == true && mounted) Navigator.of(context).pop(group);
      case null:
    }
  }

  List<String> _selectedIn(List<Term> terms) => [
    for (final t in terms)
      if (_selected!.contains(t.id)) t.id,
  ];

  Future<void> _pickTarget(
    Vocabulary data,
    TermGroup? from,
    List<Term> terms,
  ) async {
    final ids = _selectedIn(terms);
    final target = await AppSheet.show<MoveTarget>(
      context,
      (_) => MoveSheet(
        groups: [
          for (final g in data.groups)
            if (g.id != from?.id) g,
        ],
        count: ids.length,
        from: from?.name ?? 'Sem grupo',
      ),
    );
    if (target == null || !mounted) return;
    final to =
        target.group ??
        await AppSheet.show<TermGroup>(context, (_) => const GroupSheet());
    if (to == null || !mounted) return;
    await _move(ids, from: from, to: to);
  }

  Future<void> _move(
    List<String> ids, {
    required TermGroup? from,
    required TermGroup to,
  }) async {
    final vocabulary = AppScope.of(context).vocabulary;
    setState(() => _moving = true);
    try {
      await vocabulary.move(ids, to.id);
    } on Exception {
      if (!mounted) return;
      setState(() => _moving = false);
      _warn('Não deu pra mover agora. Confira a internet e tente de novo.');
      return;
    }
    if (!mounted) return;
    setState(() {
      _moving = false;
      _selected = null;
    });
    final one = ids.length == 1;
    AppToast.show(
      context,
      title: one ? '1 termo movido' : '${ids.length} termos movidos',
      message: 'Agora ${one ? 'está' : 'estão'} em ${to.name}.',
      actionLabel: 'Desfazer',
      onAction: () async {
        try {
          await vocabulary.move(ids, from?.id);
        } on Exception {
          if (mounted) _warn('Não deu pra desfazer agora.');
        }
      },
    );
  }

  Future<void> _delete(List<Term> terms) async {
    final ids = _selectedIn(terms);
    final vocabulary = AppScope.of(context).vocabulary;
    setState(() => _deleting = true);
    try {
      await vocabulary.deleteTerms(ids);
    } on Exception {
      if (!mounted) return;
      setState(() => _deleting = false);
      _warn('Não deu pra apagar agora. Confira a internet e tente de novo.');
      return;
    }
    if (!mounted) return;
    setState(() {
      _deleting = false;
      _selected = null;
    });
    final one = ids.length == 1;
    AppToast.show(
      context,
      title: one ? '1 termo apagado' : '${ids.length} termos apagados',
      message: one ? 'Saiu do vocabulário.' : 'Saíram do vocabulário.',
      actionLabel: 'Desfazer',
      onAction: () async {
        try {
          await vocabulary.restoreTerms(ids);
        } on Exception {
          if (mounted) _warn('Não deu pra desfazer agora.');
        }
      },
    );
  }

  void _warn(String message) => ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));

  @override
  Widget build(BuildContext context) {
    final vocabulary = AppScope.of(context).vocabulary;

    return ListenableBuilder(
      listenable: vocabulary,
      builder: (context, _) {
        final data = vocabulary.data ?? const Vocabulary();
        final id = widget.groupId;
        if (id != null) _group = data.group(id) ?? _group;
        final group = _group;
        final terms = id == null ? data.ungrouped : group?.terms ?? const [];
        final filtered = group != null && terms.isNotEmpty;
        final visible = filtered ? group.termsWith(_filters[_filter]) : terms;
        final selected = _selected;

        return PopScope(
          canPop: selected == null,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) return _select(null);
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
          child: SheetPage(
            header: _GroupHeader(
              icon: group?.icon ?? AppIcons.ungrouped,
              name: group?.name ?? 'Sem grupo',
              meta: _meta(group, terms, selected),
              bar: filtered ? group : null,
              leading: selected == null
                  ? AppIconButton(
                      icon: AppIcons.back,
                      tooltip: 'Voltar',
                      onPressed: () => Navigator.of(context).pop(),
                      variant: AppIconButtonVariant.onHeader,
                    )
                  : AppIconButton(
                      icon: AppIcons.close,
                      tooltip: 'Cancelar seleção',
                      onPressed: () => _select(null),
                      variant: AppIconButtonVariant.onHeader,
                    ),
              trailing: switch ((selected, group)) {
                (null, final group?) => AppIconButton(
                  icon: AppIcons.more,
                  tooltip: 'Mais opções',
                  onPressed: () => _openMenu(group),
                  variant: AppIconButtonVariant.onHeader,
                ),
                _ when terms.isEmpty => null,
                (null, null) => AppButton(
                  label: 'Selecionar',
                  variant: AppButtonVariant.onHeader,
                  size: AppButtonSize.small,
                  onPressed: () => _select({}),
                ),
                _ => AppButton(
                  label: 'Selecionar todos',
                  variant: AppButtonVariant.onHeader,
                  size: AppButtonSize.small,
                  onPressed: () =>
                      _select({...?selected, for (final t in visible) t.id}),
                ),
              },
            ),
            gap: AppSpacing.s3,
            centerLast: terms.isEmpty,
            footer: selected == null
                ? null
                : Row(
                    spacing: AppSpacing.s3,
                    children: [
                      AppButton(
                        label: 'Apagar',
                        leading: const Icon(AppIcons.delete, size: 20),
                        variant: AppButtonVariant.outline,
                        size: AppButtonSize.large,
                        loading: _deleting,
                        onPressed: selected.isEmpty || _moving
                            ? null
                            : () => _delete(terms),
                      ),
                      Expanded(
                        child: AppButton(
                          label: switch (selected.length) {
                            0 => 'Selecione os termos',
                            1 => 'Mover 1 termo',
                            final n => 'Mover $n termos',
                          },
                          size: AppButtonSize.large,
                          expand: true,
                          loading: _moving,
                          onPressed: selected.isEmpty || _deleting
                              ? null
                              : () => _pickTarget(data, group, terms),
                        ),
                      ),
                    ],
                  ),
            children: [
              if (terms.isEmpty)
                id == null
                    ? const StateMessage(
                        icon: AppIcons.ungrouped,
                        title: 'Tudo organizado',
                        message:
                            'Os termos que você confirmar nas capturas chegam '
                            'aqui.',
                      )
                    : StateMessage(
                        icon: group?.icon ?? AppIcons.vocabulary,
                        accent: group?.accent ?? AppAccent.violet,
                        title: 'Nenhum termo aqui ainda',
                        message:
                            'Termos novos chegam em Sem grupo. De lá, mova '
                            'os que forem daqui.',
                      )
              else ...[
                if (id == null)
                  Text(
                    'Os termos que você confirma nas capturas chegam aqui. '
                    'Mova cada um pro grupo dele.',
                    style: AppText.bodyMd.copyWith(
                      color: context.colors.inkSoft,
                    ),
                  ),
                if (filtered)
                  SegmentedControl(
                    options: [
                      for (final status in _filters)
                        status?.label ?? 'Todos · ${terms.length}',
                    ],
                    selected: _filter,
                    onChanged: (i) => setState(() => _filter = i),
                  ),
                for (final term in visible)
                  TermTile(
                    term: term,
                    selecting: selected != null,
                    selected: selected?.contains(term.id) ?? false,
                    onTap: selected == null ? null : () => _toggle(term.id),
                    onLongPress: selected == null
                        ? () => _select({term.id})
                        : null,
                  ),
              ],
            ],
          ),
        );
      },
    );
  }

  static String _meta(
    TermGroup? group,
    List<Term> terms,
    Set<String>? selected,
  ) => switch (selected?.length) {
    0 => 'Toque nos termos pra escolher',
    1 => '1 selecionado',
    final int n => '$n selecionados',
    null when group == null =>
      terms.isEmpty
          ? 'Nenhum termo pra organizar'
          : '${termsLabel(terms.length)} pra pôr num grupo',
    null when terms.isEmpty => 'Nenhum termo ainda',
    null => '${termsLabel(terms.length)} · ${group.masteredCount} dominados',
  };
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({
    required this.icon,
    required this.name,
    required this.meta,
    required this.bar,
    required this.leading,
    required this.trailing,
  });

  final IconData icon;
  final String name;
  final String meta;
  final TermGroup? bar;
  final Widget leading;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Column(
      spacing: 14,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [leading, ?trailing],
        ),
        PageHeader(
          title: name,
          subtitle: meta,
          leading: AppBubble(
            size: 52,
            color: AppPalette.white,
            foreground: c.header,
            child: Icon(icon),
          ),
        ),
        if (bar case final group?)
          SegmentBar(
            gap: 3,
            semanticLabel:
                '${group.terms.length - group.masteredCount} aprendendo, '
                '${group.masteredCount} dominados',
            segments: [
              Segment(
                group.terms.length - group.masteredCount,
                AppPalette.mango,
              ),
              Segment(group.masteredCount, AppPalette.mint),
            ],
          ),
      ],
    );
  }
}

enum _MenuAction { edit, select, delete }

class _GroupMenu extends StatelessWidget {
  const _GroupMenu({required this.group});

  final TermGroup group;

  @override
  Widget build(BuildContext context) {
    return AppSheet(
      icon: group.icon,
      accent: group.accent,
      title: group.name,
      subtitle: termsLabel(group.terms.length),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.s3,
        children: [
          OptionRow(
            icon: AppIcons.edit,
            accent: AppAccent.violet,
            title: 'Editar grupo',
            subtitle: 'Nome, ícone e cor',
            onTap: () => Navigator.pop(context, _MenuAction.edit),
          ),
          if (group.terms.isNotEmpty)
            OptionRow(
              icon: AppIcons.move,
              accent: AppAccent.violet,
              title: 'Selecionar termos',
              subtitle: 'Mova ou apague termos',
              onTap: () => Navigator.pop(context, _MenuAction.select),
            ),
          OptionRow(
            icon: AppIcons.delete,
            accent: AppAccent.coral,
            title: 'Apagar grupo',
            subtitle: 'Os termos voltam pra Sem grupo',
            onTap: () => Navigator.pop(context, _MenuAction.delete),
          ),
        ],
      ),
    );
  }
}

class _DeleteGroupSheet extends StatefulWidget {
  const _DeleteGroupSheet({required this.group});

  final TermGroup group;

  @override
  State<_DeleteGroupSheet> createState() => _DeleteGroupSheetState();
}

class _DeleteGroupSheetState extends State<_DeleteGroupSheet> {
  var _busy = false;
  String? _error;

  Future<void> _delete() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await AppScope.of(context).vocabulary.deleteGroup(widget.group.id);
      if (mounted) Navigator.pop(context, true);
    } on Exception {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error =
            'Não deu pra apagar agora. Confira a internet e tente de novo.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final group = widget.group;

    return AppSheet(
      icon: AppIcons.delete,
      accent: AppAccent.coral,
      title: 'Apagar ${group.name}?',
      subtitle: switch (group.terms.length) {
        0 => 'O grupo está vazio.',
        1 => 'O termo volta pra Sem grupo.',
        final n => 'Os $n termos voltam pra Sem grupo.',
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.s3,
        children: [
          if (_error case final error?)
            Text(
              error,
              style: AppText.bodyMd.copyWith(color: context.colors.alert),
            ),
          AppButton(
            label: 'Apagar grupo',
            variant: AppButtonVariant.danger,
            expand: true,
            loading: _busy,
            onPressed: _delete,
          ),
          AppButton(
            label: 'Cancelar',
            variant: AppButtonVariant.text,
            expand: true,
            onPressed: _busy ? null : () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}

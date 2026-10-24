import 'package:flutter/material.dart';

import 'package:tagarela/app/app_scope.dart';
import 'package:tagarela/data/models.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/features/vocabulary/count_label.dart';
import 'package:tagarela/features/vocabulary/widgets/move_sheet.dart';
import 'package:tagarela/features/vocabulary/widgets/new_group_sheet.dart';
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
  bool _moving = false;

  void _select(Set<String>? selected) => setState(() => _selected = selected);

  void _toggle(String id) => _select(
    _selected!.contains(id)
        ? ({..._selected!}..remove(id))
        : {..._selected!, id},
  );

  Future<void> _openMenu(TermGroup group) async {
    final move = await AppSheet.show<bool>(
      context,
      (_) => _GroupMenu(group: group),
    );
    if (move == true && mounted) _select({});
  }

  Future<void> _pickTarget(
    Vocabulary data,
    TermGroup? from,
    List<Term> terms,
  ) async {
    final ids = [
      for (final t in terms)
        if (_selected!.contains(t.id)) t.id,
    ];
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
        await AppSheet.show<TermGroup>(context, (_) => const NewGroupSheet());
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
        final group = id == null ? null : data.group(id);
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
                _ when terms.isEmpty => null,
                (null, final group?) => AppIconButton(
                  icon: AppIcons.more,
                  tooltip: 'Mais opções',
                  onPressed: () => _openMenu(group),
                  variant: AppIconButtonVariant.onHeader,
                ),
                (null, null) => AppButton(
                  label: 'Mover termos',
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
                : AppButton(
                    label: switch (selected.length) {
                      0 => 'Selecione os termos',
                      1 => 'Mover 1 termo',
                      final n => 'Mover $n termos',
                    },
                    size: AppButtonSize.large,
                    expand: true,
                    loading: _moving,
                    onPressed: selected.isEmpty
                        ? null
                        : () => _pickTarget(data, group, terms),
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
      child: OptionRow(
        icon: AppIcons.move,
        accent: AppAccent.violet,
        title: 'Mover termos',
        subtitle: 'Escolha termos e mande pra outro grupo',
        onTap: () => Navigator.pop(context, true),
      ),
    );
  }
}

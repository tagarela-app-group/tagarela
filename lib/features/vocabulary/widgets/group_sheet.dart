import 'package:flutter/material.dart';

import 'package:tagarela/app/app_scope.dart';
import 'package:tagarela/data/api_client.dart';
import 'package:tagarela/data/models.dart';
import 'package:tagarela/design_system/design_system.dart';

class GroupSheet extends StatefulWidget {
  const GroupSheet({this.group, super.key});

  final TermGroup? group;

  static const maxName = 30;

  @override
  State<GroupSheet> createState() => _GroupSheetState();
}

class _GroupSheetState extends State<GroupSheet> {
  static final _icons = [
    for (final i in GroupIcon.values) (icon: i.icon, label: i.label),
  ];

  late final _name = TextEditingController(text: widget.group?.name);
  late var _icon = GroupIcon.values.firstWhere(
    (i) => i.icon == widget.group?.icon,
    orElse: () => GroupIcon.layers,
  );
  late var _accent = widget.group?.accent ?? AppAccent.violet;
  var _busy = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save(String name) async {
    setState(() => _busy = true);
    final vocabulary = AppScope.of(context).vocabulary;
    final editing = widget.group;
    final verb = editing == null ? 'criar' : 'salvar';
    try {
      final group = editing == null
          ? await vocabulary.createGroup(
              name: name,
              icon: _icon,
              accent: _accent,
            )
          : await vocabulary.updateGroup(
              editing.id,
              name: name,
              icon: _icon,
              accent: _accent,
            );
      if (mounted) Navigator.pop(context, group);
    } on ApiException catch (e) {
      _fail(
        e.rejected
            ? e.fieldError('name') ?? 'Não deu pra $verb o grupo.'
            : 'Não deu pra $verb o grupo agora. Tente de novo.',
      );
    } on Exception {
      _fail('Sem conexão. Tente de novo.');
    }
  }

  void _fail(String message) {
    if (!mounted) return;
    setState(() {
      _busy = false;
      _error = message;
    });
  }

  @override
  Widget build(BuildContext context) {
    final vocabulary = AppScope.of(context).vocabulary.data;
    final name = _name.text.trim();
    final editing = widget.group;
    final taken = vocabulary?.hasGroupNamed(name, except: editing?.id) ?? false;

    return AppSheet(
      icon: _icon.icon,
      accent: _accent,
      title: editing == null ? 'Novo grupo' : 'Editar grupo',
      subtitle: editing == null
          ? 'Junte termos do mesmo assunto'
          : 'Mude o nome, o ícone ou a cor',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.s4,
        children: [
          AppTextField(
            label: 'Nome',
            hint: 'Ex.: Música, Faculdade',
            controller: _name,
            maxLength: GroupSheet.maxName,
            autofocus: editing == null,
            textInputAction: TextInputAction.done,
            errorText: taken ? 'Você já tem um grupo com esse nome.' : _error,
            onChanged: (_) => setState(() => _error = null),
          ),
          IconPicker(
            icons: _icons,
            selected: _icon.index,
            accent: _accent,
            onChanged: (i) => setState(() => _icon = GroupIcon.values[i]),
          ),
          AccentPicker(
            selected: _accent,
            onChanged: (accent) => setState(() => _accent = accent),
          ),
          AppButton(
            label: switch ((name.isEmpty, editing)) {
              (true, _) => 'Dê um nome ao grupo',
              (false, null) => 'Criar grupo',
              _ => 'Salvar',
            },
            expand: true,
            loading: _busy,
            onPressed: name.isEmpty || taken ? null : () => _save(name),
          ),
        ],
      ),
    );
  }
}

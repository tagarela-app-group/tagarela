import 'package:flutter/material.dart';

import 'package:tagarela/app/app_scope.dart';
import 'package:tagarela/data/api_client.dart';
import 'package:tagarela/data/models.dart';
import 'package:tagarela/design_system/design_system.dart';

class NewGroupSheet extends StatefulWidget {
  const NewGroupSheet({super.key});

  static const maxName = 30;

  @override
  State<NewGroupSheet> createState() => _NewGroupSheetState();
}

class _NewGroupSheetState extends State<NewGroupSheet> {
  static final _icons = [
    for (final i in GroupIcon.values) (icon: i.icon, label: i.label),
  ];

  final _name = TextEditingController();
  var _icon = GroupIcon.layers;
  var _accent = AppAccent.violet;
  var _busy = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _create(String name) async {
    setState(() => _busy = true);
    try {
      final group = await AppScope.of(
        context,
      ).vocabulary.createGroup(name: name, icon: _icon, accent: _accent);
      if (mounted) Navigator.pop(context, group);
    } on ApiException catch (e) {
      _fail(
        e.rejected
            ? e.fieldError('name') ?? 'Não deu pra criar o grupo.'
            : 'Não deu pra criar o grupo agora. Tente de novo.',
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
    final taken = vocabulary?.hasGroupNamed(name) ?? false;

    return AppSheet(
      icon: _icon.icon,
      accent: _accent,
      title: 'Novo grupo',
      subtitle: 'Junte termos do mesmo assunto',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.s4,
        children: [
          AppTextField(
            label: 'Nome',
            hint: 'Ex.: Música, Faculdade',
            controller: _name,
            maxLength: NewGroupSheet.maxName,
            autofocus: true,
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
            label: name.isEmpty ? 'Dê um nome ao grupo' : 'Criar grupo',
            expand: true,
            loading: _busy,
            onPressed: name.isEmpty || taken ? null : () => _create(name),
          ),
        ],
      ),
    );
  }
}

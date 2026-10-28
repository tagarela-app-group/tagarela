import 'package:flutter/material.dart';

import 'package:tagarela/app/app_scope.dart';
import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/l10n/l10n.dart';
import 'package:tagarela/shared/logic/group_style.dart';

class GroupModal extends StatefulWidget {
  const GroupModal({this.group, super.key});

  final TermGroup? group;

  static const maxName = 30;

  @override
  State<GroupModal> createState() => _GroupModalState();
}

class _GroupModalState extends State<GroupModal> {
  late final _name = TextEditingController(text: widget.group?.name);
  late var _icon = widget.group?.icon ?? GroupIcon.layers;
  late var _color = widget.group?.color ?? GroupColor.violet;
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
    final l10n = context.l10n;
    final editing = widget.group;
    final action = editing == null ? 'create' : 'save';
    try {
      final group = editing == null
          ? await vocabulary.createGroup(name: name, icon: _icon, color: _color)
          : await vocabulary.updateGroup(
              editing.id,
              name: name,
              icon: _icon,
              color: _color,
            );
      if (mounted) Navigator.pop(context, group);
    } on RejectedException catch (e) {
      _fail(e.fields['name'] ?? l10n.groupSaveRejected(action));
    } on ServerException {
      _fail(l10n.groupSaveFailed(action));
    } on Exception {
      _fail(l10n.offlineRetry);
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

    return AppModal(
      icon: _icon.glyph,
      accent: _color.accent,
      title: editing == null ? context.l10n.newGroup : context.l10n.editGroup,
      subtitle: editing == null
          ? context.l10n.groupModalNewHint
          : context.l10n.groupModalEditHint,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.s4,
        children: [
          AppTextField(
            label: context.l10n.name,
            hint: context.l10n.groupNameHint,
            controller: _name,
            maxLength: GroupModal.maxName,
            autofocus: editing == null,
            textInputAction: TextInputAction.done,
            errorText: taken ? context.l10n.groupNameTaken : _error,
            onChanged: (_) => setState(() => _error = null),
          ),
          IconPicker(
            icons: [
              for (final i in GroupIcon.values)
                (icon: i.glyph, label: context.l10n.groupIcon(i.name)),
            ],
            selected: _icon.index,
            accent: _color.accent,
            onChanged: (i) => setState(() => _icon = GroupIcon.values[i]),
          ),
          AccentPicker(
            selected: _color.accent,
            onChanged: (accent) =>
                setState(() => _color = GroupColorAccent.of(accent)),
          ),
          AppButton(
            label: switch ((name.isEmpty, editing)) {
              (true, _) => context.l10n.nameTheGroup,
              (false, null) => context.l10n.createGroup,
              _ => context.l10n.save,
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

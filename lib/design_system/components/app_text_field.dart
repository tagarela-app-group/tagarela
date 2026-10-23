import 'package:flutter/material.dart';

import 'package:tagarela/design_system/components/app_icon_button.dart';
import 'package:tagarela/design_system/theme.dart';
import 'package:tagarela/design_system/tokens/app_icons.dart';
import 'package:tagarela/design_system/tokens/app_tokens.dart';
import 'package:tagarela/design_system/tokens/app_typography.dart';

class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    this.label,
    this.hint,
    this.icon,
    this.errorText,
    this.obscure = false,
    this.controller,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
  });

  final String? label;
  final String? hint;
  final IconData? icon;
  final String? errorText;
  final bool obscure;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  final _focus = FocusNode();
  late bool _hidden = widget.obscure;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final hasError = widget.errorText != null;
    final focused = _focus.hasFocus;
    final borderColor = hasError
        ? c.alert
        : focused
        ? c.primary
        : c.line;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 6,
      children: [
        if (widget.label != null)
          ExcludeSemantics(child: Text(widget.label!, style: AppText.label)),
        AnimatedContainer(
          duration: AppMotion.fast,
          height: 52,
          padding: EdgeInsets.only(
            left: AppSpacing.s4,
            right: widget.obscure ? AppSpacing.s1 : AppSpacing.s4,
          ),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
              color: borderColor,
              width: focused || hasError ? 2 : 1.5,
            ),
            boxShadow: [
              if (focused && !hasError)
                BoxShadow(color: c.primaryRing, spreadRadius: 4),
            ],
          ),
          child: Row(
            spacing: 10,
            children: [
              if (widget.icon != null)
                Icon(
                  widget.icon,
                  size: 20,
                  color: focused ? c.primaryText : c.inkSoft,
                ),
              Expanded(
                child: Semantics(
                  label: widget.label,
                  child: TextField(
                    controller: widget.controller,
                    focusNode: _focus,
                    obscureText: _hidden,
                    keyboardType: widget.keyboardType,
                    textInputAction: widget.textInputAction,
                    onChanged: widget.onChanged,
                    style: AppText.bodyLg.copyWith(color: c.ink),
                    decoration: InputDecoration.collapsed(
                      hintText: widget.hint,
                      hintStyle: AppText.bodyLg.copyWith(color: c.inkSoft),
                    ),
                  ),
                ),
              ),
              if (widget.obscure)
                AppIconButton(
                  icon: _hidden ? AppIcons.showPassword : AppIcons.hidePassword,
                  tooltip: _hidden ? 'Mostrar senha' : 'Ocultar senha',
                  size: 40,
                  onPressed: () => setState(() => _hidden = !_hidden),
                ),
            ],
          ),
        ),
        if (hasError)
          Text(
            widget.errorText!,
            style: AppText.label.copyWith(
              color: c.alert,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }
}

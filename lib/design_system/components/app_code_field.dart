import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:tagarela/design_system/theme.dart';
import 'package:tagarela/design_system/tokens/app_tokens.dart';
import 'package:tagarela/design_system/tokens/app_typography.dart';
import 'package:tagarela/l10n/l10n.dart';

class AppCodeField extends StatefulWidget {
  const AppCodeField({
    super.key,
    required this.controller,
    this.length = 6,
    this.errorText,
    this.onCompleted,
    this.autofocus = true,
  });

  final TextEditingController controller;
  final int length;
  final String? errorText;
  final ValueChanged<String>? onCompleted;
  final bool autofocus;

  @override
  State<AppCodeField> createState() => _AppCodeFieldState();
}

class _AppCodeFieldState extends State<AppCodeField> {
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(_refresh);
    widget.controller.addListener(_refresh);
  }

  @override
  void didUpdateWidget(AppCodeField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller == widget.controller) return;
    oldWidget.controller.removeListener(_refresh);
    widget.controller.addListener(_refresh);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_refresh);
    _focus.dispose();
    super.dispose();
  }

  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final code = widget.controller.text;
    final hasError = widget.errorText != null;
    final active = _focus.hasFocus && code.length < widget.length
        ? code.length
        : -1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 6,
      children: [
        Stack(
          children: [
            Row(
              spacing: AppSpacing.s2,
              children: [
                for (var i = 0; i < widget.length; i++)
                  Expanded(
                    child: _CodeBox(
                      digit: i < code.length ? code[i] : '',
                      active: i == active,
                      error: hasError,
                    ),
                  ),
              ],
            ),
            Positioned.fill(
              child: Opacity(
                opacity: 0,
                alwaysIncludeSemantics: true,
                child: Semantics(
                  label: context.l10n.codeFieldLabel(widget.length),
                  child: TextField(
                    controller: widget.controller,
                    focusNode: _focus,
                    autofocus: widget.autofocus,
                    keyboardType: TextInputType.number,
                    autofillHints: const [AutofillHints.oneTimeCode],
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(widget.length),
                    ],
                    showCursor: false,
                    enableInteractiveSelection: false,
                    maxLines: null,
                    expands: true,
                    decoration: const InputDecoration.collapsed(hintText: null),
                    onChanged: (value) {
                      if (value.length == widget.length) {
                        widget.onCompleted?.call(value);
                      }
                    },
                  ),
                ),
              ),
            ),
          ],
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

class _CodeBox extends StatelessWidget {
  const _CodeBox({
    required this.digit,
    required this.active,
    required this.error,
  });

  final String digit;
  final bool active;
  final bool error;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final borderColor = error
        ? c.alert
        : active
        ? c.primary
        : c.line;

    return AnimatedContainer(
      duration: AppMotion.fast,
      height: AppSpacing.s14,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: borderColor,
          width: active || error ? 2 : 1.5,
        ),
        boxShadow: [
          if (active && !error)
            BoxShadow(color: c.primaryRing, spreadRadius: 4),
        ],
      ),
      child: active
          ? Container(width: 2, height: AppSpacing.s6, color: c.primary)
          : Text(digit, style: AppText.titleLg.copyWith(color: c.ink)),
    );
  }
}

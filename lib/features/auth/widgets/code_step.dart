import 'dart:async';

import 'package:flutter/material.dart';

import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/features/auth/auth_form.dart';
import 'package:tagarela/l10n/l10n.dart';

class CodeStep extends StatefulWidget {
  const CodeStep({
    super.key,
    required this.email,
    required this.controller,
    required this.onConfirm,
    required this.onResend,
    required this.onChangeEmail,
    this.errorText,
    this.loading,
  });

  static const length = 6;
  static const resendAfter = Duration(seconds: 60);

  final String email;
  final TextEditingController controller;
  final VoidCallback onConfirm;
  final Future<void> Function() onResend;
  final VoidCallback onChangeEmail;
  final String? errorText;
  final AuthAction? loading;

  bool get busy => loading != null;

  @override
  State<CodeStep> createState() => _CodeStepState();
}

class _CodeStepState extends State<CodeStep> {
  Timer? _timer;
  int _seconds = 0;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_refresh);
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.controller.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() => setState(() {});

  void _startCountdown() {
    _seconds = CodeStep.resendAfter.inSeconds;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _seconds--);
      if (_seconds == 0) timer.cancel();
    });
  }

  Future<void> _resend() async {
    await widget.onResend();
    if (mounted) setState(_startCountdown);
  }

  void _confirm() {
    if (widget.busy) return;
    widget.onConfirm();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final complete = widget.controller.text.length == CodeStep.length;
    final soft = AppText.bodyMd.copyWith(color: c.inkSoft);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: AppSpacing.s4,
      children: [
        Text.rich(
          TextSpan(
            text: '${context.l10n.codeSent(CodeStep.length)} ',
            children: [
              TextSpan(
                text: widget.email,
                style: TextStyle(fontWeight: FontWeight.w700, color: c.ink),
              ),
              const TextSpan(text: '.'),
            ],
          ),
          style: AppText.bodyLg.copyWith(color: c.inkSoft),
        ),
        AppCodeField(
          controller: widget.controller,
          length: CodeStep.length,
          errorText: widget.errorText,
          onCompleted: (_) => _confirm(),
        ),
        AppButton(
          label: context.l10n.confirm,
          onPressed: complete && !widget.busy ? _confirm : null,
          size: AppButtonSize.large,
          expand: true,
          loading: widget.loading == AuthAction.submit,
        ),
        Column(
          spacing: AppSpacing.s1,
          children: [
            if (_seconds > 0)
              Text(
                context.l10n.resendIn(
                  '${_seconds ~/ 60}:${'${_seconds % 60}'.padLeft(2, '0')}',
                ),
                style: soft,
              )
            else
              AppButton(
                label: context.l10n.resendCode,
                onPressed: widget.busy ? null : _resend,
                variant: AppButtonVariant.text,
                size: AppButtonSize.small,
                loading: widget.loading == AuthAction.resend,
              ),
            Text(context.l10n.checkSpam, style: soft),
          ],
        ),
        Center(
          child: AppButton(
            label: context.l10n.changeEmail,
            onPressed: widget.onChangeEmail,
            variant: AppButtonVariant.text,
            size: AppButtonSize.small,
          ),
        ),
      ],
    );
  }
}

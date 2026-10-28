import 'package:flutter/material.dart';

import 'package:tagarela/app/app_scope.dart';
import 'package:tagarela/app/course_gate.dart';
import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/data/stores/auth_store.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/features/auth/login_page.dart';
import 'package:tagarela/features/capture/modals/audio_capture_modal.dart';
import 'package:tagarela/features/capture/modals/photo_capture_modal.dart';
import 'package:tagarela/features/capture/modals/text_capture_modal.dart';
import 'package:tagarela/features/capture/widgets/capture_saved_toast.dart';
import 'package:tagarela/features/home/home_page.dart';
import 'package:tagarela/features/inbox/inbox_page.dart';
import 'package:tagarela/features/profile/profile_page.dart';
import 'package:tagarela/features/vocabulary/vocabulary_page.dart';
import 'package:tagarela/l10n/l10n.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  static void open(BuildContext context) {
    AppScope.of(context).session.loadAll();
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const CourseGate()),
      (_) => false,
    );
  }

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  static const _vocabularyTab = 1;
  static const _inboxTab = 2;

  final _menu = GlobalKey<ArcMenuState>();
  int _tab = 0;
  AuthStore? _auth;

  void _goTo(int tab) => setState(() => _tab = tab);

  Future<void> _capture(CaptureSource source) async {
    final saved = await AppModal.show<Capture>(
      context,
      (_) => switch (source) {
        CaptureSource.text => const TextCaptureModal(),
        CaptureSource.photo => const PhotoCaptureModal(),
        CaptureSource.audio => const AudioCaptureModal(),
      },
    );
    if (saved == null || !mounted) return;
    showCaptureSaved(context, saved, onSee: () => _goTo(_inboxTab));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _auth ??= AppScope.of(context).auth..addListener(_onAuthChanged);
  }

  @override
  void dispose() {
    _auth?.removeListener(_onAuthChanged);
    super.dispose();
  }

  void _onAuthChanged() {
    if (!_auth!.sessionExpired) return;
    final messenger = ScaffoldMessenger.of(context);
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (_) => false,
    );
    messenger.showSnackBar(
      SnackBar(content: Text(context.l10n.sessionExpired)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final captures = AppScope.of(context).captures;
    final courses = AppScope.of(context).courses;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: MediaQuery(
                  data: media.copyWith(
                    padding: media.padding.copyWith(bottom: ArcMenu.overhang),
                  ),
                  child: _FadeTabStack(
                    index: _tab,
                    children: [
                      HomePage(
                        onSeeVocabulary: () => _goTo(_vocabularyTab),
                        onCapture: () => _menu.currentState?.open(),
                      ),
                      const VocabularyPage(),
                      const InboxPage(),
                      const ProfilePage(),
                    ],
                  ),
                ),
              ),
              ListenableBuilder(
                listenable: captures,
                builder: (context, _) => AppTabBar(
                  currentIndex: _tab,
                  onTap: _goTo,
                  centerGap: 72,
                  items: [
                    AppTabItem(
                      icon: AppIcons.home,
                      label: context.l10n.tabHome,
                    ),
                    AppTabItem(
                      icon: AppIcons.vocabulary,
                      label: context.l10n.tabVocabulary,
                    ),
                    AppTabItem(
                      icon: AppIcons.inbox,
                      label: context.l10n.tabInbox,
                      badge:
                          captures.data?.where((c) => c.needsAction).length ??
                          0,
                    ),
                    AppTabItem(
                      icon: AppIcons.profile,
                      label: context.l10n.tabProfile,
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned.fill(
            child: ListenableBuilder(
              listenable: courses,
              builder: (context, _) => ArcMenu(
                key: _menu,
                anchorBottom: AppTabBar.height + media.padding.bottom,
                title: context.l10n.captureMenuTitle,
                subtitle: context.l10n.captureMenuSubtitle,
                items: [
                  for (final (icon, label, color, source) in [
                    (
                      AppIcons.camera,
                      context.l10n.captureCamera,
                      AppPalette.mango,
                      CaptureSource.photo,
                    ),
                    (
                      AppIcons.audio,
                      context.l10n.captureAudio,
                      AppPalette.coral,
                      CaptureSource.audio,
                    ),
                    (
                      AppIcons.text,
                      context.l10n.captureText,
                      AppPalette.mint,
                      CaptureSource.text,
                    ),
                  ])
                    if (source != CaptureSource.audio ||
                        (courses.active?.learning.hasAudio ?? true))
                      ArcMenuItem(
                        icon: icon,
                        label: label,
                        color: color,
                        onTap: () => _capture(source),
                      ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FadeTabStack extends StatefulWidget {
  const _FadeTabStack({required this.index, required this.children});

  final int index;
  final List<Widget> children;

  @override
  State<_FadeTabStack> createState() => _FadeTabStackState();
}

class _FadeTabStackState extends State<_FadeTabStack>
    with SingleTickerProviderStateMixin {
  static const _still = AlwaysStoppedAnimation(Offset.zero);

  late final _controller =
      AnimationController(vsync: this, duration: AppMotion.slow, value: 1)
        ..addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            setState(() => _previous = null);
          }
        });
  late final _curve = CurvedAnimation(
    parent: _controller,
    curve: AppMotion.standard,
  );
  late final _slide = Tween(
    begin: const Offset(0, 0.02),
    end: Offset.zero,
  ).animate(_curve);

  int? _previous;

  @override
  void didUpdateWidget(_FadeTabStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index == widget.index) return;
    _previous = oldWidget.index;
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _curve.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final order = [
      for (var i = 0; i < widget.children.length; i++)
        if (i != widget.index && i != _previous) i,
      ?_previous,
      widget.index,
    ];
    return Stack(
      fit: StackFit.expand,
      children: [for (final i in order) _layer(i)],
    );
  }

  Widget _layer(int i) {
    final current = i == widget.index;
    final hidden = !current && i != _previous;
    return KeyedSubtree(
      key: ValueKey(i),
      child: Offstage(
        offstage: hidden,
        child: TickerMode(
          enabled: !hidden,
          child: IgnorePointer(
            ignoring: !current,
            child: FadeTransition(
              opacity: current ? _curve : kAlwaysCompleteAnimation,
              child: SlideTransition(
                position: current ? _slide : _still,
                child: widget.children[i],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import 'package:tagarela/app/app_scope.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/features/home/home_page.dart';
import 'package:tagarela/features/inbox/inbox_page.dart';
import 'package:tagarela/features/profile/profile_page.dart';
import 'package:tagarela/features/vocabulary/vocabulary_page.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  static void open(BuildContext context) {
    AppScope.of(context).loadAll();
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeShell()),
      (_) => false,
    );
  }

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  static const _vocabularyTab = 1;
  static const _inboxTab = 2;

  int _tab = 0;

  void _goTo(int tab) => setState(() => _tab = tab);

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final inbox = AppScope.of(context).inbox;

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
                      HomePage(onSeeVocabulary: () => _goTo(_vocabularyTab)),
                      const VocabularyPage(),
                      const InboxPage(),
                      const ProfilePage(),
                    ],
                  ),
                ),
              ),
              ListenableBuilder(
                listenable: inbox,
                builder: (context, _) => AppTabBar(
                  currentIndex: _tab,
                  onTap: _goTo,
                  centerGap: 72,
                  items: [
                    const AppTabItem(icon: AppIcons.home, label: 'Início'),
                    const AppTabItem(
                      icon: AppIcons.vocabulary,
                      label: 'Vocabulário',
                    ),
                    AppTabItem(
                      icon: AppIcons.inbox,
                      label: 'Inbox',
                      badge: inbox.data?.length ?? 0,
                    ),
                    const AppTabItem(icon: AppIcons.profile, label: 'Perfil'),
                  ],
                ),
              ),
            ],
          ),
          Positioned.fill(
            child: ArcMenu(
              anchorBottom: AppTabBar.height + media.padding.bottom,
              title: 'O que você ouviu hoje?',
              subtitle: 'Fotografe, grave ou digite. A análise vai pro Inbox.',
              items: [
                for (final (icon, label, color) in const [
                  (AppIcons.camera, 'Câmera', AppPalette.mango),
                  (AppIcons.audio, 'Áudio', AppPalette.coral),
                  (AppIcons.text, 'Texto', AppPalette.mint),
                ])
                  ArcMenuItem(
                    icon: icon,
                    label: label,
                    color: color,
                    onTap: () => _goTo(_inboxTab),
                  ),
              ],
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

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
      backgroundColor: context.colors.header,
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
                  child: _FadeIndexedStack(
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

class _FadeIndexedStack extends StatefulWidget {
  const _FadeIndexedStack({required this.index, required this.children});

  final int index;
  final List<Widget> children;

  @override
  State<_FadeIndexedStack> createState() => _FadeIndexedStackState();
}

class _FadeIndexedStackState extends State<_FadeIndexedStack>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: AppMotion.slow,
    value: 1,
  );
  late final _curve = CurvedAnimation(
    parent: _controller,
    curve: AppMotion.standard,
  );
  late final _slide = Tween(
    begin: const Offset(0, 0.02),
    end: Offset.zero,
  ).animate(_curve);

  @override
  void didUpdateWidget(_FadeIndexedStack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index != widget.index) _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _curve.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _curve,
      child: SlideTransition(
        position: _slide,
        child: IndexedStack(index: widget.index, children: widget.children),
      ),
    );
  }
}

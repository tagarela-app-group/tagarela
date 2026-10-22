import 'package:flutter/material.dart';

import 'package:tagarela/app/app_scope.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/features/home/home_page.dart';
import 'package:tagarela/features/inbox/inbox_page.dart';
import 'package:tagarela/features/profile/profile_page.dart';
import 'package:tagarela/features/vocabulary/vocabulary_page.dart';

/// Abas principais + botão de captura (menu em arco).
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

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
      // Cada aba (SheetPage) cuida do teclado; a tab bar fica parada.
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                // Abas não tocam a área segura inferior (fica com a tab bar),
                // mas deixam espaço para o botão que invade o conteúdo.
                child: MediaQuery(
                  data: media.copyWith(
                    padding: media.padding.copyWith(bottom: ArcMenu.overhang),
                  ),
                  child: IndexedStack(
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

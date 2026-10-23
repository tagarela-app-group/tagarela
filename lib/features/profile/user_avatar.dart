import 'package:flutter/material.dart';

import 'package:tagarela/data/models.dart';
import 'package:tagarela/design_system/design_system.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key, required this.user, this.size = 44});

  final User? user;
  final double size;

  @override
  Widget build(BuildContext context) {
    final picture = user?.picture;
    return AppBubble(
      size: size,
      image: picture == null ? null : NetworkImage(picture),
      child: switch (user) {
        final user? => Text(user.initials),
        null => const Icon(AppIcons.profile),
      },
    );
  }
}

import 'package:flutter/material.dart';

import 'package:tagarela/data/models.dart';
import 'package:tagarela/design_system/design_system.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key, required this.user, this.size = 44, this.ring});

  final User? user;
  final double size;
  final Color? ring;

  @override
  Widget build(BuildContext context) {
    final picture = user?.picture;
    return AppBubble(
      size: size,
      ring: ring,
      image: picture == null ? null : NetworkImage(picture),
      child: switch (user) {
        final user? => Text(user.initials),
        null => const Icon(AppIcons.profile),
      },
    );
  }
}

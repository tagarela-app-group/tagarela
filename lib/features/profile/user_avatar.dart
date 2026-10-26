import 'package:flutter/material.dart';

import 'package:tagarela/data/models/models.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/l10n/countries.dart';
import 'package:tagarela/l10n/l10n.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key, required this.user, this.size = 44, this.ring});

  final User? user;
  final double size;
  final Color? ring;

  @override
  Widget build(BuildContext context) {
    final picture = user?.picture;
    final country = user?.country;
    final name = country == null ? null : context.l10n.countryName(country);
    return AppBubble(
      size: size,
      ring: ring,
      image: picture == null ? null : NetworkImage(picture),
      badge: country == null || name == null
          ? null
          : FlagBadge(
              country: country,
              size: size * 0.38,
              ring: context.colors.header,
              semanticLabel: context.l10n.countryFlag(name),
            ),
      child: switch (user) {
        final user? => Text(user.initials),
        null => const Icon(AppIcons.profile),
      },
    );
  }
}

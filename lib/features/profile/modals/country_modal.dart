import 'package:flutter/material.dart';

import 'package:tagarela/app/app_scope.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/l10n/countries/countries.dart';
import 'package:tagarela/l10n/l10n.dart';
import 'package:tagarela/shared/logic/busy_action.dart';

class CountryModal extends StatefulWidget {
  const CountryModal({super.key});

  @override
  State<CountryModal> createState() => _CountryModalState();
}

class _CountryModalState extends State<CountryModal> with BusyAction {
  final _query = TextEditingController();

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  Future<void> _pick(String? country) => runAction(() async {
    await AppScope.of(context).auth.updateCountry(country);
    if (mounted) Navigator.pop(context);
  }, failureOf: (_) => context.l10n.countrySaveFailed);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final current = AppScope.of(context).auth.user?.country;
    final query = foldText(_query.text.trim());
    final countries = [
      for (final country in l10n.countries())
        if (foldText(country.name).contains(query)) country,
    ];
    final rows = [
      if (query.isEmpty)
        OptionRow(
          icon: AppIcons.flag,
          accent: AppAccent.mango,
          title: l10n.countryNone,
          selected: current == null,
          onTap: busy ? null : () => _pick(null),
        ),
      for (final country in countries)
        OptionRow(
          leading: FlagBadge(country: country.code, size: AppBubbleSize.md),
          title: country.name,
          selected: current == country.code,
          onTap: busy ? null : () => _pick(country.code),
        ),
    ];

    return AppModal(
      icon: AppIcons.flag,
      accent: AppAccent.mango,
      title: l10n.countryOfOrigin,
      subtitle: l10n.countryModalSubtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: AppSpacing.s3,
        children: [
          AppTextField(
            label: l10n.searchCountry,
            icon: AppIcons.search,
            controller: _query,
            textInputAction: TextInputAction.search,
            onChanged: (_) => setState(() {}),
          ),
          if (failure case final error?) FormError(error),
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.45,
            child: rows.isEmpty
                ? StateMessage(
                    icon: AppIcons.search,
                    title: l10n.noCountryFound,
                    message: _query.text.trim(),
                  )
                : ListView.separated(
                    itemCount: rows.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.s2),
                    itemBuilder: (_, i) => rows[i],
                  ),
          ),
        ],
      ),
    );
  }
}

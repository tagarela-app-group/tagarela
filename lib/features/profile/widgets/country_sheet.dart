import 'package:flutter/material.dart';

import 'package:tagarela/app/app_scope.dart';
import 'package:tagarela/design_system/design_system.dart';
import 'package:tagarela/l10n/countries.dart';
import 'package:tagarela/l10n/l10n.dart';

class CountrySheet extends StatefulWidget {
  const CountrySheet({super.key});

  @override
  State<CountrySheet> createState() => _CountrySheetState();
}

class _CountrySheetState extends State<CountrySheet> {
  final _query = TextEditingController();
  var _saving = false;
  String? _error;

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  Future<void> _pick(String? country) async {
    final failed = context.l10n.countrySaveFailed;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await AppScope.of(context).auth.updateCountry(country);
      if (mounted) Navigator.pop(context);
    } on Exception {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = failed;
      });
    }
  }

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
          onTap: _saving ? null : () => _pick(null),
        ),
      for (final country in countries)
        OptionRow(
          leading: FlagBadge(country: country.code, size: 40),
          title: country.name,
          selected: current == country.code,
          onTap: _saving ? null : () => _pick(country.code),
        ),
    ];

    return AppSheet(
      icon: AppIcons.flag,
      accent: AppAccent.mango,
      title: l10n.countryOfOrigin,
      subtitle: l10n.countrySheetSubtitle,
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
          if (_error case final error?)
            Text(
              error,
              style: AppText.bodyMd.copyWith(color: context.colors.alert),
            ),
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

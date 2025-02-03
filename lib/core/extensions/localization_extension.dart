import 'package:flutter/widgets.dart';
import 'package:smartkyc/l10n/app_localizations.dart';

extension LocalizationExtension on BuildContext {
  AppLocalizations get loc => AppLocalizations.of(this);
}

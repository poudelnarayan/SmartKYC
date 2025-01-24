import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LivenessStrings {
  final String lookUpInstruction;
  final String lookDownInstruction;
  final String lookLeftInstruction;
  final String lookRightInstruction;
  final String centerHeadInstruction;
  final String verificationCompleted;

  const LivenessStrings({
    required this.lookUpInstruction,
    required this.lookDownInstruction,
    required this.lookLeftInstruction,
    required this.lookRightInstruction,
    required this.centerHeadInstruction,
    required this.verificationCompleted,
  });

  factory LivenessStrings.fromContext(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return LivenessStrings(
      lookUpInstruction: l10n.lookUpInstruction,
      lookDownInstruction: l10n.lookDownInstruction,
      lookLeftInstruction: l10n.lookLeftInstruction,
      lookRightInstruction: l10n.lookRightInstruction,
      centerHeadInstruction: l10n.centerHeadInstruction,
      verificationCompleted: l10n.verificationCompleted,
    );
  }
}
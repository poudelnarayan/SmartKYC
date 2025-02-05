import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:smartkyc/core/theme/app_color_scheme.dart';

class AboutBottomSheet extends StatelessWidget {
  const AboutBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColorScheme.getCardBackground(isDark),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColorScheme.darkCardBorder
                  : AppColorScheme.lightCardBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          CircleAvatar(
            radius: 40,
            backgroundColor: isDark
                ? AppColorScheme.darkPrimary
                : AppColorScheme.lightPrimary,
            child: Icon(
              Icons.info_outline,
              size: 40,
              color: AppColorScheme.getCardBackground(isDark),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'About SmartKYC',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? AppColorScheme.darkText
                      : AppColorScheme.lightText,
                ),
          ),
          const SizedBox(height: 16),
          Text(
            'SmartKYC is a secure and efficient Know Your Customer (KYC) solution that uses advanced technology for identity verification.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: isDark
                  ? AppColorScheme.darkTextSecondary
                  : AppColorScheme.lightTextSecondary,
            ),
          ),
          const SizedBox(height: 24),
          FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Column(
                  children: [
                    Divider(
                      color: isDark
                          ? AppColorScheme.darkCardBorder
                          : AppColorScheme.lightCardBorder,
                    ),
                    _buildInfoRow('Version', snapshot.data!.version, isDark),
                    _buildInfoRow('Build', snapshot.data!.buildNumber, isDark),
                  ],
                );
              }
              return CircularProgressIndicator(
                color: isDark
                    ? AppColorScheme.darkPrimary
                    : AppColorScheme.lightPrimary,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDark
                  ? AppColorScheme.darkTextSecondary
                  : AppColorScheme.lightTextSecondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color:
                  isDark ? AppColorScheme.darkText : AppColorScheme.lightText,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:predictions_shared/predictions_shared.dart';
import 'package:url_launcher/url_launcher.dart';

import '../vip_tips/vip_tips_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const String _supportEmail = 'kevin20557@gmail.com';
  static const String _playStorePackageName = 'com.flore.footballtips';

  Future<void> _launchPrivacyPolicy() async {
    final uri = Uri.parse(
      'https://www.freeprivacypolicy.com/live/9f7df775-62c8-4661-89e8-640d5c36a063',
    );
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch privacy policy');
    }
  }

  Future<void> _launchRateApp() async {
    final uri = Uri.https(
      'play.google.com',
      '/store/apps/details',
      <String, String>{'id': _playStorePackageName},
    );
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch app store listing');
    }
  }

  Future<void> _launchSubscriptionManagement() async {
    final uri = Uri.https(
      'play.google.com',
      '/store/account/subscriptions',
    );
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch subscription management');
    }
  }

  Future<void> _launchSupportEmail() async {
    final uri = Uri(
      scheme: 'mailto',
      path: _supportEmail,
      queryParameters: <String, String>{
        'subject': 'Sports Predictions Support',
      },
    );
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch email client');
    }
  }

  void _navigateToVIP(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const VipTipsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = [
      _SettingTile(
        icon: Icons.star_rate,
        title: 'Rate App',
        subtitle: 'Leave a review on Google Play',
        onTap: _launchRateApp,
        color: Colors.amber.shade700,
      ),
      _SettingTile(
        icon: Icons.workspace_premium,
        title: 'Upgrade to VIP',
        subtitle: 'Unlock premium features',
        onTap: () => _navigateToVIP(context),
        color: Colors.amber.shade700,
      ),
      _SettingTile(
        icon: Icons.receipt_long,
        title: 'Subscription Management',
        subtitle: 'Manage or cancel your subscription',
        onTap: _launchSubscriptionManagement,
        color: AppColors.royal,
      ),
      _SettingTile(
        icon: Icons.email_outlined,
        title: 'Reach Us Now',
        subtitle: 'Open your email app to contact support',
        onTap: _launchSupportEmail,
        color: AppColors.ocean,
      ),
      _SettingTile(
        icon: Icons.shield,
        title: 'Privacy Policy',
        subtitle: 'Review how we handle data',
        onTap: _launchPrivacyPolicy,
      ),
    ];

    final children = <Widget>[
      const _SettingsHeader(),
      const SizedBox(height: 20),
    ];

    for (var index = 0; index < items.length; index++) {
      children.add(Card(child: items[index]));
      if (index < items.length - 1) {
        children.add(const SizedBox(height: 12));
      }
    }

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: children,
      ),
    );
  }
}

class _SettingsHeader extends StatelessWidget {
  const _SettingsHeader();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Settings',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Manage ratings, subscriptions, support, and privacy.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.grey.shade400,
          ),
        ),
      ],
    );
  }
}

class _SettingTile extends StatelessWidget {
  const _SettingTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.color,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: (color ?? AppColors.royal).withValues(alpha: 0.2),
        child: Icon(icon, color: color ?? AppColors.royal),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

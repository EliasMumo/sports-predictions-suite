import 'package:flutter/material.dart';
import 'package:predictions_shared/predictions_shared.dart';
import 'package:url_launcher/url_launcher.dart';
import '../vip_tips/vip_tips_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _launchPrivacyPolicy() async {
    final uri = Uri.parse('https://www.freeprivacypolicy.com/live/9f7df775-62c8-4661-89e8-640d5c36a063');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch privacy policy');
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
        icon: Icons.workspace_premium,
        title: 'Upgrade to VIP',
        subtitle: 'Unlock premium features',
        onTap: () => _navigateToVIP(context),
        color: Colors.amber.shade700,
      ),
      _SettingTile(
        icon: Icons.shield,
        title: 'Privacy Policy',
        subtitle: 'Review how we handle data',
        onTap: _launchPrivacyPolicy,
      ),
    ];

    return SafeArea(
      child: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemBuilder: (_, index) => Card(
          child: items[index],
        ),
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemCount: items.length,
      ),
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

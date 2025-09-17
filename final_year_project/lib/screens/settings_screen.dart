import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/profile_service.dart';
import '../models/user_profile.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late UserSettings _settings;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    final profileService = Provider.of<ProfileService>(context, listen: false);
    _settings = profileService.userProfile?.settings ?? UserSettings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Settings',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          if (_hasChanges)
            Consumer<ProfileService>(
              builder: (context, profileService, child) {
                return TextButton(
                  onPressed: profileService.isLoading ? null : _saveSettings,
                  child: profileService.isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          'Save',
                          style: TextStyle(
                            color: Colors.blue[600],
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                );
              },
            ),
        ],
      ),
      body: Consumer<ProfileService>(
        builder: (context, profileService, child) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // App Preferences
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'App Preferences',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Dark Mode Toggle
                        _SettingsTile(
                          icon: Icons.dark_mode_outlined,
                          title: 'Dark Mode',
                          subtitle: 'Enable dark theme',
                          trailing: Switch(
                            value: _settings.darkMode,
                            onChanged: (value) {
                              setState(() {
                                _settings = _settings.copyWith(darkMode: value);
                                _hasChanges = true;
                              });
                            },
                            activeColor: Colors.blue[600],
                          ),
                        ),
                        
                        const Divider(),
                        
                        // Biometric Authentication
                        _SettingsTile(
                          icon: Icons.fingerprint,
                          title: 'Biometric Authentication',
                          subtitle: 'Use fingerprint or face unlock',
                          trailing: Switch(
                            value: _settings.biometricAuth,
                            onChanged: (value) {
                              setState(() {
                                _settings = _settings.copyWith(biometricAuth: value);
                                _hasChanges = true;
                              });
                            },
                            activeColor: Colors.blue[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Regional Settings
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Regional Settings',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Language Setting
                        _SettingsTile(
                          icon: Icons.language,
                          title: 'Language',
                          subtitle: _getLanguageDisplayName(_settings.preferredLanguage),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () => _showLanguageSelector(),
                        ),
                        
                        const Divider(),
                        
                        // Currency Setting
                        _SettingsTile(
                          icon: Icons.attach_money,
                          title: 'Currency',
                          subtitle: _getCurrencyDisplayName(_settings.preferredCurrency),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () => _showCurrencySelector(),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Privacy & Security
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Privacy & Security',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        _SettingsTile(
                          icon: Icons.privacy_tip_outlined,
                          title: 'Privacy Policy',
                          subtitle: 'Read our privacy policy',
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () => _showPrivacyPolicy(),
                        ),
                        
                        const Divider(),
                        
                        _SettingsTile(
                          icon: Icons.security,
                          title: 'Data & Security',
                          subtitle: 'Manage your data and security settings',
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () => _showSecuritySettings(),
                        ),
                        
                        const Divider(),
                        
                        _SettingsTile(
                          icon: Icons.delete_outline,
                          title: 'Delete Account',
                          subtitle: 'Permanently delete your account',
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () => _showDeleteAccountDialog(),
                          textColor: Colors.red,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Support & Information
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Support & Information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        _SettingsTile(
                          icon: Icons.help_outline,
                          title: 'Help Center',
                          subtitle: 'Get help and support',
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () => _showHelpCenter(),
                        ),
                        
                        const Divider(),
                        
                        _SettingsTile(
                          icon: Icons.feedback_outlined,
                          title: 'Send Feedback',
                          subtitle: 'Share your thoughts with us',
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () => _showFeedbackDialog(),
                        ),
                        
                        const Divider(),
                        
                        _SettingsTile(
                          icon: Icons.info_outline,
                          title: 'About App',
                          subtitle: 'Version 1.0.0',
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () => _showAboutDialog(),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Save Button
                  if (_hasChanges)
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: profileService.isLoading ? null : _saveSettings,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[600],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: profileService.isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text(
                                'Save Settings',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Helper Methods
  String _getLanguageDisplayName(String code) {
    switch (code) {
      case 'en':
        return 'English';
      case 'es':
        return 'Español';
      case 'fr':
        return 'Français';
      case 'de':
        return 'Deutsch';
      case 'zh':
        return '中文';
      default:
        return 'English';
    }
  }

  String _getCurrencyDisplayName(String code) {
    switch (code) {
      case 'USD':
        return 'US Dollar (\$)';
      case 'EUR':
        return 'Euro (€)';
      case 'GBP':
        return 'British Pound (£)';
      case 'JPY':
        return 'Japanese Yen (¥)';
      case 'CNY':
        return 'Chinese Yuan (¥)';
      default:
        return 'US Dollar (\$)';
    }
  }

  // Dialog and Selector Methods
  void _showLanguageSelector() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption('en', 'English'),
            _buildLanguageOption('es', 'Español'),
            _buildLanguageOption('fr', 'Français'),
            _buildLanguageOption('de', 'Deutsch'),
            _buildLanguageOption('zh', '中文'),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(String code, String name) {
    return ListTile(
      title: Text(name),
      leading: Radio<String>(
        value: code,
        groupValue: _settings.preferredLanguage,
        onChanged: (value) {
          setState(() {
            _settings = _settings.copyWith(preferredLanguage: value);
            _hasChanges = true;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showCurrencySelector() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Currency'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildCurrencyOption('USD', 'US Dollar (\$)'),
            _buildCurrencyOption('EUR', 'Euro (€)'),
            _buildCurrencyOption('GBP', 'British Pound (£)'),
            _buildCurrencyOption('JPY', 'Japanese Yen (¥)'),
            _buildCurrencyOption('CNY', 'Chinese Yuan (¥)'),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyOption(String code, String name) {
    return ListTile(
      title: Text(name),
      leading: Radio<String>(
        value: code,
        groupValue: _settings.preferredCurrency,
        onChanged: (value) {
          setState(() {
            _settings = _settings.copyWith(preferredCurrency: value);
            _hasChanges = true;
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showPrivacyPolicy() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Privacy Policy coming soon!')),
    );
  }

  void _showSecuritySettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Security settings coming soon!')),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to permanently delete your account? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Account deletion coming soon!')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showHelpCenter() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Help center coming soon!')),
    );
  }

  void _showFeedbackDialog() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Feedback form coming soon!')),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About App'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('E-Commerce App'),
            SizedBox(height: 8),
            Text('Version: 1.0.0'),
            SizedBox(height: 8),
            Text('Build: 2024.09.17'),
            SizedBox(height: 16),
            Text('A comprehensive e-commerce application built with Flutter and Django.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveSettings() async {
    final profileService = Provider.of<ProfileService>(context, listen: false);
    final success = await profileService.updateNotificationSettings(_settings);

    if (mounted) {
      if (success) {
        setState(() {
          _hasChanges = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Settings updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(profileService.errorMessage ?? 'Failed to update settings'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? textColor;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: textColor ?? Colors.grey[700],
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: textColor?.withOpacity(0.7) ?? Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/profile_service.dart';
import '../models/user_profile.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
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
          'Notifications',
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
                  // Main Notification Toggle
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
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.notifications_active,
                                color: Colors.blue[600],
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'All Notifications',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Master switch for all notifications',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: _settings.notificationsEnabled,
                              onChanged: (value) {
                                setState(() {
                                  _settings = _settings.copyWith(notificationsEnabled: value);
                                  _hasChanges = true;
                                });
                              },
                              activeColor: Colors.blue[600],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Notification Types
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
                          'Notification Types',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Push Notifications
                        _NotificationTile(
                          icon: Icons.phone_android,
                          title: 'Push Notifications',
                          subtitle: 'Receive notifications on your device',
                          value: _settings.pushNotifications && _settings.notificationsEnabled,
                          enabled: _settings.notificationsEnabled,
                          onChanged: (value) {
                            setState(() {
                              _settings = _settings.copyWith(pushNotifications: value);
                              _hasChanges = true;
                            });
                          },
                        ),
                        
                        const Divider(),
                        
                        // Email Notifications
                        _NotificationTile(
                          icon: Icons.email_outlined,
                          title: 'Email Notifications',
                          subtitle: 'Receive notifications via email',
                          value: _settings.emailNotifications && _settings.notificationsEnabled,
                          enabled: _settings.notificationsEnabled,
                          onChanged: (value) {
                            setState(() {
                              _settings = _settings.copyWith(emailNotifications: value);
                              _hasChanges = true;
                            });
                          },
                        ),
                        
                        const Divider(),
                        
                        // SMS Notifications
                        _NotificationTile(
                          icon: Icons.sms_outlined,
                          title: 'SMS Notifications',
                          subtitle: 'Receive notifications via text message',
                          value: _settings.smsNotifications && _settings.notificationsEnabled,
                          enabled: _settings.notificationsEnabled,
                          onChanged: (value) {
                            setState(() {
                              _settings = _settings.copyWith(smsNotifications: value);
                              _hasChanges = true;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Notification Categories
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
                          'What you want to be notified about',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Order Updates
                        _NotificationTile(
                          icon: Icons.shopping_bag_outlined,
                          title: 'Order Updates',
                          subtitle: 'Status changes, shipping updates, and delivery notifications',
                          value: _settings.notificationsEnabled, // This would be a separate setting in a real app
                          enabled: _settings.notificationsEnabled,
                          onChanged: (value) {
                            // Handle order notification preferences
                          },
                        ),
                        
                        const Divider(),
                        
                        // Promotions & Offers
                        _NotificationTile(
                          icon: Icons.local_offer_outlined,
                          title: 'Promotions & Offers',
                          subtitle: 'Special deals, discounts, and exclusive offers',
                          value: _settings.notificationsEnabled, // This would be a separate setting in a real app
                          enabled: _settings.notificationsEnabled,
                          onChanged: (value) {
                            // Handle promotion notification preferences
                          },
                        ),
                        
                        const Divider(),
                        
                        // Account Security
                        _NotificationTile(
                          icon: Icons.security,
                          title: 'Account Security',
                          subtitle: 'Login alerts and security notifications',
                          value: _settings.notificationsEnabled, // This would be a separate setting in a real app
                          enabled: _settings.notificationsEnabled,
                          onChanged: (value) {
                            // Handle security notification preferences
                          },
                        ),
                        
                        const Divider(),
                        
                        // New Products
                        _NotificationTile(
                          icon: Icons.new_releases_outlined,
                          title: 'New Products',
                          subtitle: 'Notifications about new arrivals and restocks',
                          value: _settings.notificationsEnabled, // This would be a separate setting in a real app
                          enabled: _settings.notificationsEnabled,
                          onChanged: (value) {
                            // Handle new product notification preferences
                          },
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Do Not Disturb
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
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.purple[50],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.do_not_disturb_on_outlined,
                                color: Colors.purple[600],
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Do Not Disturb',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    'Configure quiet hours',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Colors.grey,
                            ),
                          ],
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
                                'Save Notification Settings',
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
            content: Text('Notification settings updated successfully!'),
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

class _NotificationTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final bool enabled;
  final ValueChanged<bool> onChanged;

  const _NotificationTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: enabled ? Colors.grey[100] : Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: enabled ? Colors.grey[700] : Colors.grey[400],
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
                    color: enabled ? Colors.black : Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: enabled ? Colors.grey[600] : Colors.grey[400],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: enabled ? onChanged : null,
            activeColor: Colors.blue[600],
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'login_screen.dart';
import 'repositories/shared_prefs_user_repository.dart';

class AppSettingsPage extends StatefulWidget {
  const AppSettingsPage({super.key});

  @override
  State<AppSettingsPage> createState() => _AppSettingsPageState();
}

class _AppSettingsPageState extends State<AppSettingsPage> {
  bool _loading = true;
  bool _darkMode = false;
  int _themeColor = 0xFF87AE73;
  bool _pushNotifications = true;
  bool _emailNotifications = false;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final prefs = await SharedPreferences.getInstance();
    _darkMode = prefs.getBool('dark_mode') ?? false;
    _themeColor = prefs.getInt('theme_primary_color') ?? 0xFF87AE73;
    _pushNotifications = prefs.getBool('notif_push') ?? true;
    _emailNotifications = prefs.getBool('notif_email') ?? false;
    if (!mounted) return;
    setState(() => _loading = false);
  }

  Future<void> _setDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('dark_mode', value);
    if (!mounted) return;
    setState(() => _darkMode = value);
  }

  Future<void> _pickThemeColor() async {
    final List<int> options = [0xFF87AE73, 0xFF6B8E5B, 0xFF4F6E43, 0xFF334E2B, 0xFF172E13];
    final chosen = await showDialog<int>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Choose theme color'),
        content: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final c in options)
              GestureDetector(
                onTap: () => Navigator.pop(context, c),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(color: Color(c), shape: BoxShape.circle, border: Border.all(color: Colors.black12)),
                ),
              ),
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
      ),
    );
    if (chosen == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme_primary_color', chosen);
    if (!mounted) return;
    setState(() => _themeColor = chosen);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Theme color saved. Restart app to apply.')));
  }

  Future<void> _setNotif(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: Color.fromARGB(255, 231, 228, 213),
        appBar: _SettingsAppBar(),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 231, 228, 213),
      appBar: const _SettingsAppBar(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Appearance',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF87AE73)),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.dark_mode_outlined),
                  title: const Text('Dark mode'),
                  value: _darkMode,
                  onChanged: (v) => _setDarkMode(v),
                ),
                const Divider(height: 0),
                ListTile(
                  leading: CircleAvatar(backgroundColor: Color(_themeColor)),
                  title: const Text('Theme color'),
                  subtitle: const Text('Tap to choose'),
                  onTap: _pickThemeColor,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          const Text(
            'Notifications',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF87AE73)),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.notifications_outlined),
                  title: const Text('Push notifications'),
                  value: _pushNotifications,
                  onChanged: (v) {
                    setState(() => _pushNotifications = v);
                    _setNotif('notif_push', v);
                  },
                ),
                const Divider(height: 0),
                SwitchListTile(
                  secondary: const Icon(Icons.email_outlined),
                  title: const Text('Email notifications'),
                  value: _emailNotifications,
                  onChanged: (v) {
                    setState(() => _emailNotifications = v);
                    _setNotif('notif_email', v);
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          const Text(
            'Data & privacy',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF87AE73)),
          ),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.delete_outline, color: Colors.red),
                  title: const Text('Reset App'),
                  subtitle: const Text('Remove cached users and balances'),
                  onTap: () async {
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Reset App?'),
                        content: const Text('This will remove locally stored users and balances.'),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Reset')),
                        ],
                      ),
                    );
                    if (ok == true) {
                      await (SharedPrefsUserRepository()).clearAllData();
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Reset Successful')),
                      );
                    }
                  },
                ),
                //const Divider(height: 0),
                /*
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Log out'),
                  onTap: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  },
                ),
                */
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _SettingsAppBar();
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Settings', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      backgroundColor: const Color(0xFF87AE73),
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
    );
  }
}




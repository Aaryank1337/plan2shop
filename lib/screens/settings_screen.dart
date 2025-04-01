import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:plan2shop/screens/login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Function to show the alarm alert dialog.
  void _showAlarmAlert() {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.shopping_cart, color: Theme.of(context).primaryColor),
              const SizedBox(width: 10),
              const Text("It's Shopping Time"),
            ],
          ),
          content: const Text("Let's collect all the things from cart."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  // Function to pick an alarm time and schedule the alert.
  void _pickAlarmTime() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (!mounted) return;
    if (pickedTime != null) {
      final now = DateTime.now();
      DateTime scheduledTime = DateTime(
        now.year,
        now.month,
        now.day,
        pickedTime.hour,
        pickedTime.minute,
      );
      if (scheduledTime.isBefore(now)) {
        scheduledTime = scheduledTime.add(const Duration(days: 1));
      }
      final duration = scheduledTime.difference(now);

      // Show snackbar with custom design
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          content: Row(
            children: [
              const Icon(Icons.access_time, color: Colors.white),
              const SizedBox(width: 12),
              Text("Reminder set for ${pickedTime.format(context)}"),
            ],
          ),
          backgroundColor: Theme.of(context).primaryColor,
        ),
      );

      // Schedule the alert.
      Future.delayed(duration, () {
        if (!mounted) return;
        _showAlarmAlert();
      });
    }
  }

  // Function to show the "How to Use" dialog.
  void _showHowToUse() {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(Icons.help, color: Theme.of(context).primaryColor),
              const SizedBox(width: 10),
              const Text("How to Use"),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Welcome to Plan2Shop!",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 16),
                _buildHowToUseStep(
                  "1",
                  "Plan Your Meal",
                  "Decide on the meal you want to cook by choosing a recipe from our list or entering your own.",
                  Icons.restaurant_menu,
                ),
                const SizedBox(height: 12),
                _buildHowToUseStep(
                  "2",
                  "Create Your Grocery List",
                  "Tap 'Add' after selecting your recipe, and the app will automatically generate a grocery list with all the required ingredients.",
                  Icons.playlist_add,
                ),
                const SizedBox(height: 12),
                _buildHowToUseStep(
                  "3",
                  "Set Shopping Reminders",
                  "Use the 'Set Reminder' feature to schedule a time to shop. A friendly alert will remind you when it's time to go.",
                  Icons.notifications_active,
                ),
                const SizedBox(height: 12),
                _buildHowToUseStep(
                  "4",
                  "Shop With Ease",
                  "While shopping, simply tap each item on your list once it's bought, and it will be removed, keeping your list updated in real time.",
                  Icons.check_circle_outline,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Got it!"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHowToUseStep(String number, String title, String description, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 18, color: Theme.of(context).primaryColor),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _logout() async {
    if (!mounted) return;
    // Show confirmation dialog
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text("Logout Confirmation"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text("Logout"),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      // Sign out from Firebase.
      await FirebaseAuth.instance.signOut();
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const LoginScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.05),
              Colors.white,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Removed the user profile section ("Hello, Shopper!" part).
              const SizedBox(height: 24),
              // Section title
              const Padding(
                padding: EdgeInsets.only(left: 8.0, bottom: 8.0),
                child: Text(
                  "App Settings",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
              // Settings cards
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    // Alarm setting ListTile
                    _buildSettingsTile(
                      icon: Icons.alarm,
                      iconColor: Colors.orange,
                      title: "Set Shopping Reminder",
                      subtitle: "Schedule a time for your shopping trip",
                      onTap: _pickAlarmTime,
                    ),
                    const Divider(height: 1),
                    // How to Use ListTile
                    _buildSettingsTile(
                      icon: Icons.help_outline,
                      iconColor: Colors.blue,
                      title: "How to Use",
                      subtitle: "Learn how to use Plan2Shop efficiently",
                      onTap: _showHowToUse,
                    ),
                    const Divider(height: 1),
                    // About Section
                    _buildSettingsTile(
                      icon: Icons.info,
                      iconColor: Colors.green,
                      title: "About",
                      subtitle: "App information and version details",
                      onTap: () {
                        if (!mounted) return;
                        showAboutDialog(
                          context: context,
                          applicationName: "Plan2Shop",
                          applicationVersion: "1.0.0",
                          applicationLegalese: "© 2025 Plan2Shop Inc.",
                          applicationIcon: const FlutterLogo(size: 48),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Account section title
              const Padding(
                padding: EdgeInsets.only(left: 8.0, bottom: 8.0),
                child: Text(
                  "Account",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),
              // Logout card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: _buildSettingsTile(
                  icon: Icons.exit_to_app,
                  iconColor: Colors.red,
                  title: "Logout",
                  subtitle: "Sign out from your account",
                  textColor: Colors.red,
                  onTap: _logout,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color iconColor = Colors.black,
    Color? textColor,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: iconColor),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}

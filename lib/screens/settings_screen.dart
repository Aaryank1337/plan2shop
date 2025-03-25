import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:plan2shop/screens/login_screen.dart'; // Adjust import if needed

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
          title: const Text("It's Shopping Time"),
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
    );
    if (pickedTime != null) {
      final now = DateTime.now();
      // Create a DateTime for today at the picked time.
      DateTime scheduledTime = DateTime(
        now.year,
        now.month,
        now.day,
        pickedTime.hour,
        pickedTime.minute,
      );
      // If the scheduled time is before now, add a day.
      if (scheduledTime.isBefore(now)) {
        scheduledTime = scheduledTime.add(const Duration(days: 1));
      }
      final duration = scheduledTime.difference(now);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Reminder set for ${pickedTime.format(context)}"),
        ),
      );
      // Schedule the alert.
      Future.delayed(duration, () {
        if (!mounted) return;
        _showAlarmAlert();
      });
    }
  }

  Future<void> _logout() async {
    // Sign out from Firebase.
    await FirebaseAuth.instance.signOut();

    // Navigate to LoginScreen or any other screen.
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginScreen(), // or your preferred screen
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Settings")),
      body: ListView(
        children: [
          // Alarm setting ListTile.
          ListTile(
            leading: const Icon(Icons.alarm),
            title: const Text("Set Reminder"),
            onTap: _pickAlarmTime,
          ),
          // About Section.
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text("About"),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: "Plan2Shop",
                applicationVersion: "1.0.0",
                applicationLegalese: "© 2025 Plan2Shop Inc.",
              );
            },
          ),
          // Logout Tile (at the bottom).
          ListTile(
            leading: const Icon(Icons.exit_to_app, color: Colors.red),
            title: const Text(
              "Logout",
              style: TextStyle(color: Colors.red),
            ),
            onTap: _logout,
          ),
        ],
      ),
    );
  }
}

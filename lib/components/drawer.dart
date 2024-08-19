import 'package:flutter/material.dart';
import 'package:googlemap/pages/settings_page.dart';
import 'package:googlemap/services/auth/auth_service.dart';
import 'drawer_tile.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  Future<void> logout(BuildContext context) async {
    print('Logging out...');
    final authService = AuthService();
    await authService.signOut();
    print('Logged out');
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 100),
            child: Icon(
              Icons.lock_open_rounded,
              size: 80,
              color: Theme.of(context).colorScheme.inversePrimary,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(25),
            child: Divider(
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          MyDrawerTile(
              text: "H O M E",
              icon: Icons.home,
              onTap: () {
                Navigator.pop(context);
              }),
          MyDrawerTile(
              text: "S E T T I N G S",
              icon: Icons.settings,
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => SettingsPage()));
              }),
          const Spacer(),
          MyDrawerTile(
              text: "L O G O U T",
              icon: Icons.logout,
              onTap: () {
                logout(context);
                Navigator.pop(context);
              }),
          const SizedBox(height: 25),
        ],
      ),
    );
  }
}

// DEPRECATED: The AppShellScreen and bottom navigation are no longer used in the identifier app template.
// All code below is commented out for reference.
/*
// lib/features/app_shell/view/app_shell_screen.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:coin_id/features/home/view/home_screen.dart';

class AppShellScreen extends StatefulWidget {
  const AppShellScreen({super.key});

  @override
  State<AppShellScreen> createState() => _AppShellScreenState();
}

class _AppShellScreenState extends State<AppShellScreen> {
  int _currentIndex = 0; // Start with settings selected

  static const List<Widget> _screens = <Widget>[
    HomeScreen(),
    Center(child: Text("Stats")),
  ];

  @override
  Widget build(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    final isDark = brightness == Brightness.dark;
    
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(0)),
        child: CupertinoTabBar(
          backgroundColor: isDark ? Colors.black12 : Colors.white,
          currentIndex: _currentIndex,
          onTap: (index) {
            HapticFeedback.lightImpact();
            setState(() {
              _currentIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(
                HugeIcons.strokeRoundedHome03,
                size: 32,
              ),
            ),
            BottomNavigationBarItem(
              icon: Icon(
                HugeIcons.strokeRoundedInbox,
                size: 32,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
*/

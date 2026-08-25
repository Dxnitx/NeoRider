import 'package:flutter/material.dart';

import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/live_ride_screen.dart';
import 'screens/rides_screen.dart';
import 'screens/alert_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/ble_test_screen.dart';
import 'screens/device/device_screen.dart';

void main() {
  runApp(const NeoRiderApp());
}

class NeoRiderApp extends StatelessWidget {
  const NeoRiderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NeoRider',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFEFF7E5),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF9BE15D)),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        '/live-ride': (context) => const LiveRideScreen(),
        '/rides': (context) => const RidesScreen(),
        '/alerts': (context) => const AlertScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/ble-test': (context) => const BleTestScreen(),
        '/device': (context) => const DeviceScreen(),
      },
    );
  }
}

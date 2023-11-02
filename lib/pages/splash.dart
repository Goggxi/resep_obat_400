import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resep_obat_400/constants.dart';
import 'package:resep_obat_400/models/user.dart';
import 'package:resep_obat_400/pages/home.dart';
import 'package:resep_obat_400/pages/login.dart';
import 'package:resep_obat_400/providers/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  void _init() async {
    final prefs = await SharedPreferences.getInstance();
    await Future.delayed(const Duration(seconds: 2));
    final user = prefs.getString(userPrefKey);
    if (user != null) {
      if (!mounted) return;
      final userData = userFromJson(user);
      context.read<UserProvider>().user = userData;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
        (route) => false,
      );
    } else {
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    }
  }

  @override
  void initState() {
    _init();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: size.width * 0.4,
            height: size.width * 0.4,
            child: Image.asset('assets/logo-bg.jpeg'),
          ),
          const SizedBox(height: 0, width: double.infinity),
          // const Text(
          //   'Resep Obat',
          //   style: TextStyle(
          //     fontSize: 24,
          //     fontWeight: FontWeight.bold,
          //     color: primaryColor,
          //   ),
          // ),
        ],
      ),
    );
  }
}

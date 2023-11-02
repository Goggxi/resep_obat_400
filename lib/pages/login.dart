import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resep_obat_400/constants.dart';
import 'package:resep_obat_400/models/user.dart';
import 'package:resep_obat_400/pages/home.dart';
import 'package:resep_obat_400/providers/user.dart';
import 'package:resep_obat_400/widgets/loading.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final firestore = FirebaseFirestore.instance;
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;
  bool isPasswordVisible = false;

  void _updatePasswordVisibility() {
    setState(() => isPasswordVisible = !isPasswordVisible);
  }

  void _showLoading() {
    Navigator.of(context).push(LoadingOverlay());
  }

  void _hideLoading() {
    Navigator.of(context).pop();
  }

  void _login({
    required String username,
    required String password,
  }) async {
    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Username atau password tidak boleh kosong'),
        ),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    setState(() => isLoading = true);
    _showLoading();
    try {
      final snapshot = await firestore
          .collection(userCollection)
          .where('username', isEqualTo: username)
          .where('password', isEqualTo: password)
          .limit(1)
          .get();
      setState(() => isLoading = false);
      _hideLoading();
      if (snapshot.docs.isNotEmpty) {
        final user = UserModel.fromMap(snapshot.docs.first.data());
        await prefs.setString(userPrefKey, userToJson(user));
        if (!mounted) return;
        context.read<UserProvider>().user = user;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const HomePage()),
          (route) => false,
        );
        return;
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Username atau password salah'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Terjadi kesalahan'),
        ),
      );
    }
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);
    return Scaffold(
      // appBar: AppBar(title: const Text('Login')),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              Colors.white,
              Colors.white,
              theme.colorScheme.primary.withOpacity(0.2),
              // theme.colorScheme.primary,
              theme.colorScheme.primary,
            ],
          ),
        ),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.only(top: size.height * 0.16),
                child: Column(
                  children: [
                    SizedBox(
                      width: size.width * 0.3,
                      height: size.width * 0.3,
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
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                decoration: BoxDecoration(
                  color: theme.scaffoldBackgroundColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, -5),
                    ),
                  ],
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        'Selamat Datang',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _textTitle(text: 'Username', isRequired: true),
                            const SizedBox(height: 8),
                            TextField(
                              controller: usernameController,
                              textInputAction: TextInputAction.next,
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                hintText: 'Masukkan Username',
                                isDense: true,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _textTitle(text: 'Password', isRequired: true),
                            const SizedBox(height: 8),
                            TextField(
                              controller: passwordController,
                              textInputAction: TextInputAction.done,
                              keyboardType: TextInputType.visiblePassword,
                              obscureText: !isPasswordVisible,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                hintText: 'Masukkan password',
                                isDense: true,
                                suffixIcon: IconButton(
                                  onPressed: _updatePasswordVisibility,
                                  icon: Icon(
                                    isPasswordVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                    side: BorderSide(
                                        color: Theme.of(context).primaryColor),
                                  ),
                                ),
                                onPressed: isLoading
                                    ? null
                                    : () => _login(
                                          username: usernameController.text,
                                          password: passwordController.text,
                                        ),
                                child: const Text('Masuk'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _textTitle({
    required String text,
    bool isRequired = false,
  }) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: text,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (isRequired)
            const TextSpan(
              text: '*',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.red,
              ),
            ),
        ],
      ),
    );
  }
}

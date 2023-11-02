import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resep_obat_400/constants.dart';
import 'package:resep_obat_400/models/user.dart';
import 'package:resep_obat_400/providers/user.dart';
import 'package:resep_obat_400/widgets/loading.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key, required this.user});

  final UserModel user;

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  final _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordOldController = TextEditingController();
  final _passwordNewController = TextEditingController();
  bool isPasswordVisible = false;

  @override
  void initState() {
    _usernameController.text = widget.user.username;
    // _passwordController.text = widget.user.password;
    super.initState();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordOldController.dispose();
    _passwordNewController.dispose();
    super.dispose();
  }

  void _updatePasswordVisibility() {
    setState(() => isPasswordVisible = !isPasswordVisible);
  }

  void _showLoading() {
    Navigator.of(context).push(LoadingOverlay());
  }

  void _hideLoading() {
    Navigator.of(context).pop();
  }

  void _update() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordOldController.text != widget.user.password) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password lama tidak sesuai')),
      );
      return;
    }

    if (_passwordOldController.text == _passwordNewController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password baru tidak boleh sama')),
      );
      return;
    }

    if (_passwordNewController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password minimal 6 karakter')),
      );
      return;
    }

    final userProvider = context.read<UserProvider>();
    final prefs = await SharedPreferences.getInstance();
    try {
      _showLoading();
      final userUpdate = UserModel(
        id: userProvider.user.id,
        name: userProvider.user.name,
        role: userProvider.user.role,
        username: _usernameController.text.toLowerCase().replaceAll(' ', ''),
        password: _passwordNewController.text,
      );
      await _firestore
          .collection(userCollection)
          .doc(userProvider.user.id)
          .update(userUpdate.toMap());
      await prefs.setString(userPrefKey, userToJson(userUpdate));
      userProvider.user = userUpdate;
      _hideLoading();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Berhasil mengubah data')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal mengubah data')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan Akun'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _textTitle(text: 'Username', isRequired: true),
              const SizedBox(height: 8),
              TextFormField(
                controller: _usernameController,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  hintText: 'Masukkan username',
                  isDense: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Username tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _textTitle(text: 'Password Lama', isRequired: true),
              const SizedBox(height: 8),
              TextFormField(
                controller: _passwordOldController,
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.visiblePassword,
                obscureText: !isPasswordVisible,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  hintText: 'Masukkan password lama',
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password lama tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              _textTitle(text: 'Password Baru', isRequired: true),
              const SizedBox(height: 8),
              TextFormField(
                controller: _passwordNewController,
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.visiblePassword,
                obscureText: !isPasswordVisible,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  hintText: 'Masukkan password baru',
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
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password baru tidak boleh kosong';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _update,
        child: const Icon(Icons.save),
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

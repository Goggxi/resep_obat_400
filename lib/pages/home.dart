import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resep_obat_400/constants.dart';
import 'package:resep_obat_400/extension.dart';
import 'package:resep_obat_400/models/recipe.dart';
import 'package:resep_obat_400/models/user.dart';
import 'package:resep_obat_400/pages/add_recipe.dart';
import 'package:resep_obat_400/pages/login.dart';
import 'package:resep_obat_400/pages/setting.dart';
import 'package:resep_obat_400/providers/user.dart';
import 'package:resep_obat_400/widgets/blank.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'chat_room.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final firestore = FirebaseFirestore.instance;

  void _dialogLogout() {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Konfirmasi'),
          content: const Text('Apakah anda yakin ingin keluar?'),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: _logout,
              child: const Text('Keluar'),
            ),
          ],
        );
      },
    );
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove(userPrefKey);
    if (!mounted) return;
    context.read<UserProvider>().user = UserModel.empty();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  Stream<List<RecipeModel>> getRecipes() async* {
    yield* firestore.collection(recipeCollection).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return RecipeModel.fromMap(doc.data());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (_, provider, __) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Daftar Resep'),
            actions: [
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SettingPage(user: provider.user),
                    ),
                  );
                },
                icon: const Icon(Icons.settings),
              ),
              IconButton(
                onPressed: _dialogLogout,
                icon: const Icon(Icons.logout),
              ),
            ],
          ),
          body: StreamBuilder<List<RecipeModel>>(
            stream: getRecipes(),
            builder: (_, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text(snapshot.error.toString()),
                );
              }

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (snapshot.hasData) {
                final recipe = snapshot.data!;
                recipe.sort((a, b) => b.date.compareTo(a.date));

                if (recipe.isEmpty) {
                  return const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      BlankWidget(),
                      SizedBox(height: 16, width: double.infinity),
                      Text('Belum ada resep'),
                    ],
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: recipe.length,
                  itemBuilder: (_, index) {
                    final item = recipe[index];
                    return Card(
                      child: ListTile(
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.date.toDate,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            Text(item.patientName),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Dokter : ${item.doctorName}'),
                          ],
                        ),
                        trailing: Text(
                          '${item.medicines.length} obat',
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatRoomPage(
                                recipe: item,
                                user: provider.user,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              }

              return const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  BlankWidget(),
                  SizedBox(height: 16, width: double.infinity),
                  Text('Belum ada resep'),
                ],
              );
            },
          ),
          floatingActionButton: Visibility(
            visible: provider.user.isDokter,
            child: FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddRecipePage()),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Resep'),
            ),
          ),
        );
      },
    );
  }
}

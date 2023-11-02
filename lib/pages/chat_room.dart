import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:resep_obat_400/constants.dart';
import 'package:resep_obat_400/extension.dart';
import 'package:resep_obat_400/models/chat.dart';
import 'package:resep_obat_400/models/recipe.dart';
import 'package:resep_obat_400/models/user.dart';
import 'package:resep_obat_400/widgets/loading.dart';

class ChatRoomPage extends StatefulWidget {
  const ChatRoomPage({super.key, required this.recipe, required this.user});

  final RecipeModel recipe;
  final UserModel user;

  @override
  State<ChatRoomPage> createState() => _ChatRoomPageState();
}

class _ChatRoomPageState extends State<ChatRoomPage> {
  final _firestore = FirebaseFirestore.instance;
  final _scrollController = ScrollController();
  bool _isLoading = false;

  void _dialog({
    required String title,
    required String message,
    required void Function() onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: onConfirm,
              child: const Text('Oke'),
            ),
          ],
        );
      },
    );
  }

  void _showLoading() {
    Navigator.of(context).push(LoadingOverlay());
  }

  void _hideLoading() {
    Navigator.of(context).pop();
  }

  void _addComment(ChatModel chat) async {
    try {
      setState(() => _isLoading = true);
      await _firestore
          .collection(chatCollection)
          .doc(chat.id)
          .set(chat.toMap());
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal menambahkan komentar'),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _deleteComment(String id) async {
    try {
      _showLoading();
      await _firestore.collection(chatCollection).doc(id).delete();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal menghapus komentar'),
        ),
      );
    } finally {
      _hideLoading();
    }
  }

  void _deleteReceipt() async {
    try {
      _showLoading();
      final comments = await _firestore
          .collection(chatCollection)
          .where('idRoom', isEqualTo: widget.recipe.id)
          .get();
      for (final comment in comments.docs) {
        await comment.reference.delete();
      }
      await _firestore
          .collection(recipeCollection)
          .doc(widget.recipe.id)
          .delete();
      _hideLoading();
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal menghapus resep'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Resep'),
        actions: [
          if (widget.user.isDokter)
            IconButton(
              onPressed: () => _dialog(
                title: 'Hapus Resep',
                message: 'Apakah anda yakin ingin menghapus resep? \n\n'
                    'Semua komentar yang ada pada resep ini akan ikut terhapus. dan tidak dapat dikembalikan lagi.',
                onConfirm: () {
                  Navigator.pop(context);
                  _deleteReceipt();
                },
              ),
              icon: const Icon(Icons.delete, color: Colors.red),
            ),
        ],
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              clipBehavior: Clip.antiAlias,
              child: ExpansionTile(
                initiallyExpanded: true,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.recipe.date.toDate,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    Text(widget.recipe.patientName),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Dokter : ${widget.recipe.doctorName}'),
                  ],
                ),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                collapsedShape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                expandedCrossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Visibility(
                          visible: widget.recipe.description.isNotEmpty,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 6),
                              const Divider(height: 0),
                              const SizedBox(height: 16),
                              const Text('Keterangan :'),
                              Text(widget.recipe.description),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Divider(height: 0),
                        const SizedBox(height: 16),
                        const Text('Daftar Obat :'),
                      ],
                    ),
                  ),
                  for (final medicine in widget.recipe.medicines)
                    ListTile(
                      title: Text(medicine.name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Jumlah : ${medicine.count}"),
                          Text("Dosis : ${medicine.dosage}"),
                          Text("Aturan Pakai :\n${medicine.description}"),
                        ],
                      ),
                      leading: Text(
                        (widget.recipe.medicines.indexOf(medicine) + 1)
                            .toString(),
                      ),
                      dense: true,
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            StreamBuilder<List<ChatModel>>(
              stream: _firestore
                  .collection(chatCollection)
                  .orderBy('time', descending: false)
                  .where('idRoom', isEqualTo: widget.recipe.id)
                  .snapshots()
                  .map(
                (snapshot) {
                  _scrollController.animateTo(
                    _scrollController.position.maxScrollExtent,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  );
                  return snapshot.docs.map((doc) {
                    return ChatModel.fromMap(doc.data());
                  }).toList();
                },
              ),
              builder: (_, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Terjadi kesalahan'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final data = snapshot.data!;

                if (data.isEmpty) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 16, width: double.infinity),
                      Icon(
                        Icons.chat_bubble_outline_rounded,
                        size: 64,
                        color: Colors.grey.withOpacity(0.5),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Belum ada komentar',
                        style: TextStyle(
                          color: Colors.grey.withOpacity(0.5),
                        ),
                      ),
                    ],
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: data.length,
                  itemBuilder: (_, index) {
                    final chat = data[index];
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (index == 0) ...[
                          const Text(
                            'Komentar',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        Row(
                          mainAxisAlignment: chat.role == widget.user.role
                              ? MainAxisAlignment.end
                              : MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (chat.role != widget.user.role) ...[
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: Colors.grey,
                                child: Text(chat.name[0]),
                              ),
                              const SizedBox(width: 8),
                            ],
                            Flexible(
                              child: Column(
                                crossAxisAlignment:
                                    chat.role == widget.user.role
                                        ? CrossAxisAlignment.end
                                        : CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: chat.role != widget.user.role
                                          ? Colors.grey.withOpacity(0.1)
                                          : primaryColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(17),
                                      border: Border.all(color: Colors.grey),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Flexible(
                                          child: Column(
                                            crossAxisAlignment:
                                                chat.role == widget.user.role
                                                    ? CrossAxisAlignment.end
                                                    : CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  if (chat.role ==
                                                      widget.user.role) ...[
                                                    Text(
                                                      '(${chat.role})',
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                  ],
                                                  Flexible(
                                                    child: Text(
                                                      chat.name,
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                  if (chat.role !=
                                                      widget.user.role) ...[
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      '(${chat.role})',
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                              Text(chat.message),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    chat.time.toDateTime,
                                    style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                ],
                              ),
                            ),
                            if (chat.role == widget.user.role) ...[
                              const SizedBox(width: 8),
                              Column(
                                children: [
                                  CircleAvatar(
                                    radius: 16,
                                    backgroundColor: primaryColor,
                                    child: Text(chat.name[0]),
                                  ),
                                  if (widget.user.role == chat.role)
                                    IconButton(
                                      onPressed: () => _dialog(
                                        title: 'Hapus Komentar',
                                        message:
                                            'Apakah anda yakin ingin menghapus?',
                                        onConfirm: () {
                                          Navigator.pop(context);
                                          _deleteComment(chat.id);
                                        },
                                      ),
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.redAccent,
                                        size: 22,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ],
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isLoading ? null : _showBottomSheetAddComment,
        child: _isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(),
              )
            : const Icon(Icons.add),
      ),
    );
  }

  void _showBottomSheetAddComment() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Container(
        padding: MediaQuery.of(context).viewInsets,
        child: AddCommentBottomSheet(
          onAdd: _addComment,
          user: widget.user,
          idRoom: widget.recipe.id,
        ),
      ),
    );
  }
}

class AddCommentBottomSheet extends StatefulWidget {
  final void Function(ChatModel model) onAdd;
  final UserModel user;
  final String idRoom;

  const AddCommentBottomSheet({
    super.key,
    required this.onAdd,
    required this.user,
    required this.idRoom,
  });

  @override
  State<AddCommentBottomSheet> createState() => _AddCommentBottomSheetState();
}

class _AddCommentBottomSheetState extends State<AddCommentBottomSheet> {
  final fromKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 18),
          padding: const EdgeInsets.all(16.0),
          child: const Text(
            'Tambah Komentar',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const Divider(height: 0),
        Flexible(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: fromKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _textTitle(text: 'Nama', isRequired: true),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: nameController,
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      hintText: 'Masukkan nama',
                      isDense: true,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nama tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _textTitle(text: 'Komentar', isRequired: true),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: descriptionController,
                    keyboardType: TextInputType.multiline,
                    maxLines: 5,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      hintText: 'Masukkan komentar',
                      isDense: true,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Komentar tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        if (!fromKey.currentState!.validate()) return;
                        final id =
                            'CHT-${DateTime.now().millisecondsSinceEpoch}';
                        final model = ChatModel(
                          id: id,
                          idRoom: widget.idRoom,
                          name: nameController.text,
                          message: descriptionController.text,
                          time: DateTime.now(),
                          role: widget.user.isDokter ? 'dokter' : 'farmasi',
                        );
                        widget.onAdd(model);
                        Navigator.pop(context);
                      },
                      child: const Text('Kirim'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
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

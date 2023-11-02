import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:resep_obat_400/constants.dart';
import 'package:resep_obat_400/extension.dart';
import 'package:resep_obat_400/models/recipe.dart';
import 'package:resep_obat_400/widgets/loading.dart';

class AddRecipePage extends StatefulWidget {
  const AddRecipePage({super.key});

  @override
  State<AddRecipePage> createState() => _AddRecipePageState();
}

class _AddRecipePageState extends State<AddRecipePage> {
  final _firestore = FirebaseFirestore.instance;
  final List<MedicineModel> _medicines = [];
  final _formKey = GlobalKey<FormState>();
  final _doctorNameController = TextEditingController();
  final _patientNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dateController = TextEditingController();
  DateTime _date = DateTime.now();

  void _showLoading() {
    Navigator.of(context).push(LoadingOverlay());
  }

  void _hideLoading() {
    Navigator.of(context).pop();
  }

  void _addMedicine(MedicineModel model) {
    if (model.name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nama obat tidak boleh kosong'),
        ),
      );
      return;
    }

    if (model.dosage.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dosis obat tidak boleh kosong'),
        ),
      );
      return;
    }

    if (model.description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Keterangan obat tidak boleh kosong'),
        ),
      );
      return;
    }

    setState(() {
      _medicines.add(model);
    });

    Navigator.pop(context);
  }

  void _removeMedicine(int index) {
    setState(() {
      _medicines.removeAt(index);
    });
  }

  void _getDate() {
    showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(1900),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    ).then((value) {
      if (value != null) {
        _date = value;
        _dateController.text = value.toDate;
      }
    });
  }

  void _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_medicines.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Obat tidak boleh kosong'),
        ),
      );
      return;
    }

    final id = 'RCP-${DateTime.now().millisecondsSinceEpoch}';
    final now = DateTime.now();
    final date = DateTime(
      _date.year,
      _date.month,
      _date.day,
      now.hour,
      now.minute,
      now.second,
    );

    final recipe = RecipeModel(
      id: id,
      doctorName: _doctorNameController.text,
      patientName: _patientNameController.text,
      date: date,
      medicines: _medicines,
      description: _descriptionController.text,
    );

    try {
      _showLoading();
      await _firestore.collection(recipeCollection).doc(id).set(recipe.toMap());
      _hideLoading();
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  void dispose() {
    _doctorNameController.dispose();
    _patientNameController.dispose();
    _dateController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tambah Resep'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _textTitle(text: 'Nama Dokter', isRequired: true),
              const SizedBox(height: 8),
              TextFormField(
                  controller: _doctorNameController,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    hintText: 'Masukkan nama dokter',
                    isDense: true,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama dokter tidak boleh kosong';
                    }
                    return null;
                  }),
              const SizedBox(height: 16),
              _textTitle(text: 'Nama Pasien', isRequired: true),
              const SizedBox(height: 8),
              TextFormField(
                  controller: _patientNameController,
                  textInputAction: TextInputAction.next,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    hintText: 'Masukkan nama pasien',
                    isDense: true,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Nama pasien tidak boleh kosong';
                    }
                    return null;
                  }),
              const SizedBox(height: 16),
              _textTitle(text: 'Tanggal Resep', isRequired: true),
              const SizedBox(height: 8),
              TextFormField(
                controller: _dateController,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.datetime,
                readOnly: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  hintText: 'Masukkan tanggal resep',
                  isDense: true,
                  suffixIcon: const Icon(Icons.calendar_today),
                ),
                onTap: _getDate,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Tanggal resep tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const Divider(height: 32),
              _textTitle(text: 'Obat', isRequired: true),
              Column(
                children: _medicines
                    .asMap()
                    .map(
                      (index, medicine) => MapEntry(
                        index,
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            ListTile(
                              title: Text(
                                medicine.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'aturan pakai:',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.w500,
                                        ),
                                  ),
                                  Text(
                                    medicine.description,
                                    style:
                                        Theme.of(context).textTheme.bodySmall,
                                  ),
                                ],
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                                side: const BorderSide(color: Colors.grey),
                              ),
                              trailing: IconButton(
                                iconSize: 22,
                                padding: EdgeInsets.zero,
                                visualDensity: VisualDensity.compact,
                                onPressed: () => _removeMedicine(index),
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                ),
                                style: ElevatedButton.styleFrom(
                                  shape: const CircleBorder(),
                                  backgroundColor: Colors.redAccent,
                                  minimumSize: const Size(40, 40),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .values
                    .toList(),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    _showBottomSheetAddMedicine();
                  },
                  child: const Text('Tambah Obat'),
                ),
              ),
              const Divider(height: 32),
              _textTitle(text: 'Keterangan Resep', isRequired: false),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                keyboardType: TextInputType.multiline,
                maxLines: 5,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  hintText: 'Masukkan keterangan resep',
                  isDense: true,
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _save,
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

  void _showBottomSheetAddMedicine() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Container(
        padding: MediaQuery.of(context).viewInsets,
        child: AddMedicineBottomSheet(
          onAdd: _addMedicine,
        ),
      ),
    );
  }
}

class AddMedicineBottomSheet extends StatefulWidget {
  final void Function(MedicineModel model) onAdd;

  const AddMedicineBottomSheet({
    super.key,
    required this.onAdd,
  });

  @override
  State<AddMedicineBottomSheet> createState() => _AddMedicineBottomSheetState();
}

class _AddMedicineBottomSheetState extends State<AddMedicineBottomSheet> {
  final fromKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final dosageController = TextEditingController();
  final descriptionController = TextEditingController();
  final countController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    dosageController.dispose();
    descriptionController.dispose();
    countController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 18),
          padding: const EdgeInsets.all(16.0),
          child: const Text(
            'Tambah Obat',
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
                  _textTitle(text: 'Nama Obat', isRequired: true),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: nameController,
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      hintText: 'Masukkan nama obat',
                      isDense: true,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nama obat tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _textTitle(text: 'Jumlah', isRequired: true),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: countController,
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      hintText: 'Masukkan jumlah obat',
                      isDense: true,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Jumlah obat tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _textTitle(text: 'Dosis', isRequired: true),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: dosageController,
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      hintText: 'Masukkan dosis obat',
                      isDense: true,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Dosis obat tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  _textTitle(text: 'Aturan Pakai', isRequired: true),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: descriptionController,
                    keyboardType: TextInputType.multiline,
                    maxLines: 5,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      hintText: 'Masukkan aturan pakai obat',
                      isDense: true,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Aturan pakai tidak boleh kosong';
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
                        final model = MedicineModel(
                          name: nameController.text,
                          dosage: dosageController.text,
                          count: countController.text,
                          description: descriptionController.text,
                        );
                        widget.onAdd(model);
                      },
                      child: const Text('Tambah'),
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

class RecipeModel {
  final String id;
  final String doctorName;
  final String patientName;
  final DateTime date;
  final List<MedicineModel> medicines;
  final String description;

  RecipeModel({
    required this.id,
    required this.doctorName,
    required this.patientName,
    required this.date,
    required this.medicines,
    this.description = '',
  });

  factory RecipeModel.empty() {
    return RecipeModel(
      id: '',
      doctorName: '',
      patientName: '',
      date: DateTime(0),
      medicines: [],
      description: '',
    );
  }

  factory RecipeModel.fromMap(Map<String, dynamic> map) {
    return RecipeModel(
      id: map['id'] as String,
      doctorName: map['doctorName'] as String,
      patientName: map['patientName'] as String,
      date: DateTime.parse(map['date'] as String),
      medicines: (map['medicines'] as List)
          .map((e) => MedicineModel.fromMap(e as Map<String, dynamic>))
          .toList(),
      description: map['description'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'doctorName': doctorName,
      'patientName': patientName,
      'date': date.toIso8601String(),
      'medicines': medicines.map((e) => e.toMap()).toList(),
      'description': description,
    };
  }
}

class MedicineModel {
  final String name;
  final String dosage;
  final String count;
  final String description;

  MedicineModel({
    required this.name,
    required this.dosage,
    required this.count,
    required this.description,
  });

  factory MedicineModel.empty() {
    return MedicineModel(
      name: '',
      dosage: '',
      count: '',
      description: '',
    );
  }

  factory MedicineModel.fromMap(Map<String, dynamic> map) {
    return MedicineModel(
      name: map['name'] as String,
      dosage: map['dosage'] as String,
      count: map['count'] as String,
      description: map['description'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'dosage': dosage,
      'count': count,
      'description': description,
    };
  }
}

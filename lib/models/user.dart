import 'dart:convert';

String userToJson(UserModel model) => json.encode(model.toMap());

UserModel userFromJson(String source) => UserModel.fromMap(json.decode(source));

class UserModel {
  final String id;
  final String name;
  final String role; // dokter, farmasi
  final String username;
  final String password;

  UserModel({
    required this.id,
    required this.name,
    required this.role,
    required this.username,
    required this.password,
  });

  bool get isDokter => role == 'dokter';

  bool get isFarmasi => role == 'farmasi';

  factory UserModel.empty() {
    return UserModel(
      id: '',
      name: '',
      role: '',
      username: '',
      password: '',
    );
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      name: map['name'],
      role: map['role'],
      username: map['username'],
      password: map['password'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'username': username,
      'password': password,
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? role,
    String? username,
    String? password,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      role: role ?? this.role,
      username: username ?? this.username,
      password: password ?? this.password,
    );
  }
}

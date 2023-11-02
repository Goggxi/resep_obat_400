class ChatModel {
  final String id;
  final String idRoom;
  final String name;
  final String message;
  final DateTime time;
  final String role;

  ChatModel({
    required this.id,
    required this.idRoom,
    required this.name,
    required this.message,
    required this.time,
    required this.role,
  });

  factory ChatModel.empty() {
    return ChatModel(
      id: '',
      idRoom: '',
      name: '',
      message: '',
      time: DateTime(0),
      role: '',
    );
  }

  factory ChatModel.fromMap(Map<String, dynamic> map) {
    return ChatModel(
      id: map['id'] as String,
      idRoom: map['idRoom'] as String,
      name: map['name'] as String,
      message: map['message'] as String,
      time: DateTime.parse(map['time'] as String),
      role: map['role'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'idRoom': idRoom,
      'name': name,
      'message': message,
      'time': time.toIso8601String(),
      'role': role,
    };
  }

  ChatModel copyWith({
    String? id,
    String? idRoom,
    String? name,
    String? message,
    DateTime? time,
    String? role,
  }) {
    return ChatModel(
      id: id ?? this.id,
      idRoom: idRoom ?? this.idRoom,
      name: name ?? this.name,
      message: message ?? this.message,
      time: time ?? this.time,
      role: role ?? this.role,
    );
  }
}

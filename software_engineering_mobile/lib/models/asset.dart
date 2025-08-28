import 'package:mongo_dart/mongo_dart.dart';

class Asset {
  ObjectId? id;
  ObjectId userId;
  String name;
  Map<String, dynamic> data;

  Asset({
    this.id,
    required this.userId,
    required this.name,
    required this.data,
  });

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'userId': userId,
      'name': name,
      'data': data,
    };
  }

  factory Asset.fromMap(Map<String, dynamic> map) {
    return Asset(
      id: map['_id'],
      userId: map['userId'],
      name: map['name'],
      data: Map<String, dynamic>.from(map['data']),
    );
  }
}
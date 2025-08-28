import 'package:mongo_dart/mongo_dart.dart';

class User {
  ObjectId? id;
  String? prefix;
  String firstName;
  String lastName;
  String? suffix;
  int age;
  String address;
  List<ObjectId> assetIds;

  User({
    this.id,
    this.prefix,
    required this.firstName,
    required this.lastName,
    this.suffix,
    required this.age,
    required this.address,
    this.assetIds = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'prefix': prefix,
      'firstName': firstName,
      'lastName': lastName,
      'suffix': suffix,
      'age': age,
      'address': address,
      'assetIds': assetIds,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['_id'],
      prefix: map['prefix'],
      firstName: map['firstName'],
      lastName: map['lastName'],
      suffix: map['suffix'],
      age: map['age'],
      address: map['address'],
      assetIds: List<ObjectId>.from(map['assetIds'] ?? []),
    );
  }
}